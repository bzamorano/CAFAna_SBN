# avoid double-inclusion
ifndef ARCH_SPEC_CPPUNIT
ARCH_SPEC_CPPUNIT=cppunit

# arch_spec_cppunit.mk
#
# Support for use of the cppunit library
#

extpkg := cppunit

CPPUNIT_LIBS = -lcppunit -ldl

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS := -I$(CPPUNIT_DIR)/include $(CPPFLAGS)
override LDFLAGS  := -L$(CPPUNIT_DIR)/lib $(LDFLAGS)
override BINLIBS  += $(CPPUNIT_LIBS)

# 07-Oct-2009, KAB - specify that the whole CPPUNIT library archive
# should be linked in.  This relies on the LIB variable containing the
# library that has the CPPUNIT tests.
ifneq "$(strip $(LIB))" ""
    override LDFLAGS  := -Wl,--whole-archive $(libdir)/$(LIB).a \
                         -Wl,--no-whole-archive $(LDFLAGS)
endif

endif
