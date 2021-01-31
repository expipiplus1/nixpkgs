{ mkDerivation, aeson, base, containers, dlist, fetchgit, foldl
, ghc, ghc-exactprint, ghcide, haskell-lsp, hls-plugin-api, lens
, lib, retrie, shake, syb, text, transformers, unordered-containers
}:
mkDerivation {
  pname = "hls-splice-plugin";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/haskell/haskell-language-server.git";
    sha256 = "18g0d7zac9xwywmp57dcrjnvms70f2mawviswskix78cv0iv4sk5";
    rev = "46d2a3dc7ef49ba57b2706022af1801149ab3f2b";
    fetchSubmodules = true;
  };
  postUnpack = "sourceRoot+=/plugins/hls-splice-plugin; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    aeson base containers dlist foldl ghc ghc-exactprint ghcide
    haskell-lsp hls-plugin-api lens retrie shake syb text transformers
    unordered-containers
  ];
  description = "HLS Plugin to expand TemplateHaskell Splices and QuasiQuotes";
  license = lib.licenses.asl20;
}
