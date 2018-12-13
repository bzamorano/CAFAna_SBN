#=======================================================================
#
#  arch_spec_novadaq.mk:
#
# Necessary to compile/run against novadaq code
# 
#
ifneq (,$(NOVADAQ_INC))
  override CPPFLAGS += -I$(NOVADAQ_INC)
  override LOADLIBES += -L$(NOVADAQ_LIB)
else
	override LOADLIBES += -L$(SRT_PRIVATE_CONTEXT)/lib/$(SRT_SUBDIR) -L$(SRT_PUBLIC_CONTEXT)/lib/$(SRT_SUBDIR)
endif
