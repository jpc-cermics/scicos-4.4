SHELL = /bin/sh

SCIDIR=../../..
SCIDIR1=..\..\..

LIBRARY=libscicos.a

include Makefile.blocks

OBJSF=  intcos.o coselm.o sciblk.o  \
	sctree.o ftree2.o ftree3.o ftree4.o skipvars.o scierr.o scifunc.o \
	list2vars.o dtosci.o itosci.o scitoi.o scitod.o vvtosci.o \
	scitovv.o  $(BLOCKS_CODE)

OBJSF = 

# utilities for blocks 

# full contents of control and calelm 

ALL_CONTROL= $(patsubst %.c,%.o,$(wildcard control/*.c))
ALL_CALELM = $(patsubst %.c,%.o,$(wildcard calelm/*.c))

# subset used by scicos 

CONTROL=riccpack.o dexpm1.o wexpm1.o wpade.o pade.o bdiag.o wbdiag.o \
	balbak.o corth.o cortr.o cbal.o exch.o split.o shrslv.o \
	dgesl.o dgefa.o dgeco.o giv.o wshrsl.o wexchn.o comqr3.o \
	hqror2.o ortran.o orthes.o balanc.o dclmat.o coef.o cerr.o \
	wgesl.o wgeco.o wclmat.o wcerr.o wgefa.o dgelsy1.o 

CALELM=dad.o dmcopy.o wdiv.o wasum.o wdotcr.o wdotci.o \
	waxpy.o wsign.o wrscal.o wmul.o pythag.o \
	gdcp2i.o wscal.o iwamax.o wsqrt.o dprxc.o wprxc.o \
	dmmul.o fn.o rat.o

# sundials and ode solvers 

SUNDIALS=cvode.o cvode_io.o cvode_dense.o nvector_serial.o ida.o ida_dense.o \
	ida_io.o ida_ic.o sundials_nvector.o sundials_math.o \
	sundials_dense.o sundials_smalldense.o\
	kinsol.o kinsol_dense.o kinsol_io.o dopri5m.o


OBJSC=  import.o scicos.o intcos.o simul.o sciblk2.o trees.o ezxml.o scicos_utils.o \
	evaluate_expr.o about.o \
	blocks/blocks_new_nsp.o blocks/blocks_nsp.o blocks/gtkrange.o \
	blocks/absolute_valuei.o blocks/switch2n.o \
	$(addprefix sundials/,$(SUNDIALS)) \
	$(addprefix blocks/,$(BLOCKSC)) \
	$(addprefix control/,$(CONTROL)) \
	$(addprefix calelm/,$(CALELM)) 

BLOCKS=$(BLOCKSF) $(BLOCKSC) $(BLOCKS_MULTIC)

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

clean:: 
	@cd blocks; make clean $(MFLAGS)
	@$(RM) */*.o */*.lo

# special rules for compilation 

sundials/%.o: sundials/%.c 
	@echo "compiling $<  Wall "
	@$(COMPILE) -c $< -o $@

sundials/%.lo: sundials/%.c 
	@echo "compiling $<  Wall "
	@$(LTCOMPILE) -c $< -o $@

blocks/%.o: blocks/%.c 
	@echo "compiling $<  Wall "
	@$(COMPILE) -c $< -o $@

blocks/%.lo: blocks/%.c 
	@echo "compiling $<  Wall "
	@$(LTCOMPILE) -c $< -o $@

control/%.o: control/%.c 
	@echo "compiling $<  Wall "
	@$(COMPILE) -c $< -o $@

control/%.lo: control/%.c 
	@echo "compiling $<  Wall "
	@$(LTCOMPILE) -c $< -o $@

calelm/%.o: calelm/%.c 
	@echo "compiling $<  Wall "
	@$(COMPILE) -c $< -o $@

calelm/%.lo: calelm/%.c 
	@echo "compiling $<  Wall "
	@$(LTCOMPILE) -c $< -o $@

