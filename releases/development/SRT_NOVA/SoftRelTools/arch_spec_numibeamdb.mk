#=======================================================================
#
#  arch_spec_numibeamdb.mk:
#
# architecture/site specific makefile fragment for clients of NumiBeamDB
# access to MINOS beam data database
#
ifdef NUMIBEAMDB_VERSION

ifneq (,$(findstring v0_0_1,$(NUMIBEAMDB_VERSION)))
  # first version of package has MINOS subpkg name
  # but this causes conflicts with GENIE
  REGISTRYLIB:=Registry
else
  REGISTRYLIB:=MinosRegistry
endif

NUMIBEAMLIBS=-lConventions -lMessageService -lValidity -lUtil -l$(REGISTRYLIB) -lConfigurable -lMinosRawData -lOnlineUtil -lDatabaseInterface -lBeamDataUtil

override CPPFLAGS  += -I$(NUMIBEAMDB_INC) -DNUMIBEAMDB
override LDFLAGS   += -L$(NUMIBEAMDB_FQ_DIR)/lib $(NUMIBEAMLIBS)

override LOADLIBES += -L$(NUMIBEAMDB_FQ_DIR)/lib $(NUMIBEAMLIBS)

#$(warning $(NUMIBEAMLIBS) are NumiBeamDB libs to be loaded)

else

$(warning NUMIBEAMDB_VERSION not defined, NumiBeamDB package not available)

endif

#=======================================================================
