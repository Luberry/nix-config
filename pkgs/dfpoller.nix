# Prometheus exporter for `df` output (https://gitlab.com/Luberry/dfpoller).
{
  lib,
  buildGoModule,
  fetchFromGitLab,
  coreutils,
}:
buildGoModule {
  pname = "dfpoller";
  version = "0-unstable-2021-12-24";
  src = fetchFromGitLab {
    owner = "Luberry";
    repo = "dfpoller";
    rev = "b29920697445bce7ca6f9f9c6d27c5acdabc8334";
    hash = "sha256-dT0z37fvflDlMEFRTQriiaQxuM41ueWX3w5vuvIwVmA=";
  };
  vendorHash = "sha256-xz1x+hQUh2zD/d+ojtoxvFfzksWuxH9jl794YFIQCjU=";
  # It shells out to /usr/bin/df, which doesn't exist on NixOS.
  postPatch = ''
    substituteInPlace main.go --replace-fail '"/usr/bin/df"' '"${coreutils}/bin/df"'
  '';
  meta.mainProgram = "dfpoller";
}
