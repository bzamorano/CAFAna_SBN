#
# doxygen.mk
#
# Rules for generating Doxygen documentation.
#
# The variables that are used in this file, but need to be defined outside
# of this file, are listed here.
#
# Variables that should be defined in arch_spec_doxygen.mk (or its children)
# (of course, these variables can be overridden elsewhere):
# - DOXYGEN_APP - the application that generates the documentation
#
# Variables that should be defined in the makefile that includes this file:
# - DOXYGEN_CONFIG_FILE - the configuration file that should be passed to Doxygen
# - DOXYGEN_OUT_DIR - the directory where the generated documentation should be placed
# - DOXYGEN_PREREQ - the prerequisite(s) to use for (re)generating the documentation
#

# limit the generation of doxygen docs in test releases to only those
# that explicitly request it
gen_doxy_docs = no
ifeq "$(SRT_PRIVATE_CONTEXT)" "."
    gen_doxy_docs = yes
endif
ifeq "$(SRT_PRIVATE_CONTEXT)" "$(SRT_PUBLIC_CONTEXT)"
    gen_doxy_docs = yes
endif
ifneq "$(GENERATE_DOXYGEN_DOCS)" ""
    gen_doxy_docs = yes
endif

# skip generation if the config file can't be found
ifeq "$(gen_doxy_docs)" "yes"
    found_file = $(wildcard $(DOXYGEN_CONFIG_FILE))
    ifeq "$(found_file)" ""
        gen_doxy_docs = no
    endif
endif

# documentation generation rules
$(DOXYGEN_OUT_DIR) : $(DOXYGEN_PREREQ)
    ifeq "$(gen_doxy_docs)" "yes"
	@echo "<**generating Doxygen documentation**> $(notdir $(DOXYGEN_CONFIG_FILE))"
	$(check_dep_dir)
	$(shell sed "s|^\s*OUTPUT_DIRECTORY\s*\=\s*.*$$|OUTPUT_DIRECTORY = $(DOXYGEN_OUT_DIR)|g" $(DOXYGEN_CONFIG_FILE) > $(workdir)/doxy_temp.conf)
	$(DOXYGEN_APP) $(workdir)/doxy_temp.conf
    endif

.PHONY : doxygen_docs
doxygen_docs : $(DOXYGEN_OUT_DIR)

# cleanup rule
.PHONY : doxygen_clean
doxygen_clean:
    ifeq "$(gen_doxy_docs)" "yes"
	-rm -rf $(DOXYGEN_OUT_DIR)
    endif

# add the local rules to the normal build cycle - only for x86, non-opt
ifeq "$(findstring LinuxPPC, $(SRT_ARCH))" ""
ifeq "$(findstring default, $(SRT_QUAL))" "default"
doc : doxygen_docs
clean : doxygen_clean
endif
endif

# include the environment variables for Doxygen
include SoftRelTools/arch_spec_doxygen.mk
