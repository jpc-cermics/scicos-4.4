SHELL = /bin/sh

include ../../../../Path.incl
include $(SCIDIR)/Makefile.incl

SUBDIRS = Branching Events IntegerOp Iterators Linear \
	MatrixOp Misc ModElectrical Modelica ModHydraulics \
	ModLinear NonLinear PDE Sinks Sources \
	Threshold

all:: 
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
		(cd $$i ; echo "making all in macros/blocks/$$i..."; \
		$(MAKE) $(MFLAGS) all); \
	done

distclean::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
		(cd $$i ; echo "making distclean in macros/blocks/$$i..."; \
		$(MAKE) $(MFLAGS) -s silent-distclean ); \
	done

clean::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
		(cd $$i ; echo "making clean in macros/blocks/$$i..."; \
		$(MAKE) $(MFLAGS) -s silent-clean  ); \
	done

