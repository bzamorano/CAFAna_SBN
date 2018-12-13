#
# cstxsd.mk
#
# Rules for generating C++ classes from XML schema definitions using
# the CodeSynthesis XSD package.
#
# The variables that are used in this file, but need to be defined outside
# of this file, are listed here.
#
# Variables that *should* be defined in arch_spec_cstxsd.mk (or its children)
# (of course, these variables can be overridden elsewhere):
# - CSTXSD_COMPILE - the application that generates the classes from the XSD files
# - CSTXSD_COMPILE_OPTIONS - the options that should be passed to the "compiler"
# - CSTXSD_TAILOR - the script that tailors the generated files for local use
#
# Variables that *should* be defined in the makefile that includes this file:
# - CSTXSD_XSD_DIR - the directory that contains XML schema definition files
# - CSTXSD_XSD_FILES - the list of XML Schema Definition files that should be
#                      used to create message classes (including paths)
# - CSTXSD_INC_PREFIX - the prefix that should be used to include the
#                       generated header file in the generated source file
# - CSTXSD_INC_DIR - the directory where the generated header files should be placed
# - CSTXSD_SRC_DIR - the directory where the generated source files should be placed
#
# Variables that *can* be defined in the makefile that includes this file:
# - CSTXSD_NAMESPACE - the namespace that should be used for the generated classes
# - CSTXSD_EXTRA_OPTIONS - any options that need to be passed to the XSD
#                          compiler but are not covered by other variables.
# - CSTXSD_TAILOR_INC_OPTIONS - the options to be passed to the "tailor" script
#                               for the header files, if any.  If this variable is
#                               not set and the CSTXSD_RUN_TAILOR_SCRIPT described
#                               below is not set, then no tailoring of header
#                               files will take place.
# - CSTXSD_TAILOR_SRC_OPTIONS - the options to be passed to the "tailor" script
#                               for the source files, if any.  If this variable is
#                               not set and the CSTXSD_RUN_TAILOR_SCRIPT described
#                               below is not set, then no tailoring of source
#                               files will take place.
# - CSTXSD_RUN_TAILOR_SCRIPT - a flag to indicate that the tailor script should
#                              be run on header and source files even though no
#                              header- or source-specific options are needed.  
#                              Setting this variable to any non-empty value
#                              enables the tailoring.
# Just a short note on tailoring:  as of cstXSD 3.2.0, the local "tailoring"
# that we support for the C++ code that CodeSynthesis XSD generates is the
# addition of some accessor methods, addition of inheritance from a common base
# class, addition of convenience methods for serialization and deserialization,
# and addition of warning messages when class instances are serialized but some
# of the non-optional elements have not been specified.
#

# declare the "all" target so that when this file appears before standard.mk
# in a GNUmakefile, the "all" target is still the first one declared
.PHONY : all
all :

# determine how much tailoring to do
cstxsd_do_inc_tailoring = 0
cstxsd_do_src_tailoring = 0
ifdef CSTXSD_RUN_TAILOR_SCRIPT
  cstxsd_do_inc_tailoring = 1
  cstxsd_do_src_tailoring = 1
else
  ifdef CSTXSD_TAILOR_INC_OPTIONS
    cstxsd_do_inc_tailoring = 1
  endif
  ifdef CSTXSD_TAILOR_SRC_OPTIONS
    cstxsd_do_src_tailoring = 1
  endif
endif

# build the list of generated header and source files
cstxsd_hdr_files := $(subst $(CSTXSD_XSD_DIR),$(CSTXSD_INC_DIR),\
	$(subst .xsd,.h,$(CSTXSD_XSD_FILES)))
cstxsd_src_files := $(subst $(CSTXSD_XSD_DIR),$(CSTXSD_SRC_DIR),\
	$(subst .xsd,.cpp,$(CSTXSD_XSD_FILES)))

# code generation rules
$(cstxsd_src_files) : $(CSTXSD_SRC_DIR)/%.cpp : $(CSTXSD_XSD_DIR)/%.xsd
	@echo "<**generating CST XSD class**> $(<F)"
	$(TRACE)$(CSTXSD_COMPILE) $(CSTXSD_COMPILE_OPTIONS) $<
ifneq "$(CSTXSD_INC_DIR)" "."
  ifneq "$(CSTXSD_INC_DIR)" "./"
	@echo "<**relocating CST XSD header**> $(subst .xsd,.h,$(<F))"
	if [ ! -d $(CSTXSD_INC_DIR) ]; then mkdir $(CSTXSD_INC_DIR); fi
	@mv $(CSTXSD_SRC_DIR)/$(subst .xsd,.h,$(notdir $<)) $(CSTXSD_INC_DIR)
  endif
endif
ifeq ($(cstxsd_do_inc_tailoring), 1)
	@echo "<**tailoring CST XSD header**> $(subst .xsd,.h,$(<F))"
	$(TRACE)$(CSTXSD_TAILOR) $(CSTXSD_TAILOR_INC_OPTIONS) \
	    $(CSTXSD_INC_DIR)/$(subst .xsd,.h,$(notdir $<))
endif
ifeq ($(cstxsd_do_src_tailoring), 1)
	@echo "<**tailoring CST XSD source file**> $(notdir $@)"
	$(TRACE)$(CSTXSD_TAILOR) $(CSTXSD_TAILOR_SRC_OPTIONS) $@
endif

.PHONY : codegen_cstxsd
codegen_cstxsd : $(cstxsd_src_files)

# cleanup rule
.PHONY : clean_cstxsd
clean_cstxsd:
	-rm -f $(cstxsd_hdr_files)
	-rm -f $(addsuffix .orig,$(cstxsd_hdr_files))
	-rm -f $(cstxsd_src_files)
	-rm -f $(addsuffix .orig,$(cstxsd_src_files))

# add the local rules to the normal build cycle
codegen: codegen_cstxsd
clean: clean_cstxsd

# include the environment variables for CST XSD
include SoftRelTools/arch_spec_cstxsd.mk

# include the xercesc arch_spec file as a convenience
include SoftRelTools/arch_spec_xercesc_novadaq.mk

# include the NovaDAQUtilities library as a convenience (needed when
# the package makefile has requested tailoring)
override BINLIBS += -lNovaDAQUtilities

# include the generated cpp files in the list of files to be compiled
LIBCPPFILES += $(cstxsd_src_files)
