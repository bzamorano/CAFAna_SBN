#=======================================================================
#
#  arch_spec_art.mk:
#
# Define ART-specific build environment
#

#=======================================================================
# Provide a mechanism to install job control files into standard locations
#
ifndef JOB_DIR
  JOB_DIR = $(SRT_PRIVATE_CONTEXT)/job/
endif

ifdef JOBFILES
  JOB_dest = $(foreach v, $(JOBFILES),$(JOB_DIR)$v)	
  SRT_PRODUCTS += $(JOB_dest)
endif

$(filter $(JOB_DIR)%, $(JOB_dest)): $(JOB_DIR)% : %

override CFLAGS += -fPIC
override CXXFLAGS += -fPIC

override CPPFLAGS += -I$(ART_INC)
override CPPFLAGS += -I$(BOOST_INC)
override CPPFLAGS += -I$(CANVAS_INC)
override CPPFLAGS += -I$(CLHEP_INC)
# override CPPFLAGS += -I$(CPPUNIT_INC)
override CPPFLAGS += -I$(MESSAGEFACILITY_INC)
override CPPFLAGS += -I$(FHICLCPP_INC)
override CPPFLAGS += -I$(CETLIB_INC)
override CPPFLAGS += -I$(CETLIB_EXCEPT_INC)
override CPPFLAGS += -I$(BOOST_INC)
override CPPFLAGS += -I$(SQLITE_INC)
override CPPFLAGS += -I$(TBB_INC)
override LOADLIBES  += -L$(ART_LIB)
override LOADLIBES  += -L$(CANVAS_LIB)
override LOADLIBES  += -L$(CLHEP_BASE)/lib
# override LOADLIBES  += -L$(CPPUNIT_LIB)
override LOADLIBES  += -L$(MESSAGEFACILITY_LIB)
override LOADLIBES  += -L$(FHICLCPP_LIB)
override LOADLIBES  += -L$(CETLIB_LIB)
override LOADLIBES  += -L$(CETLIB_EXCEPT_LIB)
override LOADLIBES  += -L$(BOOST_LIB)
override LOADLIBES  += -L$(SQLITE_LIB)
override LOADLIBES  += -L$(TBB_LIB)

ART_EXEC_LIBS := \
-lcanvas \
-lart_Framework_Art \
-lboost_program_options \
-lart_Framework_Services_System_CurrentModule_service \
-lart_Framework_Services_System_FloatingPointControl_service \
-lart_Framework_Services_System_TriggerNamesService_service \
-lart_Framework_Services_Optional_RandomNumberGenerator_service \
-lPhysics \
-lGraf \
-lTree \
-lHist \
-lMatrix \
-lNet \
-lMathCore \
-lRIO \
-lThread \
-lCore \
-ldl

codegen: job 

clean: cleanjob

job: $(JOB_dest) 

#$(foreach v,$(SUBDIRS),$v.py)

$(JOB_dest):
	if [ ! -d $(JOB_DIR) ]; then mkdir -p $(JOB_DIR); fi
	@echo "<**installing JOB file**> $(@F)"
	$(TRACE)rm -f $@
	$(TRACE)cp $< $@

#%.xml:
#	$(TRACE)$(pass-to-subdirs)

cleanjob:
	if [ ! -d $(JOB_DIR) ]; then mkdir -p $(JOB_DIR); fi
	$(TRACE)rm -f $@

#=======================================================================
