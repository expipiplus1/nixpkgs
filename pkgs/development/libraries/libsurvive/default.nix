{ stdenv, fetchFromGitHub, cmake, libusb, openblas, zlib }:

stdenv.mkDerivation rec {
  pname = "libsurvive";
  version = "2020-12-04";

  src = fetchFromGitHub {
    owner = "cntools";
    repo = "libsurvive";
    rev = "892b9044e6f533feeaccf2e1ab7b7adcb586fdd3";
    sha256 = "1j0xy0896p4fad2gpr4xif80mg88g0rxvai635lldjwi99yvw0hp";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libusb openblas zlib ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/cntools/libsurvive";
    description = "An open source Lighthouse Tracking System";
    platforms = platforms.linux;
    license = licenses.mit;
    maintainers = with maintainers; [ expipiplus1 ];
  };
}

