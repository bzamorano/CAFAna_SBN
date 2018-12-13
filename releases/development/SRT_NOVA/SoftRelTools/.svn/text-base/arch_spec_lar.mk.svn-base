#=======================================================================
#
#  arch_spec_nova.mk:
#
# Define LAR-specific build environment
#

override CPPFLAGS += -DLAR_RELEASE=\"$(SRT_BASE_RELEASE)-$(USER)\"

#=======================================================================
# Provide a mechanism to install XML files into standard locations
#
ifndef XML_DIR
  XML_DIR = $(SRT_PRIVATE_CONTEXT)/xml/
endif

ifdef XMLFILES
  XML_dest = $(foreach v, $(XMLFILES),$(XML_DIR)$v)	
  SRT_PRODUCTS += $(XML_dest)
endif

$(filter $(XML_DIR)%, $(XML_dest)): $(XML_DIR)% : %

LAR_flags = -W -Wall -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -fno-strict-aliasing

override CXXFLAGS += -ansi $(LAR_flags)
override CPPFLAGS += $(LAR_flags)
override CFLAGS   += -ansi $(LAR_flags)


#ifndef NO_OPTIMIZE
ifeq ($(findstring debug,$(SRT_QUAL)),debug)
  override CXXFLAGS += -g -O0 -Wall
  override CPPFLAGS += -g -O0 -Wall
  override CFLAGS   += -g -O0 -Wall
  override LDFLAGS  += -g -O0
endif

codegen: xml 

clean: cleanxml

xml: $(XML_dest) 

#$(foreach v,$(SUBDIRS),$v.xml)

$(XML_dest):
	if [ ! -d $(XML_DIR) ]; then mkdir $(XML_DIR); fi
	@echo "<**installing XML file**> $(@F)"
	$(TRACE)rm -f $@
	$(TRACE)cp $< $@

#%.xml:
#	$(TRACE)$(pass-to-subdirs)

cleanxml:
	if [ ! -d $(XML_DIR) ]; then mkdir $(XML_DIR); fi
	$(TRACE)rm -f $@

#=======================================================================
