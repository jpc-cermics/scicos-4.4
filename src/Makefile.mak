#-----------------------------
# generated from Makefile: DO NOT EDIT
# -----------------------------
SHELL = /bin/sh

SCIDIR=../../..
SCIDIR1=..\..\..

LIBRARY=libscicos.lib

BLOCKSF=evtdly.obj cstblk.obj \
	lusat.obj pload.obj qzcel.obj qzflr.obj \
	qzrnd.obj qztrn.obj lsplit.obj csslti.obj \
	dsslti.obj trash.obj zcross.obj \
	expblk.obj logblk.obj sinblk.obj tanblk.obj powblk.obj \
	sqrblk.obj delay.obj selblk.obj forblk.obj writef.obj invblk.obj hltblk.obj \
	gensin.obj rndblk.obj lookup.obj timblk.obj gensqr.obj mfclck.obj \
	sawtth.obj tcslti.obj tcsltj.obj integr.obj readf.obj affich2.obj affich.obj \
	intpol.obj intplt.obj minblk.obj maxblk.obj dlradp.obj  iocopy.obj \
	sum2.obj sum3.obj delayv.obj mux.obj demux.obj samphold.obj dollar.obj \
	intrp2.obj intrpl.obj fsv.obj memo.obj \
	absblk.obj bidon.obj gain.obj cdummy.obj dband.obj cosblk.obj ifthel.obj \
	eselect.obj

BLOCKS_CODE=evtdly.obj cstblk.obj \
	lusat.obj pload.obj qzcel.obj qzflr.obj \
	qzrnd.obj qztrn.obj lsplit.obj csslti.obj \
	dsslti.obj trash.obj zcross.obj \
	expblk.obj logblk.obj sinblk.obj tanblk.obj powblk.obj \
	sqrblk.obj delay.obj selblk.obj forblk.obj  writef.obj invblk.obj hltblk.obj \
	gensin.obj rndblk.obj lookup.obj timblk.obj gensqr.obj mfclck.obj \
	sawtth.obj tcslti.obj tcsltj.obj integr.obj readf.obj affich2.obj affich.obj \
	intpol.obj intplt.obj minblk.obj maxblk.obj dlradp.obj  iocopy.obj \
	sum2.obj sum3.obj delayv.obj mux.obj demux.obj samphold.obj dollar.obj \
	intrp2.obj intrpl.obj fsv.obj memo.obj \
	ifthel.obj eselect.obj

