#
# Makefile for XDI Fortran code
#
# you may want to customize these two items:
#
FORT    = gfortran 
AR      = ar
RANLIB  = ranlib

FFLAGS  = -O2 -Wall
FLIBS   = -lgfortran -lgfortranbegin -lm -lgcc_s
FLIBS   = -lgfortran -lm 
FLINK   = $(FORT) $(FFLAGS) -o $@

.f.o:
	$(FORT) $(FFLAGS) -c $*.f

# INSTALLDIR= /usr/local/bin/
INSTALLDIR= .

# you shouldn't have to alter anything below this line
#---------------------------------
EXAMPLE1  = xdi_example1

all: $(EXAMPLE1)

.PHONY: clean install default

default: $(EXAMPLE1)

XDI_OBJ = xdifile.o str_util.o

libxdi.a: $(XDI_OBJ)
	@rm -f $@
	$(AR) cru libxdi.a $(XDI_OBJ)
	$(RANLIB) libxdi.a


$(EXAMPLE1).o: $(EXAMPLE1).f

$(EXAMPLE1): $(EXAMPLE1).o libxdi.a
	$(FLINK) $(EXAMPLE1).o -L. -lxdi -o $(EXAMPLE1)  $(FLIBS)

clean :
	rm -f $(OBJ) $(EXAMPLE1).o $(EXAMPLE1) libxdi.a

install: $(EXAMPLE1) 
	cp $(EXAMPLE1) $(INSTALLDIR)/$(EXAMPLE1)
