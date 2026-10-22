final: prev:

let
  pname = "x1plus";
  version = "3.1";
  tag = "x1plus%2F${version}";

  deps = with prev; [
    nss
    glib
    gtk3
    atk
    at-spi2-atk
    at-spi2-core
    cups
    dbus
    mesa
    pango
    cairo
    alsa-lib
    expat
    libxkbcommon

    xorg.libxcb
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
  ];

in
{
  x1plus = prev.stdenv.mkDerivation {
    inherit pname version;

    src = prev.fetchurl {
      url = "https://github.com/X1Plus/X1Plus/releases/download/${tag}/x1plus-install-${version}-linux-x64.tar.gz";
      sha256 = "sha256-zorWDIw2dLYh0oBr/uG40X8m0rj/w8UqRwcpQkoAdjI=";
    };

    nativeBuildInputs = [
      prev.autoPatchelfHook
      prev.makeWrapper
    ];

    buildInputs = deps;

    installPhase = ''
      mkdir -p $out/libexec/x1plus
      cp -r ./* $out/libexec/x1plus/

      mkdir -p $out/bin

      mv "$out/libexec/x1plus/X1Plus Installer" \
         "$out/libexec/x1plus/x1plus"

      makeWrapper "$out/libexec/x1plus/x1plus" \
        "$out/bin/x1plus" \
        --prefix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath deps} \
        --chdir "$out/libexec/x1plus" \
        --add-flags "--no-sandbox --disable-gpu --disable-software-rasterizer --ozone-platform=wayland"
    '';

    meta = with prev.lib; {
      description = "X1Plus installer (Electron-based)";
      homepage = "https://github.com/X1Plus/X1Plus";
      platforms = platforms.linux;
    };
  };
}
