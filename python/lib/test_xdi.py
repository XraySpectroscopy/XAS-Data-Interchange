import os
from xdi import XDIFile, DEFINED_FIELDS

testfile = os.path.join('..', '..', 'perl', 't', 'xdi.aps10id')
    
f = XDIFile(testfile)

print( 'Read file ', f.fname, ' Version: ', f.file_version)
print( '==Pre-Defined Fields==')
for key in sorted(DEFINED_FIELDS):
    attr = key.lower().replace('-','_')
    if hasattr(f, attr):
        print( '  %s: %s' % (key, getattr(f, attr)))

print( '==Extra Fields')
for key, val in f.attributes.items():
    print( '  %s: %s' % (key, val))

print( '==User Comments:')
print( '\n'.join(f.comments))
print( '==Labels:')
print( f.labels, f.has_numpy)

if f.has_numpy:
    print( '==Data: numeric array', f.data.shape)

else:
    print( '==Data: lists', len(f.data))


print( 'Energy: ', f.columns['energy'])
print( 'Monitor:', f.columns['i0'])
print( 'Trans: ', f.columns['itrans'])
print( 'Fluor: ', f.columns['ifluor'])
print( 'Refer: ',  f.columns['irefer'])

print( 'Mu Trans: ',  f.mu['trans'])
print( 'Mu Fluor: ',  f.mu['fluor'])
print( 'Mu Refer: ',  f.mu['refer'])

f.write('out.xdi')
