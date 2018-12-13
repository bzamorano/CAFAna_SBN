# avoid double-inclusion
ifndef ARCH_SPEC_XERCESC_NOVADAQ
ARCH_SPEC_XERCESC_NOVADAQ=xercesc_novadaq

#=======================================================================
#
#  arch_spec_xercesc_novadaq.mk:
#
#  architecture/site specific makefile fragment for clients of
#  Xerces-c XML interface
#

override CPPFLAGS := -I${XERCESCROOT}/include $(CPPFLAGS)
override LDFLAGS  := -L${XERCESCROOT}/lib $(LDFLAGS)
override BINLIBS  += -lxerces-c

ifneq "$(findstring LinuxPPC, $(SRT_ARCH))" ""
  # only for PPC
  include SoftRelTools/arch_spec_icu4c.mk
endif

#=======================================================================

endif
