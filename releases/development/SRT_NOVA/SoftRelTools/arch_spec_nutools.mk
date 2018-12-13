#=======================================================================
#
#  arch_spec_nutools.mk:
#
# Necessary to compile/run against nutools code
# 
#

override CPPFLAGS += -I$(NUTOOLS_INC) -I$(NUSIMDATA_INC)
override LOADLIBES += -L$(NUTOOLS_LIB) -L$(NUSIMDATA_LIB)
