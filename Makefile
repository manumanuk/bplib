###############################################################################
# File: Makefile
#
#   Copyright 2019 United States Government as represented by the 
#   Administrator of the National Aeronautics and Space Administration. 
#   All Other Rights Reserved.  
#
#   This software was created at NASA's Goddard Space Flight Center.
#   This software is governed by the NASA Open Source Agreement and may be 
#   used, distributed and modified only pursuant to the terms of that 
#   agreement.
#
# Maintainer(s):
#  Joe-Paul Swinski, Code 582 NASA GSFC
#
# Notes:
#  1. Most settings used to build the library can be overridden in the config.mk
#     file.  To create a custom build of this library, copy and edit your own
#     config.mk file and then issue the following commands to build the library:
#
#        make CONFIG=config.mk
#
#  2. In order to use clang instead of gcc, set the COMPILER and TOOLCHAIN variables.
#     For example, if you wanted to run AddressSanitizer via clang, issue the following
#     commands to build the library:  
# 
#        make COMPILER=clang TOOLCHAIN=llvm APP_COPT=-fsanitize=address APP_LOPT=-fsanitize=address 
#
#  3. To build the unit tests:
#
#        make APP_COPT=-DUNITTEST unittest
#

##############################################################################
## DEFINITIONS and CONFIGURATION (populated/overridden in application includes)

# bplib repository root directory
ROOT	    := .
	
# bplib repository application interface include directory
API         := $(ROOT)/inc

# location to install bplib
PREFIX	    := /usr/local
	
# application object files, application should add their objects to this variable
APP_OBJ := bplib.o
APP_OBJ += bib.o
APP_OBJ += cteb.o
APP_OBJ += pay.o
APP_OBJ += pri.o
APP_OBJ += sdnv.o
APP_OBJ += crc.o
APP_OBJ += rb_tree.o
APP_OBJ += file.o
APP_OBJ += ram.o

# definitions needed by the application (used to declare things like -D_APP_NAME_)
APP_DEFS    ?=

# compiler options needed by the application
APP_COPT    ?=

# linker options needed by the application
APP_LOPT    ?=

# search path for application objects (note this is a make system variable)
VPATH	    := $(ROOT)/lib
VPATH	    += $(ROOT)/v6
VPATH	    += $(ROOT)/os
VPATH	    += $(ROOT)/store
VPATH	    += $(ROOT)/common

# compiler options for search path for include headers (in form of -I_header_)  
INCLUDES    := -I$(ROOT)/inc
INCLUDES    += -I$(ROOT)/lib
INCLUDES    += -I$(ROOT)/v6
INCLUDES    += -I$(ROOT)/os
INCLUDES    += -I$(ROOT)/store
INCLUDES    += -I$(ROOT)/common

# c compiler and linker used for c file extensions
COMPILER    ?= gcc

# tool chain used as prefix for binary utilities like archival tool
TOOLCHAIN   ?= gcc

# configuration makefile, if not set then uses default 
CONFIG      ?= posix.mk 

# include configuration makefile to override and add to above definitions
include $(CONFIG)

###############################################################################
##  DEFINES

TGTLIB  :=   bp
TGTVER  :=   $(shell cat version.txt)
CONSOLE :=   bpc
LIBDIR  :=   $(PREFIX)/lib
INCDIR  :=   $(PREFIX)/include/$(TGTLIB)
BLDDIR  :=   build
O       ?=   3 # default optimization level

COPT    :=   -g -Wall -Wextra -O$(O) -D'LIBID="$(TGTVER)"' $(INCLUDES) $(APP_DEFS)
COPT    +=   -DLIBPATH=\"$(LIBDIR)\"
COPT    +=   -DINCPATH=\"$(INCDIR)\"
COPT    +=   -Wshadow
 
LOPT    :=

###############################################################################
##  TOOLS

CC       =   $(COMPILER)
AR       =   $(TOOLCHAIN)-ar
RM       =   rm -f
CP       =   cp
DIFF     =   diff
LN       =   ln
MKDIR	 =   mkdir

###############################################################################
##  COMPILER RULES

ALL_OBJ := $(addprefix $(BLDDIR)/, $(APP_OBJ))
ALL_COPT := $(COPT) $(APP_COPT)
ALL_LOPT := $(LOPT) $(APP_LOPT)

$(BLDDIR)/%.o: %.c
	$(CC) -c $(ALL_COPT) -o $@ $<

##############################################################################
##  TARGET RULES

all: clean $(BLDDIR) static-lib shared-lib

static-lib: $(BLDDIR) $(ALL_OBJ)
	$(AR) crs $(BLDDIR)/lib$(TGTLIB).a $(ALL_OBJ)

shared-lib: $(BLDDIR) $(ALL_OBJ)
	$(CC) $(ALL_OBJ) $(ALL_LOPT) -shared -o $(BLDDIR)/lib$(TGTLIB).so.$(TGTVER)


install: static-lib shared-lib install-headers install-static install-shared

install-headers: $(INCDIR)
	$(CP) $(foreach element,$(API),$(subst -I,,$(element)/*.h)) $(INCDIR)
	chmod 644 $(INCDIR)/*

install-static: $(PREFIX) $(LIBDIR)
	$(CP) $(BLDDIR)/lib$(TGTLIB).a $(LIBDIR)
	chmod 644 $(LIBDIR)/lib$(TGTLIB).a

install-shared: $(PREFIX) $(LIBDIR)
	$(CP) $(BLDDIR)/lib$(TGTLIB).so.$(TGTVER) $(LIBDIR)
	$(LN) -sf $(LIBDIR)/lib$(TGTLIB).so.$(TGTVER) $(LIBDIR)/lib$(TGTLIB).so
	ldconfig
	chmod 644 $(LIBDIR)/lib$(TGTLIB).so
	chmod 644 $(LIBDIR)/lib$(TGTLIB).so.$(TGTVER)

$(BLDDIR):
	-$(MKDIR) -p $(BLDDIR)

$(PREFIX):
	-$(MKDIR) -p $(PREFIX)

$(LIBDIR):
	-$(MKDIR) -p $(LIBDIR)

$(INCDIR):
	-$(MKDIR) -p $(INCDIR)

prep: $(BLDDIR)

unittest: clean prep exe
 
exe: $(ALL_OBJ)
	$(CC) $^ $(ALL_LOPT) -o $(TGTLIB).out

clean ::
	-$(RM) -R $(BLDDIR)

# end of file


