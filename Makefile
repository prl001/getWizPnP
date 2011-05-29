PREFIX=/usr/local
BIN=$(PREFIX)/bin
LIB=$(PREFIX)/lib/perl

NAME=getWizPnP

# Basic Windows vs Unix shell configuration: $/ is the separator in file paths.

ifdef ComSpec
    OS=Windows
    # Ugly way to get a single \ into a variable
    /=$(shell echo \)
else
    OS=$(shell ( uname -o 2> /dev/null || uname -s ) | sed 's/GNU\///')
    /=/
endif

VERSION=$(shell .$/$(NAME).pl --version 2>&1)

MKDIR=mkdir -p
CP=cp

ifeq ($(OS),Cygwin)
    EXEEXT=.exe
else ifeq ($(OS),Windows)
    EXEEXT=.exe
    MKDIR=mkdir
    CP=copy/y
endif

OSCOMPILED=Compiled$/$(OS)
OSCOMPILEDZIP=.$/.$/.
EXEDIR=$(OSCOMPILED)$/$(NAME)

BWMODULEDIR=Beyonwiz
RECMODULEDIR=$(BWMODULEDIR)/Recording

SCRIPTS=$(NAME).pl
EXE=$(NAME)$(EXEEXT)

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

install: all check install_lib install_perl

install_lib:
	mkdir -p '$(LIB)/$(BWMODULEDIR)' '$(LIB)/$(RECMODULEDIR)'
	cd '$(LIB)' && rm -f $(CLEANUPMODULES)
	cp $(BWMODULES) '$(LIB)/$(BWMODULEDIR)'
	cp $(RECMODULES) '$(LIB)/$(RECMODULEDIR)'

install_perl: $(BIN)
	$(CP) $(SCRIPTS) "$(BIN)"

install_bin: all compile $(BIN)
	$(CP) "$(EXEDIR)$/$(EXE)" "$(BIN)"

zip: check
	rm -f ../$(NAME)-$(VERSION).zip
	cd .. && zip -r $(NAME)-$(VERSION).zip $(NAME)

zip-compile: compile
	cd $(OSCOMPILED) && \
	rm -f $(OSCOMPILEDZIP)$/$(NAME)-$(VERSION)-Compiled-$(OS).zip && \
	zip -r $(OSCOMPILEDZIP)$/$(NAME)-$(VERSION)-Compiled-$(OS).zip $(NAME)

compile: check $(EXEDIR) $(EXEDIR)$/$(EXE) doc
	$(CP) "html/$(NAME).html" "$(EXEDIR)"
	$(CP) "doc/$(NAME).txt" "$(EXEDIR)"

uninstall: uninstall_bin uninstall_lib

uninstall_perl:
	cd '$(BIN)' && rm -f $(SCRIPTS)
	
uninstall_bin:
	cd '$(BIN)' && rm -f $(EXE)
	
uninstall_lib:
	cd '$(LIB)' && rm -f $(MODULES)
	-rmdir '$(LIB)/$(RECMODULEDIR)' '$(LIB)/$(BWMODULEDIR)'

.PHONY: doc
	
doc:
	./make_doc.sh $(SCRIPTS) $(MODULES)

check:
	./checkModules.pl $(SCRIPTS) $(MODULES)

$(EXEDIR)$/$(EXE): $(SCRIPTS)
	pp -o "$(EXEDIR)$/$(EXE)" $(SCRIPTS)

$(EXEDIR):
	$(MKDIR) "$(EXEDIR)"

$(BIN):
	$(MKDIR) "$(BIN)"

