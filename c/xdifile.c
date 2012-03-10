/* read XDI file in C */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "strutil.h"
#include "xdifile.h"

/*-------------------------------------------------------*/
int readxdi(char *filename, XDIFile *xdifile) {
  char *textlines[MAX_LINES];
  char *header[MAX_LINES];
  char *words[MAX_WORDS];
  char *c, *val, *key, *version_xdi, *version_extra;
  FILE *inpFile;
  mapping *dict, *map;

  long  file_length, ilen, index, i, j;
  long  ncol, nrows, nheader, nwords, ndict;
  int   is_newline, fnlen, mode;

  /* read file to text lines */
  printf( "Welcome to readxdi %s\n" , filename);
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
    if (strncmp(words[0], "XDI/", 4) != 0)  {
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
  mode = 0; /*  metadata (Family.Member: Value) mode */
  for (i = 1; i < nheader; i++) {
    if (strncmp(textlines[i], "#", 1) == 0)  {
      COPY_STRING(val, textlines[i]);
      val++;
      nwords = split_on(val, ":", words);
      if (nwords == 2) {
	COPY_STRING(xdifile->metadata[ndict].key, words[0]);
	COPY_STRING(xdifile->metadata[ndict].val, words[1]);
	ndict++;

      } else {
	printf(" BARE: |%s|\n", words[0]);
      }
    }
  }

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
  printf("reeadxdi A!\n");

  COPY_STRING(xdifile->filename, filename);
  xdifile->nrows = nrows;
  xdifile->npts = ncol;
  xdifile->nmetadata = ndict;
  printf("End of readxdi!\n");
  return 0;
}

