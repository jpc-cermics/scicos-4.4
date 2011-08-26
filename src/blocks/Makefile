SHELL = /bin/sh

SCIDIR=../../../..
SCIDIR1=..\..\..\..

LIBRARY=libblocks.a 

include ../Makefile.blocks 

OBJSC=  $(BLOCKSC) blocks_new_nsp.o blocks_nsp.o gtkrange.o absolute_valuei.o switch2n.o

include $(SCIDIR)/Makefile.incl

CFLAGS = $(CC_OPTIONS) 
FFLAGS = $(FC_OPTIONS)
OBJS = $(OBJSC) $(OBJSF)

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
	@$(COMPILE) -c $< -o $@

%.lo: %.c 
	@echo "compiling $<  Wall "
	@$(LTCOMPILE) -c $< -o $@
