# arch_spec_CLHEP.mk
#
# Expects:
# - CLHEP_DIR to point to a base directory
# - CLHEP_LIB to point to a library name (eg. CLHEP-2.1.4.1)
# - CLHEP_INC to point to an include directory
#

extpkg:=CLHEP
CLHEP_DIR_DEFAULT := /usr/local
ifndef CLHEP_DIR
    arch_spec_warning:=\
    "Using default value CLHEP_DIR = $(CLHEP_DIR_DEFAULT)"
    CLHEP_DIR := $(CLHEP_DIR_DEFAULT)
endif
ifndef CLHEP_INC 
    CLHEP_INC = $(CLHEP_DIR)/include
endif
ifndef CLHEP_LIB_DIR
    CLHEP_LIB_DIR = $(CLHEP_DIR)/lib
endif
ifndef CLHEP_LIB
    CLHEP_LIB = CLHEP
endif
CLHEPLIBS = -l$(CLHEP_LIB)

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += -I$(CLHEP_INC)
override LDFLAGS   += -L$(CLHEP_LIB_DIR)
override LOADLIBES += -l$(CLHEP_LIB)
