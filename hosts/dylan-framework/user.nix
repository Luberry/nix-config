{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  users.users = {
    dylan = {
      initialPassword = "password";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDU1RjJ01Kw/T1V8pmghbI86+nQlJ8HidlFNNBNHHFoE6mXvhaFw8xrLRNB/4lb17KY2aaLg3MdxdDZSQQlys9h7cT2+EU2cPjjz1gNYeUVTye6L6EMgSh2tjKUzg9hFXvDbQS0AaP5FJeIqeHnnga7B8emdlbokUjMRVi0mGphe2lFbR1ucGH8mxVf6Ktn0pKupxlQ5Q+q/4LuhqTwJOs8Qws3d1sjEmN89ngnvk/zQ2eMznDOa+LXsbcBLGwg3EacazXUOMBex5gDZEPHeF8CJr3JhKaDWRDWjfxH1XBL1w2leI3Iw8R3eHsslGYTpylNKwr5eBsOr+R4OS+MK1cu4F0RgXt86BzzKmfBp4qpOv9nkb7u7F7FrIxvlG3hJ06VJawYrok3ZcWSU7/IDaf9Zer+cFvCCgGKRxgC1Br378rZ3boZBOiiwf2BxFcW7vJxzVYEV6mk4yvS4OI7RvGykl6jmOH5O//jf4WNcKhpm3yIr3lnHqw3DjqeRKbIUMM="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFaZpyQPXMZh5gUOouvvn7cxAgMX42PZ+9xuBNdZu5dQ"
      ];
      extraGroups = [
        "wheel"
        "dialout"
        "bluetooth"
        "docker"
        "plugdev"
        "video"
        "scanner"
        "lp"
      ];
      shell = pkgs.zsh;
    };
  };
}
