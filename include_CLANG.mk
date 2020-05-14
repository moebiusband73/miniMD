CC  = clang
CXX = clang
MPICXX = clang
LINKER = $(CXX)

ANSI_CFLAGS  = -ansi
ANSI_CFLAGS += -std=c99
ANSI_CFLAGS += -pedantic
ANSI_CFLAGS += -Wextra

PROFILE  = #-g  -pg
ASFLAGS  = -masm=intel
# OPTS = -O3 -fno-vectorize
OPTS = -Ofast -march=cascadelake
# OPTS = -O3 -fno-vectorize
CFLAGS   = $(PROFILE) $(OPTS)  #$(ANSI_CFLAGS)
CXXFLAGS = $(CFLAGS)
ASFLAGS  = -masm=intel
FCFLAGS  =
LFLAGS   =
DEFINES  = -D_GNU_SOURCE
INCLUDES = $(MPIINC)
LIBS     = $(MPILIB) -lmpi -lm -lstdc++
