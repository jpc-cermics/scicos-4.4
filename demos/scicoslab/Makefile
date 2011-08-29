SHELL=/bin/csh

.SUFFIXES: .cos .cosf .scos .scosf

TOP=../..

include $(TOP)/Path.incl
include $(TOP)/$(SCIDIR)/Makefile.incl

COS=$(patsubst orig/%.cosf,%.cos,$(wildcard orig/*.cosf))

all	:: $(COS) 

.scosf.scos :

# special target 

%.cos: orig/%.cos
	@echo "convert $<  Wall "
	@$(TOP)/$(SCIDIR)/bin/nsp -nw  -f save_to_cosf.sce -e "save_to_nsp('$<');quit"









