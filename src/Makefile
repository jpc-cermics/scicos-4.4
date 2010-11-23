SHELL = /bin/sh

SCIDIR=../../..
SCIDIR1=..\..\..

LIBRARY=libscicos.a

BLOCKSF=evtdly.o cstblk.o \
	lusat.o pload.o qzcel.o qzflr.o \
	qzrnd.o qztrn.o lsplit.o csslti.o \
	dsslti.o trash.o zcross.o \
	expblk.o logblk.o sinblk.o tanblk.o powblk.o \
	sqrblk.o delay.o selblk.o forblk.o writef.o invblk.o hltblk.o \
	gensin.o rndblk.o lookup.o timblk.o gensqr.o mfclck.o \
	sawtth.o tcslti.o tcsltj.o integr.o readf.o affich2.o affich.o \
	intpol.o intplt.o minblk.o maxblk.o dlradp.o  iocopy.o \
	sum2.o sum3.o delayv.o mux.o demux.o samphold.o dollar.o \
	intrp2.o intrpl.o fsv.o memo.o \
	absblk.o bidon.o gain.o cdummy.o dband.o cosblk.o ifthel.o \
	eselect.o

BLOCKS_CODE=evtdly.o cstblk.o \
	lusat.o pload.o qzcel.o qzflr.o \
	qzrnd.o qztrn.o lsplit.o csslti.o \
	dsslti.o trash.o zcross.o \
	expblk.o logblk.o sinblk.o tanblk.o powblk.o \
	sqrblk.o delay.o selblk.o forblk.o  writef.o invblk.o hltblk.o \
	gensin.o rndblk.o lookup.o timblk.o gensqr.o mfclck.o \
	sawtth.o tcslti.o tcsltj.o integr.o readf.o affich2.o affich.o \
	intpol.o intplt.o minblk.o maxblk.o dlradp.o  iocopy.o \
	sum2.o sum3.o delayv.o mux.o demux.o samphold.o dollar.o \
	intrp2.o intrpl.o fsv.o memo.o \
	ifthel.o eselect.o

