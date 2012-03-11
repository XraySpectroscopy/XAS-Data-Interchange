#define MAX_COLUMNS 64

typedef struct {
  char *key;
  char *val;
} mapping;


typedef struct {
  long nmetadata;
  long narrays;
  long npts;
  long ncolumn_labels;
  double dspacing;
  char *xdi_version;
  char *extra_version;
  char *filename;
  char *element;
  char *edge;
  char *comments;
  mapping *metadata;
  double **array;
  char **column_labels;
  char **column_units;
} XDIFile;


int readxdi(char *filename, XDIFile *xdifile) ;

