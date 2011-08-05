SHELL=/bin/csh
MFLAGS=-s --no-print-directory

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

clean	::
	@echo "Clean src " 
	@cd src; make $(MFLAGS) clean 
	@echo "Clean macros"
	@cd macros ; make $(MFLAGS) clean

cleanm	::
	@echo "Clean macros"
	@cd macros ; make $(MFLAGS) clean

distclean:: 
	@echo "Clean src"
	@cd src; make distclean  >& /dev/null;
	@echo "Clean macros"
	@cd macros ; make distclean >& /dev/null;

PATH_INCL= $(wildcard Path.incl)

test	::
ifeq ($(PATH_INCL),Path.incl)
	@echo $(PATH_INCL) "is already present" 
else
	@echo Path.incl "copied from ../../"
	@cp ../../Path.incl .
endif





