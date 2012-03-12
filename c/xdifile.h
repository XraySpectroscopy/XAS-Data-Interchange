#define MAX_COLUMNS 64

typedef struct {
  char *key;
  char *val;
} mapping;

typedef struct {
  long nmetadata;       /* number of metadata key/val pairs */
  long narrays;         /* number of arrays */
  long npts;            /* number of data points for all arrays */
  long narray_labels;   /* number of labeled arrays (may be < narrays) */
  double dspacing;      /* monochromator d spacing */
  char *xdi_version;    /* XDI version string */
  char *extra_version;  /* Extra version strings from first line of file */ 
  char *filename;       /* name of file */
  char *element;        /* atomic symbol for element */
  char *edge;           /* name of absorption edge: "K", "L1", ... */
  char *comments;       /* multi-line, user-supplied comment */
  mapping *metadata;    /* key/value pairs for metadata from file header */
  double **array;       /* 2D array of all array data */
  char **array_labels;  /* labels for arrays */
  char **array_units;   /* units for arrays */
} XDIFile;


int readxdi(char *filename, XDIFile *xdifile) ;

