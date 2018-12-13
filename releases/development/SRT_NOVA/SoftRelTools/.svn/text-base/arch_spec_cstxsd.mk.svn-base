# avoid double-inclusion
ifndef ARCH_SPEC_CSTXSD
ARCH_SPEC_CSTXSD=cstxsd

#
# arch_spec_cstxsd.mk
#
# Definitions used when generating C++ classes from XML schema definitions
# using the CodeSynthesis XSD package.
#

extpkg := cstxsd

CSTXSD_COMPILE  := $(CSTXSD_FQ_DIR)/bin/xsd
CSTXSD_COMPILE_OPTIONS := cxx-tree --generate-serialization \
	--generate-default-ctor --hxx-suffix .h --cxx-suffix .cpp --std c++11 \
	--include-with-brackets --root-element-all --output-dir $(CSTXSD_SRC_DIR)
ifneq "$(strip $(CSTXSD_INC_PREFIX))" ""
    CSTXSD_COMPILE_OPTIONS += --include-prefix $(CSTXSD_INC_PREFIX)/
endif
ifneq "$(strip $(CSTXSD_NAMESPACE))" ""
    CSTXSD_COMPILE_OPTIONS += --namespace-map ""=$(CSTXSD_NAMESPACE)
endif
ifneq "$(strip $(CSTXSD_EXTRA_OPTIONS))" ""
    CSTXSD_COMPILE_OPTIONS += $(CSTXSD_EXTRA_OPTIONS)
endif

ifneq "$(SRT_PRIVATE_CONTEXT)" "."
    CSTXSD_TAILOR := $(firstword $(wildcard $(SRT_PRIVATE_CONTEXT)/NovaDAQUtilities/tools/tailorXsdGeneratedClassesForNova.pl $(SRT_PUBLIC_CONTEXT)/bin/tailorXsdGeneratedClassesForNova.pl))
else
    CSTXSD_TAILOR := $(SRT_PUBLIC_CONTEXT)/bin/tailorXsdGeneratedClassesForNova.pl
endif

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS += -I$(CSTXSD_FQ_DIR)/include

endif
