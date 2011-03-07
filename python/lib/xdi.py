#!/usr/bin/env python
"""
Read/Write XAS Data Interchange Format for Python

"""

import os
import re
from string import printable

try:
    import numpy
    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False
    

ALLOWED_CRYSTALS = ("Si", "Ge", "Diamond", "YB66", "InSb", "Beryl", "Multilayer")
match = {'word':       re.compile(r'[a-zA-Z0-9_]+$').match,
         'properword': re.compile(r'[a-zA-Z_][a-zA-Z0-9_-]*$').match,
         'mathexpr':   re.compile(r'(-+)?(ln|exp|sin|asin)?\(?(\$\d)([/\*])*(\$\d)*\)?$').match,
         'datetime':   re.compile(r'(\d{4})-(\d{1,2})-(\d{1,2})[ T](\d{1,2}):(\d{1,2}):(\d{1,2})$').match,
         }

def validate_datetime(input):
    "validate allowed datetimes"
    return match['datetime'](input)

def validate_mathexpr(input):
    "validate mathematical expression"
    return match['mathexpr'](input)

def validate_crystal(input):
    """validate allowed names of crystal reflections:
    Si 111,  Ge 220 etc are allowed:  ALLOWED CRYSTAL  3_integers
    """    
    xtal, reflection  = input.split(' ', 1)
    if xtal.lower() not in (a.lower() for a in  ALLOWED_CRYSTALS):
        return False
    try:
        refl = [int(i) for i in reflection.replace(' ','')]
        return len(refl)>2
    except ValueError:
        return False
    
def validate_int(input):
    "validate for int"
    try:
        int(input)
        return True
    except ValueError:
        return False
    
def validate_float(input):
    "validate for float"
    try:
        float(input)
        return True
    except ValueError:
        return False

def validate_float_or_nan(input):
    "validate for float, with nan, inf"
    try:
        return (input.lower() == 'nan' or
                input.lower() == 'inf' or
                float(input))
    except ValueError:
        return False

def validate_words(input):
    "validate for words"
    for s in input.strip().split(' '):
        if not match['word'](s):
            return False
    return True

def validate_properword(input):
    "validate for words"
    return  match['properword'](input)

def validate_chars(input):
    "validate for string"
    for s in input:
        if s not in printable:
            return False
    return True

def strip_comment(input):
    """remove leading '#' or ';', return stripped_string,
    returns None if string does NOT start with # or ;"""
    if input.startswith('#') or input.startswith(';'):
        return input[1:].strip()
    return None

class XDIFileException(Exception):
    """XDI File Exception: General Errors"""
    def __init__(self, msg, **kws):
        Exception.__init__(self)
        self.msg = msg
    def __str__(self):
        return self.msg


defined_fields = {
    "Abscissa": validate_mathexpr,
    "Beamline": validate_words,
    "Collimation": validate_words,
    "Crystal" : validate_crystal,
    "D_spacing" : validate_float,
    "Edge_energy": validate_float, 
    "End_time"   : validate_datetime,
    "Focusing"   : validate_words, 
    "Harmonic_rejection": validate_chars,
    "Mu_fluorescence" : validate_mathexpr,
    "Mu_reference"    : validate_mathexpr,
    "Mu_transmission" : validate_mathexpr,
    "Ring_current"  : validate_float,
    "Ring_energy"   : validate_float,
    "Start_time"    : validate_datetime, 
    "Source"        : validate_words, 
    "Undulator_harmonic" : validate_int}

class XDIFile(object):
    """ XAS Data Interchange Format"""
    def __init__(self, fname=None, **kws):
        self.fname = fname
        self.attributes = {}
        self.comments = []
        self.data = []
        self.labels = []
        for keyname in defined_fields:
            setattr(self, keyname.lower().replace('-','_'), None)
        if self.fname:
            self.read(self.fname)

    def error(self, msg, with_line=True):
        msg = '%s: %s' % (self.fname, msg)
        if with_line:
            msg = "%s (line %i)\n   %s" % (msg, self.lineno, self.line)
        raise XDIFileException(msg)

    def read(self, fname=None):
        if fname is None and self.fname is not None:
            fname = self.fname
        text  = open(fname, 'r').readlines()
        line0 = strip_comment(text.pop(0))
        try:
            if not line0.startswith('XDI/'):
                raise TypeError
            self.file_version, other = line0[4:].split(' ', 1)
            self.application_info = other.split('/')
        except:
            self.error('is not a valid XDI File.', with_line=False)

        self.lineno = 1
        state = 'FIELDS'
        for line in text:
            self.line = line
            self.lineno += 1
            if state != 'DATA':
                line = strip_comment(line)
            if line.startswith('//'):
                state = 'COMMENTS'
            elif line.startswith('---'):
                state = 'LABELS'
            elif state == 'COMMENTS':
                if not validate_chars(line):
                    self.error('invalid comment')
                self.comments.append(line)
            elif state == 'LABELS':
                self.labels = line.split()
                for lab in self.labels:
                    if not validate_properword(lab):
                        self.error("invalid column label")
                state = 'DATA'
            elif state == 'DATA':
                if len(self.data) == 0:
                    dat = line.split()
                    self.npts = len(dat)
                else:
                    dat = line.split()
                    if len(dat) != self.npts:
                        self.error("inconsistent number of data points")
                try:
                    [validate_float_or_nan(i) for i in dat]
                except:
                    self.error("non-numeric data")
                dat = [float(d) for d in dat]
                self.data.append(dat)
            elif state == 'FIELDS':
                fieldname, value = [i.strip() for i in line.split(':', 1)]
                if fieldname in defined_fields:
                    attr = fieldname.lower().replace('-','_')
                    validator = defined_fields[fieldname]
                    if validator(value):
                        setattr(self, attr, value)
                else:
                    if not validate_properword(fieldname):
                        self.error("invalid field name '%s'" % fieldname)
                    if not validate_chars(value):
                        self.error("invalid field value '%s'" % value)

                    self.attributes[fieldname] = value

        if HAS_NUMPY:
            self.data = numpy.array(self.data)
            
if __name__ == '__main__':
    testfile = os.path.join('..','perl','t','xdi.aps10id')
    
    f = XDIFile(testfile)
    print 'Read file ', f.fname, ' Version: ', f.file_version
    print '==Pre-Defined Fields=='
    for key in sorted(defined_fields):
        attr = key.lower().replace('-','_')
        if hasattr(f, attr):
            print '  %s: %s' % (key, getattr(f, attr))

    print '==Extra Fields'
    for key, value in f.attributes.items():
        print '  %s: %s' % (key, value)

    print '==User Comments:'
    print '\n'.join(f.comments)
    if HAS_NUMPY:
        print '==Data: numeric array', f.data.shape
    else:
        print '==Data: lists', len(f.data)
    print f.data[0:3]        
        
