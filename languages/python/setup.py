#!/usr/bin/env python
from setuptools import setup
from xdifile import __version__

setup(name         = 'xdifile',
      version      = __version__,
      author       = 'Matthew Newville',
      author_email = 'newville@cars.uchicago.edu',
      url          = 'http://xas.org/XasDataLibrary',
      license      = 'Public Domain',
      description  = 'x-ray absorption spectra library',
      package_dir  = {'xdifile': 'xdifile'},
      packages     = ['xdifile'])
