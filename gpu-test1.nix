{ stdenv, gcc5, cudatoolkit, mpi}:

stdenv.mkDerivation rec {
  name = "gpu-mpi-test1";

  src = ./gpu-mpi-test;

  propagatedBuildInputs = [
    cudatoolkit
    mpi
  ];

  nativeBuildInputs = [
    gcc5
  ];

  buildPhase = ''
    export MPICH_CC=nvcc
    export OMPI_CC=nvcc
    $(mpicc -show check_cuda_aware.c -arch sm_53 | sed -e 's/-Wl,/-Xlinker /g' | sed -e 's/-pthread/-Xcompiler -pthread/')
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp a.out $out/bin/gpu-mpi-test1
  '';
}
