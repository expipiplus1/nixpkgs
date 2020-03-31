{ stdenv, fetchgit, python3, cmake, libX11, libXext }:

stdenv.mkDerivation rec {
  pname = "swiftshader";
  version = "2020-03-31";

  src = fetchgit {
    url = "https://swiftshader.googlesource.com/SwiftShader";
    rev = "5cf1e9a31c90ccd9ec40d0c5ef1357f6e0ec1cfd";
    sha256 = "0az0k3m4kf4w9dam1wzjrdapn30svp56x5m642c4qg9v24dhhgxp";
  };

  nativeBuildInputs = [ cmake python3 ];
  buildInputs = [ libX11 libXext ];

  # Make sure we include libvulkan.so in the output as the cmake generated
  # install command only puts in the spirv-tools stuff.
  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib"
    mv Linux/* "$out/lib"
    ln -s "$out/lib/libvulkan.so.1" "$out/lib/libvulkan.so"

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description =
      "A high-performance CPU-based implementation of the Vulkan, OpenGL ES, and Direct3D 9 graphics APIs";
    homepage = "https://opensource.google/projects/swiftshader";
    license = licenses.asl20;
    # Should be possible to support Darwin by changing the install phase with
    # 's/Linux/Darwin/' and 's/so/dylib/' or something similar.
    platforms = platforms.linux;
    maintainers = with maintainers; [ expipiplus1 ];
  };
}
