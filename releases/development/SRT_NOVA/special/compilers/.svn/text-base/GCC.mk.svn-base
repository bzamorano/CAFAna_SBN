override SHAREDAR := g++

override CXXFLAGS += -g -gdwarf-4 -DML_NDEBUG -Wall -Wwrite-strings -Wno-inline -Woverloaded-virtual -Wno-unused-local-typedefs -Wextra -Wpedantic
# Temporary!
override CXXFLAGS += -Wno-unused-parameter -Wno-ignored-qualifiers
override CCFLAGS  += -g -gdwarf-4 -DML_NDEBUG -Wall -Wwrite-strings -Wno-inline -Wpedantic

# C++ 2014 flags
# The last flag turns off warnings due to variable length arrays that are turned on by c++1y

override CXXFLAGS += -std=c++14 -fdiagnostics-color=auto -Wno-vla

override CXXFLAGS += -O3 -fno-omit-frame-pointer
override CCFLAGS += -O3 -fno-omit-frame-pointer
override FCFLAGS += -O3 -fno-omit-frame-pointer


LDFLAGS += -Wl,--no-undefined
