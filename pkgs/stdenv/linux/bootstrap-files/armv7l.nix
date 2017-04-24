{
  busybox = import <nix/fetchurl.nix> {
    url = file:///nix/store/xdji4v69zqk5g36vnh1555zn9lskylv9-busybox-1.26.2/bin/busybox;
    sha256 = "1d8aaz3p45x4yvhzbvhj78bhf8p2vchwhir9zsrng03192pyh7hb";
    executable = true;
  };

  bootstrapTools = import <nix/fetchurl.nix> {
    url = file:///nix/store/pwgffnimf2n0drain6s23b94dgrr9z3d-stdenv-bootstrap-tools/on-server/bootstrap-tools.tar.xz;
    sha256 = "1xq581hlrs5lw7cdqy278zvvcbfy3d1cj5vrsc42jlvqy1msj3x2";
  };
}
