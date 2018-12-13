# Darwin.mk for MacOSX

CPP:= g++
CXX:= g++
CC:= gcc
AR:= ar
SHAREDAR:=g++

SHAREDEXT:=.dylib
BUNDLEEXT:=.so
STATICEXT:=.a

# Tell make what -lfoo means for shared libraries.
# The colon is a shell no-op.
# Overrides definition in standard.mk to replace ".so" with ".dylib"

-l%: lib%$(SHAREDEXT)
	:

-u %:
	:

DATAREP  = -DDATAREP_BIG_IEEE -DDATAREP_BIG_ENDIAN

override DEFINES += -DUNIX -DMACOSX
override DEFINES += -D__UNIX__ -D__MACOSX__

override CPPFLAGS += -DHAVE_LONG_LONG # -no-cpp-precomp
override CXXFLAGS += -fno-common -pipe

override PICFLAG = -fPIC
override ARFLAGS = -rs

override SOFLAGS += -dynamiclib -flat_namespace -undefined suppress
override LDFLAGS += -Xlinker -bind_at_load -flat_namespace

override SHAREDARFLAGS = $(SOFLAGS)            # Used to link .dylib (shared lib)
override BUNDLEARFLAGS = -bundle -undefined suppress -Wl,-x $(LDFLAGS) # .so lib

override SHAREDAROFLAG = -o # Need blank after -o
override BUNDLEAROFLAG = -o # Need blank after -o

override DEFINES += -DUNIX -DMACOSX
override DEFINES += -D__UNIX__ -D__MACOSX__

INLINE_DEP_CAPABLE = no

# Find this in the GCC documentation. I dare you.
INLINE_DEP      = -Wp,-MD,$(dir $@)/$(basename $(notdir $<)).d
STANDALONE_DEP  = -M $< > $(dir $@)/$(basename $(notdir $<)).d
CSTANDALONE_DEP = $(STANDALONE_DEP)

override DEFECTS += -DDEFECT_NO_IOSTREAM_NAMESPACES

# Fortran
FC=g77
FPP=$(FC)
FCFLAGS += -fdollar-ok -fno-automatic  
FCFLAGS += -fno-second-underscore -ffixed-line-length-132 
FCFLAGS += -fno-globals  -w
FCFLAGS += -fdebug-kludge
FCFLAGS += -DFORTRAN -DLANGUAGE_FORTRAN

FCPPFLAGS += -C -P -DUNIX -DMACOSX
FCPPFLAGS += -DFORTRAN -DLANGUAGE_FORTRAN

FCPICFLAG  =
FCPPMFLAGS = -x none

# From arch_spec.mk
define build_mach_bundle
cd $(sharedlib_o_dir) ; \
$(SHAREDAR) $(BUNDLEARFLAGS) $(BUNDLEAROFLAG) \
            $(SHAREDLIB:$(SHAREDEXT)=$(BUNDLEEXT)) \
            $(actual_sharedlib_files) $(LIBLIBS) ;
endef

# Support for various qualifiers

ifeq ($(findstring default,$(SRT_QUAL)),default)
    override CXXFLAGS += -g
    override CCFLAGS += -g
    override FCFLAGS += -g
    override SHAREDARFLAGS += -g
    override BUNDLEARFLAGS += -g
endif

ifeq ($(findstring noopt,$(SRT_QUAL)),noopt)
    override CXXFLAGS += -O0
    override CCFLAGS += -O0
    override FCFLAGS += -O0
endif

ifeq ($(findstring debug,$(SRT_QUAL)),debug)
    override CXXFLAGS += -g
    override CCFLAGS += -g
    override FCFLAGS += -g
    override SHAREDARFLAGS += -g
    override BUNDLEARFLAGS += -g
endif

ifeq ($(findstring maxopt,$(SRT_QUAL)),maxopt)
    override CXXFLAGS += -O2
    override CCFLAGS += -O2
    override FCFLAGS += -O2
endif

-include SRT_$(SRT_PROJECT)/special/platforms/Darwin.mk
-include SRT_SITE/special/platforms/Darwin.mk
