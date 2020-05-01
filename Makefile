
#CONFIGURE BUILD SYSTEM
TARGET	   = miniMD-$(VERSION)-$(TAG)
BUILD_DIR  = ./$(VERSION)-$(TAG)
SRC_DIR    = ./src-$(VERSION)
MAKE_DIR   = ./
Q         ?= @

#DO NOT EDIT BELOW
include $(MAKE_DIR)/config.mk
include $(MAKE_DIR)/include_$(TAG).mk
include $(MAKE_DIR)/include_LIKWID.mk
INCLUDES  += -I./$(SRC_DIR)/includes
DEFINES   += $(OPTIONS)

ASM       = $(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/%.s,$(wildcard $(SRC_DIR)/*.cpp))
OBJ       = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o,$(wildcard $(SRC_DIR)/*.c))
OBJ      += $(patsubst $(SRC_DIR)/%.cc, $(BUILD_DIR)/%.o,$(wildcard $(SRC_DIR)/*.cc))
OBJ      += $(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/%.o,$(wildcard $(SRC_DIR)/*.cpp))
VPATH     = $(SRC_DIR)
CPPFLAGS := $(CPPFLAGS) $(DEFINES) $(INCLUDES)

ifeq ($(ENABLE_MPI),true)
CXX = $(MPICXX)
else
OBJ       += $(BUILD_DIR)/mpi.o
INCLUDES  += -I./mpi-stubs
VPATH     += ./mpi-stubs
endif


${TARGET}: $(BUILD_DIR) $(OBJ)
	@echo "===>  LINKING  $(TARGET)"
	$(Q)${LINKER} ${LFLAGS} -o $(TARGET) $(OBJ) $(LIBS)

asm:  $(BUILD_DIR) $(ASM)

$(BUILD_DIR)/%.o:  %.c
	@echo "===>  COMPILE  $@"
	$(Q)$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@
	$(Q)$(CC) $(CPPFLAGS) -MT $(@:.d=.o) -MM  $< > $(BUILD_DIR)/$*.d

$(BUILD_DIR)/%.s:  %.cpp
	@echo "===>  GENERATE ASM  $@"
	$(Q)$(CXX) -S $(ASFLAGS)  $(CPPFLAGS) $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o:  %.cpp
	@echo "===>  COMPILE  $@"
	$(Q)$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@
	$(Q)$(CXX) $(CPPFLAGS) -MT $(@:.d=.o) -MM  $< > $(BUILD_DIR)/$*.d

$(BUILD_DIR)/%.o:  %.c
	@echo "===>  COMPILE  $@"
	$(Q)$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@
	$(Q)$(CC) $(CPPFLAGS) -MT $(@:.d=.o) -MM  $< > $(BUILD_DIR)/$*.d


tags:
	@echo "===>  GENERATE  TAGS"
	$(Q)ctags -R


$(BUILD_DIR):
	@mkdir $(BUILD_DIR)

ifeq ($(findstring $(MAKECMDGOALS),clean),)
-include $(OBJ:.o=.d)
endif

.PHONY: clean distclean

clean:
	@echo "===>  CLEAN"
	@rm -rf $(BUILD_DIR)
	@rm -f tags

distclean: clean
	@echo "===>  DIST CLEAN"
	@rm -f $(TARGET)
	@rm -f tags

