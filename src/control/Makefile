SHELL = /bin/sh
SCIDIR=../../..
SCIDIR1=..\..\..

LIBRARY = $(SCIDIR)/libs/control.a

ARL2= arl2.o arl2a.o phi.o \
	outl2.o jacl2.o feq.o optml2.o deg1l2.o degl2.o storl2.o calsca.o \
	hessl2.o tild.o mzdivq.o domout.o front.o  dzdivq.o \
	scapol.o onface.o watfac.o modul.o lq.o rootgp.o 

OBJSC =

OBJSF =  bezous.o cerr.o coef.o dclmat.o dexpm1.o \
	dfrmg.o dhetr.o expan.o find.o folhp.o fout.o \
	invtpl.o irow1.o irow2.o lrow2.o lybad.o \
	lybsc.o lydsr.o pade.o polmc.o \
	proj2.o qzk.o ricd.o rilac.o ssxmc.o sszer.o  \
	sybad.o sydsr.o syhsc.o wcerr.o wclmat.o \
	wdegre.o wesidu.o wexpm1.o wpade.o rtitr.o \
	dgbfa.o dgbsl.o dgeco.o dgedi.o dgefa.o dgesl.o dlslv.o \
	dpofa.o dqrdc.o dqrsl.o dqrsm.o drref.o dsvdc.o giv.o hhdml.o \
	shrslv.o wgeco.o wgedi.o wgefa.o wgesl.o wlslv.o wpofa.o wqrdc.o \
	wqrsl.o wrref.o wsvdc.o ereduc.o \
	balanc.o balbak.o bdiag.o calcsc.o cbal.o comqr3.o \
	corth.o cortr.o dsubsp.o exch.o exchqz.o fxshfr.o hqror2.o htribk.o \
	htridi.o imtql3.o inva.o newest.o nextk.o orthes.o ortran.o \
	qhesz.o qitz.o quad.o quadit.o quadsd.o qvalz.o qvecz.o \
	realit.o scaleg.o reduc2.o \
	rpoly.o split.o tql2.o tred2.o wbalin.o wbdiag.o wexchn.o \
	wshrsl.o fstair.o riccpack.o \
	$(ARL2)

include ../../../Makefile.incl

CFLAGS = $(CC_OPTIONS)
FFLAGS = $(FC_OPTIONS)

include ../../Make.lib

# according to compiler, do not optimize the following files

hqror2.o: hqror2.c
	@echo "compiling $<  Wall "
	@$(CC)  $(CC_OPTIONS1) -c $< -o $@

comqr3.o: comqr3.c
	@echo "compiling $<  Wall "
	@$(CC)  $(CC_OPTIONS1) -c $< -o $@

tql2.o: tql2.c
	@echo "compiling $<  Wall "
	@$(CC)  $(CC_OPTIONS1) -c $< -o $@

imtql3.o: imtql3.c
	@echo "compiling $<  Wall "
	@$(CC)  $(CC_OPTIONS1) -c $< -o $@

dsvdc.o: dsvdc.c
	@echo "compiling $<  Wall "
	@$(CC)  $(CC_OPTIONS1) -c $< -o $@

wsvdc.o: wsvdc.c
	@echo "compiling $<  Wall "
	@$(CC)  $(CC_OPTIONS1) -c $< -o $@

pade.o: pade.c
	@echo "compiling $<  Wall "
	@$(CC)  $(CC_OPTIONS1) -c $< -o $@

