#!/bin/sh

## convert markdown to latex
pandoc -f markdown -t latex $1.md > temp1.tex

## used starred sectioning on the first page
if [ "$1" = "spec" ]; then
    sed 's/section{XAS Data/section*{XAS Data/' temp1.tex > temp2.tex
    sed 's/subsection{XDI Working Group/\subsection*{XDI Working Group/' temp2.tex > temp3.tex
elif [ "$1" = "background" ]; then
    sed 's/\\section{Use cases/~\n\n\\section*{Use cases/' temp1.tex > temp3.tex
else
    echo "$1 not valid"
    exit
fi

## insert some latex markup for TOC, line numbering, and page styling
if [ "$1" = "spec" ]; then
    sed '/section.Intro/i \\\tableofcontents\\thispagestyle{empty}\\newpage\\linenumbers\\linenumbersep=25pt\n\n~\n' temp3.tex > temp4.tex
elif [ "$1" = "background" ]; then
    sed '/section.Conve/i \\\linenumbers\\linenumbersep=25pt\n' temp3.tex > temp4.tex
fi

## use the \xdi macro
sed 's/XDI /{\\xdi} /g' temp4.tex > temp5.tex

## use the xditt "font"
sed 's/texttt/xditt/g' temp5.tex > temp6.tex

## clean up
cp temp6.tex $1.tex
rm -f temp?.tex
