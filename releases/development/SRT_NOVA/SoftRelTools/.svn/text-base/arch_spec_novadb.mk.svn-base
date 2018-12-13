# avoid double-inclusion
ifndef ARCH_SPEC_NOVADATABASE
ARCH_SPEC_NOVADATABASE=novadatabase

#
# arch_spec_novadb.mk
#
# Definitions for using the NovaDatabase package
#

extpkg := NovaDatabase Database

override BINLIBS += -lNovaDatabase -lNovaDAQUtilities -lcurl

include SoftRelTools/arch_spec_boost.mk
include SoftRelTools/cstxsd.mk
include SoftRelTools/arch_spec_pgsql.mk
include SoftRelTools/arch_spec_wda.mk
#include SoftRelTools/arch_spec_xercesc_novadaq.mk

endif
