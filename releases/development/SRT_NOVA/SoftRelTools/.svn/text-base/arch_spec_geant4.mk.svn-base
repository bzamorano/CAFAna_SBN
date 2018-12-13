#=======================================================================
#
# arch_spec_geant4.mk:
#
# architecture/site specific makefile fragment for clients of the
# geant4 detector simulation and particle transport libraries.
# This expects to find the variables used by GEANT4 during its build
# which can ge setup with a command like:
#
# % source /usr/local/geant4/4.9.2/env.csh
#
#
# For information about geant4 see http://cern.ch/geant4
#

override CPPFLAGS += -I${G4INCLUDE} 

#
# User interface flags from the environment
#
  override CPPFLAGS += -DG4UI_USE 
  override CPPFLAGS += -DG4UI_USE_TCSH 
  override CPPFLAGS += -DG4UI_USE_XM 
##  override CPPFLAGS += -DG4UI_USE_XAW 

  override CPPFLAGS += -DG4VERBOSE 

#
# Visualization options from the environment
#
# should not be using these unless you have a geant4 with these turned on!!!
##  override CPPFLAGS += -DG4VIS_USE
##  override CPPFLAGS += -DG4VIS_USE_DAWNFILE 
##  override CPPFLAGS += -DG4VIS_USE_HEPREPFILE 
##  override CPPFLAGS += -DG4VIS_USE_OPENGLX 
##  override CPPFLAGS += -DG4VIS_USE_OPENGLXM 
##  override CPPFLAGS += -DG4VIS_USE_OPENGL 
##  override CPPFLAGS += -DG4VIS_USE_RAYTRACER 
##  override CPPFLAGS += -DG4VIS_USE_VRMLFILE 
##  override CPPFLAGS += -DG4VIS_USE_ASCIITREE 
##  override CPPFLAGS += -DG4VIS_USE_GAGTREE 
##  override CPPFLAGS += -DG4VIS_USE_DAWN 
##  override CPPFLAGS += -DG4VIS_USE_RAYTRACERX 
##  override CPPFLAGS += -DG4VIS_USE_VRML 
  override CPPFLAGS += -DG4VIS_USE_OPENGLX 
  override CPPFLAGS += -DG4VIS_USE_OPENGL 

#
# Probably shouldn't need the CLHEP added to the library list like
# this, but here it is. SRT's arch_spec_CLHEP seems to clash with the
# geant4 configuration of the environment. Go with geant4's
# configuration.
#
G4LIBS = \
-lG4FR \
-lG4GMocren \
-lG4OpenGL \
-lG4RayTracer \
-lG4Tree \
-lG4VRML \
-lG4analysis \
-lG4digits_hits \
-lG4error_propagation \
-lG4event \
-lG4geometry \
-lG4gl2ps \
-lG4global \
-lG4graphics_reps \
-lG4intercoms \
-lG4interfaces \
-lG4materials \
-lG4modeling \
-lG4parmodels \
-lG4particles \
-lG4persistency \
-lG4physicslists \
-lG4processes \
-lG4readout \
-lG4run \
-lG4track \
-lG4tracking \
-lG4visHepRep \
-lG4visXXX \
-lG4vis_management \
-lG4zlib \

override LDFLAGS  += -L${G4LIB}/$(G4SYSTEM) -L${CLHEP_DIR}/lib ${G4LIBS}

override LOADLIBES += -L$(G4LIB)/$(G4SYSTEM) $(G4LIBS) -L$(CLHEP_BASE)/lib -lCLHEP
#=======================================================================
