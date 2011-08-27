#-----------------------------
# generated from Makefile: DO NOT EDIT
# -----------------------------
SHELL = /bin/sh

SCIDIR=../../..
SCIDIR1=..\..\..

LIBRARY=libscicos.lib

include Makefile.blocks

OBJSF=  intcos.obj coselm.obj sciblk.obj  \
	sctree.obj ftree2.obj ftree3.obj ftree4.obj skipvars.obj scierr.obj scifunc.obj \
	list2vars.obj dtosci.obj itosci.obj scitoi.obj scitod.obj vvtosci.obj \
	scitovv.obj  $(BLOCKS_CODE)

OBJSF = 

# utilities for blocks 

# full contents of control and calelm 

ALL_CONTROL= $(patsubst %.c,%.obj,$(wildcard control/*.c))
ALL_CALELM = $(patsubst %.c,%.obj,$(wildcard calelm/*.c))

# subset used by scicos 

CONTROL=riccpack.obj dexpm1.obj wexpm1.obj wpade.obj pade.obj bdiag.obj wbdiag.obj \
	balbak.obj corth.obj cortr.obj cbal.obj exch.obj split.obj shrslv.obj \
	dgesl.obj dgefa.obj dgeco.obj giv.obj wshrsl.obj wexchn.obj comqr3.obj \
	hqror2.obj ortran.obj orthes.obj balanc.obj dclmat.obj coef.obj cerr.obj \
	wgesl.obj wgeco.obj wclmat.obj wcerr.obj wgefa.obj dgelsy1.obj \
	polmc.obj ssxmc.obj dqrdc.obj hhdml.obj dqrsm.obj dqrsl.obj

CALELM=dad.obj dmcopy.obj wdiv.obj wasum.obj wdotcr.obj wdotci.obj \
	waxpy.obj wsign.obj wrscal.obj wmul.obj pythag.obj \
	gdcp2i.obj wscal.obj iwamax.obj wsqrt.obj dprxc.obj wprxc.obj \
	dmmul.obj fn.obj rat.obj

# sundials and ode solvers 

SUNDIALS=cvode.obj cvode_io.obj cvode_dense.obj nvector_serial.obj ida.obj ida_dense.obj \
	ida_io.obj ida_ic.obj sundials_nvector.obj sundials_math.obj \
	sundials_dense.obj sundials_smalldense.obj\
	kinsol.obj kinsol_dense.obj kinsol_io.obj dopri5m.obj


OBJSC=  import.obj scicos.obj intcos.obj simul.obj sciblk2.obj trees.obj ezxml.obj scicos_utils.obj \
	evaluate_expr.obj about.obj \
	blocks/blocks_new_nsp.obj blocks/blocks_nsp.obj blocks/gtkrange.obj \
	blocks/absolute_valuei.obj blocks/switch2n.obj \
	$(addprefix sundials/,$(SUNDIALS)) \
	$(addprefix blocks/,$(BLOCKSC)) \
	$(addprefix control/,$(CONTROL)) \
	$(addprefix calelm/,$(CALELM)) 

BLOCKS=$(BLOCKSF) $(BLOCKSC) $(BLOCKS_MULTIC)

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

clean:: 
	@cd blocks; make clean $(MFLAGS)
	@$(RM) */*.obj */*.lo

# special rules for compilation 

sundials/%.obj: sundials/%.c 
	@echo "compiling $<  Wall "
	@$(COMPILE) -c $< -o $@

sundials/%.lo: sundials/%.c 
	@echo "compiling $<  Wall "
	@$(LTCOMPILE) -c $< -o $@

blocks/%.obj: blocks/%.c 
	@echo "compiling $<  Wall "
	@$(COMPILE) -c $< -o $@

blocks/%.lo: blocks/%.c 
	@echo "compiling $<  Wall "
	@$(LTCOMPILE) -c $< -o $@

control/%.obj: control/%.c 
	@echo "compiling $<  Wall "
	@$(COMPILE) -c $< -o $@

control/%.lo: control/%.c 
	@echo "compiling $<  Wall "
	@$(LTCOMPILE) -c $< -o $@

calelm/%.obj: calelm/%.c 
	@echo "compiling $<  Wall "
	@$(COMPILE) -c $< -o $@

calelm/%.lo: calelm/%.c 
	@echo "compiling $<  Wall "
	@$(LTCOMPILE) -c $< -o $@

