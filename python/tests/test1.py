import os
import sys
sys.path.insert(0, '../')
import lib as  xdi

testfile = os.path.join('..', '..', 'data', 'cu_metal_10k.xdi')
if len(sys.argv) > 1:
    testfile = sys.argv[1]

f = xdi.XDIFile(testfile)

print( 'Read file ', f.filename)

#print( '==Extra Fields')
#for key in dir(f):
#    if not key.startswith('_'):
#        print( '  %s: %s' % (key, getattr(f, key)))

print( '==File:', f.filename)
print( '==Element, Edge: ', f.element, f.edge)
print( '==Extra Version:', f.extra_version)
print( '==User Comments:', f.comments)
print( '==Array Labels:', f.array_labels)
print( '==Array Npts:', f.npts)
print( '==Data: array shape, type:', f.rawdata.shape, f.rawdata.dtype)
