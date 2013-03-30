PREFIX=/usr/local
BIN=$(PREFIX)/bin
LIB=$(PREFIX)/lib/perl

NAME=getWizPnP

# Basic Windows vs Unix shell configuration: / is the separator in file paths.

ifdef ComSpec
    OSNAME=Windows
    MKDIR=mkdir
else
    OSNAME:=$(shell ( uname -o 2> /dev/null || uname -s ) | sed "s/GNU\///")
    MKDIR=mkdir -p
endif

VERSION:=$(shell perl ./$(NAME).pl --version 2>&1)

CP=cp

PP=pp
PPEXTRAMODULES=--module="Beyonwiz::PPModules"

ifeq ($(OSNAME),Cygwin)
    EXEEXT=.exe
else ifeq ($(OSNAME),Windows)
    EXEEXT=.exe
endif

COMPILED=Compiled
OSCOMPILED=$(COMPILED)/$(OSNAME)
OSCOMPILEDZIP=../../..
EXEDIR=$(OSCOMPILED)/$(NAME)

BWMODULEDIR=Beyonwiz
RECMODULEDIR=$(BWMODULEDIR)/Recording

SCRIPTS=$(NAME).pl
EXE=$(NAME)$(EXEEXT)

PPMODULES=$(BWMODULEDIR)/PPModules.pm

BWMODULES=$(BWMODULEDIR)/Utils.pm $(BWMODULEDIR)/WizPnP.pm \
	$(BWMODULEDIR)/WizPnPDevice.pm

RECMODULES=$(RECMODULEDIR)/Accessor.pm $(RECMODULEDIR)/Check.pm \
	$(RECMODULEDIR)/FileAccessor.pm $(RECMODULEDIR)/HTTPAccessor.pm \
	$(RECMODULEDIR)/Header.pm $(RECMODULEDIR)/Index.pm \
	$(RECMODULEDIR)/IndexEntry.pm $(RECMODULEDIR)/Recording.pm \
	$(RECMODULEDIR)/Stat.pm $(RECMODULEDIR)/Trunc.pm \
	$(RECMODULEDIR)/TruncEntry.pm

CLEANUPMODULES=$(RECMODULEDIR)/HTTPIndex.pm $(RECMODULEDIR)/FileIndex.pm \
	$(RECMODULEDIR)/HTTPRecording.pm $(RECMODULEDIR)/FileRecording.pm \
	$(RECMODULEDIR)/HTTPHeader.pm $(RECMODULEDIR)/FileHeader.pm \
	$(RECMODULEDIR)/FileIndexEntry.pm $(RECMODULEDIR)/HTTPIndexEntry.pm \
	$(RECMODULEDIR)/FileTrunc.pm $(RECMODULEDIR)/HTTPTrunc.pm


MODULES=$(BWMODULES) $(RECMODULES)

all:
	echo ver $(VERSION)

install: all check install_lib install_perl

install_lib:
	mkdir -p "$(LIB)/$(BWMODULEDIR)" "$(LIB)/$(RECMODULEDIR)"
	cd "$(LIB)" && rm -f $(CLEANUPMODULES)
	cp $(BWMODULES) "$(LIB)/$(BWMODULEDIR)"
	cp $(RECMODULES) "$(LIB)/$(RECMODULEDIR)"

install_perl: $(BIN)
	$(CP) $(SCRIPTS) "$(BIN)"

install_bin: all compile $(BIN)
	$(CP) "$(EXEDIR)/$(EXE)" "$(BIN)"

zip: check
	rm -f ../$(NAME)-$(VERSION).zip
	cd .. && zip -r $(NAME)-$(VERSION).zip $(NAME)

zip-compile: compile
	cd $(OSCOMPILED) && \
	rm -f $(OSCOMPILEDZIP)/$(NAME)-$(VERSION)-Compiled-$(OSNAME).zip && \
	zip -r $(OSCOMPILEDZIP)/$(NAME)-$(VERSION)-Compiled-$(OSNAME).zip $(NAME)

compile: check $(EXEDIR) $(EXEDIR)/$(EXE) doc
	$(CP) "html/$(NAME).html" "$(EXEDIR)"
	$(CP) "doc/$(NAME).txt" "$(EXEDIR)"
	$(CP) "README-VERSION.txt" "$(EXEDIR)"
	$(CP) "getwizpnp.conf" "$(EXEDIR)"

uninstall: uninstall_bin uninstall_lib

uninstall_perl:
	cd "$(BIN)" && rm -f $(SCRIPTS)
	
uninstall_bin:
	cd "$(BIN)" && rm -f $(EXE)
	
uninstall_lib:
	cd "$(LIB)" && rm -f $(MODULES)
	-rmdir "$(LIB)/$(RECMODULEDIR)" "$(LIB)/$(BWMODULEDIR)"

.PHONY: doc
	
doc:
	perl ./make_doc.pl $(SCRIPTS) $(MODULES)

check:
	./checkModules.pl $(SCRIPTS) $(MODULES)

clean:
	rm -rf $(COMPILED)

$(EXEDIR)/$(EXE): $(SCRIPTS)
	$(PP) $(PPEXTRAMODULES) \
	    -o "$(EXEDIR)/$(EXE)" $(SCRIPTS)

$(EXEDIR):
	$(MKDIR) "$(EXEDIR)"

$(BIN):
	$(MKDIR) "$(BIN)"

