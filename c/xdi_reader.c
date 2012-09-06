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
  long  file_length, ilen, index, i, j, ret;
  long  ncol, nrows, nheader, nwords, ndict;
  int   is_newline, fnlen, k;
  double *tdat;


  /* require 2 arguments! */
  if (argc < 2) {
    show_syntax();
    return 1;
  }

  /* read xdifile */
  xdifile = malloc(sizeof(XDIFile));
  ret = XDI_readfile(argv[1], xdifile);
  if (ret < 0) {
    printf("Error reading XDI file '%s':\n     %s\n",
	   argv[1], XDI_errorstring(ret));
    return 1;
  }
  printf("Error status '%s':\n     %ld   %s\n",
	 argv[1], ret, XDI_errorstring(ret));

  printf("# XDI FILE Read %s VERSIONS: %s|%s|\n" ,
	 xdifile->filename,
	 xdifile->xdi_version, xdifile->extra_version);

  printf("# Elem/Edge: %s|%s|\n",xdifile->element, xdifile->edge);
  printf("# User Comments:\n%s\n",xdifile->comments);

  printf("# Metadata(%ld entries):\n", xdifile->nmetadata);
  for (i=0; i < xdifile->nmetadata; i++) {
    printf(" %s / %s => %s\n",
	   xdifile->meta_families[i],
	   xdifile->meta_keywords[i],
	   xdifile->meta_values[i]);
  }

  printf("# Arrays (index, name, first 4 elements):\n");

  tdat = (double *)calloc(xdifile->npts, sizeof(double));
  for (j = 0; j < xdifile->narrays; j++ ) {
    printf("  %ld '%s':\t", j, xdifile->array_labels[j]);
    ret = XDI_get_array_name(xdifile,
			     xdifile->array_labels[j], tdat);
    for (k=0; k< 4; k++) {
      printf(" %f", tdat[k]);
    }
    printf(" ...\n");
  }

  free(xdifile);
  return 0;
}
