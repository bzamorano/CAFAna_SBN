override CPPFLAGS += -I$(ARTDAQ_CORE_INC) -I$(TRACE_INC)
override LDFLAGS += -L$(ARTDAQ_CORE_LIB)

include SoftRelTools/arch_spec_art.mk
