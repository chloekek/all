{callPackage}:
{
    buildRakuPackage = callPackage ./buildRakuPackage.nix {};
    rakudo = callPackage ./rakudo.nix {};
}
