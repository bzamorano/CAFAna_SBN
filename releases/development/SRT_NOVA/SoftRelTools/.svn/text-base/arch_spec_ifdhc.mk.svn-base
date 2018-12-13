# 
#   Support for FNAL IF Beams DB interface
#
#   jpaley@anl.gov 2013/06/07
#
#
ifndef ARCH_SPEC_IFDHC
ARCH_SPEC_IFDHC=ifdhc

extpkg := ifdhc

ifndef IFDHC_FQ_DIR
	arch_spec_warning:=\
	"Using default value IFDHC_FQ_DIR = $(EXTERNALS)/ifdhc"
	IFDHC_FQ_DIR = $(EXTERNALS)/ifdhc
endif
ifndef IFDHC_DIR
	arch_spec_warning:=\
	"Using default value IFDHC_DIR = $(EXTERNALS)/ifdhc"
	IFDHC_DIR = $(EXTERNALS)/ifdhc
endif
ifndef IFDHC_INC
	IFDHC_INC = $(IFDHC_FQ_DIR)/inc
endif
ifndef IFDHC_LIB
	IFDHC_LIB = $(IFDHC_FQ_DIR)/lib
endif

IFDHC_LIBES = -lifbeam

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS := -I$(IFDHC_INC) $(CPPFLAGS)
override LDFLAGS  := -L$(IFDHC_LIB) $(LDFLAGS)
override BINLIBS  += $(IFDHC_LIBES)

endif
