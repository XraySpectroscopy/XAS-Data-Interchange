#!/usr/bin/env python
"""
Read/Write XAS Data Interchange Format for Python
"""
import re
import sys
import os
import ctypes
import ctypes.util
from math import pi, exp, log, sin, asin
import time
import warnings
from string import printable as PRINTABLE

try:
    import numpy as np
    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False

RAD2DEG  = 180.0/pi
# from NIST.GOV CODATA:
# Planck constant over 2 pi times c: 197.3269718 (0.0000044) MeV fm
PLANCK_hc = 1973.269718 * 2 * pi # hc in eV * Ang = 12398.4193

##
## Dictionary of XDI terms -- Python Version
## Most data is actually given as json strings

ENERGY_UNITS = ('eV', 'keV', 'GeV')
ANGLE_UNITS = ('deg', 'rad')
COLUMN_NAMES = ('energy', 'angle', 'k', 'chi', 'i0', 'time',
		'itrans', 'ifluor', 'irefer',
		'mutrans', 'mufluor', 'murefer',
		'normtrans', 'normfluor', 'normrefer')

XRAY_EDGES =  ("K", "L", "L1", "L2", "L3",
               "M", "M1", "M2", "M3", "M4", "M5",
               "N", "N1", "N2", "N3", "N4", "N5", "N6", "N7",
               "O", "O1", "O2", "O3", "O4", "O5", "O6", "O7")

ATOM_SYMS = ('H ', 'He', 'Li', 'Be', 'B ', 'C ', 'N ', 'O ', 'F ', 'Ne',
             'Na', 'Mg', 'Al', 'Si', 'P ', 'S ', 'Cl', 'Ar', 'K ', 'Ca',
             'Sc', 'Ti', 'V ', 'Cr', 'Mn', 'Fe', 'Co', 'Ni', 'Cu', 'Zn',
             'Ga', 'Ge', 'As', 'Se', 'Br', 'Kr', 'Rb', 'Sr', 'Y ', 'Zr',
             'Nb', 'Mo', 'Tc', 'Ru', 'Rh', 'Pd', 'Ag', 'Cd', 'In', 'Sn',
             'Sb', 'Te', 'I ', 'Xe', 'Cs', 'Ba', 'La', 'Ce', 'Pr', 'Nd',
             'Pm', 'Sm', 'Eu', 'Gd', 'Tb', 'Dy', 'Ho', 'Er', 'Tm', 'Yb',
             'Lu', 'Hf', 'Ta', 'W ', 'Re', 'Os', 'Ir', 'Pt', 'Au', 'Hg',
             'Tl', 'Pb', 'Bi', 'Po', 'At', 'Rn', 'Fr', 'Ra', 'Ac', 'Th',
             'Pa', 'U ', 'Np', 'Pu', 'Am', 'Cm', 'Bk', 'Cf', 'Es', 'Fm',
             'Md', 'No', 'Lr', 'Rf', 'Db', 'Sg', 'Bh', 'Hs', 'Mt', 'Ds',
             'Rg', 'Cn', 'Uut', 'Fl', 'Uup', 'Lv', 'Uus', 'Uuo')


class XDIFileStruct(ctypes.Structure):
    "emulate XDI File"
    _fields_ = [('nmetadata',     ctypes.c_long),
                ('narrays',       ctypes.c_long),
                ('npts',          ctypes.c_long),
                ('narray_labels', ctypes.c_long),
                ('dspacing',      ctypes.c_double),
                ('xdi_libversion', ctypes.c_char_p),
                ('xdi_version',   ctypes.c_char_p),
                ('extra_version', ctypes.c_char_p),
                ('filename',      ctypes.c_char_p),
                ('element',       ctypes.c_char_p),
                ('edge',          ctypes.c_char_p),
                ('comments',      ctypes.c_char_p),
                ('array_labels',  ctypes.c_void_p),
                ('array_units',   ctypes.c_void_p),
                ('meta_families', ctypes.c_void_p),
                ('meta_keywords', ctypes.c_void_p),
                ('meta_values',   ctypes.c_void_p),
                ('array',         ctypes.c_void_p)]


