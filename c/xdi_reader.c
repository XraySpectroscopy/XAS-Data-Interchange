/* read XDI file in C */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define LF 10            /* Line Feed */
#define CR 13            /* Carriage Return */
#define EOF_WIN 26       /* End of File, Win */

#define MAX_LINE_LENGTH 8192 /* Max chars in a line */
#define MAX_LINES 16384      /* Max number of lines */
#define MAX_WORDS 128
/* Read function */
int readlines(char *filename, char **lines);
/* Output functions */
void show_syntax(void);


/*-------------------------------------------------------*/
/* show syntax */
void show_syntax(void) {
  /* show command line syntax */
  printf("\nSyntax: xdi_reader filename\n");
}
/*-------------------------------------------------------*/

/*-------------------------------------------------------*/
/* read array of text lines from an open data file  */
int readlines(char *filename, char **textlines) {
  /* returns number of lines read, textlines should be pre-declared
      as char *text[MAX] */

  FILE *inpFile;
  char  thisline[MAX_LINE_LENGTH];
  char *file_text, *c;
  long file_length, index, i, ilen;
  int  is_newline;

  inpFile = fopen(filename, "r");
  if (inpFile == NULL) {
    printf("Error opening %s: %s\n", filename, strerror(errno));
    return -2;
  }

  fseek(inpFile, 0L, SEEK_END);
  file_length = ftell(inpFile);
  rewind(inpFile);

  file_text = calloc(file_length + 1, sizeof(char));

  if(file_text == NULL ) {
    printf("\nnot enough memory to read file.\n");
    return -1;
  }

  fread(file_text, file_length, 1, inpFile);
  fclose(inpFile);

  ilen = -1;

  c = file_text;
  while (*c) {
    index = 0;
    is_newline = 0;
    while (*c) {
      if (!is_newline) {
	if (*c == CR || *c == LF) {
	  is_newline = 1;
	}
      } else if (*c != CR  && *c != LF) {
	break;
      }
      thisline[index++] = *c++;
    }
    thisline[index] = '\0';
    ++ilen;
    textlines[ilen] = calloc(index+1, sizeof(char));
    strcpy(textlines[ilen], thisline);
    if (ilen >= MAX_LINES-1) {
      printf("\nfile has too many lines.  Limit is %d \n " , MAX_LINES);
      return -2;
    }
  }
  free(file_text);
  return ilen;

}
/*-------------------------------------------------------*/
int make_words(char *input, char *out[], int maxwords) {
  char *p = input;
  int  i, nwords;
  nwords = 0;
  for (i = 0; i < maxwords; i++) {
    /* skip leading whitespace */
    while (isspace(*p)) {
      p++;
    }
    if (*p != '\0') {
      out[nwords++] = p;
    } else {
      out[nwords] = 0;
      break;
    }
    while (*p != '\0' && !isspace(*p)) {
      p++;
    }
    /* terminate arg: */
    if (*p != '\0' && i < maxwords-1){
      *p++ = '\0';
    }
  }
  return nwords;
}



/*-------------------------------------------------------*/
int main(int argc, char **argv) {

  char *textlines[MAX_LINES];
  char *header[MAX_LINES];
  char *words[MAX_WORDS];

  FILE *inpFile;
  long  file_length, ilen, index, i, j;
  long  ncol, nrows, nheader, nwords;
  int   is_newline;
  double **array;

  /* require 2 arguments! */
  if (argc < 2) {
    show_syntax();
    return 1;
  }

  /* read file to text lines */
  ilen = readlines(argv[1], textlines);
  if (ilen < 0) {
    return 1;
  }

  printf("#== read %ld lines from %s\n", ilen, argv[1]);
  nheader=0;
  for (i = 0; i < ilen ; i++) {
    if (strncmp(textlines[i], "#", 1) == 0)  {
	printf("  :: %s",  textlines[i]);
	nheader++;
    } else {
      break;
    }
  }
  ncol = ilen - nheader + 1;
  printf(" %ld header lines  / %ld data lines\n", nheader, ncol);
  printf(" Last header: %s", textlines[nheader-1]);
  printf(" First data: %s", textlines[nheader]);

  nrows = make_words(textlines[nheader], words, MAX_WORDS);
  array = (double **)calloc(nrows, sizeof(double*));
  for (i = 0; i < nrows; i++) {
    array[i] = (double*)calloc(ncol, sizeof(double));
    array[i][0] = strtod(words[i], NULL);
  }

  for (i = 1; i < ncol; i++ ) {
    nrows = make_words(textlines[nheader+i], words, MAX_WORDS);
    for (j = 0; j < nrows; j++) {
      array[j][i] = strtod(words[j], NULL);
    }
  }
  for (j = 0; j < nrows ; j++ ) {
    printf(" J=%ld :", j);
    for (i = 0; i < 5; i++) {
	 printf(" %f,", array[j][i]);
    }
    printf("... \n");
}
  return 0;
}


int build_array(int nrow, int ncol, double **array) {
  int i;
  array = (double **)calloc(nrow, sizeof(double*));
  for(i = 0; i < nrow; i++) {
    array[i] = (double*)calloc(ncol, sizeof(double));
  }
  return nrow*ncol;
}

int destroy_array(int nrows, double **array) {
  int i;
  for(i = 0; i < nrows; i++) {
    printf(" free i %d \n ", i);
    free(array[i]);
  }

  free(array);
  return 0;
}
