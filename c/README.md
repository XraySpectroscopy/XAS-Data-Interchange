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

### Read an XDI file

Read an XDI file, store it's content in an XDIFile struct, and return
an integer return code.

```C
	XDIFile *xdifile;
	int ret;

	xdifile = malloc(sizeof(XDIFile));
	ret = XDI_readfile("mydata.xdi", xdifile);
```

### Interpret the XDI_readfile error code

Interpret the return code by printing the corresponding error message
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

### Test for required metadata

Test whether the **required** metadata was present in the XDI file.
If `XDI_required_metadata` returns a non-zero value, the file is
**not compliant** with the XDI specification.

```C
	j = XDI_required_metadata(xdifile);
	if (j != 0 ) {
		printf("\n# check for required metadata -- (requirement code %ld):\n%s\n",
			j, xdifile->error_message);
	}
```

Run `xdi_reader` agains `baddata/bad_30.xdi` for an example of a
file which is non-compliant because of missing **required** metadata.

### Test for recommended metadata

Test whether the **recommended** metadata was present in the XDI file.
If `XDI_required_metadata` returns a non-zero value, the file is
compliant with the XDI specification, but lacks information considered
highly useful to the interchange of the data contained in the file.

```C
	j = XDI_recommended_metadata(xdifile);
	if (j != 0 ) {
		printf("\n# check for recommended metadata -- (recommendation code %ld):\n%s\n",
			j, xdifile->error_message);
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

| code | message                                                      |
| ---- | ------------------------------------------------------------ |
|  -1  | not an XDI file, no XDI versioning information in first line |
|  -2  | <word> -- invalid family name in metadata                    |
|  -4  | <word> -- invalid keyword name in metadata                   |
|  -8  | <word> -- not formatted as Family.Key: Value                 |
| -16  | number of columns changes in data table                      |
| -32  | non-numeric value in data table: <word>                      |

Here `<word>` will be the the text that triggered the error.

### XDI_readfile warning codes

 |  code | message                                                      |
 | ----- | ------------------------------------------------------------ |
 |    1  | no mono.d_spacing given with angle array                     |
 |    2  | no line of minus signs '#-----' separating header from data  |
 |    4  | contains unrecognized header lines                           |
 |    8  | element.symbol missing or not valid                          |
 |   16  | element.edge missing or not valid                            |
 |   32  | element.reference not valid                                  |
 |   64  | element.ref\_edge  not valid                                 |
 |  128  | extension field used without versioning information          |
 |  256  | Column.1 is not "energy" or "angle"                          |
 |  512  | invalid timestamp: format should be ISO 8601 (YYYY-MM-DD HH:MM:SS) |
 | 1024  | invalid timestamp: date out of valuid range                  |


### XDI_required_metadata return codes

The return code from `XDI_required_metadata` can be interpreted
bitwise.  That is, a return code of 7 means that all three required
metadata fields were missing.

 | code | message                             |
 | ---- | ----------------------------------- |
 |  1   | Element.symbol missing or not valid |
 |  2   | Element.edge missing or not valid   |
 |  4   | Mono.d\_spacing missing             |
 |  4   | Mono.d\_spacing not valid           |

### XDI_recommended_metadata return codes

The return code from `XDI_recommended_metadata` can be interpreted
bitwise.  That is, a return code of 7 means that the first three
recommendation metadata fields were missing.

 | code | message                                             |
 | ---- | --------------------------------------------------- |
 |  1   | Missing recommended metadata field: Facility.name   |
 |  2   | Missing recommended metadata field: Facility.source |
 |  4   | Missing recommended metadata field: Beamline.name   |
 |  8   | Missing recommended metadata field: Scan.start_time |
 | 16   | Missing recommended metadata field: Column.1        |

