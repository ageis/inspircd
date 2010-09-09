#               InspIRCd Main Makefile
#
#       (C) InspIRCd Development Team, 2002-2010
# This file is automagically generated by configure, from
# make/templates/main.mk. Any changes make to the generated
#     files will go away whenever it is regenerated!
#
# Please do not edit unless you know what you're doing. This
# needs to work in both GNU and BSD make; it is mangled for
# them by configure.
#

CC = @CC@
SYSTEM = @SYSTEM@
BUILDPATH = @BUILD_DIR@
SOCKETENGINE = @SOCKETENGINE@
CXXFLAGS = -pipe -fPIC -DPIC
LDLIBS = -pthread -lstdc++
LDFLAGS = 
CORELDFLAGS = -rdynamic -L. $(LDFLAGS)
PICLDFLAGS = -fPIC -shared -rdynamic $(LDFLAGS)
BASE = "$(DESTDIR)@BASE_DIR@"
CONPATH = "$(DESTDIR)@CONFIG_DIR@"
MODPATH = "$(DESTDIR)@MODULE_DIR@"
BINPATH = "$(DESTDIR)@BINARY_DIR@"
INSTUID = @UID@
INSTMODE_DIR = 0755
INSTMODE_BIN = 0755
INSTMODE_LIB = 0644

@IFEQ $(CC) icc
  CXXFLAGS += -Wshadow
@ELSE
  CXXFLAGS += -pedantic -Woverloaded-virtual -Wshadow -Wformat=2 -Wmissing-format-attribute -Wall
@ENDIF


@IFEQ $(SYSTEM) linux
  LDLIBS += -ldl -lrt
@ELSIFEQ $(SYSTEM) solaris
  LDLIBS += -lsocket -lnsl -lrt -lresolv
@ELSIFEQ $(SYSTEM) sunos
  LDLIBS += -lsocket -lnsl -lrt -lresolv
@ELSIFEQ $(SYSTEM) darwin
  CXXFLAGS += -DDARWIN -frtti
  LDLIBS += -ldl
  CORELDFLAGS = -dynamic -bind_at_load -L. $(LDFLAGS)
  PICLDFLAGS = -fPIC -shared -bundle -twolevel_namespace -undefined dynamic_lookup $(LDFLAGS)
@ELSIFEQ $(SYSTEM) interix
  CXXFLAGS += -D_ALL_SOURCE -I/usr/local/include
@ENDIF 

@IFNDEF D
  D=0
@ENDIF

@IFEQ $(D) 0
  CXXFLAGS += -O2 -g1
  HEADER = std-header
@ELSIFEQ $(D) 1
  CXXFLAGS += -O0 -g3 -Werror
  HEADER = debug-header
@ELSIFEQ $(D) 2
  CXXFLAGS += -O2 -g3
  HEADER = debug-header
@ELSE
  HEADER = unknown-debug-level
@ENDIF
FOOTER = finishmessage

CXXFLAGS += -Iinclude

@GNU_ONLY MAKEFLAGS += --no-print-directory

@GNU_ONLY SOURCEPATH = $(shell /bin/pwd)
@BSD_ONLY SOURCEPATH != /bin/pwd

@IFDEF V
  RUNCC = $(CC)
  RUNLD = $(CC)
  VERBOSE = -v
@ELSE
  @GNU_ONLY MAKEFLAGS += --silent
  @BSD_ONLY MAKE += -s
  RUNCC = perl $(SOURCEPATH)/make/run-cc.pl $(CC)
  RUNLD = perl $(SOURCEPATH)/make/run-cc.pl $(CC)
@ENDIF

@IFDEF PURE_STATIC
  CXXFLAGS += -DPURE_STATIC
@ENDIF

@DO_EXPORT RUNCC RUNLD CXXFLAGS LDLIBS PICLDFLAGS VERBOSE SOCKETENGINE CORELDFLAGS
@DO_EXPORT SOURCEPATH BUILDPATH PURE_STATIC SPLIT_CC

# Default target
TARGET = all

