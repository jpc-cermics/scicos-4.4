SHELL = /bin/sh

SCIDIR=../../../..
SCIDIR1=..\..\..\..

LIBRARY=libblocks.a

OBJS=$(patsubst %.c,%.o,$(wildcard *.c))

include $(SCIDIR)/Makefile.incl

CFLAGS = $(CC_OPTIONS)
FFLAGS = $(FC_OPTIONS)

include $(SCIDIR)/config/Makeso.incl

all:: Makefile.mak

Makefile.mak	: Makefile
	$(SCIDIR)/scripts/Mak2VCMak Makefile

Makefile.amk	: Makefile
	$(SCIDIR)/scripts/Mak2ABSMak Makefile

distclean:: clean
	@$(RM) -f -r .libs *.so *.la

clean::
	@$(RM) *.o *.lo

# special rules for compilation
#-------------------------------

%.o: %.c
	@echo "compiling $<  Wall "
	$(COMPILE) -c $< -o $@

%.lo: %.c
	@echo "compiling $<  Wall "
	@$(LTCOMPILE) -c $< -o $@
