/* read XDI file in C */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <math.h>

#ifndef max
#define max( a, b ) ( ((a) > (b)) ? (a) : (b) )
#endif
#ifndef min
#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
#endif

#include "strutil.h"
#include "xdi_tokens.h"
#include "xdifile.h"
/*-------------------------------------------------------*/
char *XDI_errorstring(int errcode) {
  if (errcode == 0) { return ""; }
  if (errcode == ERR_NOTXDI) {
    return "not an XDI file";
  } else if (errcode == ERR_NOELEM) {
    return "no element.symbol given";
  } else if (errcode == ERR_NOEDGE) {
    return "no element.edge given";
  }
  return "";
}

int XDI_readfile(char *filename, XDIFile *xdifile) {
  char *textlines[MAX_LINES];
  char *header[MAX_LINES];
  char *words[MAX_WORDS], *cwords[2];
  char *col_labels[MAX_COLUMNS], *col_units[MAX_COLUMNS];
  char *c, *line, *mkey,  *mval, *version_xdi, *version_extra;
  char tlabel[32];
  char comments[1024] = "";
  FILE *inpFile;

  long  file_length, ilen, index, i, j, maxcol;
  long  ncol, nrows, nxrows, nheader, nwords, ndict;
  int   is_newline, fnlen, mode, valid;

  int n_edges = sizeof(ValidEdges)/sizeof(char*);
  int n_elems = sizeof(ValidElems)/sizeof(char*);

  for (i=0; i < MAX_COLUMNS; i++) {
    sprintf(tlabel, "col%ld", i+1);
    COPY_STRING(col_labels[i], tlabel);
    COPY_STRING(col_units[i], "");
  }

  /* read file to text lines */
  ilen = readlines(filename, textlines);
  if (ilen < 0) {
    if (errno == 0) {
      errno = -ilen;
    }
    printf("%s\n", strerror(errno));
    return ilen;
  }
  nheader=0;
  /* check fist line for XDI header, get version info */
  if (strncmp(textlines[0], TOK_COMM, 1) == 0)  {
    line = textlines[0]; line++;
    line[strcspn(line, CRLF)] = '\0';
    nwords = make_words(line, cwords, 2);
    if (nwords < 1) { return ERR_NOTXDI; }
    if (strncasecmp(cwords[0], TOK_VERSION, strlen(TOK_VERSION)) != 0)  {
      return ERR_NOTXDI;
    } else {
      line = line+5;
      COPY_STRING(xdifile->xdi_version, line)
    }
    if (nwords > 1) { /* extra version tags */
      COPY_STRING(xdifile->extra_version, cwords[1]);
    }
  }

  nheader = 1;
  for (i = 1; i < ilen ; i++) {
    if (strncmp(textlines[i], TOK_COMM, 1) == 0)  {
      nheader = i+1; /*++;*/
    }
  }

  xdifile->dspacing = 0;
  COPY_STRING(xdifile->element, "~~");
  COPY_STRING(xdifile->edge, "~~");

  xdifile->meta_families = calloc(nheader, sizeof(char *));
  xdifile->meta_keywords = calloc(nheader, sizeof(char *));
  xdifile->meta_values   = calloc(nheader, sizeof(char *));

  ndict = -1;
  maxcol = 0;
  mode = 0; /*  metadata (Family.Member: Value) mode */
  for (i = 1; i < nheader; i++) {
    if (strncmp(textlines[i], TOK_COMM, 1) == 0)  {
      COPY_STRING(line, textlines[i]);
      line++;
      nwords = split_on(line, TOK_DELIM, words);
      if (nwords < 1) {continue;}
      COPY_STRING(mkey, words[0]);
      if ((mode==0) && (nwords == 2)) {
	COPY_STRING(mval, words[1]);
	nwords = split_on(words[0], TOK_DOT, words);
	if (nwords > 1) {
	  ndict++;
	  COPY_STRING(xdifile->meta_values[ndict],   mval);
	  COPY_STRING(xdifile->meta_families[ndict], words[0]);
	  COPY_STRING(xdifile->meta_keywords[ndict], words[1]);
	}
	/* printf(" metadata:  %d %s %s\n", ndict, mkey, mval);   */
	/* ndict,  words[0], words[1],  xdifile->meta_values[ndict]);*/
	if (strncasecmp(mkey, TOK_COLUMN, strlen(TOK_COLUMN)) == 0) {
	  j = atoi(mkey+7)-1;
	  if ((j > -1) && (j < MAX_COLUMNS)) {
	    nrows = make_words(mval, cwords, 2);
	    col_labels[j] = cwords[0];
	    if (nrows == 2) {
	      col_units[j] = cwords[1];
	    }
	    maxcol =  max(maxcol, j);
	  }
	} else if (strcasecmp(mkey, TOK_EDGE) == 0) {
	  for (j = 0; j < n_edges; j++) {
	    if (strcasecmp(ValidEdges[j], mval) == 0) {
	      COPY_STRING(xdifile->edge, mval);
	      break;
	    }
	  }
	} else if (strcasecmp(mkey, TOK_ELEM) == 0) {
	  for (j = 0; j < n_elems; j++) {
	    if (strcasecmp(ValidElems[j], mval) == 0) {
	      COPY_STRING(xdifile->element, mval);
	      break;
	    }
	  }
	} else if (strcasecmp(mkey, TOK_DSPACE) == 0) {
	  xdifile->dspacing = strtod(mval, NULL);
	}
      } else if (strncasecmp(mkey, TOK_USERCOM_0, strlen(TOK_USERCOM_0)) == 0) {
	mode = 1;
      } else if (strncasecmp(mkey, TOK_USERCOM_1, strlen(TOK_USERCOM_1)) == 0) {
	mode = 2;
      } else if (mode==1) {
	if ((strlen(comments) > 0) && strlen(comments) < sizeof(comments)) {
	  strncat(comments, "\n", sizeof(comments)-strlen(comments) - 1);
	}
	if (strlen(line) + 1 > sizeof(comments) - strlen(comments)) {
	  printf("Warning.... user comment may be truncated!\n");
	}
	strncat(comments, line, sizeof(comments) - strlen(comments) - 1);
      }
    } else {
      printf("Warning - ignoring line:   %s", textlines[i]);
    }
  }
  /* check edge, element, return error code if invalid */
  valid = 0;
  for (j = 0; j < n_edges; j++) {
    if (strcasecmp(ValidEdges[j], xdifile->edge) == 0) {
      valid = 1;
      break;
    }
  }
  if (valid == 0) { printf("Invalid EDGE ");
    return ERR_NOEDGE;}

  valid = 0;
  for (j = 0; j < n_elems; j++) {
    if (strcasecmp(ValidElems[j], xdifile->element) == 0) {
      valid = 1;
      break;
    }
  }
  if (valid == 0) { return ERR_NOELEM;}

  ncol = ilen - nheader + 1;
  nrows = make_words(textlines[nheader], words, MAX_WORDS);
  COPY_STRING(xdifile->comments, comments);
  COPY_STRING(xdifile->filename, filename);

  maxcol++;

  xdifile->array_labels = calloc(nrows, sizeof(char *));
  xdifile->array_units  = calloc(nrows, sizeof(char *));
  for (j=0; j < nrows; j++) {
    COPY_STRING(xdifile->array_labels[j], col_labels[j]);
    COPY_STRING(xdifile->array_units[j], col_units[j]);
  }
  /* printf(" XDFILE maxcol, ncol, nrows %ld, %ld, %ld\n", maxcol, ncol, nrows); */
  xdifile->array = calloc(nrows, sizeof(double *));
  for (j = 0; j < nrows; j++) {
    xdifile->array[j] = calloc(ncol, sizeof(double));
    xdifile->array[j][0] = strtod(words[j], NULL);
  }
  for (i = 1; i < ncol; i++ ) {
    nxrows = make_words(textlines[nheader+i], words, MAX_WORDS);
    nxrows = min(nrows, nxrows);
    for (j = 0; j < nxrows; j++) {
      xdifile->array[j][i] = strtod(words[j], NULL);
    }
  }
  xdifile->npts = ncol;
  xdifile->narrays = nrows;
  xdifile->narray_labels = min(nrows, maxcol);
  xdifile->nmetadata = ndict;
  return 0;
}

int XDI_get_array_index(XDIFile *xdifile, long n, double *out) {
  /* get array by index (starting at 0) from an XDIFile structure */
  long j;
  if (n < xdifile->narrays) {
    for (j=0; j < xdifile->npts ; j++) {
      out[j] = xdifile->array[n][j] ;
    }
    return 0;
  }
  return ERR_NOARR_INDEX;
}

int XDI_get_array_name(XDIFile *xdifile, char *name, double *out) {
  /* get array by name from an XDIFile structure */
  long i;
  for (i = 0; i < xdifile->narray_labels; i++) {
    if (strcasecmp(name, xdifile->array_labels[i]) == 0) {
      return XDI_get_array_index(xdifile, i, out);
    }
  }
  return ERR_NOARR_NAME;
}
