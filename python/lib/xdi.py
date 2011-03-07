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
    

ALLOWED_CRYSTALS = ("Si", "Ge", "Diamond", "YB66",
                    "InSb", "Beryl", "Multilayer")
MATHEXPR = r'(-+)?(ln|exp|sin|asin)?\(?(\$\d)([/\*])*(\$\d)*\)?$'
DATETIME = r'(\d{4})-(\d{1,2})-(\d{1,2})[ T](\d{1,2}):(\d{1,2}):(\d{1,2})$'
match = {'word':       re.compile(r'[a-zA-Z0-9_]+$').match,
         'properword': re.compile(r'[a-zA-Z_][a-zA-Z0-9_-]*$').match,
         'mathexpr':   re.compile(MATHEXPR).match,
         'datetime':   re.compile(DATETIME).match
         }

def validate_datetime(sinput):
    "validate allowed datetimes"
    return match['datetime'](sinput)

def validate_mathexpr(sinput):
    "validate mathematical expression"
    return match['mathexpr'](sinput)

def validate_crystal(sinput):
    """validate allowed names of crystal reflections:
    Si 111,  Ge 220 etc are allowed:  ALLOWED CRYSTAL  3_integers
    """    
    xtal, reflection  = sinput.split(' ', 1)
    if xtal.lower() not in (a.lower() for a in  ALLOWED_CRYSTALS):
        return False
    try:
        refl = [int(i) for i in reflection.replace(' ','')]
        return len(refl)>2
    except ValueError:
        return False
    
def validate_int(sinput):
    "validate for int"
    try:
        int(sinput)
        return True
    except ValueError:
        return False
    
def validate_float(sinput):
    "validate for float"
    try:
        float(sinput)
        return True
    except ValueError:
        return False

def validate_float_or_nan(sinput):
    "validate for float, with nan, inf"
    try:
        return (sinput.lower() == 'nan' or
                sinput.lower() == 'inf' or
                float(sinput))
    except ValueError:
        return False

def validate_words(sinput):
    "validate for words"
    for s in sinput.strip().split(' '):
        if not match['word'](s):
            return False
    return True

def validate_properword(sinput):
    "validate for words"
    return  match['properword'](sinput)

def validate_chars(sinput):
    "validate for string"
    for s in sinput:
        if s not in printable:
            return False
    return True

def strip_comment(sinput):
    """remove leading '#' or ';', return stripped_string,
    returns None if string does NOT start with # or ;"""
    if sinput.startswith('#') or sinput.startswith(';'):
        return sinput[1:].strip()
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
    def __init__(self, fname=None):
        self.fname = fname
        self.attributes = {}
        self.comments = []
        self.data = []
        self.npts = 0
        self.file_version = None
        self.application_info = None
        self.lineno  = 0
        self.line    = ''
        self.labels = []
        for keyname in defined_fields:
            setattr(self, keyname.lower().replace('-','_'), None)
        if self.fname:
            self.read(self.fname)

    def error(self, msg, with_line=True):
        "wrapper for raising an XDIFile Exception"
        msg = '%s: %s' % (self.fname, msg)
        if with_line:
            msg = "%s (line %i)\n   %s" % (msg, self.lineno, self.line)
        raise XDIFileException(msg)

    def write(self, fname):
        "write out an XDI File"
        pass

    def read(self, fname=None):
        "read, validate XDI datafile"
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
                validator = validate_chars
                if fieldname in defined_fields:
                    attr = fieldname.lower().replace('-','_')
                    validator = defined_fields[fieldname]
                elif not validate_properword(fieldname):
                    self.error("invalid field name '%s'" % fieldname)                    

                if not validator(value):
                    self.error("invalid field value '%s'" % value)                    
                if fieldname in defined_fields:
                    setattr(self, attr, value)
                else:
                    self.attributes[fieldname] = value

        if HAS_NUMPY:
            self.data = numpy.array(self.data)
        self.assign_arrays()
        
    def assign_arrays(self):
        # energy:
        enx = int(validate_mathexpr(self.abscissa).groups()[2].replace('$', ''))

        i0x, i1x, ifx, irx = -1, -1, -1, -1
        trans =  validate_mathexpr(self.mu_transmission).groups()
        if trans is not None and trans[1] == 'ln' and trans[3] == '/':
            if trans[0] == '-':
                i0x = int(trans[4].replace('$', ''))
                i1x = int(trans[2].replace('$', ''))
            else:
                i0x = int(trans[2].replace('$', ''))
                i1x = int(trans[4].replace('$', ''))
        refer =  validate_mathexpr(self.mu_reference).groups()
        if refer is not None and refer[1] == 'ln' and refer[3] == '/':
            if refer[0] == '-':
                irx = int(refer[2].replace('$', ''))
            else:
                irx = int(refer[4].replace('$', ''))
        fluor =  validate_mathexpr(self.mu_fluorescence).groups()
        if fluor is not None:
            ifx = int(fluor[2].replace('$', ''))
                
        if HAS_NUMPY:
            self.energy = self.data[:,enx-1]
            if i0x > 0:
                self.i0 = self.data[:,i0x-1]
            if i1x > 0:
                self.trans = self.data[:,i1x-1]
            if ifx > 0:
                self.fluor = self.data[:,ifx-1]
            if irx > 0:
                self.refer = self.data[:,irx-1]
                
if __name__ == '__main__':
    testfile = os.path.join('..', '..', 'perl', 't', 'xdi.aps10id')
    
    f = XDIFile(testfile)
    print 'Read file ', f.fname, ' Version: ', f.file_version
    print '==Pre-Defined Fields=='
    for key in sorted(defined_fields):
        attr = key.lower().replace('-','_')
        if hasattr(f, attr):
            print '  %s: %s' % (key, getattr(f, attr))

    print '==Extra Fields'
    for key, val in f.attributes.items():
        print '  %s: %s' % (key, val)

    print '==User Comments:'
    print '\n'.join(f.comments)
    print '==Labels:'
    print f.labels
    if HAS_NUMPY:
        print '==Data: numeric array', f.data.shape

    else:
        print '==Data: lists', len(f.data)
    print f.energy, f.i0, f.refer
        

    

