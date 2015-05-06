# libxdifile

This is a C implementation of the XDI specification.  While the XDI
specification is not difficult to implement correctly, we encourage
people implementing XDI readers in other languages to base their
implementation on `libxdifile`.  That way, the behavior of XDI
readers in different languages is guaranteed to be identical (or at
least very similar).

See `xdi_reader.c` for an example of a C program using `libxdifile` to
import and interpret XDI-formatted data.  See the python and perl
wrappers for examples of language specific implementations which link
directly to the `libxdifile` library.

`libxdifile` was written by Matt Newville and Bruce Ravel.

## XDIFile struct

This is the content of the XDIFile struct.  It will contain the entire
contents of the XDI file along with a few particularly important
metadata items (d-spacing, element, and edge).

| attribute       | type               | explanation                                                           |
| --------------- | ------------------ | --------------------------------------------------------------------- |
| filename        | char*              | the name of the XDI file                                              |
| nmetadata       | long               | number of metadata fields                                             |
| meta\_families  | array of char*     | array of family names found among the metadata, indexed to nmetadata  |
| meta\_keywords  | array of char*     | array of keyword names found among the metadata, indexed to nmetadata |
| meta\_values    | array of char*     | array of values found among the metadata, indexed to nmetadata        |
| narrays         | long               | number of arrays in data table                                        |
| npts            | long               | number of rows in data table                                          |
| array           | 2D array of double | the data table                                                        |
| narray\_labels  | long               | number of array labels                                                |
| array\_labels   | array of char*     | array of labels for arrays in the data table                          |
| array\_units    | array of char*     | array of units for arrays in the data table                           |
| comments        | char*              | the user supplied comments from the XDI file                          |
| xdi\_libversion | char*              | the `libxdifile` version number                                       |
| xdi\_version    | char*              | the XDI file specification version number from the file               |
| extra\_version  | char*              | versioning information for extension fields                           |
| dspacing        | double             | the Mono.d-spacing value                                              |
| element         | char*              | the Element.symbol value, the 1, 2, or 3 letter symbol of the element |
| edge            | char*              | the Element.edge value, the 1 or 2 letter symbol of the edge          |
| error\_lineno   | long               | the line number of a line returning an error                          |
| error\_line     | char*              | the line returning an error                                           |
| error\_message  | char*              | the error message                                                     |
| nouter          | long               | (\*)                                                                  |
| outer\_label    | array char*        | (\*)                                                                  |
| outer\_array    | array of double    | (\*)                                                                  |
| outer\_breakpts | array of long      | (\*)                                                                  |

(\*) Currently undocumented struct elements intended for support of
two-dimensional data.  This may be supported in a future version of
`libxdifile`.

## API

The API is intended to separate, as much as possible, the chores of
parsing the file and validating its content.

The main point of entry is the function `XDI_readfile` which creates
an `XDIFile` struct, then opens and parses a file for XDI content.
This function will signal an error and issue a useful error message in
the event that some content of the file precludes its being understood
as XDI data.  These situations include such things as

 * Missing XDI versioning information in the first line of the file
 * Non-numeric content in the data table
 * Variable number of columns in the data table
 * Headers that cannot be interpreted as XDI metadata

Certain conditions that are non-conforming with the XDI specification
but which do not preclude partial interpretation of the XDI file
result in warning messages issued by `XDI_readfile`.

Validating the content of the XDI metadata is treated in three
separate steps.  The philosophy of use of the XDI library is:

 1. Read the XDI file, stopping only in the case of an unrecoverable error, then
 2. Check that the metadata identified in the specification as **required** are present, then
 3. Check that the metadata identified in the specification as **recommended** are present, then
 4. Validate each individual metadata item against its dictionary definition

This allows an application to take a fine-grained approach to how
strictly it will follow the details of the XDI specification.  Thus, a
file can be read and used with any level of validation -- including
_no validation_ -- being performed.

The three validation functions are:

* `XDI_required_metadata`: This function tests that the pieces of
  metadata which are **required** by the specification are present in
  the file and intepretable.  These three metadata items are
  `Mono.d_spacing`, `Element.symbol`, and `Element.edge`.  If not
  present, this function returns a non-zero error code and issues an
  explanatory error message.

* `XDI_recommended_metadata`: This function tests that the pieces of
  metadata which are **recommended** by the specification are present
  in the file and intepretable.  The absence of these items does not
  make the file non-compliant with the XDI specification, but their
  absence impacts the utility and quality of the data.  If not
  present, this function returns a non-zero warning code and issues an
  explanatory error message.

