#=======================================================================
#
#  pre_standard.mk:
#
#  Define ART-specific build environment
#  For specializations included by SoftRelTools/include/standard.mk

#=======================================================================
#if we have the genreflex source file, we add what it makes to 
# the "codegen" target
#=======================================================================

ifneq (,$(wildcard classes_def.xml))

  MWM_CLASSES_DEF_GEN= $(PACKAGE)_dict.cc
  codegen: $(MWM_CLASSES_DEF_GEN)

   $(MWM_CLASSES_DEF_GEN): classes_def.xml
	$(TRACE)genreflex classes.h -l $(shlibdir)lib$(PACKAGE)_dict.so \
  --noIncludePaths \
  --rootmap-lib=lib$(PACKAGE)_dict.so \
  --rootmap=$(shlibdir)lib$(PACKAGE)_dict.rootmap \
  -s classes_def.xml -o $(PACKAGE)_dict.cc $(CPPFLAGS) --fail_on_warnings

  SRT_PRODUCTS += $(MWM_CLASSES_DEF_GEN)
endif

#=======================================================================
#if we have _plugin  source files, we add an extra .so to the dependencies of the lib target.
#=======================================================================

PLUGINSRC=$(sort $(wildcard *_dict.cc *_module.cc *_plugin.cc *_service.cc *_source.cc) $(MWM_CLASSES_DEF_GEN))


ifneq (,$(PLUGINSRC))
  PLUGINOBJ=$(addprefix $(shlibdir),$(addsuffix .o,$(basename $(PLUGINSRC))))
  SRT_PRODUCTS += $(PLUGINOBJ)
  PLUGINLIB=$(addprefix $(shlibdir)lib,$(addsuffix .so,$(basename $(PLUGINSRC))))
  SRT_PRODUCTS += $(PLUGINLIB) #$(warning Plugin library base $(PLUGINSRC) for $(PLUGINLIB) found)
#  $(warning $(LIBLIBS) is LIBLIBS)

  lib%_dict.so : %_dict.o
	@echo "<**linking**> $(@F)"
	$(TRACE)$(SHAREDAR) $(SHAREDARFLAGS) $(SHAREDAROFLAG) $@ $<  $(LIBLINK) $(LIBLIBS)

  $(tmpdir)checked_lib%_dict.so.stamp : lib%_dict.so
	@echo "<**checking class version numbers**> $(<F)"
	$(TRACE)checkClassVersion -G -l lib$(PACKAGE)_dict -x classes_def.xml && touch "$(@)"

  lib%_module.so : %_module.o
	@echo "<**linking**> $(@F)"
	$(TRACE)$(SHAREDAR) $(SHAREDARFLAGS) $(SHAREDAROFLAG) $@ $<  $(LIBLINK) $(LIBLIBS)

  lib%_service.so : %_service.o
	@echo "<**linking**> $(@F)"
	$(TRACE)$(SHAREDAR) $(SHAREDARFLAGS) $(SHAREDAROFLAG) $@ $<  $(LIBLINK) $(LIBLIBS)

  lib%_plugin.so : %_plugin.o
	@echo "<**linking**> $(@F)"
	$(TRACE)$(SHAREDAR) $(SHAREDARFLAGS) $(SHAREDAROFLAG) $@ $<  $(LIBLINK) $(LIBLIBS)

  lib%_source.so : %_source.o
	@echo "<**linking**> $(@F)"
	$(TRACE)$(SHAREDAR) $(SHAREDARFLAGS) $(SHAREDAROFLAG) $@ $<  $(LIBLINK) $(LIBLIBS)

  libobjects: $(PLUGINOBJ)

  lib: $(PLUGINLIB) #$(warning Saw plugin sources.. $(PLUGINSRC))

  all: lib

  lib: $(sharedlib_o_dir)
	mkdir -p $(sharedlib_o_dir)

  all: checkdicts

  checkdicts: $(foreach d, $(filter %_dict.so,$(PLUGINLIB)),$(tmpdir)checked_$(notdir $(d)).stamp)

else

all: checkdicts
checkdicts: checkdirs $(foreach v,$(SUBDIRS),$v.checkdicts)
%.checkdicts:
	$(TRACE)$(pass-to-subdirs)

endif
#=======================================================================
