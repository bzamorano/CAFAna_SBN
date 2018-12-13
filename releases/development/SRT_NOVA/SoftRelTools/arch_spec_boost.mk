# avoid double-inclusion
ifndef ARCH_SPEC_BOOST
ARCH_SPEC_BOOST=boost

# arch_spec_boost.mk
#
# novadaq-specific version (this version differs from the NOvA offline [SRT_NOVA]
# version in that it uses the newer BINLIBS variable for specifying libraries
# rather than the older LOADLIBES - this is needed for the online to consistently
# specify libraries) 
#
# Support for use of the boost library
# http://www.boost.org
#
# This file must be included *before* standard.mk
#

extpkg := boost
BOOST_DIR_DEFAULT := /usr/local

ifndef BOOST_DIR
	arch_spec_warning:=\
	"Using default value BOOST_DIR = $(BOOST_DIR_DEFAULT)"
	BOOST_DIR = $(BOOST_DIR_DEFAULT)
endif
ifndef BOOST_INC
	BOOST_INC = $(BOOST_DIR)/boost
endif
ifndef BOOST_LIB
	BOOST_LIB = $(BOOST_DIR)/lib
endif


# It would be nice to pick up debug or optimized by default
#BOOST_LIBES = -lboost_regex -lboost_date_time-mt-d -lboost_thread-mt-d -lboost_filesystem-mt-d -lboost_system-mt-d
BOOST_LIBES = -lboost_regex -lboost_date_time -lboost_thread -lboost_filesystem -lboost_system -lboost_program_options

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS := -I$(BOOST_INC) $(CPPFLAGS)
override LDFLAGS  := -L$(BOOST_LIB) $(LDFLAGS)
override BINLIBS  += $(BOOST_LIBES)
override LIBLIBS  += -L$(BOOST_LIB) -lboost_thread

endif