BLOCKSC=selector.obj sum.obj prod.obj switchn.obj relay.obj readc.obj writec.obj writeau.obj \
	readau.obj plusblk.obj slider.obj  sliderm.obj zcross2.obj mswitch.obj logicalop.obj \
	switch2.obj variable_delay.obj time_delay.obj cscope.obj cmscope.obj \
	satur.obj step_func.obj integral_func.obj absolute_value.obj bounce_ball.obj \
	bouncexy.obj extractor.obj scalar2vector.obj minmax.obj signum.obj product.obj \
	summation.obj multiplex.obj gainblk.obj relationalop.obj modulo_count.obj \
	hystheresis.obj ratelimiter.obj backlash.obj deadband.obj ramp.obj \
	deriv.obj sin_blk.obj cos_blk.obj tan_blk.obj asin_blk.obj acos_blk.obj atan_blk.obj \
        sinh_blk.obj cosh_blk.obj tanh_blk.obj asinh_blk.obj acosh_blk.obj atanh_blk.obj \
	evtvardly.obj edgetrig.obj tcslti4.obj tcsltj4.obj dsslti4.obj \
	csslti4.obj cstblk4.obj samphold4.obj dollar4.obj invblk4.obj delay4.obj \
	cevscpe.obj cfscope.obj cscopxy.obj canimxy.obj canimxy3d.obj cscopxy3d.obj \
	matmul_m.obj mattran_m.obj cmatview.obj cmat3d.obj \
	extdiag.obj exttril.obj mat_bksl.obj mat_diag.obj mat_lu.obj mat_svd.obj \
	matz_absc.obj matz_conj.obj matz_expm.obj matz_reim.obj matz_svd.obj root_coef.obj \
	extdiagz.obj exttrilz.obj mat_cath.obj mat_div.obj mat_pinv.obj mat_vps.obj matz_bksl.obj \
	matz_det.obj matz_inv.obj matz_reimc.obj matz_vps.obj rootz_coef.obj extract.obj exttriu.obj \
	mat_catv.obj mat_expm.obj mat_reshape.obj mat_vpv.obj matz_cath.obj matz_diag.obj matz_lu.obj \
	matz_reshape.obj matz_vpv.obj submat.obj extractz.obj exttriuz.obj mat_det.obj mat_inv.obj \
	mat_sing.obj matz_abs.obj matz_catv.obj matz_div.obj matz_pinv.obj matz_sing.obj ricc_m.obj \
	submatz.obj switch2_m.obj dollar4_m.obj cstblk4_m.obj integralz_func.obj \
        matzmul_m.obj matztran_m.obj mat_sum.obj mat_sumc.obj mat_suml.obj cumsum_c.obj cumsum_m.obj \
	cumsum_r.obj matz_sum.obj matz_sumc.obj matz_suml.obj cumsumz_c.obj cumsumz_m.obj \
	cumsumz_r.obj selector_m.obj summation_z.obj \
	convert.obj logicalop_i32.obj logicalop_ui32.obj logicalop_i16.obj logicalop_ui16.obj \
	logicalop_i8.obj logicalop_ui8.obj logicalop_m.obj samphold4_m.obj matmul_i32s.obj \
	matmul_i32n.obj matmul_i32e.obj matmul_i16s.obj matmul_i16n.obj matmul_i16e.obj \
	matmul_i8s.obj matmul_i8n.obj matmul_i8e.obj matmul_ui32s.obj matmul_ui32n.obj \
	matmul_ui32e.obj matmul_ui16s.obj matmul_ui16n.obj matmul_ui16e.obj matmul_ui8s.obj \
	matmul_ui8n.obj matmul_ui8e.obj summation_i32s.obj summation_i32n.obj summation_i32e.obj \
	summation_i16s.obj summation_i16n.obj summation_i16e.obj summation_i8s.obj \
	summation_i8n.obj summation_i8e.obj summation_ui32s.obj summation_ui32n.obj \
	summation_ui32e.obj summation_ui16s.obj summation_ui16n.obj summation_ui16e.obj \
	summation_ui8s.obj summation_ui8n.obj summation_ui8e.obj gainblk_i32s.obj \
	gainblk_i32n.obj gainblk_i32e.obj gainblk_i16s.obj gainblk_i16n.obj gainblk_i16e.obj \
	gainblk_i8s.obj gainblk_i8n.obj gainblk_i8e.obj gainblk_ui32s.obj gainblk_ui32n.obj \
	gainblk_ui32e.obj gainblk_ui16s.obj gainblk_ui16n.obj gainblk_ui16e.obj gainblk_ui8s.obj \
	gainblk_ui8n.obj gainblk_ui8e.obj delay4_ints.obj mat_sqrt.obj \
	matz_sqrt.obj relational_op_ints.obj evtdly4.obj\
	matmul2_m.obj matzmul2_m.obj expblk_m.obj logic.obj bit_clear_ints.obj \
	bit_set_ints.obj extract_bit_32_UH0.obj extract_bit_16_UH0.obj \
	extract_bit_8_UH0.obj extract_bit_32_UH1.obj extract_bit_16_UH1.obj extract_bit_8_UH1.obj \
	extract_bit_32_LH.obj extract_bit_16_LH.obj extract_bit_8_LH.obj extract_bit_32_MSB0.obj \
        extract_bit_16_MSB0.obj extract_bit_8_MSB0.obj extract_bit_32_MSB1.obj extract_bit_16_MSB1.obj \
        extract_bit_8_MSB1.obj extract_bit_32_LSB.obj extract_bit_16_LSB.obj extract_bit_8_LSB.obj \
        extract_bit_32_RB0.obj extract_bit_16_RB0.obj extract_bit_8_RB0.obj extract_bit_32_RB1.obj \
        extract_bit_16_RB1.obj extract_bit_8_RB1.obj shift_ints.obj \
	extract_bit_u32_UH1.obj extract_bit_u16_UH1.obj extract_bit_u8_UH1.obj extract_bit_u32_MSB1.obj\
	extract_bit_u16_MSB1.obj extract_bit_u8_MSB1.obj extract_bit_u32_RB1.obj extract_bit_u16_RB1.obj \
        extract_bit_u8_RB1.obj rndblk_m.obj relational_op.obj curve_c.obj counter.obj m_frequ.obj \
        tows_c.obj rndblkz_m.obj fromws_c.obj mathermit_m.obj scicosexit.obj automat.obj lookup_c.obj tablex2d_c.obj\
	matbyscal.obj matbyscal_s.obj matbyscal_e.obj matmul2_s.obj matmul2_e.obj constraint_c.obj lookup2d.obj \
	diffblk_c.obj andlog.obj foriterator.obj assignment.obj whileiterator.obj loopbreaker.obj

BLOCKS_MULTIC=absolute_valuei_SCSREAL_COP absolute_valuei_SCSINT32_COP \
	absolute_valuei_SCSINT16_COP absolute_valuei_SCSINT8_COP absolute_valuei_SCSUINT32_COP \
	absolute_valuei_SCSUINT16_COP absolute_valuei_SCSUINT8_COP

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
	wgesl.obj wgeco.obj wclmat.obj wcerr.obj wgefa.obj dgelsy1.obj 

CALELM=dad.obj dmcopy.obj wdiv.obj wasum.obj wdotcr.obj wdotci.obj \
	waxpy.obj wsign.obj wrscal.obj wmul.obj pythag.obj \
	gdcp2i.obj wscal.obj iwamax.obj wsqrt.obj dprxc.obj wprxc.obj \
	dmmul.obj fn.obj

# sundials and ode solvers 

SUNDIALS=cvode.obj cvode_io.obj cvode_dense.obj nvector_serial.obj ida.obj ida_dense.obj \
	ida_io.obj ida_ic.obj sundials_nvector.obj sundials_math.obj \
	sundials_dense.obj sundials_smalldense.obj\
	kinsol.obj kinsol_dense.obj kinsol_io.obj dopri5m.obj


OBJSC=  import.obj scicos.obj intcos.obj simul.obj sciblk2.obj trees.obj ezxml.obj scicos_utils.obj \
	evaluate_expr.obj about.obj \
	blocks/blocks_new_nsp.obj blocks/blocks_nsp.obj blocks/gtkrange.obj blocks/absolute_valuei.obj\
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
	@echo Cleaning in subdirs
	@$(RM) */*.obj */*.lo

#---------------Blocks

# include Make.Blocks.mak

distclean::
	$(RM) Fblocknames Cblocknames blocks.h

# special rules for compilation 
#-------------------------------

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

