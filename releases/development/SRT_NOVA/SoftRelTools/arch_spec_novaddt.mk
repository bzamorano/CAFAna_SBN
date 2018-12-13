#=======================================================================
#
#  arch_spec_novaddt.mk:
#
# Necessary to compile/run against novaddt code
# 
#
ifneq (,$(NOVADDT_INC))
  override CPPFLAGS += -I$(NOVADDT_INC)
  override LDFLAGS  += -L$(NOVADDT_LIB)
endif