XDILIB = None
def get_xdilib():
    """make initial connection to XDI dll"""
    global XDILIB
    if XDILIB is None:
        dllpath  = ctypes.util.find_library('xdifile')
        load_dll = ctypes.cdll.LoadLibrary
        if os.name == 'nt':
            load_dll = ctypes.windll.LoadLibrary
        XDILIB = load_dll(dllpath)
    return XDILIB

######
##  Classes are broken here into a 2-level heierarchy:  Family.Member
##    Families have a name and a dictionary of Members
##    Members have a name and a pair of values:
##        type information
##        description
##   The member type information is of the form <TYPE> or <TYPE(UNITS)>
##   where TYPE is one of
##        str, int, float, datetime, atom_sym, xray_edge
##   str:       general string
##   int:       integer, unitless
##   float:     floating point number, with implied units as specified
##   datetime:  an ISO-structured datetime string
##   atom_sym:  two character symbol for element
##   xray_edge: standard symbol for absorption edge

CLASSES = {"facility": {"name":  ["<str>", "name of facility / storage ring"],
                        "energy": ["<float>", "stored beam energy, GeV"],
                        "current": ["<float>", "stored beam current, mA"],
                        "xray_source": ["<str>", "description of x-ray source"],
                        "critical_energy": ["<float>", "critical x-ray energy of source, keV"],
                        },
	   "beamline": {"name":  ["<str>", "name of beamline"],
                        "focussing": ["<str>", "describe focussing"],
                        "collimation": ["<str>", "describe x-ray beam collimation"],
                        "harmonic_rejection": ["<str>", "describe harmonic rejection scheme"],
                        },
	   "mono":     {"name":  ["<str>", "name of monochromator"],
                        "d_spacing": ["<float>", "d spacing, Angstroms"],
                        "cooling": ["<str>", "describe cooling scheme"],
                        },
	   "scan":    {"mode": ["<str>", "describe scan mode"],
                       "element": ["<atom_sym>", "atomic symbol of element being scanned"],
                       "edge": ["<xray_edge>",   "edge being scanned"],
                       "edge_energy": ["<float>",   "edge energy"],
                       "start_time": ["<datetime>", "scan start time"],
                       "stop_time": ["<datetime>", "scan stop time"],
                       "n_regiions": ["<int>", "number of scan regions for segmented step scan"],
                       },
	   "detectors": {"i0": ["<str>", "describe I0 detector"],
                         "itrans": ["<str>", "describe transmission detector"],
                         "ifluor": ["<str>", "describe fluorescence detector"],
                         "irefer": ["<str>", "describe reference sample detector and scheme"],
                         },
	   "sample":  {"name": ["<str>", "describe sample"],
                       "formula": ["<str>", "sample formula"],
                       "preparation": ["<str>", "describe sample prepation"],
                       "reference": ["<str>", "describe reference sample"]},
           }

DATETIME = r'(\d{4})-(\d{1,2})-(\d{1,2})[ T](\d{1,2}):(\d{1,2}):(\d{1,2})$'

MATCH = {'word': re.compile(r'[a-zA-Z0-9_]+$').match,
         'properword': re.compile(r'[a-zA-Z_][a-zA-Z0-9_-]*$').match,
         'datetime': re.compile(DATETIME).match
         }

def validate_datetime(txt):
    "validate allowed datetimes"
    return MATCH['datetime'](txt)

def validate_int(txt, value=False):
    "validate for int"
    try:
        int(txt)
        return True
    except ValueError:
        return False

def validate_float_or_nan(txt, value=False):
    "validate for float, with nan, inf"
    try:
        return (txt.lower() == 'nan' or
                txt.lower() == 'inf' or
                float(txt))
    except ValueError:
        return False

def validate_float(txt):
    "validate for float"
    try:
        float(txt)
        return True
    except ValueError:
        return False

def validate_xrayedge(txt):
    "validate x-ray edge"
    return txt.upper() in XRAY_EDGES

def validate_atomsym(txt):
    "validate for atomic symbols"
    return txt.title() in ATOM_SYMS

