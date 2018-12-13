# 
#   Support for FNAL CD DB Apps WebDataAccessCAPI
#
#   jpaley@anl.gov 2013/03/22
#
#
ifndef ARCH_SPEC_WDA
ARCH_SPEC_WDA=libwda

extpkg := libwda

ifndef LIBWDA_DIR
	arch_spec_warning:=\
	"Using default value LIBWDA_DIR = $(EXTERNALS)/libwda"
	LIBWDA_DIR = $(EXTERNALS)/libwda
endif
ifndef LIBWDA_INC
	LIBWDA_INC = $(LIBWDA_FQ_DIR)/include
endif
ifndef LIBWDA_LIB
	LIBWDA_LIB = $(LIBWDA_DIR)/lib
endif

LIBWDA_LIBES = -lwda

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS := -I$(LIBWDA_INC) $(CPPFLAGS)
override LDFLAGS  := -L$(LIBWDA_LIB) $(LDFLAGS)
override BINLIBS  += $(LIBWDA_LIBES)

endif