BLOCKSC=selector.o sum.o prod.o switchn.o relay.o readc.o writec.o writeau.o \
	readau.o plusblk.o slider.o  zcross2.o mswitch.o logicalop.o \
	switch2.o variable_delay.o time_delay.o cscope.o cmscope.o \
	satur.o step_func.o integral_func.o absolute_value.o bounce_ball.o \
	bouncexy.o extractor.o scalar2vector.o minmax.o signum.o product.o \
	summation.o multiplex.o gainblk.o relationalop.o modulo_count.o \
	hystheresis.o ratelimiter.o backlash.o deadband.o ramp.o \
	deriv.o sin_blk.o cos_blk.o tan_blk.o asin_blk.o acos_blk.o atan_blk.o \
        sinh_blk.o cosh_blk.o tanh_blk.o asinh_blk.o acosh_blk.o atanh_blk.o \
	evtvardly.o edgetrig.o tcslti4.o tcsltj4.o dsslti4.o \
	csslti4.o cstblk4.o samphold4.o dollar4.o invblk4.o delay4.o \
	cevscpe.o cfscope.o cscopxy.o canimxy.o canimxy3d.o cscopxy3d.o \
	matmul_m.o mattran_m.o cmatview.o cmat3d.o \
	extdiag.o exttril.o mat_bksl.o mat_diag.o mat_lu.o mat_svd.o \
	matz_absc.o matz_conj.o matz_expm.o matz_reim.o matz_svd.o root_coef.o \
	extdiagz.o exttrilz.o mat_cath.o mat_div.o mat_pinv.o mat_vps.o matz_bksl.o \
	matz_det.o matz_inv.o matz_reimc.o matz_vps.o rootz_coef.o extract.o exttriu.o \
	mat_catv.o mat_expm.o mat_reshape.o mat_vpv.o matz_cath.o matz_diag.o matz_lu.o \
	matz_reshape.o matz_vpv.o submat.o extractz.o exttriuz.o mat_det.o mat_inv.o \
	mat_sing.o matz_abs.o matz_catv.o matz_div.o matz_pinv.o matz_sing.o ricc_m.o \
	submatz.o switch2_m.o dollar4_m.o cstblk4_m.o integralz_func.o \
        matzmul_m.o matztran_m.o mat_sum.o mat_sumc.o mat_suml.o cumsum_c.o cumsum_m.o \
	cumsum_r.o matz_sum.o matz_sumc.o matz_suml.o cumsumz_c.o cumsumz_m.o \
	cumsumz_r.o selector_m.o summation_z.o \
	convert.o logicalop_i32.o logicalop_ui32.o logicalop_i16.o logicalop_ui16.o \
	logicalop_i8.o logicalop_ui8.o logicalop_m.o samphold4_m.o matmul_i32s.o \
	matmul_i32n.o matmul_i32e.o matmul_i16s.o matmul_i16n.o matmul_i16e.o \
	matmul_i8s.o matmul_i8n.o matmul_i8e.o matmul_ui32s.o matmul_ui32n.o \
	matmul_ui32e.o matmul_ui16s.o matmul_ui16n.o matmul_ui16e.o matmul_ui8s.o \
	matmul_ui8n.o matmul_ui8e.o summation_i32s.o summation_i32n.o summation_i32e.o \
	summation_i16s.o summation_i16n.o summation_i16e.o summation_i8s.o \
	summation_i8n.o summation_i8e.o summation_ui32s.o summation_ui32n.o \
	summation_ui32e.o summation_ui16s.o summation_ui16n.o summation_ui16e.o \
	summation_ui8s.o summation_ui8n.o summation_ui8e.o gainblk_i32s.o \
	gainblk_i32n.o gainblk_i32e.o gainblk_i16s.o gainblk_i16n.o gainblk_i16e.o \
	gainblk_i8s.o gainblk_i8n.o gainblk_i8e.o gainblk_ui32s.o gainblk_ui32n.o \
	gainblk_ui32e.o gainblk_ui16s.o gainblk_ui16n.o gainblk_ui16e.o gainblk_ui8s.o \
	gainblk_ui8n.o gainblk_ui8e.o delay4_ints.o mat_sqrt.o \
	matz_sqrt.o relational_op_ints.o evtdly4.o\
	matmul2_m.o matzmul2_m.o expblk_m.o logic.o bit_clear_32.o bit_clear_16.o bit_clear_8.o\
	bit_set_32.o bit_set_16.o bit_set_8.o extract_bit_32_UH0.o extract_bit_16_UH0.o \
	extract_bit_8_UH0.o extract_bit_32_UH1.o extract_bit_16_UH1.o extract_bit_8_UH1.o \
	extract_bit_32_LH.o extract_bit_16_LH.o extract_bit_8_LH.o extract_bit_32_MSB0.o \
        extract_bit_16_MSB0.o extract_bit_8_MSB0.o extract_bit_32_MSB1.o extract_bit_16_MSB1.o \
        extract_bit_8_MSB1.o extract_bit_32_LSB.o extract_bit_16_LSB.o extract_bit_8_LSB.o \
        extract_bit_32_RB0.o extract_bit_16_RB0.o extract_bit_8_RB0.o extract_bit_32_RB1.o \
        extract_bit_16_RB1.o extract_bit_8_RB1.o shift_8_LA.o shift_16_LA.o shift_32_LA.o \
	shift_8_LC.o shift_16_LC.o shift_32_LC.o shift_8_RA.o shift_16_RA.o shift_32_RA.o \
	shift_8_RC.o shift_16_RC.o shift_32_RC.o shift_u8_RA.o shift_u16_RA.o shift_u32_RA.o\
	extract_bit_u32_UH1.o extract_bit_u16_UH1.o extract_bit_u8_UH1.o extract_bit_u32_MSB1.o\
	extract_bit_u16_MSB1.o extract_bit_u8_MSB1.o extract_bit_u32_RB1.o extract_bit_u16_RB1.o \
        extract_bit_u8_RB1.o rndblk_m.o relational_op.o curve_c.o counter.o m_frequ.o \
        tows_c.o rndblkz_m.o fromws_c.o mathermit_m.o scicosexit.o automat.o lookup_c.o tablex2d_c.o\
	matbyscal.o matbyscal_s.o matbyscal_e.o matmul2_s.o matmul2_e.o constraint_c.o lookup2d.o \
	diffblk_c.o andlog.o foriterator.o assignment.o whileiterator.o loopbreaker.o

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
	dmmul.o fn.o

# sundials and ode solvers 

SUNDIALS=cvode.o cvode_io.o cvode_dense.o nvector_serial.o ida.o ida_dense.o \
	ida_io.o ida_ic.o sundials_nvector.o sundials_math.o \
	sundials_dense.o sundials_smalldense.o\
	kinsol.o kinsol_dense.o kinsol_io.o dopri5m.o


OBJSC=  import.o scicos.o intcos.o simul.o sciblk2.o trees.o ezxml.o scicos_utils.o \
	evaluate_expr.o \
	blocks/blocks_new_nsp.o blocks/blocks_nsp.o \
	$(addprefix sundials/,$(SUNDIALS)) \
	$(addprefix blocks/,$(BLOCKSC)) \
	$(addprefix control/,$(CONTROL)) \
	$(addprefix calelm/,$(CALELM)) 

BLOCKS=$(BLOCKSF) $(BLOCKSC)

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
	@echo Cleaning in subdirs
	@$(RM) */*.o */*.lo

#---------------Blocks

# include Make.Blocks

distclean::
	$(RM) Fblocknames Cblocknames blocks.h

# special rules for compilation 
#-------------------------------

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