def validate_properword(txt):
    "validate for words"
    return  MATCH['properword'](txt)

def validate_printable(txt):
    "validate for printable string"
    return all([c in PRINTABLE for c in txt])

def validate_columnname(txt):
    "validate for string"
    return txt.lower() in COLUMN_NAMES


VALIDATORS = {'str': validate_printable,
              'int': validate_int,
              'float': validate_float,
              'column_name': validate_columnname,
              'xray_edge': validate_xrayedge,
              'atom_sym': validate_atomsym,
              'datetime': validate_datetime,
              'float_or_nan': validate_float_or_nan,
              'word': validate_properword,
              }

def validate(value, dtype, return_val=False):
    if dtype.startswith('<') and dtype.endswith('>'):
        dtype = dtype[1:-1]
    isvalid = VALIDATORS[dtype](value)
    if isvalid and return_val:
        if dtype == 'int':
            return int(value)
        elif dtype in ('float', 'float_or_nan'):
            return float(value)
        else:
            return value
    return isvalid


def strip_comment(txt):
    """remove leading comment character
    returns IsCommentLine, stripped comment-removed text
    """
    isComment = False
    if txt[0] in '#;*%C!$*/':
        isComment = True
        txt = txt[1:]
    return isComment, txt.strip()

class XDIFileException(Exception):
    """XDI File Exception: General Errors"""
    def __init__(self, msg, **kws):
        Exception.__init__(self)
        self.msg = msg

    def __str__(self):
        return self.msg


class XDIFile(object):
    """ XAS Data Interchange Format:

    See https://github.com/XraySpectrscopy/XAS-Data-Interchange

    for further details

    >>> xdi_file = XDFIile(filename)

    Principle data members:
      columns:  dict of column indices, with keys
                       'energy', 'i0', 'itrans', 'ifluor', 'irefer'
                       'mutrans', 'mufluor', 'murefer'
                 some of which may be None.
      column_data: dict of data for arrays -- same keys as
                 for columns.
    Principle methods:
      read():     read XDI data file, set column data and attributes
      write(filename):  write xdi_file data to an XDI file.

    """
    _invalid_msg = "invalid data for '%s':  was expecting %s, got '%s'"

    def __init__(self, filename=None):
        self.filename = filename
        self.app_info =  {'pylib': '1.0.0'}
        self.comments = []
        self.rawdata = []
        # self.column_labels = {}
        # self.column_attrs = {}
        self.file_version = None
        self._lineno  = 0
        self._text = ''
        self.labels = []
        self.attrs = {}

        if self.filename:
            self.read(self.filename)

    def _error(self, msg, with_line=True):
        "wrapper for raising an XDIFile Exception"
        msg = '%s: %s' % (self.filename, msg)
        if with_line:
            msg = "%s (line %i)\n   %s" % (msg, self._lineno+1,
                                           self._text[self._lineno])
        raise XDIFileException(msg)

    def _warn(self, msg, with_line=True):
        "wrapper for raising an XDIFile Exception"
        msg = '%s: %s' % (self.filename, msg)
        if with_line:
            msg = "%s (line %i)\n   %s" % (msg, self._lineno+1,
                                           self._text[self._lineno])
        print msg

    def write(self, filename):
        "write out an XDI File"
        print 'Writing XDI file not currently supported'

    def open(self, filename=None):
        """read validate and parse an XDI datafile into python structures
        """
        if filename is None and self.filename is not None:
            filename = self.filename
        XDILIB = get_xdilib()
        pxdi = ctypes.pointer(XDIFileStruct())
        out = XDILIB.XDI_readfile(filename, pxdi)
        if out != 0:
            print 'Error reading XDIFile %s ' % filename
            return
        return pxdi

    def read(self, filename=None):
        """read validate and parse an XDI datafile into python structures
        """
        if filename is None and self.filename is not None:
            filename = self.filename
        XDILIB = get_xdilib()
        
        pxdi = ctypes.pointer(XDIFileStruct())
        out = XDILIB.XDI_readfile(filename, pxdi)
        if out != 0:
            print 'Error reading XDIFile %s ' % filename
            return
        xdi = pxdi.contents
        for attr in dict(xdi._fields_):
            setattr(self, attr, getattr(xdi, attr))

        pchar = ctypes.c_char_p
        self.array_labels = (self.narrays*pchar).from_address(xdi.array_labels)[:]
        self.array_units = (self.narrays*pchar).from_address(xdi.array_units)[:]


        mfams = (self.nmetadata*pchar).from_address(xdi.meta_families)[:]
        mkeys = (self.nmetadata*pchar).from_address(xdi.meta_keywords)[:]
        mvals = (self.nmetadata*pchar).from_address(xdi.meta_values)[:]

        self.attrs = {}
        for fam, key, val in zip(mfams, mkeys, mvals):
            fam = fam.lower()
            key = key.lower()
            if fam not in self.attrs:
                self.attrs[fam] = {}
            self.attrs[fam][key] = val

        parrays  = (xdi.narrays*ctypes.c_void_p).from_address(xdi.array)[:]
        arrays  = [(xdi.npts*ctypes.c_double).from_address(p)[:] for p in parrays]

        if HAS_NUMPY:
            arrays = np.array(arrays)
            arrays.shape = (self.narrays, self.npts)
        self.rawdata = arrays
        # print 'Before Assign Arrays ', self.rawdata[:, :5]
        self._assign_arrays()

        # now do error checking....
