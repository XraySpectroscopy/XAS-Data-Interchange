Questions on the XAS Data Interchange Format Draft Specification, version 1.0
=============================================================================

XDI Working Group
-----------------

  * Matthew NEWVILLE (University of Chicago Center for Advanced Radiation Sources, APS)
  * Bruce RAVEL (NIST) [bravel AT bnl DOT gov](mailto:bravel@bnl.gov)
  * V. Armando SOLÉ (ESRF)
  * Gerd WELLENREUTHER (DESY)
  * [mailing list - http://millenia.cars.aps.anl.gov/mailman/listinfo/xasformat](http://millenia.cars.aps.anl.gov/mailman/listinfo/xasformat)
  * [GitHub organization - https://github.com/XraySpectroscopy](https://github.com/XraySpectroscopy)

# Introduction

This document contains questions about the XAS Data Interchange Format
(XDI), version 1.0, a simple file format for a single X-ray Absorption
Spectroscopy (XAS) measurement.  These are questions that should be
resolved prior to the announcement if the 1.0 release.

This document is an effort of an *ad hoc* working group
reporting to the
[International X-ray Absorption Society (IXAS)](http://www.ixasportal.net/)
and the
[XAFS Commission of International Union of Crystallography (IUCr-XC)](http://www.iucr.org/resources/commissions/xafs).
The charge of this working group is to propose standards for the
storage and dissemination of XAS and related data.


# Questions

## Regarding the dictionary definition of the Detector namespace

Items in this namespace are an area for which James advocated the use
of tables in order to capture a full complement of information about
the detectors.  For example, an ion chamber might be identified by by
any or all of length, gas content, voltage, gap, gas pressure, dark
current offset, and details (shaping time, amplification, etc.) about
the signal chain behind the detector.


## Regarding the dictionary definition of the Column namespace

Is a file non-compliant if the `Column` fileds are missing?  Is it
non-compliant if the number of `Column` fields is different from the
number of columns?  Is it non-compliant if the `Column` field values
are different from the words in the column label line at the end of
the header?

## Regarding XDI files containing data as chi(k), chi(R), or Filtered[chi(k)]

The table of array labels in the dictionary has entries for chi(k) and
chi(R).  It seems the `k` and `r` columns should have units.  For `k`,
this is presumably inverse Angstroms.  For `r`, Angstroms, picometers,
or nanometers (with Angstroms preferred).

Some questions:

1. Should Angstrom be spelled with or without diacritic marks over the
   "A" and "o"?

2. And should "inverse Angstrom" be two words with a space between, or
   a single word (either concatinated or with an underscore)?

Regarding 1, I suggest recognizing `[ÅåAa]ngstr[öo]m`

Regarding 2, The explanation of values with units in the dictionary,
as written, is ambiguous as to whether the string explaning the units
is a single word or may be multiple words.  I propose "inverse
Angstrom" with the multiple spelling of Angstrom suggested above.
