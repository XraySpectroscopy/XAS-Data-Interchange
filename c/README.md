# libxdifile

This is a C implementation of the XDI specification.  While the XDI
specification is not difficult to implement correctly, we encourage
people implementing XDI readers in other languages to base their
implementation on `libxdifile`.  That way, the behaviour of XDI
readers in different languages is guaranteed to be identical (or at
least very similar).

See `xdi_reader.c` for an example of a C program using `libxdifile` to
import and interpret XDI-formatted data.

## API

```C
	int ret;
	xdifile = malloc(sizeof(XDIFile));
	ret = XDI_readfile(argv[1], xdifile);
```
