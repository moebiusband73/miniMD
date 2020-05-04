# Supported: GCC, CLANG, ICC
TAG ?= ICC
# Supported: 1.2, 2.0
VERSION ?= 1.2
ENABLE_MPI ?= true
ENABLE_LIKWID ?= false

#Feature options
OPTIONS  =  -DNOCHUNK
# OPTIONS +=  -DUSE_SIMD
OPTIONS +=  -DPAD4
# OPTIONS +=  -DPRECISION=1
