# Prometheus exporter for Plex (https://github.com/arnarg/plex_exporter); the
# source of the old granra/plex_exporter docker image.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "plex_exporter";
  version = "0-unstable-2022-03-02";
  src = fetchFromGitHub {
    owner = "arnarg";
    repo = "plex_exporter";
    rev = "0132160fcf2f41f25a5e18e78392eb324e932c5f";
    hash = "sha256-Jg/sQnAVplgag4Mv12pCbSO3v4GwcUUHvEUbF9m2R+Q=";
  };
  # Dependencies are vendored in the repo.
  vendorHash = null;
  meta.mainProgram = "plex_exporter";
}
