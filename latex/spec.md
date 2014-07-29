The XAS Data Interchange Format Draft Specification, version 1.0
================================================================

XDI Working Group
-----------------

  * Matthew NEWVILLE (University of Chicago Center for Advanced Radiation Sources, APS)
  * Bruce RAVEL (NIST) [bravel AT bnl DOT gov](mailto:bravel@bnl.gov)
  * V. Armando SOLÉ (ESRF)
  * Gerd WELLENREUTHER (DESY)
  * [mailing list](http://millenia.cars.aps.anl.gov/mailman/listinfo/xasformat)
  * [GitHub organization](https://github.com/XraySpectroscopy)

# Introduction


This document describes the XAS Data Interchange Format (XDI),
version \xdiversion, a simple file format for a single X-ray
Absorption Spectroscopy (XAS) measurement.

This document is an effort of an \textit{ad hoc} working group
reporting to the
[International X-ray Absorption Society (IXAS)](http://www.ixasportal.net/)
and the
[XAFS Commission of International Union of Crystallography (IUCr-XC)](http://www.iucr.org/resources/commissions/xafs).
The charge of this working group is to propose standards for the
storage and dissemination of XAS and related data.

## Purpose

We are define this format to accomplish the following goals:

 * Establish a common language for transferring data between XAS
   beamlines, XAS experimenters, data analysis packages, web
   applications, and anything else that needs to process XAS data.

 * Increase the relevance and longevity of experimental data by
   reducing the amount of \textit{data archeology} future
   interpretations of that data will require. [The Farrel
   Lytle ``database''](http://ixs.csrri.iit.edu/database/data/index.html)
   is a particularly trenchant example of data archeology.

 * Enhance the user experience by promoting interoperability among
   data acquisition systems, data analysis packages, and other
   applications.

 * Provide a mechanism for extracting and preserving a single
   XAS-like data set from a related experiment (for example, a DAFS or
   inelastic scattering measurement) or from a complex data structure
   (for example, a database or a hierarchical data file used to store a
   multi-spectral data set).
   
 * Provide a representation of an XAS spectrum suitable for
   deposition with a journal.

In short, we are trying to share data across continents, decades, and
analysis toolkits.

This format is intended to encode a single XAS spectrum in a data file
with metadata.  It is not intended to encode relationships between
many XAS measurements or between an XAS measurement and other parts of
a multi-spectral experiment.

In order to fulfill these goals, XDI files provide a flexible,
consistent representation of information common to all XAS
experiments.  This format is simpler than a format based on XML, HDF,
or a database; it yields self-documenting files; and it is easy for
both humans and computers to read.  Its structure is inspired by that
of Internet electronic mail (See
[RFC822: Standard for ARPA Internet Text Messages](http://www.w3.org/Protocols/rfc822/)),
a plain-text data format which has proven to be robust, extensible,
and enduring.  It can be read as is by many existing programs for XAS
and other data analysis and by many scientifc plotting programs.

Due to these advantages, and because of our intention to develop free
software tools and libraries that support XDI, we hope that this
file format described in this specification will see wide adoption in
the XAS community.

## Scope

We do not intend this specification to dictate the file formats used
by data acquisition systems during XAS experiments, although this may
be a suitable format for that purpose.  Any attempt to do so would be
unreasonable due to the number of different data acquisition systems
currently deployed at synchrotrons around the world, the variety of
experiments performed at these installations, and the continuing
development of new experimental techniques.

*This specification addresses the representation of a single scan of
 XAS data after an experiment has been completed.*

A beamline which adopts this specification shall either use this
format as its native file format or shall provide their users with
tools that convert between their native file formats and XDI.  In
short, when that beamline sends a user home with XAS data that is
ready to be analyzed, that XAS data will be stored in this format.  We
intend to encourage this practice by developing tools for reading,
editing, writing, and validating XDI files.  Beamlines may choose
to modify their data acquisition systems to write data using this
format in situations where that would be appropriate.  We plan to
assist in this effort by developing libraries for popular programming
languages which can read, manipulate, and write XDI files.

With their experimental data stored in XDI files, users may choose
data analysis packages which are capable of reading this format.  It
is our hope that, as this specification gains wider adoption, users
will ultimately be freed from the responsibility of understanding file
formats.  With this aim in mind, we shall assist software developers
in supporting XDI files.




# The Contents of the XDI File

{\xdi} files contain two sections, a header with information about one
scan of an XAS experiment followed by the data collected during that
scan. The header section consists of versioning information, a series
of fields that contain information about the scan, an area for users
to store comments about the experiment, and a sequence of labels for
the columns of data. The data section contains these columns, with
each row corresponding to one point of the scan.

The header has been designed to contain arbitrary metadata describing
the contents of the file. This metadata is organized in a way that is
easily readable by both humans and computers. These fields, described
below, contain information about XAS experiments which is useful for
both users and applications. A complete list of defined headers along
with their specifications is found in Sec.~\ref{sec:defnamespaces}.

