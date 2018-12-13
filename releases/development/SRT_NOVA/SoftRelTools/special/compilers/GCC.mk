
# override settings from SoftRelTools/include/compilers/GCC.mk

#allow for things like -g switch when not using default compiler
ifeq ($(findstring 3_4_3,$(SRT_QUAL)),3_4_3)
    override CPPFLAGS += -g -O2 -Wall
    override CXXFLAGS += -g -O2 -Wall
    override CCFLAGS  += -g -O2 -Wall
    override LDFLAGS  += -g
endif

ifeq ($(findstring prof,$(SRT_QUAL)),prof)
    override CXXFLAGS += -g -O3 -DNDEBUG -fno-omit-frame-pointer
    override CCFLAGS += -g -O3 -DNDEBUG -fno-omit-frame-pointer
endif

# C++ 2011 flags
override CXXFLAGS += -std=c++11 -Wno-deprecated-declarations

$(sharedlib_o_dir)%.o: %.cc
        @echo "<**compiling**> $(<F)"
        $(TRACE)$(cxx_compile_pic_with_depends)


