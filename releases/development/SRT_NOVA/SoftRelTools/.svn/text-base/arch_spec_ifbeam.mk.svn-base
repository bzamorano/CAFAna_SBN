# 
#   Support for FNAL IF Beams DB interface
#
#   janzirn 2013/10/09
#
#
ifndef ARCH_SPEC_IFBEAM
ARCH_SPEC_IFBEAM=ifbeam

extpkg := ifbeam

ifndef IFBEAM_DIR
	arch_spec_warning:=\
	"Using default value IFBEAM_DIR = $(EXTERNALS)/ifbeam"
	IFBEAM_DIR = $(EXTERNALS)/ifbeam
endif
ifndef IFBEAM_INC
	IFBEAM_INC = $(IFBEAM_FQ_DIR)/include
endif
ifndef IFBEAM_LIB
	IFBEAM_LIB = $(IFBEAM_FQ_DIR)/lib
endif
ifndef LIBWDA_INC
	LIBWDA_INC = $(LIBWDA_FQ_DIR)/include
endif
#IFBEAM_LIBES = -lifbeam

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS := -I$(LIBWDA_INC) -I$(IFBEAM_INC) $(CPPFLAGS) 
override LDFLAGS  := -L$(IFBEAM_LIB) $(LDFLAGS)

endif
