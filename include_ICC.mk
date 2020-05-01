CC  = icc
CXX = icpc
MPICXX = mpiicpc
LINKER = $(CXX)

#	-O3 -fasm-blocks -DMPICH_IGNORE_CXX_SEEK -restrict -vec_report2 -fasm-blocks -fopenmp -DNOCHUNK -mavx -DUSE_SIMD
#-mGLOB_default_function_attrs="use_approx_f64_divide=true"
#-DPAD=3
#-DPAD=4
#-DPRECISION=1
#-DPRECISION=2 DP
#
#-DPREC_TIMER
#-lrt

#-O3 -fasm-blocks -fopenmp

PROFILE  = #-g  -pg
# OPTS     = -Ofast -xCORE-AVX512 -qopt-zmm-usage=high -fasm-blocks -mGLOB_default_function_attrs="use_approx_f64_divide=true" $(PROFILE)
# OPTS     = -Ofast -xCORE-AVX512 -qopt-zmm-usage=high
# OPTS     =  -Ofast -xCORE-AVX2
# OPTS     =  -Ofast -xAVX
# OPTS     =  -Ofast -xSSE4.2
# OPTS     =  -Ofast -xCORE-AVX512  -qopt-zmm-usage=high  -mGLOB_default_function_attrs="use_approx_f64_divide=true" $(PROFILE)
# OPTS     =  -O3 -no-vec -fasm-blocks -mGLOB_default_function_attrs="use_approx_f64_divide=true" $(PROFILE)
OPTS     =  -O3 -no-vec
# OPTS     =  -O3 -xHost -fasm-blocks -mGLOB_default_function_attrs="use_approx_f64_divide=true" $(PROFILE)
CFLAGS   = $(PROFILE) -restrict $(OPTS)
CXXFLAGS = $(CFLAGS)
ASFLAGS  = -masm=intel
FCFLAGS  =
LFLAGS   = $(PROFILE) $(OPTS)
DEFINES  = -D_GNU_SOURCE
INCLUDES = $(MPIINC) $(LIKWID_INC)
LIBS     = $(LIKWID_LIB) -llikwid


