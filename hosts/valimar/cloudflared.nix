# Cloudflare tunnel 91cc6228-5440-498b-adf6-c896227d0866. It's managed from the
# Cloudflare dashboard (routes live there), so valimar only needs its token.
# The NixOS cloudflared module only handles locally-configured tunnels.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets.cloudflared-token.sopsFile = ../../secrets/valimar.yaml;

  systemd.services.cloudflared = {
    description = "Cloudflare tunnel";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.cloudflared} tunnel --no-autoupdate run --token-file \${CREDENTIALS_DIRECTORY}/token";
      LoadCredential = [ "token:${config.sops.secrets.cloudflared-token.path}" ];
      DynamicUser = true;
      Restart = "always";
      RestartSec = 5;
    };
  };
}
