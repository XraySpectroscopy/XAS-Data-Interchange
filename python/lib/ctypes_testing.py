import ctypes
import ctypes.util
import numpy
import os
import sys
import time

class XDIFile(ctypes.Structure):
    "emulate XDI File"
    _fields_ = [('nmetadata',     ctypes.c_ulong),
                ('narrays',       ctypes.c_ulong),
                ('npts',          ctypes.c_ulong),
                ('narray_labels', ctypes.c_ulong),
                ('dspacing',      ctypes.c_double),
                ('xdi_version',   ctypes.c_char_p),
                ('extra_version', ctypes.c_char_p),
                ('filename',      ctypes.c_char_p),
                ('element',       ctypes.c_char_p),
                ('edge',          ctypes.c_char_p),
                ('comments',      ctypes.c_char_p),
                ('array_labels',  ctypes.c_void_p),
                ('array_units',   ctypes.c_void_p),
                ('metadata_keys', ctypes.c_void_p),
                ('metadata_vals', ctypes.c_void_p),
                ('array',         ctypes.c_void_p)]


dllpath  = ctypes.util.find_library('xdifile')
print dllpath

load_dll = ctypes.cdll.LoadLibrary
global xdilib
if os.name == 'nt':
    load_dll = ctypes.windll.LoadLibrary

xdilib = load_dll(dllpath)

print xdilib
xdif = ctypes.pointer(XDIFile())
# print xdilib.XDI_readfile
print xdilib.XDI_readfile('cu_metal_rt.xdi', xdif)

print dir(xdif.contents)
for i in dict(xdif.contents._fields_): print i

print xdif.contents.npts
print xdif.contents.narrays
print xdif.contents.filename
print xdif.contents.xdi_version
print xdif.contents.element
print xdif.contents.edge
print xdif.contents.comments
array_labels = (xdif.contents.narrays*ctypes.c_char_p).from_address(xdif.contents.array_labels)[:]
array_units = (xdif.contents.narrays*ctypes.c_char_p).from_address(xdif.contents.array_units)[:]

nmeta = xdif.contents.nmetadata
meta_keys = (nmeta*ctypes.c_char_p).from_address(xdif.contents.metadata_keys)[:]
meta_vals = (nmeta*ctypes.c_char_p).from_address(xdif.contents.metadata_vals)[:]
# rawmeta = xdif.contents.metadata
print 'Meta ', nmeta
for i in range(nmeta):
    print '%s : %s' % ( meta_keys[i], meta_vals[i])

# metadata = ctypes.cast(rawmeta, ctypes.pointer(nmeta*Mapping))
# print 'Meta ', metadata
# x = (*metadata).from_address(xdif.contents.metadata)
# print x

ntotal = xdif.contents.narrays * xdif.contents.npts

parrays  = (xdif.contents.narrays*ctypes.c_void_p).from_address(xdif.contents.array)[:]
array  = [(xdif.contents.npts*ctypes.c_double).from_address(p)[:] for p in parrays]
print array[0][:10]
print array[1][:10]
print array[2][:10]


pxdi = ctypes.pointer(XDIFile())
print xdilib.XDI_readfile('cu_metal_rt.xdi', pxdi)
xdi = pxdi.contents

class Empty(): pass

self = Empty()

for attr in dict(xdi._fields_):
    setattr(self, attr, getattr(xdi, attr))

pchar = ctypes.c_char_p
self.array_labels = (self.narrays*pchar).from_address(xdi.array_labels)[:]
self.array_units = (self.narrays*pchar).from_address(xdi.array_units)[:]

mkeys = (self.nmetadata*pchar).from_address(xdi.metadata_keys)[:]
mvals = (self.nmetadata*pchar).from_address(xdi.metadata_vals)[:]
self.metadata = {}
for key, val in zip(mkeys, mvals):
    self.metadata[key] = val

parrays  = (xdi.narrays*ctypes.c_void_p).from_address(xdi.array)[:]
arrays  = [(xdi.npts*ctypes.c_double).from_address(p)[:] for p in parrays]

arrays = numpy.array(arrays)
arrays.shape = (self.narrays, self.npts)

print self.metadata.keys()

print array_labels
print arrays.shape
print arrays[:,:10]
