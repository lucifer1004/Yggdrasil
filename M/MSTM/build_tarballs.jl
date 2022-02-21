using BinaryBuilder, Pkg

name = "MSTM"
version = v"4.0.1"

# Collection of sources required to complete build
sources = [
  GitSource("https://github.com/dmckwski/MSTM.git", "b15798c1ef216cd5e6b6022463dd972b058d372d")
]

# Bash recipe for building across all platforms
script = raw"""
if [[ "$target" == x86_64-w64-mingw32 ]]; then
  cd $WORKSPACE/destdir/include
  cp $WORKSPACE/destdir/src/mpi.f90 .
  gfortran -DWIN64 -DINT_PTR_KIND=8 -fno-range-check mpi.f90 || true
  cd $WORKSPACE/srcdir/MSTM/code
  echo "void __guard_check_icall_fptr(unsigned long ptr) { }" > cfg_stub.c
  gcc -c cfg_stub.c
  gfortran -O2 -fno-range-check mpidefs-parallel.f90 mstm-intrinsics.f90 mstm-v4.0.f90 cfg_stub.o -L${WORKSPACE}/destdir/lib -I${WORKSPACE}/destdir/include -lmsmpifec64 -lmsmpi64 -o "${bindir}/mstm${exeext}"
elif [[ "$target" == *-mingw* ]]; then
  cd $WORKSPACE/destdir/include
  cp $WORKSPACE/destdir/src/mpi.f90 .
  gfortran -DWIN32 -DINT_PTR_KIND=8 -fno-range-check mpi.f90 || true
  cd $WORKSPACE/srcdir/MSTM/code
  gfortran -O2 -fno-range-check mpidefs-parallel.f90 mstm-intrinsics.f90 mstm-v4.0.f90 -L${WORKSPACE}/destdir/lib -I${WORKSPACE}/destdir/include -lmsmpifec -lmsmpi -o "${bindir}/mstm${exeext}"
else
  cd $WORKSPACE/srcdir/MSTM/code
  mpifort -O2 -fno-range-check mpidefs-parallel.f90 mstm-intrinsics.f90 mstm-v4.0.f90 -o "${bindir}/mstm${exeext}"
fi
install_license ${WORKSPACE}/srcdir/MSTM/LICENSE
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = expand_gfortran_versions(supported_platforms())

# The products that we will ensure are always built
products = [
  ExecutableProduct("mstm", :mstm)
]

# Dependencies that must be installed before this package can be built
dependencies = [
  Dependency(PackageSpec(name = "MPICH_jll", uuid = "7cb0a576-ebde-5e09-9194-50597f1243b4")),
  Dependency(PackageSpec(name = "MicrosoftMPI_jll", uuid = "9237b28f-5490-5468-be7b-bb81f5f5e6cf")),
  Dependency(PackageSpec(name = "CompilerSupportLibraries_jll", uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"))
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat = "1.6")
