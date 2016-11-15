{ stdenv, fetchurl, bootPkgs, perl, binutilsCross, coreutils, hscolour
, patchutils, gccCrossStageFinal, llvm_37, ncurses, gmp, cross 
}:

let
  inherit (bootPkgs) ghc;

  fetchFilteredPatch = args: fetchurl (args // {
    downloadToTemp = true;
    postFetch = ''
      ${patchutils}/bin/filterdiff --clean --strip-match=1 -x 'testsuite/*' "$downloadedFile" > "$out"
    '';
  });
in
stdenv.mkDerivation rec {
  version = "8.0.1";
  name = "ghc-${version}";

  src = fetchurl {
    url = "https://downloads.haskell.org/~ghc/8.0.1/${name}-src.tar.xz";
    sha256 = "1lniqy29djhjkddnailpaqhlqh4ld2mqvb1fxgxw1qqjhz6j1ywh";
  };

  patches = [
    ./ghc-8.x-dont-pass-linker-flags-via-response-files.patch  # https://github.com/NixOS/nixpkgs/issues/10752
    ./relocation.patch
    
    # Cross compiling host build fix
    (fetchFilteredPatch { url = https://git.haskell.org/ghc.git/patch/682518d410a4c522be5d10550c5c915b1f56084d; sha256 = "0w67igqlaay057s22ml981v2vm01z3lpb756iflyy6cykmd1gr5w"; })
    (fetchFilteredPatch { url = https://git.haskell.org/ghc.git/patch/b20502997c0e1817b2360e3aaabcea31c1d7dedd; sha256 = "1lyadp3xlr6n8b8g09asmppbvih7gkkmgygvwbgx0cf2qb9nih9g"; })

    # Fix https://ghc.haskell.org/trac/ghc/ticket/12130
    (fetchFilteredPatch { url = https://git.haskell.org/ghc.git/patch/4d71cc89b4e9648f3fbb29c8fcd25d725616e265; sha256 = "0syaxb4y4s2dc440qmrggb4vagvqqhb55m6mx12rip4i9qhxl8k0"; })
    (fetchFilteredPatch { url = https://git.haskell.org/ghc.git/patch/2f8cd14fe909a377b3e084a4f2ded83a0e6d44dd; sha256 = "06zvlgcf50ab58bw6yw3krn45dsmhg4cmlz4nqff8k4z1f1bj01v"; })
  ] ++ stdenv.lib.optional stdenv.isLinux ./ghc-no-madv-free.patch;

  buildInputs = [ gccCrossStageFinal llvm_37 ghc perl hscolour ];

  enableParallelBuilding = true;

  outputs = [ "out" "doc" ];

  preConfigure = ''
    cat > mk/build.mk <<EOF
    BuildFlavour = perf-cross
    GhcLibHcOpts = -O2
    GhcStage1HcOpts = -O -fPIC
    GhcStage2HcOpts = -O0 -fPIC -fllvm
    SplitObjs = NO
    Stage1Only = YES
    DYNAMIC_BY_DEFAULT = NO
    DYNAMIC_GHC_PROGRAMS = NO
    GhcLibWays = v thr p
    HADDOCK_DOCS = NO
    EOF
  '';

  configureFlags = [
    "--target=${cross.config}"
    "--with-gcc=${gccCrossStageFinal}/bin/${cross.config}-gcc"
    "--with-gmp-includes=${gmp.crossDrv.dev}/include" 
    "--with-gmp-libraries=${gmp.crossDrv.out}/lib"
    "--with-curses-includes=${ncurses.crossDrv.dev}/include" 
    "--with-curses-libraries=${ncurses.crossDrv.out}/lib"
    "--datadir=$doc/share/doc/ghc"
  ];

  dontSetConfigureCross = true;

  # required, because otherwise all symbols from HSffi.o are stripped, and
  # that in turn causes GHCi to abort
  stripDebugFlags = [ "-S" ];

  postInstall = ''
    # Install the bash completion file.
    # This annoyingly doesn't work for all targets, as the ghc binary often has
    # the vendor in the target string.
    install -D -m 444 utils/completion/ghc.bash $out/share/bash-completion/completions/${cross.config}-ghc

    # Patch scripts to include "${cross.config}-ld", "readelf" and "cat" in $PATH.
    for i in "$out/bin/"*; do
      test ! -h $i || continue
      egrep --quiet '^#!' <(head -n 1 $i) || continue
      sed -i -e '2i export PATH="$PATH:${stdenv.lib.makeBinPath [ binutilsCross coreutils ]}"' $i
    done
  '';

  passthru = {
    inherit bootPkgs;
    inherit cross;
  };

  meta = {
    homepage = "http://haskell.org/ghc";
    description = "The Glasgow Haskell Compiler";
    maintainers = with stdenv.lib.maintainers; [ marcweber andres peti ];
    inherit (ghc.meta) license platforms;
  };
}
