XDI Specification Documents
===========================

 * [XDI Specification](spec.md): The XAS Data Interchange specification

 * [XDI background](background.md): Background on what XDI can be used for

 * Dictionary of Metadata

## Generating PDF version of the specification documents

The file [maketex.sh](maketex.sh) is a Bash shell script which uses
[Pandoc](http://johnmacfarlane.net/pandoc/) and
[sed](http://www.gnu.org/software/sed/) to convert the markdown source
into latex and to apply several hand-crafted customizations to make
the resulting PDF documents look lovely.

The latex files are then compiled into PDF using
[pdflatex](https://www.tug.org/texlive/).

**To make the specification document:**

        ~> ./maketex.sh spec
        ~> pdflatex xdi_spec.tex
        ~> pdflatex xdi_spec.tex

Running the shell script generates the latex file.  You then run
pdflatex twice to get all the internal references correct.

This makes a PDF file called `xdi_spec.pdf`.

**To make the background document:**

        ~> ./maketex.sh background
        ~> pdflatex xdi_background.tex
        ~> pdflatex xdi_background.tex

This makes a PDF file called `xdi_background.pdf`.

