{callPackage}:
rec {
    buildRakuPackage = callPackage ./buildRakuPackage.nix {inherit rakudo;};
    rakudo = callPackage ./rakudo.nix {};
}
