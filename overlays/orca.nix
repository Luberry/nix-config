self: super: {
  orca-slicer-appimage =
    let
      # Create the custom gst-plugins-good with GTK support enabled
      gst-plugins-good-gtk = super.gst_all_1.gst-plugins-good.override {
        gtkSupport = true;
      };
    in
    super.appimageTools.wrapType2 rec {
      name = "BambuStudio";
      pname = "orca-slicer";
      version = "02.05.01.52";
      ubuntu_version = "24.04";

      src = super.fetchurl {
        url = "https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v2.4.2/OrcaSlicer_Linux_AppImage_Ubuntu2404_V2.4.2.AppImage";
        sha256 = "sha256-0S+4yOrBrs0t+2N3rNSPmU+PpDntUpL6Uy3YKIDwKf0=";
      };

      profile = ''
        export SSL_CERT_FILE="${super.cacert}/etc/ssl/certs/ca-bundle.crt"
        export GIO_MODULE_DIR="${super.glib-networking}/lib/gio/modules/"
      '';

      extraPkgs =
        pkgs: with pkgs; [
          cacert
          glib
          glib-networking
          gst_all_1.gst-plugins-bad
          gst_all_1.gst-plugins-base
          gst-plugins-good-gtk # <-- Swapped the default one for your custom version
          webkitgtk_4_1
          libsoup_3
        ];
    };
}
