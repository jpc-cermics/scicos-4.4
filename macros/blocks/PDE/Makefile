include ../../../../../Path.incl
include $(SCIDIR)/macros/Makefile.lib


SUBDIRS = gencode

all:: 
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
		(cd $$i ; echo "making all in macros/blocks/PDE/$$i..."; \
		$(MAKE) $(MFLAGS) -s all); \
	done

distclean::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
		(cd $$i ; echo "making distclean in macros/blocks/PDE/$$i..."; \
		$(MAKE) $(MFLAGS) -s silent-distclean ); \
	done

clean::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
		(cd $$i ; echo "making clean in macros/blocks/PDE/$$i..."; \
		$(MAKE) $(MFLAGS) -s silent-clean  ); \
	done


