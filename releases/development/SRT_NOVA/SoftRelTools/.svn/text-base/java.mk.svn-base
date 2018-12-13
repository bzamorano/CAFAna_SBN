#
# java.mk
#
# Rules for compiling Java code for the NOvA online software.
#
# The variables that are used in this file, but need to be defined outside
# of this file, are listed here.
#
# Variables that should be defined in arch_spec_java.mk (or its children)
# (of course, these variables can be overridden elsewhere):
# - JAVAC - the Java compiler
# - JAVACFLAGS - flags to be passed to the Java compiler
# - JAR - the Java archive tool, Jar
# - JARFLAGS - flags to be passed to Jar
#
# Variables that should be defined in the makefile that includes this file:
# - JAVA_FILES - the list of Java source files to be compiled
# - JAR_FILE - the name of the Jar file to be created (e.g. abc.jar)
# - JAVA_SRC_PATH - the path to the top directory in the Java source
#                   tree for the code that is being compiled
# - JAVA_CLASSPATH - additional entries for the classpath
# - JAVA_DEP_PKGS - the list of project-based packages that the Java
#                   code in the current package depends on
#

# local variable definitions
ifeq "$(findstring Test.jar, $(JAR_FILE))" ""
    java_workdir = $(libdir)/classes
else
    java_workdir = $(libdir)/testClasses
endif
java_libdir = $(libdir)
java_class_files := $(addprefix $(java_workdir)/,$(subst .java,.class,$(JAVA_FILES)))
java_file_count = $(words $(JAVA_FILES))

# build the list of additional source paths and dependencies, if any
extra_src_paths =
extra_src_dependencies =
ifneq "$(JAVA_DEP_PKGS)" ""
    dir_list := $(foreach pkg,$(JAVA_DEP_PKGS),\
                  $(addsuffix /java/src,$(addprefix $(SRT_PUBLIC_CONTEXT)/,$(pkg))))
    extra_src_paths := :$(shell echo $(dir_list) | sed 's/ /:/'g)
    extra_src_dependencies := $(shell find $(dir_list) -type f -name "*.java" -print 2>/dev/null)

    ifneq "$(SRT_PRIVATE_CONTEXT)" "."
        dir_list := $(foreach pkg,$(JAVA_DEP_PKGS),\
                      $(addsuffix /java/src,$(addprefix $(SRT_PRIVATE_CONTEXT)/,$(pkg))))
        extra_src_paths := :$(shell echo $(dir_list) | sed 's/ /:/'g)$(extra_src_paths)
        extra_src_dependencies := $(shell find $(dir_list) -type f -name "*.java" -print 2>/dev/null)
    endif
endif

# compilation rule
$(java_workdir)/%.class : %.java $(extra_src_dependencies)
	@echo "<**compiling**> $(<F)"
	$(check_dep_dir)
	$(JAVAC) $(JAVACFLAGS) -d $(java_workdir) \
	    -classpath $(java_workdir):$(JAVA_CLASSPATH):$(CLASSPATH) \
	    -sourcepath $(JAVA_SRC_PATH)$(extra_src_paths) $<

# "library" rules (just references the appropriate Jar file)
.PHONY : libjava testjava
ifeq "$(findstring Test.jar, $(JAR_FILE))" ""
    libjava: $(java_class_files)
    testjava:
else
    libjava:
    testjava: $(java_class_files)
endif

# cleanup rule
.PHONY : cleanjava
cleanjava:
	-rm -f $(java_libdir)/$(JAR_FILE)
	-rm -f $(java_class_files)

# add the local rules to the normal build cycle
lib: libjava
tbin: testjava
clean: cleanjava

# include the environment variables for Java
include SoftRelTools/arch_spec_java.mk
