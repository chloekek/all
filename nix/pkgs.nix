let
    tarball = fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/f40b8471e745a44929bcc93e6ac76498ebd66fce.tar.gz";
        sha256 = "0r7nshgi93sh2ig5hmrhk3fvnj4496rs8qq108cyqkf3ja0dwj75";
    };
    config = {
        packageOverrides = pkgs: {
            # We do not want to accidentally use this old version of Rakudo. We
            # have our own Nix expression for it.
            rakudo = throw "Do not use Rakudo from Nixpkgs.";
        };
    };
in
    {}: import tarball {inherit config;}
