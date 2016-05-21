#
# Global variables
#
#

CC=gcc
CXX=g++
ifdef NO_YASM
ASM=nasm
else
ASM=yasm
endif

OPERATING_SYSTEM := $(shell uname -s)

ifeq ($(OPERATING_SYSTEM),Darwin)
 BASE_OBJ_FORMAT := macho
 OBJ_FORMAT := $(BASE_OBJ_FORMAT)32
 OBJ_DEBUG_OPT :=
endif

ifeq ($(OPERATING_SYSTEM),Linux)
 BASE_OBJ_FORMAT := elf
 PLATFORM := $(shell uname -m | sed -e "s/i[3456]86/i386/")
 OBJ_DEBUG_OPT := -g dwarf2

 ifeq ($(PLATFORM),i386)
  OBJ_FORMAT := $(BASE_OBJ_FORMAT)32
 endif

 ifeq ($(PLATFORM),x86_64)
  OBJ_FORMAT := $(BASE_OBJ_FORMAT)64
 endif
endif

ifdef NO_YASM
 OBJ_FORMAT:=$(BASE_OBJ_FORMAT)
 OBJ_DEBUG_OPT := -F stabs
endif

ifndef OBJ_FORMAT
 ERROR_MSG:=The object format for this platform is unknown; this file needs updating
 $(error $(ERROR_MSG))
endif

UNIV_CFLAGS := -std=c89 -pedantic -Wall -Wextra -pedantic -Wno-long-long -Wfloat-equal -Wshadow -Wwrite-strings -Wswitch-default -Wswitch-enum -Wconversion -Wundef -Wpointer-arith -Wcast-align -Wstrict-prototypes -Wcast-qual
UNIV_CXXFLAGS := -std=c++14 -Wall -Wextra -pedantic -Wno-long-long -Wfloat-equal -Wshadow -Wwrite-strings -Wswitch-default -Wswitch-enum -Wconversion -Wundef -Wpointer-arith -Wcast-align -Wcast-qual

ifeq ($(Cfg),release32)
 Out := _out/release32
 Root := .
 GLBL_CPPFLAGS := -DNDEBUG
 GLBL_CFLAGS := -m32 -O3 $(UNIV_CFLAGS)
 GLBL_CXXFLAGS := -m32 -O3 $(UNIV_CXXFLAGS)
 GLBL_LDFLAGS := -m32
 GLBL_ASMFLAGS := -f $(BASE_OBJ_FORMAT)32
endif

ifeq ($(Cfg),debug32)
 Out := _out/debug32
 Root := .
 GLBL_CPPFLAGS := -D_DEBUG
 GLBL_CFLAGS := -m32 -g $(UNIV_CFLAGS)
 GLBL_CXXFLAGS := -m32 -g $(UNIV_CXXFLAGS)
 GLBL_LDFLAGS := -m32
 GLBL_ASMFLAGS := -f $(BASE_OBJ_FORMAT)32 $(OBJ_DEBUG_OPT)
endif

ifeq ($(Cfg),release)
 Out := _out/release
 Root := .
 GLBL_CPPFLAGS := -DNDEBUG
 GLBL_CFLAGS := -O3 $(UNIV_CFLAGS)
 GLBL_CXXFLAGS := -O3 $(UNIV_CXXFLAGS)
 GLBL_ASMFLAGS := -f $(OBJ_FORMAT)
endif

ifeq ($(Cfg),cov)
 Out := _out/coverage
 Root := .
 GLBL_CPPFLAGS := -D_DEBUG
 GLBL_CFLAGS := -fprofile-arcs -ftest-coverage $(UNIV_CFLAGS)
 GLBL_CXXFLAGS := -fprofile-arcs -ftest-coverage $(UNIV_CXXFLAGS)
 GLBL_LDLIBS := gcov
 GLBL_ASMFLAGS := -f $(OBJ_FORMAT)
endif

ifeq ($(Cfg),prof)
 Out := _out/profile
 Root := .
 GLBL_CPPFLAGS := -DNDEBUG
 GLBL_CFLAGS := -pg -O3 $(UNIV_CFLAGS)
 GLBL_CXXFLAGS := -pg -O3 $(UNIV_CXXFLAGS)
 GLBL_LDFLAGS := -pg
 GLBL_ASMFLAGS := -f $(OBJ_FORMAT)
