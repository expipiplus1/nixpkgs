{ lib, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, freeglut
, liblapack
, libusb1
, openblas
, zlib
}:

stdenv.mkDerivation rec {
  pname = "libsurvive";
  version = "unstable-2021-11-08";

  src = fetchFromGitHub {
    owner = "cntools";
    repo = "libsurvive";
    rev = "e630386cea6e49bce7558b07e46119d9c9cb1f9d";
    sha256 = "11rc6qfvpm2gvamkpj8dbvkpkccchj37q5gpyk2szdsgvwzinqsx";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [
    freeglut
    liblapack
    libusb1
    openblas
    zlib
  ];

  dontStrip = true;
  NIX_CFLAGS_COMPILE = "-ggdb -Og";

  meta = with lib; {
    description = "Open Source Lighthouse Tracking System";
    homepage = "https://github.com/cntools/libsurvive";
    license = licenses.mit;
    maintainers = with maintainers; [ expipiplus1 prusnak ];
    platforms = platforms.linux;
  };
}
