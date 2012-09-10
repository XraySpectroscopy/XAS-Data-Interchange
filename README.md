
XAS Data Interchange
====================

			 

This README file explains the XAS Data Interchange (XDI) distribution.
The XDI distribution contains the specification documents and various
implementations of a formally specified system for reading and writing
files containing single-scan XAS data.


**This is a work in progress.  Version 1.0 of the XDI specification has
not yet been released.**


Specification Document
------------------------


The
[XDI specification](https://github.com/XraySpectroscopy/XAS-Data-Interchange/wiki/Xdispec)
is maintained as a GitHub wiki

The
[metadata dictionary](https://github.com/XraySpectroscopy/XAS-Data-Interchange/wiki/Dictionary-of-metadata)
is also a GitHub wiki

Please note that the LaTeX version of the specification is out-of-date
with respect to the version on the wiki.  The LaTeX will be brought
up-to-date when the final version 1.0 specification is agreed upon by
those involved.

The specification is also provided as
[a grammer file](https://github.com/bruceravel/XAS-Data-Interchange/blob/master/grammar).
In that file, the file specification is defined as an augmeted
Backus-Naur Form (BNF) grammer.  This grammer can be used by any
aBNF-aware tool to parse the contents of an XDI-compliant file.  This,
too, may be out of date until the 1.0 specification is released.


Implementations
---------------

Implementations are found in directories named according to the
programming language.  At this time, we provide

 * C (written by Matt Newville with input from Bruce Ravel)
 * Python (written by Matt Newville)
 * Perl (written by Bruce Ravel)
 * Fortran 77 (written by Matt Newville)
 
We encourage the contribution of new language implementations,
especially:

 * Matlab
 * IDL
 * LabView
 * C++
 * Fortran 95
 * Java

and any other language that gets used by XAS practitioners.

The contents of a folder containing a language implementation should
follow the package distribution conventions used by that language
community.  Unit testing is strongly encouraged.  So is complete
documentation of the building, installation, and use of the language
package.

Other files
-----------

 * The `binaries/` folder contains shared object compilations of the C
   interface, `libxdifile` for various common operating systems.
 * The `data/` folder contains examples of valid XDI files
 * The `baddata/` folder contains examples of files that fail to
   validate as XDI
 * The `doc/` folder contains the LaTeX source of the poster on XDI
   presented at the XAFS15 conference
 * The `magic` file can be appended to `/etc/magic` or otherwise used
   by the Unix file determination system:
   
        ~> file -m magic data/co_metal_rt.xdi 
		data/co_metal_rt.xdi: XAS Data Interchange file -- XDI specification 1.0