endif

ifndef Out
 Out := _out/debug
 Root := .
 GLBL_CPPFLAGS := -D_DEBUG
 GLBL_CFLAGS := -g $(UNIV_CFLAGS)
 GLBL_CXXFLAGS := -g $(UNIV_CXXFLAGS)
 GLBL_ASMFLAGS := -f $(OBJ_FORMAT) $(OBJ_DEBUG_OPT)
endif

GLBL_LDPATH := $(Out)/lib
GLBL_LDRPATH := \$$ORIGIN/../lib
CLEAN_FILES :=
TEST_FILES :=
INTEGRATION_TEST_FILES :=
SLOW_INTEGRATION_TEST_FILES :=
DEP_FILES :=

#
# Universal rules
#

.SECONDEXPANSION:

define makedir
	@echo Making directory $(@D)
	@mkdir -p $(@D)
	@touch $@
endef

define makeso
	@echo Linking shared library $@
	@$(CC) -shared $(LDFLAGS) $(LDPATH:%=-L%) -o $@ $(OBJECTS) $(LDLIBS:%=-l%)
endef

define makecppso
	@echo Linking shared library $@
	@$(CXX) -shared $(LDFLAGS) $(LDPATH:%=-L%) -o $@ $(OBJECTS) $(LDLIBS:%=-l%)
endef

ifeq ($(OPERATING_SYSTEM),Darwin)

define makeexe
	@echo Linking executable $@
	@$(CC) $(LDFLAGS) $(LDPATH:%=-L%) -o $@ $(OBJECTS) $(LDLIBS:%=-l%)
endef

define makecppexe
	@echo Linking executable $@
	@$(CXX) $(LDFLAGS) $(LDPATH:%=-L%) -o $@ $(OBJECTS) $(LDLIBS:%=-l%)
endef

else

define makeexe
	@echo Linking executable $@
	@$(CC) $(LDFLAGS) $(LDRPATH:%=-Wl,-rpath,%) $(LDPATH:%=-L%) -o $@ $(OBJECTS) $(LDLIBS:%=-l%)
endef

define makecppexe
	@echo Linking executable $@
	@$(CXX) $(LDFLAGS) $(LDRPATH:%=-Wl,-rpath,%) $(LDPATH:%=-L%) -o $@ $(OBJECTS) $(LDLIBS:%=-l%)
endef

endif

define makelib
	@echo Making library $@
	@$(AR) rcs $@ $(OBJECTS)
endef

define compilec
	@echo Compiling $< \(\$$stem=$(stem)\)
	@$(CC) $(CPPFLAGS) $(INCLUDES:%=-I%) $(CFLAGS) -c -o $@ $<
endef

define compilecpp
	@echo Compiling $< \(\$$stem=$(stem)\)
	@$(CXX) $(CPPFLAGS) $(INCLUDES:%=-I%) $(CXXFLAGS) -c -o $@ $<
endef

ifdef NO_YASM

define assemble
	@echo Assembling $<
	@$(ASM) $(ASMFLAGS) $(CPPFLAGS) $(INCLUDES:%=-I%/) -I$(<D)/ -o $@ $<
endef

else

define assemble
	@echo Assembling $<
	@$(ASM) $(ASMFLAGS) $(CPPFLAGS) $(INCLUDES:%=-I%) -o $@ $<
endef

endif

define makecdep
	@echo Generating dependencies for $<
	@$(CC) $(CPPFLAGS) $(INCLUDES:%=-I%) -MF $@ -MM -MP -MT $@ -MT $(basename $@).o $<
endef

define makecppdep
	@echo Generating dependencies for $<
	@$(CXX) $(CPPFLAGS) $(INCLUDES:%=-I%) -MF $@ -MM -MP -MT $@ -MT $(basename $@).o $<
endef

define makeasmdep
	@echo Generating dependencies for $<
	@$(ASM) $(ASMFLAGS) $(CPPFLAGS) $(INCLUDES:%=-I%) -M $< | sed 's/^$(basename $(@F)).o/$(subst /,\/,$@) $(subst /,\/,$(basename $@)).o/;' >$@
endef

$(Out)/lib/.touch:
	$(makedir)

$(Out)/bin/.touch:
	$(makedir)

