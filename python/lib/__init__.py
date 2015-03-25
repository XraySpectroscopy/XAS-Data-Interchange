"""
   Xas Data Interchange Format

   Matthew Newville <newville@cars.uchicago.edu>
   last update:  2015-Mar-24

== License:
   To the extent possible, the authors have waived all rights
   granted by copyright law and related laws for the code and
   documentation that make up the XAS Data Library.  While
   information about Authorship may be retained in some files
   for historical reasons, this work is hereby placed in the
   Public Domain.  This work is published from: United States.

== Overview:
   The xdi module provides a way to read/write files in the
   XAS Data Interchange format

"""
__version__ = '0.2.1'

from . import xdi
XDIFile = xdi.XDIFile
