# 
#   Support for FNAL IF Beams DB interface
#
#   jpaley@anl.gov 2013/06/07
#
#
ifndef ARCH_SPEC_IFDHART
ARCH_SPEC_IFDHART=ifdhart

extpkg := ifdhart

ifndef IFDH_ART_FQ_DIR
	arch_spec_warning:=\
	"Using default value IFDH_ART_FQ_DIR = $(EXTERNALS)/ifdh_art"
	IFDH_ART_FQ_DIR = $(EXTERNALS)/ifdh_art
endif
ifndef IFDH_ART_INC
	IFDH_ART_INC = $(IFDH_ART_DIR)/inc
endif
ifndef IFDH_ART_LIB
	IFDH_ART_LIB = $(IFDH_ART_FQ_DIR)/lib
endif

#IFDHC_LIBES = -lifbeam

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS := -I$(IFDH_ART_INC) $(CPPFLAGS)
override LDFLAGS  := -L$(IFDH_ART_LIB) $(LDFLAGS)


endif
