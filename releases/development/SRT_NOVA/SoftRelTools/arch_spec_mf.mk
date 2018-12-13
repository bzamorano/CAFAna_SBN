# arch_spec_mf.mk
#
# Definitions used for building libraries and applications that use
# the Message Facility.
#

extpkg := mf_shared

MF_LIBS=-lfhiclcpp -lcetlib -lcetlib_except

include SoftRelTools/arch_spec_boost.mk

override CPPFLAGS := -I$(MESSAGEFACILITY_INC) -I$(FHICLCPP_INC) -I${CETLIB_INC} -I${CETLIB_EXCEPT_INC} $(CPPFLAGS)
override LDFLAGS  := -L$(MESSAGEFACILITY_LIB) -L$(FHICLCPP_LIB) -L${CETLIB_LIB} -L${CETLIB_EXCEPT_LIB} $(LDFLAGS)
override BINLIBS  += $(MF_LIBS)
