#define MAX_COLUMNS 64

typedef struct {
  char *key;
  char *val;
} mapping;


typedef struct {
  long nmetadata;
  long nrows;
  long npts;
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

  /*

  */

int readxdi(char *filename, XDIFile *xdifile) ;

#define N_VALID_EDGES 35
static char *ValidEdges[N_VALID_EDGES] =
  {"K", "L1", "L2", "L3", "L",
   "M", "M1", "M2", "M3", "M4", "M5",
   "N", "N1", "N2", "N3", "N4", "N5", "N6", "N7",
   "O", "O1", "O2", "O3", "O4", "O5", "O6", "O7",
   "P", "P1", "P2", "P3", "P4", "P5", "P6", "P7"};

#define N_VALID_ELEMS 112
static char *ValidElems[N_VALID_ELEMS] =
  {"H",  "He", "Li", "Be", "B",  "C",  "N",  "O",
   "F",  "Ne", "Na", "Mg", "Al", "Si", "P",  "S",
   "Cl", "Ar", "K",  "Ca", "Sc", "Ti", "V",  "Cr",
   "Mn", "Fe", "Co", "Ni", "Cu", "Zn", "Ga", "Ge",
   "As", "Se", "Br", "Kr", "Rb", "Sr", "Y",  "Zr",
   "Nb", "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd",
   "In", "Sn", "Sb", "Te", "I",  "Xe", "Cs", "Ba",
   "La", "Ce", "Pr", "Nd", "Pm", "Sm", "Eu", "Gd",
   "Tb", "Dy", "Ho", "Er", "Tm", "Yb", "Lu", "Hf",
   "Ta", "W",  "Re", "Os", "Ir", "Pt", "Au", "Hg",
   "Tl", "Pb", "Bi", "Po", "At", "Rn", "Fr", "Ra",
   "Ac", "Th", "Pa", "U",  "Np", "Pu", "Am", "Cm",
   "Bk", "Cf", "Es", "Fm", "Md", "No", "Lr", "Rf",
   "Db", "Sg", "Bh", "Hs", "Mt", "Ds", "Rg", "Cn"};
