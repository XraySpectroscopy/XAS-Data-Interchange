#define MAX_COLUMNS 64

typedef struct {
  long nmetadata;        /* number of metadata family/key/val metadata */
  long narrays;          /* number of arrays */
  long npts;             /* number of data points for all arrays */
  long narray_labels;    /* number of labeled arrays (may be < narrays) */
  double dspacing;       /* monochromator d spacing */
  char *xdi_version;     /* XDI version string */
  char *extra_version;   /* Extra version strings from first line of file */
  char *filename;        /* name of file */
  char *element;         /* atomic symbol for element */
  char *edge;            /* name of absorption edge: "K", "L1", ... */
  char *comments;        /* multi-line, user-supplied comment */
  char **array_labels;   /* labels for arrays */
  char **array_units;    /* units for arrays */
  char **meta_families;  /* family for metadata from file header */
  char **meta_keywords;  /* keyword for metadata from file header */
  char **meta_values;    /* value for metadata from file header */
  double **array;        /* 2D array of all array data */
} XDIFile;

int XDI_readfile(char *filename, XDIFile *xdifile) ;
int XDI_get_array_index(XDIFile *xdifile, long n, double *out);
int XDI_get_array_name(XDIFile *xdifile, char *name, double *out);
/*
   int XDI_get_metadata(XDIFile *xdifile, char *family, char *key, char *value);
*/

/* error codes */
#define ERR_NOTXDI  -10
#define ERR_NOARR_NAME  -21
#define ERR_NOARR_INDEX -22
#define ERR_NOELEM -31
#define ERR_NOEDGE -32

char *XDI_errorstring(int errcode);

