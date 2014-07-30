#!/bin/sh

file="spec"
if [ $1 ]; then
    file=$1
fi

## convert markdown to latex
echo "converting $1"
echo -n "markdown to latex ... "
pandoc --no-wrap -f markdown -t latex $file.md > temp1.tex

## used starred sectioning on the first page
echo -n "fixing first section, TOC, linenumbering ... "
if [ "$file" = "spec" ]; then
    sed -i 's/section{XAS Data/section*{XAS Data/' temp1.tex
    sed -i 's/subsection{XDI Working Group/\subsection*{XDI Working Group/' temp1.tex
    sed -i '/section.Intro/i \\\tableofcontents\\thispagestyle{empty}\\newpage\\linenumbers\\linenumbersep=25pt\n\n~\n' temp1.tex
elif [ "$file" = "background" ]; then
    echo -n "image size ... "
    sed -i 's/\\section{Use cases/~\n\n\\section*{Use cases/' temp1.tex
    sed -i '/section.Conve/i \\\linenumbers\\linenumbersep=25pt\n' temp1.tex
    sed -i 's/includegraphics/includegraphics[height=100px]/' temp1.tex
elif [ "$file" = "dictionary" ]; then
    sed -i 's/section{Dictionary of/section*{Dictionary of Data/' temp1.tex
    sed -i 's/subsection{XDI Working Group/\subsection*{XDI Working Group/' temp1.tex
    sed -i '/section.Overview/i \\\tableofcontents\\thispagestyle{empty}\\newpage\\linenumbers\\linenumbersep=25pt\n\n~\n' temp1.tex
else
    echo "$file not valid"
    exit
fi

##sed  's/\\hyperref[(.*)]{.*}/Sec.~\\ref{$1}/' temp1.tex
sed -i 's/\\hyperref\[\(.*\)\]{.*}/Sec.~\\ref{\1}/' temp1.tex

echo -n "xdi and xditt commands ..."
## use the \xdi macro
sed -i 's/XDI\([ \.]\)/{\\xdi}\1/g' temp1.tex
## use the xditt "font"
sed -i 's/texttt/xditt/g' temp1.tex

sed -i 's/mu(E)/$\\mu(E)$/g' temp1.tex
sed -i 's/chi(k)/$\\chi(k)$/g' temp1.tex

## clean up
inner="_inner"
mv temp1.tex $file$inner.tex
echo "done"