* `XDI_validate_item`: This tests a specific metadata item to see if
  its value is interpretable according to its description in the XDI
  dictionary.  Not all items defined in the dictionary have validation
  tests.  If the value does not conform to its dictionary definition a
  non-zero warning code is returned and an explanatory error message
  is issued.  The purpose of this validation tool is to aid in
  automated quality assurance.  For example, data by a user for
  consideration in a curated standards database might require that all
  automated validation tests pass before the data are passed along to
  a human for further consideration.

All error messages are returned in English as the content of the
`error_message` attribute of the `XDIFile` struct.  The
`error_message` attribute always contains a description of the error
condition of the most recently performed action.  The relation between
the returned error/warning codes and the error messages are tabulated
below.



### Read an XDI file

Read an XDI file, store it's content in an XDIFile struct, and return
an integer return code.

```C
	#include "xdifile.h"

	XDIFile *xdifile;
	int ret;

	xdifile = malloc(sizeof(XDIFile));
	ret = XDI_readfile(xdifile, "mydata.xdi");
```

### Interpret the XDI_readfile error code

Interpret the `XDI_readfile` return code by printing the corresponding
error or warning message to the screen:

```C
	/* react to an error reading the file */
	if (ret < 0) {
		printf("Error reading XDI file '%s':\n     %s\t(error code = %ld)\n",
			argv[1], xdifile->error_message, ret);
		XDI_cleanup(xdifile, ret);
		free(xdifile);
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
explain the meaning of the error code in English.  Note that cleanup
and deallocation must be performed in the event of an error precluding
the reading of the file.

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

Run `xdi_reader` against `baddata/bad_30.xdi` for an example of a
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

Run `xdi_reader` against `baddata/bad_32.xdi` for an example of a
file which is missing **recommended** metadata.


### Examine and validate metadata

This `for` loop iterates through each set of metadata family, keyword,
and value found in the XDI file.  `XDI_validate_item` tests the value
to see if it meets the recommendation of the specification.
Validation tests do not exist for all items in the metadata dictionary
-- `XDI_validate_item` will return 0 for any free-format dictionary
item.

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

### Extract named arrays from the data table

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

### Extract indexed arrays from the data table

```C
	double *enarray, *muarray;
	enarray = (double *)calloc(xdifile->npts, sizeof(double));
	muarray = (double *)calloc(xdifile->npts, sizeof(double));
    ret = XDI_get_array_index(xdifile, 1, enarray);
    ret = XDI_get_array_index(xdifile, 2, muarray);
```

The return value is 0 if an array with that index is in the data
table.  That is, the index argument must be smaller than the `narrays`
attribute. The return value is -1 if the array cannot be retrieved.

### Destroy and deallocate the XDIFile struct

To deallocate the memory from the XDIFile struct, do this:

```C
	XDI_cleanup(xdifile, ret);
	free(xdifile);
```

Here, the second argument is the return code from the call to
XDI_readfile.  That is needed so that the cleanup method knows how
much stuff needs to be freed.



## Error codes

Here is a list of all error codes and their English explanation.  An
application using `libxdifile` can use these lists as the basis for
translation of a table of error messages into another language.

### XDI_readfile error codes

| code | message                                                      |
| ---: | ------------------------------------------------------------ |
|  -1  | not an XDI file, no XDI versioning information in first line |
|  -2  | `<word>` -- invalid family name in metadata                  |
|  -4  | `<word>` -- invalid keyword name in metadata                 |
|  -8  | `<word>` -- not formatted as Family.Key: Value               |
| -16  | number of columns changes in data table                      |
| -32  | non-numeric value in data table: `<word>`                    |

Here `<word>` will be the text that triggered the error.

### XDI_readfile and XDI_validate_item warning codes

|  code | message                                                      |
| ----: | ------------------------------------------------------------ |
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
| 1024  | invalid timestamp: date out of valid range                   |
| 2048  | <not used>                                                   |
| 4096  | bad value in Sample namespace                                |
| 8192  | bad value in Facility namespace                              |


### XDI_required_metadata return codes

The return code from `XDI_required_metadata` is interpreted bitwise.
That is, a return code of 7 means that all three required metadata
fields were missing or invalid.

| code | message                                |
| ---: | -------------------------------------- |
|  1   | Element.symbol missing or not valid    |
|  2   | Element.edge missing or not valid      |
|  4   | Mono.d\_spacing missing                |
|  8   | Non-numeric value for Mono.d\_spacing  |

### XDI_recommended_metadata return codes

The return code from `XDI_recommended_metadata` is interpreted
bitwise.  That is, a return code of 7 means that the first three
recommended metadata fields were missing.

| code | message                                                   |
| ---: | --------------------------------------------------------- |
|  1   | Missing recommended metadata field: Facility.name         |
|  2   | Missing recommended metadata field: Facility.xray\_source |
|  4   | Missing recommended metadata field: Beamline.name         |
|  8   | Missing recommended metadata field: Scan.start_time       |
| 16   | Missing recommended metadata field: Column.1              |

