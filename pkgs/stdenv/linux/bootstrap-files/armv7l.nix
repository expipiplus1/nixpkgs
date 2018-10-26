let
  bootPkgsRev = "b19e8f0f4450dc508952c23257080adc7328a2ed";
  bootPkgsSHA256 = "1xrqnvw5ypabbk16c9qamlshrw4wqf42ifggj4768lnq85ka00j3";
  pkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${bootPkgsRev}.tar.gz";
    sha256 = bootPkgsSHA256;
  };
  make-tools = import (pkgs + "/pkgs/stdenv/linux/make-bootstrap-tools.nix");
in (make-tools { localSystem = { system = "armv7l-linux"; }; }).bootstrapFiles
