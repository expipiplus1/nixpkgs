{ mkDerivation, base, containers, fetchgit, ghc, ghc-exactprint
, ghcide, haskell-lsp-types, hls-plugin-api, lib, text
, unordered-containers
}:
mkDerivation {
  pname = "hls-haddock-comments-plugin";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/haskell/haskell-language-server.git";
    sha256 = "18g0d7zac9xwywmp57dcrjnvms70f2mawviswskix78cv0iv4sk5";
    rev = "46d2a3dc7ef49ba57b2706022af1801149ab3f2b";
    fetchSubmodules = true;
  };
  postUnpack = "sourceRoot+=/plugins/hls-haddock-comments-plugin; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base containers ghc ghc-exactprint ghcide haskell-lsp-types
    hls-plugin-api text unordered-containers
  ];
  homepage = "https://github.com/haskell/haskell-language-server";
  description = "Haddock comments plugin for Haskell Language Server";
  license = lib.licenses.asl20;
}
