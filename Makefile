PREFIX=/usr/local
BIN=$(PREFIX)/bin
LIB=$(PREFIX)/lib/perl

BWMODULEDIR=Beyonwiz
RECMODULEDIR=$(BWMODULEDIR)/Recording

SCRIPTS=getWizPnP.pl

BWMODULES=$(BWMODULEDIR)/Utils.pm $(BWMODULEDIR)/WizPnP.pm \
	$(BWMODULEDIR)/WizPnPDevice.pm

RECMODULES=$(RECMODULEDIR)/Accessor.pm $(RECMODULEDIR)/FileAccessor.pm \
	$(RECMODULEDIR)/HTTPAccessor.pm $(RECMODULEDIR)/Header.pm \
	$(RECMODULEDIR)/Index.pm $(RECMODULEDIR)/IndexEntry.pm \
	$(RECMODULEDIR)/Recording.pm $(RECMODULEDIR)/Trunc.pm \
	$(RECMODULEDIR)/TruncEntry.pm

CLEANUPMODULES=$(RECMODULEDIR)/HTTPIndex.pm $(RECMODULEDIR)/FileIndex.pm \
	$(RECMODULEDIR)/HTTPRecording.pm $(RECMODULEDIR)/FileRecording.pm \
	$(RECMODULEDIR)/HTTPHeader.pm $(RECMODULEDIR)/FileHeader.pm \
	$(RECMODULEDIR)/FileIndexEntry.pm $(RECMODULEDIR)/HTTPIndexEntry.pm \
	$(RECMODULEDIR)/FileTrunc.pm $(RECMODULEDIR)/HTTPTrunc.pm


MODULES=$(BWMODULES) $(RECMODULES)

all:

install: all check install_lib install_bin

install_lib:
	mkdir -p '$(LIB)/$(BWMODULEDIR)' '$(LIB)/$(RECMODULEDIR)'
	cd '$(LIB)' && rm -f $(CLEANUPMODULES)
	cp $(BWMODULES) '$(LIB)/$(BWMODULEDIR)'
	cp $(RECMODULES) '$(LIB)/$(RECMODULEDIR)'

install_bin:
	mkdir -p '$(LIB)'
	cp $(SCRIPTS) '$(BIN)'

uninstall: uninstall_bin uninstall_lib

uninstall_bin:
	cd '$(BIN)' && rm -f $(SCRIPTS)
	
uninstall_lib:
	cd '$(LIB)' && rm -f $(MODULES)
	-rmdir '$(LIB)/$(RECMODULEDIR)' '$(LIB)/$(BWMODULEDIR)'

.PHONY: doc
	
doc:
	./make_doc.sh $(SCRIPTS) $(MODULES)

check:
	./checkModules.pl $(SCRIPTS) $(MODULES)
