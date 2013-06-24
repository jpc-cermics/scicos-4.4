SHELL = /bin/sh

include ../../../../Path.incl
include $(SCIDIR)/macros/Makefile.lib

# added targets 

SUBDIRS=

all::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
		(cd $$i ; echo "making all in macros/$$i..."; \
		$(MAKE) $(MFLAGS) all); \
	done

distclean::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
		(cd $$i ; echo "making distclean in macros/$$i..."; \
		$(MAKE) $(MFLAGS) -s silent-distclean); \
	done

clean::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
		(cd $$i ; echo "making clean in macros/$$i..."; \
		$(MAKE) $(MFLAGS) -s silent-clean); \
	done

