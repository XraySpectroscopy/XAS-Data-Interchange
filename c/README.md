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

### read an XDI file

Read an XDI file, store it's content in an XDIFile struct, and return
an integer return code.

```C
	XDIFile *xdifile;
	int ret;

	xdifile = malloc(sizeof(XDIFile));
	ret = XDI_readfile("mydata.xdi", xdifile);
```

### interpret the XDI_readfile error code

Interpret the return code by printing teh corresponding error massage
to the screen:

```C
	/* react to a terminal error */
	if (ret < 0) {
		printf("Error reading XDI file '%s':\n     %s\t(error code = %ld)\n",
			argv[1], xdifile->error_message, ret);
		XDI_cleanup(xdifile, ret);
		return 1;
	}

	/* react to a warning */
	if (ret > 0) {
		printf("Warning reading XDI file '%s':\n     %s\t(warning code = %ld)\n\n",
			argv[1], xdifile->error_message, ret);
	}
```

The `xdifile->error_message` attribute will always contain the error
or warning message from the most recent action.  If an error code
returns as non-zero, the content of `xdifile->error_message` will
explain the meaning of the error code in English.

### test for required metadata

Test whether the **required** metadata was present in the XDI file.
If `XDI_required_metadata` returns a non-zero value, the file is
**not compliant** with the XDI specification.

```C
	j = XDI_required_metadata(xdifile);
	if (j != 0) {
		printf("\n# check for required metadata -- (requirement code %ld):\n%s\n", j, xdifile->error_message);
	}
```

Run `xdi_reader` agains `baddata/bad_30.xdi` for an example of a
file which is non-compliant because of missing **required** metadata.

### test for recommended metadata

Test whether the **recommended** metadata was present in the XDI file.
If `XDI_required_metadata` returns a non-zero value, the file is
compliant with the XDI specification, but lacks information considered
highly useful to the interchange of the data contained in the file.

```C
	j = XDI_recommended_metadata(xdifile);
	if (j != ) {
		printf("\n# check for recommended metadata -- (recommendation code %ld):\n%s\n", j, xdifile->error_message);
	}
```

Run `xdi_reader` agains `baddata/bad_32.xdi` for an example of a
file which is missing **recommended** metadata.


### Examine and validate metadata

This `for` loop iterates through each set of metadata family, keyword,
and value found in the XDI file.  `XDI_validate_item` tests the value
to see if it meets the recommendation of the specification.
Validation tests do not exist for all items in the metadata dictionary
-- `XDI_validate_item` will return 0 for 

```C
	for (i=0; i < xdifile->nmetadata; i++) {
		printf(" %s / %s => %s\n",
			xdifile->meta_families[i],
			xdifile->meta_keywords[i],
			xdifile->meta_values[i]);

	    j = XDI_validate_item(xdifile, xdifile->meta_families[i], xdifile->meta_keywords[i], xdifile->meta_values[i]);
		if (j!=0) {
			printf("-- Warning for %s.%s: %s\t(warning code = %ld)\n\t%s\n",
				xdifile->meta_families[i], xdifile->meta_keywords[i], xdifile->meta_values[i], j, xdifile->error_message);
	    }
    }
```

### Examine arrays from the data table

```C
	double *enarray, *muarray;
	enarray = (double *)calloc(xdifile->npts, sizeof(double));
	muarray = (double *)calloc(xdifile->npts, sizeof(double));
    ret = XDI_get_array_name(xdifile, "energy",  enarray);
    ret = XDI_get_array_name(xdifile, "mutrans", muarray);
```

The return value is 0 if an array by that name was found in the data
table.  The return value is -1 if the array cannot be retrieved.

The array names are held in the `Column.N` metadata fields.

## Error codes

Here is a list of all error codes and their English explanation.  An
application using `libxdifile` can use these lists as the basis for
translation of a table of error messages into another language.

### XDI_readfile error codes

| code | message |
|  -1  | |
|  -2  | |

### XDI_readfile warning codes

|  1  | |
|  2  | |

### XDI_required_metadata return codes

The return code from `XDI_required_metadata` can be interpreted
bitwise.  That is, a return code of 7 means that all three required
metadata fields were missing.

|  1  | |
|  2  | |
|  4  | |

### XDI_recommended_metadata return codes

The return code from `XDI_recommended_metadata` can be interpreted
bitwise.  That is, a return code of 7 means that the first three
recommendation metadata fields were missing.

|  1  | |
|  2  | |
|  4  | |
|  8  | |
| 16  | |
