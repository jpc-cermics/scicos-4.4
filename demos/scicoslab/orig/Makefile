SHELL=/bin/sh

.SUFFIXES: .cos .cosf 

COS=$(patsubst %.cosf,%.cos,$(wildcard *.cosf))

all	:: $(COS) 

clean	::

distclean:: 
	@$(RM) -f $(COS) 

SCICOSLAB=/usr/local/src/scilab/scicoslab-svn/bin/scilab

.cosf.cos :
	@echo "conversion from cosf to cos for" $* 
	@$(SCICOSLAB) -nw -nb -e "name='$*.cosf';exec('./sci-cosf2cos.sce');quit" 










