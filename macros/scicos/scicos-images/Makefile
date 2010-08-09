include ../../../../../Path.incl

ALL = $(wildcard *.svg )
PNG= $(ALL:.svg=.png)

all	: $(PNG)

%.png	: %.svg
	inkscape $*.svg --export-area-drawing --export-png=$*.png  --export-dpi=48

svg	:
	$(SCIDIR)/bin/scilex -e "exec('../../../loader.sce');create_palette_icons();quit"



