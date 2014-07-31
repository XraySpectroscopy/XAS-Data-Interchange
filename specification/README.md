XDI Specification Documents
===========================

 * [XDI Specification](spec.md): The XAS Data Interchange specification [(PDF file)](xdi_spec.pdf)

 * [Dictionary of Metadata](dictionary.md): The XDI dictionary [(PDF file)](xdi_dictionary.pdf)

 * [XDI background](background.md): Background on what XDI can be used for [(PDF file)](xdi_background.pdf)

## Generating PDF versions of these documents

The following software is used to convert the markdown source files
into nice-lookingt PDF files:

1. [Pandoc](http://johnmacfarlane.net/pandoc/): convert markdown into LaTeX.
1. [sed](http://www.gnu.org/software/sed/): apply several customizations to the LaTeX files
1. [pdflatex](https://www.tug.org/texlive/): compile the LaTeX files into PDF

The file [maketex.sh](maketex.sh) is a Bash shell script which
automates the first two steps.

The file [xdi.sty](xdi.sty) is a LeTeX style file which controls the
appearance of the PDF output

**To make the XDI Specification document:**

        ~> ./maketex.sh spec
        ~> pdflatex xdi_spec.tex
        ~> pdflatex xdi_spec.tex

Running the shell script generates the latex file.  You then run
pdflatex twice to get all the internal references correct.

This makes a PDF file called `xdi_spec.pdf`.

**To make the XDI Dictionary of Metadata document:**

        ~> ./maketex.sh dictionary
        ~> pdflatex xdi_dictionary.tex
        ~> pdflatex xdi_dictionary.tex

This makes a PDF file called `xdi_dictionary.pdf`.

**To make the XDI Background document:**

        ~> ./maketex.sh background
        ~> pdflatex xdi_background.tex
        ~> pdflatex xdi_background.tex

This makes a PDF file called `xdi_background.pdf`.

