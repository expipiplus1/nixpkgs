{ stdenv, lib, fetchgit, bootPkgs, buildPackages, ncurses, libiconv, binutils, coreutils
, autoconf, automake, happy, alex, buildPlatform, hostPlatform, targetPlatform
, __targetPackages
, llvmPackages_39

  # If enabled GHC will be build with the GPL-free but slower integer-simple
  # library instead of the faster but GPLed integer-gmp library.
, enableIntegerSimple ? false, gmp
}:

let
  inherit (bootPkgs) ghc;

  commonBuildInputs = [
    ghc
    buildPackages.buildPackages.perl
    buildPackages.autoconf
    buildPackages.automake
    happy
    alex
    buildPackages.python3
  ];

  version = "8.3";
  rev = "6cffee6a567a60a85792a5eb7c899b2878c7192d";

  commonPreConfigure =  ''
    echo ${version} >VERSION
    echo ${rev} >GIT_COMMIT_ID
    ./boot
    sed -i -e 's|-isysroot /Developer/SDKs/MacOSX10.5.sdk||' configure
  '' + stdenv.lib.optionalString (!stdenv.isDarwin) ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $out/lib/ghc-${version}"
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    export NIX_LDFLAGS+=" -no_dtrace_dof"
  '' + stdenv.lib.optionalString enableIntegerSimple ''
    echo "INTEGER_LIBRARY=integer-simple" > mk/build.mk
  '';

  targetStdenv =
    if (hostPlatform.config != targetPlatform.config)
      then __targetPackages.stdenv
      else stdenv;

  crossCompile = buildPlatform != hostPlatform;

  prefix =
    if buildPlatform == targetPlatform || crossCompile
      then ""
      else "${targetPlatform.config}-";

in stdenv.mkDerivation (rec {
  inherit version rev;
  name = "${prefix}ghc-${version}";

  src = fetchgit {
    url = "git://git.haskell.org/ghc.git";
    inherit rev;
    sha256 = "1hn74620p5av37ydhffl13yyfz32675s43fg728rdp2kvcqbd4ia";
  };

  patches = [ ./ghc-no-terminfo.patch ];

  postPatch = "patchShebangs .";

  preConfigure = commonPreConfigure;

  buildInputs = commonBuildInputs;

  enableParallelBuilding = true;

  configureFlags = [
    "CC=${stdenv.cc}/bin/cc"
    "--with-curses-includes=${ncurses.dev}/include" "--with-curses-libraries=${ncurses.out}/lib"
  ] ++ stdenv.lib.optional (! enableIntegerSimple) [
    "--with-gmp-includes=${gmp.dev}/include" "--with-gmp-libraries=${gmp.out}/lib"
  ] ++ stdenv.lib.optional stdenv.isDarwin [
    "--with-iconv-includes=${libiconv}/include" "--with-iconv-libraries=${libiconv}/lib"
  ];

  # required, because otherwise all symbols from HSffi.o are stripped, and
  # that in turn causes GHCi to abort
  stripDebugFlags = [ "-S" ] ++ stdenv.lib.optional (!stdenv.isDarwin) "--keep-file-symbols";

  checkTarget = "test";

  postInstall = ''
    paxmark m $out/lib/${name}/bin/${if buildPlatform != targetPlatform then "ghc" else "{ghc,haddock}"}

    # Install the bash completion file.
    install -D -m 444 utils/completion/ghc.bash $out/share/bash-completion/completions/${prefix}ghc

    # Patch scripts to include "readelf" and "cat" in $PATH.
    for i in "$out/bin/"*; do
      test ! -h $i || continue
      egrep --quiet '^#!' <(head -n 1 $i) || continue
      sed -i -e '2i export PATH="$PATH:${stdenv.lib.makeBinPath [ (targetStdenv.binutilsCross or binutils) coreutils ]}"' $i
    done
  '';

  passthru = {
    inherit bootPkgs;
  };

  meta = {
    homepage = "http://haskell.org/ghc";
    description = "The Glasgow Haskell Compiler";
    maintainers = with stdenv.lib.maintainers; [ marcweber andres peti ];
    inherit (ghc.meta) license platforms;
  };

} // stdenv.lib.optionalAttrs (targetPlatform != buildPlatform) {
  preConfigure = commonPreConfigure + ''
    sed 's|#BuildFlavour  = quick-cross|BuildFlavour  = perf-cross|' mk/build.mk.sample > mk/build.mk
    echo 'Stage1Only = ${if crossCompile then "NO" else "YES"}' >> mk/build.mk
  '';

  configureFlags = [
    "CC=${targetStdenv.ccCross}/bin/${targetPlatform.config}-gcc"
    "--build=${buildPlatform.config}"
    "--host=${buildPlatform.config}"
    "--target=${targetPlatform.config}"
    "--enable-bootstrap-with-devel-snapshot"
    "--verbose"
    "--with-curses-includes=${if crossCompile then buildPackages.ncurses.dev else ncurses.dev}/include"
    "--with-curses-libraries=${if crossCompile then buildPackages.ncurses.out else ncurses.out}/lib"
  ]
    # fix for iOS: https://www.reddit.com/r/haskell/comments/4ttdz1/building_an_osxi386_to_iosarm64_cross_compiler/d5qvd67/
  ++ lib.optional (targetPlatform.config or null == "aarch64-apple-darwin14") "--disable-large-address-space"
  ++ lib.optionals (!enableIntegerSimple) [
    "--with-gmp-includes=${(__targetPackages.gmp or gmp).dev}/include"
    "--with-gmp-libraries=${(__targetPackages.gmp or gmp).out}/lib"
  ];

  propagatedBuildInputs = [
    ncurses.out
    (__targetPackages.ncurses.out or null)
    buildPackages.ncurses.out
  ] ++ stdenv.lib.optionals (!enableIntegerSimple) [
    gmp.out
    (__targetPackages.gmp.out or null)
  ];

  # Top, without __targetPackages in propagatedBuildInputs
  # Bottom, with __targetPackages in propagatedBuildInputs

  makeFlags = [ "VERBOSE=1" "TRACE=1" ];

  buildInputs = commonBuildInputs ++ [
    targetStdenv.ccCross
    (__targetPackages.binutilsCross or binutils)
    (if crossCompile
      then buildPackages.llvmPackages_39.llvm
      else llvmPackages_39.llvm)
  ];

  dontSetConfigureCross = true;

  dontUseCmakeConfigure = true;

  passthru = {
    inherit bootPkgs targetPlatform;

    cc = "${targetStdenv.ccCross}/bin/${targetPlatform.config}-cc";

    ld = "${__targetPackages.binutilsCross}/bin/${targetPlatform.config}-ld";
  };
})
