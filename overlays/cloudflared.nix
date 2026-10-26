# cloudflared 2026.10.3, which isn't in stable or unstable yet and is needed
# for its fixes. It requires go >= 1.27.3, which only unstable has, so it's
# built with unstable's go 1.27 builder.
# TEMPORARY: drop this once nixpkgs ships >= 2026.10.3.
{ inputs }:
self: super:
let
  unstable = import inputs.nixpkgs-unstable { system = super.stdenv.hostPlatform.system; };
in
{
  cloudflared =
    (super.cloudflared.override { buildGoModule = unstable.buildGo127Module; }).overrideAttrs
      (
        finalAttrs: old: {
          version = "2026.10.3";
          src = super.fetchFromGitHub {
            owner = "cloudflare";
            repo = "cloudflared";
            tag = finalAttrs.version;
            hash = "sha256-k1OMkHHItOT5VHhQqgC8ODm/RCJEtwtZi0Lxyf/esLg=";
          };
          # Upstream stopped committing vendor/ (nixpkgs expects it), so fetch deps.
          vendorHash = "sha256-KqTLXEm0jxJ1TsyYzxAwYMe8niIgJxBHQPz/aZKmS40=";
          # protocol_test.go (and the test nixpkgs skips in it) was removed
          # upstream; keep the rest of nixpkgs' test workarounds.
          preCheck =
            builtins.replaceStrings
              [ ''substituteInPlace "edgediscovery/protocol_test.go"'' ]
              [
                ''[ ! -e edgediscovery/protocol_test.go ] || substituteInPlace "edgediscovery/protocol_test.go"''
              ]
              old.preCheck;
        }
      );
}
