/* read XDI file in C */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <math.h>

#ifndef max
#define max( a, b ) ( ((a) > (b)) ? (a) : (b) )
#endif

#include "strutil.h"
#include "xdi_tokens.h"
#include "xdifile.h"
/*-------------------------------------------------------*/

int readxdi(char *filename, XDIFile *xdifile) {
  char *textlines[MAX_LINES];
  char *header[MAX_LINES];
  char *words[MAX_WORDS], *cwords[2];
  char *column_labels[MAX_COLUMNS], *column_units[MAX_COLUMNS];
  char *c, *val, *key, *version_xdi, *version_extra;
  char comments[1024] = "";
  FILE *inpFile;
  mapping *dict, *map;

  long  file_length, ilen, index, i, j, maxcol;
  long  ncol, nrows, nheader, nwords, ndict;
  int   is_newline, fnlen, mode;

  int n_edges = sizeof(ValidEdges)/sizeof(char*);
  int n_elems = sizeof(ValidElems)/sizeof(char*);

  /* read file to text lines */
  ilen = readlines(filename, textlines);
  if (ilen < 0) {
    return 1;
  }
  nheader=0;
  /* check fist line for XDI header, get version info */
  if (strncmp(textlines[0], TOK_COMM, 1) == 0)  {
    val = textlines[0]; val++;
    val[strcspn(val, CRLF)] = '\0';
    nwords = make_words(val, cwords, 2);
    if (strncasecmp(cwords[0], TOK_VERS, strlen(TOK_VERS)) != 0)  {
      return -2;
    } else {
      val = val+5;
      COPY_STRING(xdifile->xdi_version, val)
    }
    if (nwords > 1) { /* extra version tags */
      COPY_STRING(xdifile->extra_version, cwords[1]);
    }
  }

  nheader = 1;
  for (i = 1; i < ilen ; i++) {
    if (strncmp(textlines[i], TOK_COMM, 1) == 0)  {
	nheader++;
    } else {
      break;
    }
  }
  printf(" N VALID EDGES %ld, \n",  sizeof(ValidEdges)/sizeof(char*));

  xdifile->metadata = calloc(nheader, sizeof(mapping));
  ndict = 0;
  maxcol = 0;
  mode = 0; /*  metadata (Family.Member: Value) mode */
  for (i = 1; i < nheader; i++) {
    if (strncmp(textlines[i], TOK_COMM, 1) == 0)  {
      COPY_STRING(val, textlines[i]);
      val++;
      nwords = split_on(val, TOK_DELIM, words);
      if ((mode==0) && (nwords == 2)) {
	COPY_STRING(xdifile->metadata[ndict].key, words[0]);
	COPY_STRING(xdifile->metadata[ndict].val, words[1]);
	ndict++;
	if (strncasecmp(words[0], TOK_COLUMN, strlen(TOK_COLUMN)) == 0) {
	  j = atoi(words[0]+7)-1;
	  if (j < MAX_COLUMNS) {
	    nrows = make_words(words[1], cwords, 2);
	    column_labels[j] = cwords[0];
	    if (nrows == 2) {
	      column_units[j] = cwords[1];
	    } else {
	      column_units[j] = "";
	    }
	    maxcol =  max(maxcol, j);
	  }
	} else if (strcasecmp(words[0], TOK_EDGE) == 0) {
	  for (j = 0; j < n_edges; j++) {
	    if (strcasecmp(ValidEdges[j], words[1]) == 0) {
	      COPY_STRING(xdifile->edge, words[1]);
	      break;
	    }
	  }
	} else if (strcasecmp(words[0], TOK_ELEM) == 0) {
	  for (j = 0; j < n_elems; j++) {
	    if (strcasecmp(ValidElems[j], words[1]) == 0) {
	      COPY_STRING(xdifile->element, words[1]);
	      break;
	    }
	  }
	} else if (strcasecmp(words[0], TOK_DSPACE) == 0) {
	  xdifile->dspacing = strtod(words[1], NULL);
	}
      } else if (strncasecmp(words[0], TOK_USERCOM_0, strlen(TOK_USERCOM_0)) == 0) {
	mode = 1;
      } else if (strncasecmp(words[0], TOK_USERCOM_1, strlen(TOK_USERCOM_1)) == 0) {
	mode = 2;
      } else if (mode==1) {
	if ((strlen(comments) > 0) && strlen(comments) < sizeof(comments)) {
	  strncat(comments, "\n", sizeof(comments)-strlen(comments) - 1);
	}
	if (strlen(val) + 1 > sizeof(comments) - strlen(comments)) {
	  printf("Warning.... user comment may be truncated!\n");
	}
	strncat(comments, val, sizeof(comments) - strlen(comments) - 1);
      }
    }
  }

  COPY_STRING(xdifile->comments, comments);
  COPY_STRING(xdifile->filename, filename);
  maxcol++;
  xdifile->column_labels = calloc(maxcol, sizeof(char *));
  xdifile->column_units = calloc(maxcol, sizeof(char *));
  for (j=0; j<maxcol; j++) {
    COPY_STRING(xdifile->column_labels[j], column_labels[j]);
    COPY_STRING(xdifile->column_units[j], column_units[j]);
  }

  ncol = ilen - nheader + 1;
  nrows = make_words(textlines[nheader], words, MAX_WORDS);

  xdifile->array = calloc(nrows, sizeof(double *));
  for (j = 0; j < nrows; j++) {
    xdifile->array[j] = calloc(ncol, sizeof(double));
    xdifile->array[j][0] = strtod(words[j], NULL);
  }
  for (i = 1; i < ncol; i++ ) {
    nrows = make_words(textlines[nheader+i], words, MAX_WORDS);
    for (j = 0; j < nrows; j++) {
      xdifile->array[j][i] = strtod(words[j], NULL);
    }
  }

  xdifile->npts = ncol;
  xdifile->narrays = nrows;
  xdifile->ncolumn_labels = maxcol;
  xdifile->nmetadata = ndict;

  return 0;
}

