## avoid double-inclusion
ifndef ARCH_SPEC_CURL
ARCH_SPEC_CURL=curl

# arch_spec_curl.mk
#
# Definitions used for building libraries and applications that use
# CURL
#

extpkg := curl

CURL_LIBES = -lcurl

ifneq (,$(CURL_INC))
override CPPFLAGS := -I$(CURL_INC) ${CPPFLAGS}
override LDFLAGS  := -L$(CURL_LIB) ${LDFLAGS}
endif

override BINLIBS  += $(CURL_LIBES)

endif
