{ region, ami, instanceType, securityGroups, publicKey, secretKey, hosts }:

{ config, pkgs, resources, ...}:
let
  python = pkgs.python3;
  cudatoolkit = pkgs.cudatoolkit;
  mpi = pkgs.openmpi.overrideDerivation (attrs: {
    configureFlags = [ "--with-cuda=${pkgs.cudatoolkit}" ];
  });
  gpu-test1 = pkgs.callPackage ./gpu-test1.nix {
    mpi = mpi;
  };
  gpu-test2 = pkgs.callPackage ./gpu-test2.nix {
    python = python;
    cython = python.pkgs.cython;
    mpi = mpi;
    cudnnSupport = true;
    cudatoolkit = cudatoolkit;
    cudnn = pkgs.cudnn;
    nccl = pkgs.nccl;
  };
in
{ imports = [ ./ec2-info.nix ];
  deployment.targetEnv = "ec2";
  deployment.ec2.ami = ami;
  deployment.ec2.region = region;
  deployment.ec2.instanceType = instanceType;
  deployment.ec2.securityGroups = securityGroups;
  deployment.ec2.ebsInitialRootDiskSize = 20;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    python
    mpi
    cudatoolkit
    gpu-test1
    gpu-test2
  ];

  services.xserver = {
    enable = true;
    videoDrivers = [
      "nvidia"
    ];
  };

  services.openssh = {
    enable = true;
    hostKeys = [
      { bits = 4096; path = "/etc/ssh/ssh_host_rsa_key"; type = "rsa"; }
      { path = "/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
      { path = "/etc/root/ssh/id_ed25519"; type = "ed25519"; }
    ];
    knownHosts = hosts;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

  environment.etc = {
    "/root/ssh/id_ed25519" = {
      enable = true;
      user = "root";
      group = "root";
      mode = "0600";
      source = secretKey;
    };
  };

  hardware.opengl = {
    extraPackages = [
      mpi
      pkgs.linuxPackages.nvidia_x11
      cudatoolkit
      cudatoolkit.lib
    ];
  };

  networking.firewall.enable = false;

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [ publicKey ];
  };

  programs.bash.shellInit = ''
    if [ ! -e ~/.ssh/id_ed25519 ] ; then
      if [ -f /etc/root/ssh/id_ed25519 ] ; then
        /run/current-system/sw/bin/ln -s /etc/root/ssh/id_ed25519 .ssh/id_ed25519
      fi
    fi
  '';
}
