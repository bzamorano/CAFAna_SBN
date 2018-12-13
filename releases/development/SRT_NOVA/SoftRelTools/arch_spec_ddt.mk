# 
#   Generic DDT makefile
#   in order to use Online UPS products
#
#   G. Davies September 7th 2012
#
#
ifndef ARCH_SPEC_DDT
ARCH_SPEC_DDT=ddt

extpkg := ddt

#DDT_LIBES = -lDAQChannelMap -lDAQDataFormats -lPackageVersion
DDT_LIBES = -lDDTBaseDataProducts -lPackageVersion

include SoftRelTools/specialize_arch_spec.mk

DDTBASE_INC=/grid/fermiapp/nova/novaddt/releases/development/include/DDTBaseDataProducts
DDTBASE_LIB=/grid/fermiapp/nova/novaddt/releases/development/lib/Linux2.6-GCC-debug

#override CPPFLAGS := -I$(DAQCHANNELMAP_INC) -I$(DAQDATAFORMATS_INC) -I$(PACKAGEVERSION_INC) $(CPPFLAGS)
#override LDFLAGS  := -L$(DAQCHANNELMAP_LIB) -L$(DAQDATAFORMATS_LIB) -L$(PACKAGEVERSION_LIB) $(LDFLAGS)
override CPPFLAGS := -I$(DDTBASE_INC) -I$(PACKAGEVERSION_INC) $(CPPFLAGS)
override LDFLAGS  := -L$(DDTBASE_LIB) -L$(PACKAGEVERSION_LIB) $(LDFLAGS)
override BINLIBS  += $(DDT_LIBES)

endif
