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
#include "xdifile.h"
/*-------------------------------------------------------*/
int readxdi(char *filename, XDIFile *xdifile) {
  char *textlines[MAX_LINES];
  char *header[MAX_LINES];
  char *words[MAX_WORDS];
  char *column_labels[MAX_COLUMNS];
  char *c, *val, *key, *version_xdi, *version_extra;
  char comment[1024] = "";
  FILE *inpFile;
  mapping *dict, *map;

  long  file_length, ilen, index, i, j, maxcol;
  long  ncol, nrows, nheader, nwords, ndict;
  int   is_newline, fnlen, mode;

  /* read file to text lines */
  ilen = readlines(filename, textlines);
  if (ilen < 0) {
    return 1;
  }
  printf("#== read %ld lines from %s\n", ilen, filename);
  nheader=0;
  /* check fist line for XDI header, version info */
  if (strncmp(textlines[0], "#", 1) == 0)  {
    val = textlines[0]; val++;
    val[strcspn(val, CRLF)] = '\0';
    nwords = make_words(val, words, 2);
    if (strncasecmp(words[0], "xdi/", 4) != 0)  {
      printf(" Not an XDI File!\n");
      return -2;
    } else {
      val = val+5;
      COPY_STRING(version_xdi, val)
    }
    if (nwords > 1) { /* extra version tags */
      COPY_STRING(version_extra, words[1]);
    }
  }
  xdifile->xdi_version = version_xdi;
  xdifile->extra_version = version_extra;

  printf( " VERSIONS: %s|%s|\n" , xdifile->xdi_version, xdifile->extra_version);

  nheader = 1;
  for (i = 1; i < ilen ; i++) {
    if (strncmp(textlines[i], "#", 1) == 0)  {
	nheader++;
    } else {
      break;
    }
  }

  xdifile->metadata = (mapping *)calloc(nheader+1, sizeof(mapping));
  ndict = 0;
  maxcol = 0;
  mode = 0; /*  metadata (Family.Member: Value) mode */
  for (i = 1; i < nheader; i++) {
    if (strncmp(textlines[i], "#", 1) == 0)  {
      COPY_STRING(val, textlines[i]);
      val++;
      nwords = split_on(val, ":", words);
      if ((mode==0) && (nwords == 2)) {
	COPY_STRING(xdifile->metadata[ndict].key, words[0]);
	COPY_STRING(xdifile->metadata[ndict].val, words[1]);
	ndict++;
	if (strncasecmp(words[0], "column.", 7) == 0) {
	  j = atoi(words[0]+7)-1;
	  column_labels[j] = words[1];
	  maxcol =  max(maxcol, j);
	  printf("see column: %ld: %s\n" , j, column_labels[j]);
	} else if (strcasecmp(words[0], "scan.edge") == 0) {
	  printf("see edge: %s\n" , words[1]);
	} else if (strcasecmp(words[0], "scan.element") == 0) {
	  printf("see elem: %s\n" , words[1]);
	} else if (strcasecmp(words[0], "mono.d_spacing") == 0) {
	  printf("see dspace: %s\n" , words[1]);
	}
      } else if (strncasecmp(words[0], "///", 3) == 0) {
	mode = 1;
      } else if (strncasecmp(words[0], "---", 3) == 0) {
	mode = 2;
      } else if (mode==1) {
	if ((strlen(comment) > 0) && strlen(comment) < sizeof(comment)) {
	  strncat(comment, "\n", sizeof(comment)-strlen(comment) - 1);
	}
	if (strlen(val) + 1 > sizeof(comment) - strlen(comment)) {
	  printf("Warning.... user comment may be truncated!\n");
	}
	strncat(comment, val, sizeof(comment) - strlen(comment) - 1);
      }
    }
  }

  COPY_STRING(xdifile->comments, comment);

  ncol = ilen - nheader + 1;
  nrows = make_words(textlines[nheader], words, MAX_WORDS);

  xdifile->array = (double **) calloc(nrows, sizeof(double *));
  for (j = 0; j < nrows; j++) {
    xdifile->array[j] = (double *)calloc(ncol, sizeof(double));
    xdifile->array[j][0] = strtod(words[j], NULL);
  }
  for (i = 1; i < ncol; i++ ) {
    nrows = make_words(textlines[nheader+i], words, MAX_WORDS);
    for (j = 0; j < nrows; j++) {
      xdifile->array[j][i] = strtod(words[j], NULL);
    }
  }

  COPY_STRING(xdifile->filename, filename);
  xdifile->nrows = nrows;
  xdifile->npts = ncol;
  xdifile->nmetadata = ndict;

  return 0;
}

