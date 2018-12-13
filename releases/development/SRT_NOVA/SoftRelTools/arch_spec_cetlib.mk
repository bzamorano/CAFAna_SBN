# arch_spec_cetlib.mk
#
# Definitions used for building libraries and applications that use CETLIB
#

extpkg := cetlib_shared

CETLIB_LIBS=-lcetlib

include SoftRelTools/arch_spec_boost.mk

override CPPFLAGS := -I${CETLIB_INC} -I${CETLIB_EXCEPT_INC} $(CPPFLAGS)
override LDFLAGS  := -L${CETLIB_LIB} -I${CETLIB_EXCEPT_LIB} $(LDFLAGS)
override BINLIBS  += $(CETLIB_LIBS)
