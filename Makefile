SHELL=/bin/csh

include ../../Path.incl
include $(SCIDIR)/Makefile.incl

all	:: builder.sce 
	@echo "running builder (be patient)"
	@$(SCIDIR)/bin/nsp -nw -e "exec('builder.sce');quit" -errcatch >& /dev/null; 	
	@echo "At prompt, enter:";
	@echo "-->exec loader.sce";
	@echo "----------------------------------------------------";

all	::
	cd src ; make all

tests	:: all
	cd examples;make distclean; make tests 

clean	::
	cd src; make clean 
	cd macros ; make clean 

distclean:: clean 
	cd src; make distclean 
	cd macros ; make distclean 

PATH_INCL= $(wildcard Path.incl)

test	::
ifeq ($(PATH_INCL),Path.incl)
	@echo $(PATH_INCL) "is already present" 
else
	@echo Path.incl "copied from ../../"
	@cp ../../Path.incl .
endif





