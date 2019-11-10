{ pkgs ? import ./nix/pkgs.nix {} }:
rec {
    raku = pkgs.callPackage ./raku {};
    hello-raku = pkgs.callPackage ./hello-raku {inherit raku;};
}
