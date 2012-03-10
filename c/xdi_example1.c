/* read XDI file in C */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "strutil.h"
#include "xdifile.h"

void show_syntax(void) {
  /* show command line syntax */
  printf("\nSyntax: xdi_reader filename\n");
}

/*-------------------------------------------------------*/
int main(int argc, char **argv) {
  XDIFile *xdifile;
  long  file_length, ilen, index, i, j;
  long  ncol, nrows, nheader, nwords, ndict;
  int   is_newline, fnlen, mode;

  /* require 2 arguments! */
  if (argc < 2) {
    show_syntax();
    return 1;
  }

  /* read xdifile */
  printf("->readxdi  %s\n", argv[1]);
  xdifile = (XDIFile *)calloc(1, sizeof(XDIFile));
  i = readxdi(argv[1], xdifile);
  if (i != 0) {
    printf(" error reading xdifile!\n");
  }

  printf(" READ XDIFILE!!\n VERSIONS: %s|%s|\n" , xdifile->xdi_version, xdifile->extra_version);

  printf(" Filename: %s | nmetadata %ld \n",xdifile->filename, xdifile->nmetadata);
  for (i=0; i < xdifile->nmetadata;  i++) {
    printf(" %ld ->:  %s: %s\n" , i, xdifile->metadata[i].key, xdifile->metadata[i].val );
  }
  printf(" Array Data: \n");
  for (j = 0; j < xdifile->nrows ; j++ ) {
    printf(" J=%ld :", j);
    for (i = 0; i < 5; i++) {
       printf(" %f,", xdifile->array[j][i]);
    }
    printf("... \n");
  }
  free(xdifile);
  return 0;
}
