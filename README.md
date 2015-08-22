
XAS Data Interchange
====================

[![License Public Domain](https://img.shields.io/badge/license-public_domain-blue.svg)](http://choosealicense.com/licenses/unlicense/)	 



This README file explains the XAS Data Interchange (XDI) distribution.
The XDI distribution contains the specification documents and various
implementations of a formally specified system for reading and writing
files containing single-scan XAS data.


**This is a work in progress.  Version 1.0 of the XDI specification has
not yet been declared done.**


Specification Documents
-----------------------

 * The [XDI specification](specification/spec.md), version 1.0.

 * The [metadata dictionary](specification/dictionary.md), version 1.0.

 * Bruce's [presentation on XDI](https://speakerdeck.com/bruceravel/xas-data-interchange-a-file-format-for-a-single-xas-spectrum) at the XAFS16 satellite meeting on [Data acquisition, treatment, storage – quality assurance in XAFS spectroscopy](https://indico.desy.de/conferenceDisplay.py?ovw=True&confId=10169)
 



Implementations
---------------

Implementations are found in directories named according to the
programming language.  The main C library is in `lib/`, all others are
under `languages`.

At this time, we provide

 * C (written by Matt Newville and Bruce Ravel)
 * Python (written by Matt Newville)
 * Perl (written by Bruce Ravel)
 * Fortran 77 (written by Matt Newville)
 
We encourage the contribution of new language implementations,
such as:

 * Matlab
 * IDL
 * LabView
 * Fortran 95 or later
 * Java

and any other language that gets used by XAS practitioners.

The contents of a folder containing a language implementation should
follow the package distribution conventions used by that language
community.  Unit testing is strongly encouraged.  So is complete
documentation of the building, installation, and use of the language
package.

Build
-----

cd into the `lib/` directory and do:

	~> ./configure
	~> make
	~> sudo make install

This will install static and dynamic libraries to `/usr/local/lib` and
header files to `/usr/local/include`.

Obviously, you will need a C compiler.

To build the language specific interfaces, cd to the folder under
`languages/` and follow the build instructions there.


Other files
-----------

 * The `binaries/` folder contains shared object compilations of the C
   interface, `libxdifile` for various common operating systems.
 * The `data/` folder contains examples of valid XDI files
 * The `baddata/` folder contains examples of files that fail to
   validate as XDI
 * The `doc/` folder contains the LaTeX source of the poster on XDI
   presented at the XAFS15 conference
 * The `filemagic` folder contains tools for use by the Unix file
   determination system:
   
        ~> file -m magic data/co_metal_rt.xdi 
		data/co_metal_rt.xdi: XAS Data Interchange file -- XDI specification 1.0

   It also defines an icon and a registry entry for XDI files on
   Windows.  (The Windows reg entry does not currently work)