@IFDEF M
    HEADER = mod-header
    FOOTER = mod-footer
    @BSD_ONLY TARGET = modules/${M:S/.so$//}.so
    @GNU_ONLY TARGET = modules/$(M:.so=).so
@ENDIF

@IFDEF T
    HEADER =
    FOOTER = target
    TARGET = $(T)
@ENDIF

all: $(FOOTER)

target: $(HEADER)
	$(MAKEENV) perl make/calcdep.pl
	cd $(BUILDPATH); $(MAKEENV) $(MAKE) -f real.mk $(TARGET)

debug:
	@${MAKE} D=1 all

debug-header:
	@echo "*************************************"
	@echo "*    BUILDING WITH DEBUG SYMBOLS    *"
	@echo "*                                   *"
	@echo "*   This will take a *long* time.   *"
	@echo "*  Please be aware that this build  *"
	@echo "*  will consume a very large amount *"
	@echo "*  of disk space (~350MB), and may  *"
	@echo "*  run slower. Use the debug build  *"
	@echo "*  for module development or if you *"
	@echo "*    are experiencing problems.     *"
	@echo "*                                   *"
	@echo "*************************************"

mod-header:
@IFDEF PURE_STATIC
	@echo 'Cannot build single modules in pure-static build'
	@exit 1
@ENDIF
	@echo 'Building single module:'

mod-footer: target
	@echo 'To install, copy $(BUILDPATH)/$(TARGET) to $(MODPATH)'
	@echo 'Or, run "make install"'

std-header:
	@echo "*************************************"
	@echo "*       BUILDING INSPIRCD           *"
	@echo "*                                   *"
	@echo "*   This will take a *long* time.   *"
	@echo "*     Why not read our wiki at      *"
	@echo "*     http://wiki.inspircd.org      *"
	@echo "*  while you wait for make to run?  *"
	@echo "*************************************"

finishmessage: target
	@echo ""
	@echo "*************************************"
	@echo "*        BUILD COMPLETE!            *"
	@echo "*                                   *"
	@echo "*   To install InspIRCd, type:      *"
	@echo "*         make install              *"
	@echo "*************************************"

install: target
	@if [ "$(INSTUID)" = 0 -o "$(INSTUID)" = root ]; then \
		echo ""; \
		echo "Error: You must specify a non-root UID for the server"; \
		echo ""; \
		echo "If you are making a package, please specify using ./configure --uid"; \
		echo "Otherwise, rerun using 'make INSTUID=irc install', where 'irc' is the user"; \
		echo "who will be running the ircd. You will also need to modify the start script."; \
		echo ""; \
		exit 1; \
	fi
	@-install -d -o $(INSTUID) -m $(INSTMODE_DIR) $(BASE)
	@-install -d -o $(INSTUID) -m $(INSTMODE_DIR) $(BASE)/data
	@-install -d -o $(INSTUID) -m $(INSTMODE_DIR) $(BASE)/logs
	@-install -d -m $(INSTMODE_DIR) $(BINPATH)
	@-install -d -m $(INSTMODE_DIR) $(CONPATH)
	@-install -d -m $(INSTMODE_DIR) $(MODPATH)
	[ $(BUILDPATH)/bin/ -ef $(BINPATH) ] || install -m $(INSTMODE_BIN) $(BUILDPATH)/bin/inspircd $(BINPATH)
@IFNDEF PURE_STATIC
	[ $(BUILDPATH)/modules/ -ef $(MODPATH) ] || install -m $(INSTMODE_LIB) $(BUILDPATH)/modules/*.so $(MODPATH)
@ENDIF
	-install -m $(INSTMODE_BIN) @STARTSCRIPT@ $(BASE) 2>/dev/null
	-install -m $(INSTMODE_LIB) tools/gdbargs $(BASE)/.gdbargs 2>/dev/null
	-install -m $(INSTMODE_LIB) docs/*.example $(CONPATH)
	@echo ""
	@echo "*************************************"
	@echo "*        INSTALL COMPLETE!          *"
	@echo "*************************************"
	@echo 'Paths:'
	@echo '  Base install:' $(BASE)
	@echo '  Configuration:' $(CONPATH)
	@echo '  Binaries:' $(BINPATH)
	@echo '  Modules:' $(MODPATH)
	@echo 'To start the ircd, run:' $(BASE)/inspircd start
	@echo 'Remember to edit your config file:' $(CONPATH)/inspircd.conf

@GNU_ONLY RCS_FILES = $(wildcard .git/index src/version.sh)
@BSD_ONLY RCS_FILES = src/version.sh
GNUmakefile BSDmakefile: make/template/main.mk configure $(RCS_FILES)
	./configure -update
@BSD_ONLY .MAKEFILEDEPS: BSDmakefile

clean:
	@echo Cleaning...
	-rm -f $(BUILDPATH)/bin/inspircd $(BUILDPATH)/include $(BUILDPATH)/real.mk
	-rm -rf $(BUILDPATH)/obj $(BUILDPATH)/modules
	@-rmdir $(BUILDPATH)/bin 2>/dev/null
	@-rmdir $(BUILDPATH) 2>/dev/null
	@echo Completed.

deinstall:
	-rm $(BINPATH)/inspircd
	-rm $(MODPATH)/*.so

squeakyclean: distclean

configureclean:
	rm -f .config.cache
	rm -f src/modules/Makefile
	rm -f src/commands/Makefile
	rm -f src/Makefile
	-rm -f Makefile
	rm -f BSDmakefile
	rm -f GNUmakefile
	rm -f include/inspircd_config.h
	rm -f include/inspircd_version.h

distclean: clean configureclean

help:
	@echo 'InspIRCd Makefile'
	@echo ''
	@echo 'Use: ${MAKE} [flags] [targets]'
	@echo ''
	@echo 'Flags:'
	@echo ' V=1       Show the full command being executed instead of "BUILD: dns.cpp"'
	@echo ' D=1       Enable debug build, for module development or crash tracing'
	@echo ' D=2       Enable debug build with optimizations, for detailed backtraces'
	@echo ' DESTDIR=  Specify a destination root directory (for tarball creation)'
	@echo ' -j <N>    Run a parallel build using N jobs'
	@echo ''
	@echo 'Targets:'
	@echo ' all       Complete build of InspIRCd, without installing (default)'
	@echo ' install   Build and install InspIRCd to the directory chosen in ./configure'
	@echo '           Currently installs to ${BASE}'
	@echo ' debug     Compile a debug build. Equivalent to "make D=1 all"'
	@echo ''
	@echo ' M=m_foo   Builds a single module (cmd_foo also works here)'
	@echo ' T=target  Builds a user-specified target, such as "inspircd" or "modules"'
	@echo '           Other targets are specified by their path in the build directory'
	@echo '           Multiple targets may be separated by a space'
	@echo ''
	@echo ' clean     Cleans object files produced by the compile'
	@echo ' distclean Cleans all files produced by compile and ./configure'
	@echo '           Note: this includes the Makefile'
	@echo ' deinstall Removes the files created by "make install"'
	@echo

.PHONY: all target debug debug-header mod-header mod-footer std-header finishmessage install clean deinstall squeakyclean configureclean help
