
ALL = $(wildcard *.svg )
PNG= $(ALL:.svg=.png)

all	: $(PNG)

%.png	: %.svg
	inkscape $*.svg --export-area-drawing --export-png=$*.png  --export-dpi=48


svg	:
	../../../bin/nsp -e "switch_graphics();create_palette_icons();quit"
