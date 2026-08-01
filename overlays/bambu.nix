self: super: {
  bambu-studio-appimage = super.appimageTools.wrapType2 rec {
    name = "BambuStudio";
    pname = "bambu-studio";
    version = "02.05.01.52";
    ubuntu_version = "24.04";

    src = super.fetchurl {
      url="https://github.com/bambulab/BambuStudio/releases/download/v02.05.01.52/Bambu_Studio_ubuntu-24.04_V02.05.01.52.AppImage";
      sha256 = "sha256-W6creYpoeLDOkQZgsVSWLY4jK8GiaQi3NS7thtEJqCs=";
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
        gst_all_1.gst-plugins-good
        webkitgtk_4_1
      ];
  };
}
