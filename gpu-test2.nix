{ stdenv, python, cython
, mpi, cudatoolkit, cudnn, nccl
, cudnnSupport ? false
}:

python.pkgs.buildPythonApplication rec {
  pname = "gpu-mpi-test2";
  version = "0.0.1";

  src = ./gpu-mpi-test2;

  propagatedBuildInputs = [
    (python.pkgs.chainermn.override {
      mpi = mpi;
      cudatoolkit = cudatoolkit;
      cudnn = cudnn;
      nccl = nccl;
      cudnnSupport = cudnnSupport;
    })
    python.pkgs.matplotlib
  ];

  nativeBuildInputs = [
    cython
  ];
}
