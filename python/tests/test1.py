import os
import sys
sys.path.insert(0, '../')
import lib as  xdi

testfile = os.path.join('..', '..', 'perl', 't', 'xdi.aps10id')
if len(sys.argv) > 1:
    testfile = sys.argv[1]
    
f = xdi.XDIFile(testfile)

print( 'Read file ', f.fname, ' Version: ', f.file_version)
# print( '==Pre-Defined Fields==')
# for key in sorted(xdi.DEFINED_FIELDS):
#     attr = key.lower().replace('-','_')
#     if hasattr(f, attr):
#         print( '  %s: %s' % (key, getattr(f, attr)))
# 
# print( '==Extra Fields')
# for key, val in f.attributes.items():
#     print( '  %s: %s' % (key, val))

print( '==User Comments:')
print( '\n'.join(f.comments))
print( '==Labels:')
print( f.labels, f.has_numpy)

if f.has_numpy:
    print( '==Data: numeric array', f.data.shape)

else:
    print( '==Data: lists', len(f.data))

for key in sorted(f.columns):
    out = None
    if f.column_data[key] is not None:
        print key, f.columns[key], len(f.column_data[key]), f.column_data[key][:3]



f.write('out3.xdi')
