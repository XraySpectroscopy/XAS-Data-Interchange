#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "strutil.h"
#include "xdifile.h"


void show_syntax(void) {
  /* show command line syntax */
  printf("\nSyntax: writetest infile outfile\n");
}

int main(int argc, char **argv) {
  XDIFile *xdifile;
  long ret, i;

  /* require 2 arguments! */
  if (argc < 3) {
    show_syntax();
    return 1;
  }


  /* read xdifile */
  xdifile = malloc(sizeof(XDIFile));
  ret = XDI_readfile(argv[1], xdifile);
  XDI_writefile(xdifile, argv[2]);
}
