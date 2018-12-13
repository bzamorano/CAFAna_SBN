ifndef ARCH_SPEC_POSTGRESQL
ARCH_SPEC_POSTGRESQL=postgresql

extpkg := postgresql

ifndef POSTGRESQL_DIR
	arch_spec_warning:=\
	"Using default value POSTGRESQL_DIR = $(EXTERNALS)/postgresql"
	POSTGRESQL_DIR = $(EXTERNALS)/postgresql
endif
ifndef POSTGRESQL_INC
	POSTGRESQL_INC = $(POSTGRESQL_FQ_DIR)/include
endif
ifndef POSTGRESQL_LIB
	POSTGRESQL_LIB = $(POSTGRESQL_FQ_DIR)/lib
endif

POSTGRESQL_LIBES = -lpq

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS := -I$(POSTGRESQL_INC) $(CPPFLAGS)
override LDFLAGS  := -L$(POSTGRESQL_LIB) $(LDFLAGS)
override BINLIBS  += $(POSTGRESQL_LIBES)

endif
