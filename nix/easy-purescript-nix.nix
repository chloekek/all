let
    tarball = fetchTarball {
        url = "https://github.com/justinwoo/easy-purescript-nix/archive/6be3f48f339034a58b1b1ae997ace534cf459826.tar.gz";
        sha256 = "10fxfxgbpr920bj69jail8vsj6qj5cf4g2r5brxiv23fz8nkzf5n";
    };
in
    {pkgs}: import tarball {inherit pkgs;}