#
#         text  = self._text = open(filename, 'r').readlines()
#         iscomm, line0 = strip_comment(text[0])
#         if not (iscomm and line0.startswith('XDI/')):
#             self._error('is not a valid XDI File.', with_line=False)
#
#         vers_info = line0[4:].split(' ', 1)
#         self.file_version = vers_info[0]
#         if len(vers_info) > 1:
#             other = vers_info[1]
#             self.app_info.update(dict([o.split('/') for o in other.split()]))
#
#         ncols = -1
#         state = 'HEADER'
#         self._lineno = 0
#
#         for line in text[1:]:
#             iscomm, line = strip_comment(line)
#             self._lineno += 1
#             if len(line) < 1:
#                 continue
#
#             # determine state: HEADER, COMMENT, LABELS, DATA
#             if line.startswith('//'):
#                 state = 'COMMENTS'
#                 continue
#             elif line.startswith('----'):
#                 state = 'LABELS'
#                 continue
#             elif not iscomm:
#                 state = 'DATA'
#             elif not state in ('COMMENTS', 'LABELS'):
#                 state = 'HEADER'
#
#             # act on STATE
#             if state == 'COMMENTS':
#                 if not validate(line, 'str'):
#                     self._error('invalid comment')
#                 self.comments.append(line)
#             elif state == 'LABELS':
#                 self.labels = line.split()
#                 for lab in self.labels:
#                     if not validate(lab, 'word'):
#                         self._error("invalid column label")
#                 state = 'DATA'
#             elif state == 'DATA':
#                 dat = line.split()
#                 if len(self.rawdata) == 0:
#                     ncols = len(dat)
#                 elif len(dat) != ncols:
#                     self._error("inconsistent number of data points")
#                 try:
#                     [validate(i, 'float_or_nan') for i in dat]
#                     self.rawdata.append([float(d) for d in dat])
#                 except ValueError:
#                     self._warn("non-numeric data in uncommented line")
#                     continue
#             elif state == 'HEADER':
#                 try:
#                     field, value = [i.strip() for i in line.split(':', 1)]
#                 except ValueError:
#                     self._warn("unknown header line")
#                 field = field.lower().replace('-','_')
#                 try:
#                     family, member = field.split('.', 1)
#                 except ValueError:
#                     family, member = field, '_'
#
#                 if family == 'column':
#                     words = value.split(' ', 1)
#                     if not (validate(member, 'int') and
#                             validate(words[0], 'column_name')):
#                         msg = self._invalid_msg % ('%s.%s' % (family,member),
#                                                    'column_name', words[0])
#                         self._error(msg)
#                     self.column_labels[int(member)] = words[0]
#                     if len(words) > 1:
#                         self.column_attrs[int(member)] = words[1]
#                 else:
#                     validator, desc = 'str', ''
#                     if family in CLASSES:
#                         if member in CLASSES[family]:
#                             validator, desc = CLASSES[family][member]
#                     if family not in self.attrs:
#                         self.attrs[family] = {}
#                     words = value.split(' ', 1)
#                     if not validate(words[0], validator):
#                         msg = self._invalid_msg % ('%s.%s' % (family,member),
#                                                    validator, value)
#                         self._error(msg)
#                     if validator in ('<int>', '<float>', 'int', 'float'):
#                         value = validate(words[0], validator, return_val=True)
#                     if member in self.attrs[family]:
#                         value = "%s %s" % (self.attrs[family][member],value)
#
#                     self.attrs[family][member] = value
#
#         self._assign_arrays()
#         self._text = None
#         self.comments = '\n'.join(self.comments)

    def _assign_arrays(self):
        """assign data arrays for principle data attributes:
           energy, angle, i0, itrans, ifluor, irefer,
           mutrans, mufluor, murefer, etc.
        """
        print 'assign arrays ' , self.array_labels
        print 'Facility ' , self.attrs['facility']
        xunits = 'eV'
        xname = None
        ix = -1
        if HAS_NUMPY:
            self.rawdata = np.array(self.rawdata)
            exp = np.exp
            log = np.log
            sin = np.log
            asin = np.arcsin

        for idx, name in enumerate(self.array_labels):
            if HAS_NUMPY:
                dat = self.rawdata[idx,:]
            else:
                dat = [d[idx] for d in self.rawdata]
            setattr(self, name, dat)
            if name in ('energy', 'angle'):
                ix = idx
                xname = name
                units = self.array_units[idx]
                if units is not None:
                    xunits = units

        if not HAS_NUMPY:
            self._warn('not calculating derived values -- install numpy!',
                       with_line=False)
            return

        # convert energy to angle, or vice versa
        if ix >= 0 and 'd_spacing' in self.attrs['mono']:
            dspace = float(self.attrs['mono']['d_spacing'])
            omega = PLANCK_hc/(2*dspace)
            if xname == 'energy' and not hasattr(self, 'angle'):
                energy_ev = self.energy
                if xunits.lower() == 'kev':
                    energy_ev = 1000. * energy_ev
                self.angle = RAD2DEG * asin(omega/energy_ev)
            elif xname == 'angle' and not hasattr(self, 'energy'):
                angle_rad = self.angle
                if xunits.lower() in ('deg', 'degrees'):
                    angle_rad = angle_rad / RAD2DEG
                self.energy = omega/sin(angle_rad)

        if hasattr(self, 'i0'):
            if hasattr(self, 'itrans') and not hasattr(self, 'mutrans'):
                self.mutrans = -log(self.itrans / (self.i0+1.e-12))
            elif hasattr(self, 'mutrans') and not hasattr(self, 'itrans'):
                self.itrans  =  self.i0 * exp(-self.mutrans)
            if hasattr(self, 'ifluor') and not hasattr(self, 'mufluor'):
                self.mufluor = self.ifluor/(self.i0+1.e-12)

            elif hasattr(self, 'mufluor') and not hasattr(self, 'ifluor'):
                self.ifluor =  self.i0 * self.mufluor

        if hasattr(self, 'itrans'):
            if hasattr(self, 'irefer') and not hasattr(self, 'murefer'):
                self.murefer = -log(self.irefer / (self.itrans+1.e-12))

            elif hasattr(self, 'murefer') and not hasattr(self, 'irefer'):
                self.irefer = self.itrans * exp(-self.murefer)

if __name__ == '__main__':
    x = XDIFile('cu_metal_rt.xdi')
    print x.attrs.keys()
    print 'Library Version, File Version ', x.xdi_libversion, x.xdi_version
    print 'Facility ' , x.attrs['facility']
    print 'Scan     ' , x.attrs['scan']
    print 'columns  ' , x.array_labels
    print x.comments
    print 'Energy: ', x.energy[:5]
    try:
        print x.angle[:5]
    except AttributeError:
        print 'no angle calculated!'
    print dir(x)
