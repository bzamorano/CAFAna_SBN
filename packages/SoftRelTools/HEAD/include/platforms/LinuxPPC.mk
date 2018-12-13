SHAREDEXT:=.so
STATICEXT:=.a

DATAREP  = -DDATAREP_BIG_IEEE -DDATAREP_BIG_ENDIAN

override DEFINES += -DUNIX -DLINUX
override DEFECTS += -DDEFECT_RECL_WORDS

# Fortran
FC=g77
FPP=$(FC)

FCFLAGS += -fdollar-ok -fno-automatic  
FCFLAGS += -fno-second-underscore -ffixed-line-length-132 
FCFLAGS += -fno-globals  -w
FCFLAGS += -fdebug-kludge
FCFLAGS += -DFORTRAN -DLANGUAGE_FORTRAN

FCPPFLAGS += -C -P -DLinux -DUNIX
FCPPFLAGS += -DFORTRAN -DLANGUAGE_FORTRAN

FCPICFLAG =
FCPPMFLAGS=-x none

# Support for various qualifiers

ifeq ($(findstring default,$(SRT_QUAL)),default)
    override FCFLAGS += -g
endif

ifeq ($(findstring debug,$(SRT_QUAL)),debug)
    override FCFLAGS += -g
endif

ifeq ($(findstring maxopt,$(SRT_QUAL)),maxopt)
    override FCFLAGS += -O2
endif

-include SRT_$(SRT_PROJECT)/special/platforms/LinuxPPC.mk
-include SRT_SITE/special/platforms/LinuxPPC.mk
