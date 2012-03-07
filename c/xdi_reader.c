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

/* Read function */
int readlines(FILE *input, char **lines); 
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
int readlines(FILE *input, char **textlines) {
  /* returns number of lines read, textlines should be pre-declared as char *text[MAX] */
  char  thisline[MAX_LINE_LENGTH]; 
  char *file_text, *c;
  long file_length, index, i, ilen;
  int  is_newline;

  fseek(input, 0L, SEEK_END); 
  file_length = ftell(input);   
  rewind(input);

  file_text = calloc(file_length + 1, sizeof(char));
  if(file_text == NULL ) {
    printf("\nnot enough memory to read file.\n");
    return -1;
  }

  fread(file_text, file_length, 1, input);
  ilen = 0;
  
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
    textlines[ilen] = calloc(index+1, sizeof(char)); 
    strcpy(textlines[ilen], thisline);
    ilen++; 
    if (ilen >= MAX_LINES) {
      printf("\nfile has too many lines.  Limit is %ld \n " , MAX_LINES);
      return -2;
    }
  }
  free(file_text);
  return ilen;

}
/*-------------------------------------------------------*/

/*-------------------------------------------------------*/
int main(int argc, char **argv) {

  int   ret;              /* Result of read function */
  int   isFilePosErr;            /* Boolean indicating file offset error */
  long  lLastFilePos;            /* Byte offset of end of previous line */
  long  lLineCount;              /* Line count accumulator */
  long  lLineLen;                /* Length of current line */
  long  lThisFilePos;            /* Byte offset of start of current line */

  char  *textlines[MAX_LINES]; 

  FILE *inpFile;  
  long  file_length, ilen, index, i;
  int is_newline;

  /* require 2 arguments! */
  if (argc < 2) {
    show_syntax();
    return 1;
  }
  
  inpFile = fopen(argv[1], "r"); 

  if (inpFile == NULL) {
    printf("Error opening %s: %s\n", argv[1], strerror(errno));
    return 1;
  }

  ilen = readlines(inpFile, textlines);
  fclose(inpFile);

  if (ilen < 0) {
    printf("Error reading %s\n", argv[1]);
    return 1;
  }
  
  printf("#== read %ld lines from %s\n#-------\n", ilen, argv[1]);
  for (i = 0; i < ilen ; i++) {
    printf(" line %ld, %s", i, textlines[i]);
  }
  
  return 0;
} 
/*-------------------------------------------------------*/

