#=======================================================================
#
#  arch_spec_xgboost.mk:
#
# architecture/site specific makefile fragment for clients of xgboost
# optimized distributed gradient boosting library
#
# For information about xgboost see https://xgboost.readthedocs.org/
#

override CPPFLAGS += -I${XGBOOST_INC}
override LDFLAGS  += -L${XGBOOST_LIB} -lxgboost

override LOADLIBES += -L$(XGBOOST_LIB)

#=======================================================================
