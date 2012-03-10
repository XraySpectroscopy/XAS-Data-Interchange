#define MAX_COLUMNS 64

typedef struct {
  char *key;
  char *val;
} mapping;


typedef struct {
  char *xdi_version;
  char *extra_version;
  char *filename;
  char element[2];
  char edge[2];
  double dspacing;
  mapping *metadata;
  long nmetadata;
  long nrows;
  long npts;
  char *comments;
  char *array_names;
  double **array;
} XDIFile;

int readxdi(char *filename, XDIFile *xdifile) ;
