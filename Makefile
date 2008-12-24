PREFIX=/usr/local
BIN=$(PREFIX)/bin
LIB=$(PREFIX)/lib/perl

MODULEDIR=Beyonwiz/Recording

SCRIPTS=getWizPnP.pl

MODULES=$(MODULEDIR)/Header.pm $(MODULEDIR)/Index.pm \
	$(MODULEDIR)/IndexEntry.pm $(MODULEDIR)/Trunc.pm \
	$(MODULEDIR)/TruncEntry.pm

all:

install: all install_lib install_bin

install_lib:
	mkdir -p '$(LIB)/$(MODULEDIR)'
	cp $(MODULES) '$(LIB)/$(MODULEDIR)'

install_bin:
	mkdir -p '$(LIB)'
	cp $(SCRIPTS) '$(BIN)'

uninstall: uninstall_bin uninstall_lib

uninstall_bin:
	cd '$(BIN)' && rm -f $(SCRIPTS)
	
uninstall_lib:
	cd '$(LIB)' && rm -f $(MODULES)
	-rmdir '$(LIB)/$(MODULEDIR)'
	
doc::
	./make_doc.sh $(SCRIPTS) # $(MODULES) # No POD in the modules yet.
