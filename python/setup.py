#!/usr/bin/env python
from distutils.core import setup
import sys
import lib
    
setup(name = 'xdi',
      version = lib.__version__,
      author = 'Matthew Newville',
      author_email = 'newville@cars.uchicago.edu',
      url         = 'http://xas.org/XasDataLibrary',
      license = 'Public Domain',
      description = 'x-ray absorption spectra library',
      package_dir = {'xdi': 'lib'},
      packages = ['xdi'])


