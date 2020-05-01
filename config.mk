# Supported: GCC, CLANG, ICC
TAG ?= ICC
# Supported: 1.2, 2.0
VERSION ?= 2.0
ENABLE_MPI ?= false
ENABLE_LIKWID ?= false

#Feature options
OPTIONS  =  -DNOCHUNK
# OPTIONS +=  -DUSE_SIMD
OPTIONS +=  -DPAD4
# OPTIONS +=  -DPRECISION=1
