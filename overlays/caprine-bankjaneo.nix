final: prev: {
  caprine = prev.caprine.overrideAttrs (old: rec {
    version = "2.61.22-bankjaneo";

    src = prev.fetchFromGitHub {
      owner = "bankjaneo";
      repo = "caprine";
      rev = "v2.61.22";

      # Replace after first build attempt:
      hash = "sha256-3sDgluG0xG0Ys0OwKfb2A9OdaRAEfa/Azv7S6r4+xEQ=";
    };

    npmDeps = prev.fetchNpmDeps {
      inherit src;
      hash = "sha256-X5FqGig0TbM1/BntuKgrttnOsCP/OpBoERpf5uLFYhs=";
    };
  });
}
