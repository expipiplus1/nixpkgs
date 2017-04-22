{
  busybox = import <nix/fetchurl.nix> {
    url = file:///nix/store/2bc6v8nlg9flynsyfzm1pg7x5kxwk35p-busybox-1.26.2/bin/busybox;
    sha256 = "1d8aaz3p45x4yvhzbvhj78bhf8p2vchwhir9zsrng03192pyh7hb";
    executable = true;
  };

  bootstrapTools = import <nix/fetchurl.nix> {
    url = file:///nix/store/l7hdd0b5dvdyy8nzcz6qhv9l89nxsqp9-stdenv-bootstrap-tools/on-server/bootstrap-tools.tar.xz;
    sha256 = "1xq581hlrs5lw7cdqy278zvvcbfy3d1cj5vrsc42jlvqy1msj3x2";
  };
}
