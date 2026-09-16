{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, makeDesktopItem
, copyDesktopItems
# Runtime dependencies
, alsa-lib
, dbus
, fontconfig
, freetype
, glib
, libGL
, libX11
, libXrender
, libXi
, libXcursor
, libXext
, libXfixes
, libXrandr
, libXcomposite
, libXdamage
, libXtst
, libxkbcommon
, nspr
, nss
, systemd
, zlib
}:

stdenv.mkDerivation rec {
  pname = "racecapture";
  version = "2.19.0";

  src = fetchurl {
    url = "https://autosportlabs-software.s3.us-west-2.amazonaws.com/racecapture_linux_x86_64_${version}.deb";
    sha256 = "sha256-OmNATAzy47eXrODzpq9Cpzpj1+Hvuyg63cczr8ifPVw="; 
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    dbus
    fontconfig
    freetype
    glib
    libGL
    libX11
    libXrender
    libXi
    libXcursor
    libXext
    libXfixes
    libXrandr
    libXcomposite
    libXdamage
    libXtst
    libxkbcommon
    nspr
    nss
    systemd
    zlib
  ];

  # This creates the .desktop file content
  desktopItems = [
    (makeDesktopItem {
      name = "racecapture";
      exec = "racecapture";
      icon = "racecapture";
      desktopName = "RaceCapture";
      genericName = "Data Acquisition and Telemetry";
      categories = [ "Utility" "Engineering" ];
      comment = "Configuration and analysis for RaceCapture devices";
    })
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/racecapture
    mkdir -p $out/bin
    mkdir -p $out/share/pixmaps

    # Copy files
    cp -r opt/racecapture/* $out/opt/racecapture/

    # Link the icon so the desktop file can find it
    # Assuming there is a .png or .ico in the opt folder; adjust name if needed
    if [ -f "$out/opt/racecapture/icon.png" ]; then
      ln -s $out/opt/racecapture/icon.png $out/share/pixmaps/racecapture.png
    fi

    chmod +x $out/opt/racecapture/race_capture

    # Wrap the binary
    makeWrapper $out/opt/racecapture/race_capture $out/bin/racecapture \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --set KIVY_NO_CONFIG 1 \
      --set KIVY_NO_FILELOG 1

    runHook postInstall
  '';

  meta = with lib; {
    description = "RaceCapture app for data acquisition and telemetry";
    homepage = "https://www.autosportlabs.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
