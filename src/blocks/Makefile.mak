#-----------------------------
# generated from Makefile: DO NOT EDIT
# -----------------------------
SHELL = /bin/sh

SCIDIR=../../../..
SCIDIR1=..\..\..\..

LIBRARY=libblocks.lib 

include ../Makefile.blocks 

OBJSC=  $(BLOCKSC) blocks_new_nsp.obj blocks_nsp.obj gtkrange.obj absolute_valuei.obj switch2n.obj

include $(SCIDIR)/Makefile.incl.mak

CFLAGS = $(CC_OPTIONS) 
FFLAGS = $(FC_OPTIONS)
OBJS = $(OBJSC) $(OBJSF)

include $(SCIDIR)/config/Makeso.incl



Makefile.mak	: Makefile
	$(SCIDIR)/scripts/Mak2VCMak Makefile

Makefile.libmk	: Makefile
	$(SCIDIR)/scripts/Mak2ABSMak Makefile

distclean:: clean 
	@$(RM) -f -r .libs *.so *.la 

clean:: 
	@$(RM) *.obj *.lo

# special rules for compilation 
#-------------------------------

%.obj: %.c 
	@echo "compiling $<  Wall "
	@$(COMPILE) -c $< -o $@

%.lo: %.c 
	@echo "compiling $<  Wall "
	@$(LTCOMPILE) -c $< -o $@
