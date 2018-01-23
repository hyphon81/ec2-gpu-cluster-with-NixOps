let
  region = "ap-northeast-1";
  ami = "ami-89b921ef";
  instanceType = "p2.xlarge";
  ec2 = import ./ec2gpu-cluster-conf.nix;

  securityGroups = [ "allow-ssh" ];
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
