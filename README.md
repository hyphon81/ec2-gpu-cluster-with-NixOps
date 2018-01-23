# ec2-gpu-cluster-with-NixOps
The Nix codes for deploying GPU cluster to AWS EC2.

# Usage
1. Please prepare the file ```ec2-info.nix``` in this project directory.
```nix:ec2-info.nix
{ config, pkgs, ... }:

with pkgs.lib;

{
  deployment.ec2.accessKeyId = "<YOUR_ACCESSKEY_ID>";
  deployment.ec2.keyPair = "<YOUR_SSH_KEY_PAIR_NAME>";
  deployment.ec2.privateKey = "<YOUR_SSH_PRIVATE_KEY_FILE_PATH>";
}
```

2. Please prepare the ed25519 ssh key pair files.
```
$ ssh-keygen -t ed25519

$ cp ~/.ssh/id_ed25519* <this project directory>/
```

3. Using from NixOps this project.
```
$ nixops create <this project directory>/ec2gpu-cluster.nix -d ec2gpu-cluster
$ nixops deploy -d ec2gpu-cluster -I nixpkgs=<the nixpkgs that includes necessary packages>

$ nixops ssh-for-each -d ec2gpu-cluster reboot

$ nixops ssh -d ec2gpu-cluster node1
[root@node1]# gpu-mpi-test1
OK.
[root@node1]# mpiexec --allow-run-as-root -n 4 -host node1,node2,node3,node4 check_mpi4py
## this order is not fixed
node1 0
node2 1
node3 2
node4 3
[root@node1]# mpiexec --allow-run-as-root -n 4 -host node1,node2,node3,node4 check_mpi4py
GPU: 0
# unit: 1000
# Minibatch-size: 100
# epoch: 20

GPU: 0
# unit: 1000
# Minibatch-size: 100
# epoch: 20

GPU: 0
# unit: 1000
# Minibatch-size: 100
# epoch: 20

GPU: 0
# unit: 1000
# Minibatch-size: 100
# epoch: 20

...
```

# Settings
In ```ec2gpu-cluster.nix```,
```nix
let
  region = "<region name>";
  ami = "<ami name>"; # See https://nixos.org/nixos/download.html
  instanceType = "<instance type>";
  ec2 = import ./ec2gpu-cluster-conf.nix;

  securityGroups = [ "<security group name>" ]; # It should open ssh port and allow all packets within cluster nodes. 
  secretKey = ./id_ed25519;
  publicKey = ./id_ed25519.pub;

  hosts = [
    { hostNames = [ "node1" ]; publicKeyFile = publicKey; }
    { hostNames = [ "node2" ]; publicKeyFile = publicKey; }
    { hostNames = [ "node3" ]; publicKeyFile = publicKey; }
    { hostNames = [ "node4" ]; publicKeyFile = publicKey; }
  ];
in
{
  network.description = "An ec2 gpu cluster create test";

  node1 = ec2 {
    inherit region ami instanceType securityGroups publicKey secretKey hosts;
  };
  node2 = ec2 {
    inherit region ami instanceType securityGroups publicKey secretKey hosts;
  };
  node3 = ec2 {
    inherit region ami instanceType securityGroups publicKey secretKey hosts;
  };
  node4 = ec2 {
    inherit region ami instanceType securityGroups publicKey secretKey hosts;
  };
}
```
