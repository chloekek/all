{stdenv, lib, fetchurl, makeWrapper, rakudo}:
{name, src}:
let
    install-dist = fetchurl {
        url = "https://raw.githubusercontent.com/rakudo/rakudo/2019.07.1/tools/install-dist.p6";
        sha256 = "1gikhzigp0l7x4ka8hyhwdwqddyvafg2wx841f4pagfs3ja4rvhm";
    };
in
    stdenv.mkDerivation {
        inherit name src;
        buildInputs = [makeWrapper rakudo];
        phases = ["installPhase"];
        installPhase = ''
            shopt -s nullglob

            # The repository contains precompiled objects.
            mkdir --parents $out/share/repository

            # Install the distribution, precompiling it.
            perl6 ${install-dist} \
                --from=${src} \
                --to=inst\#$out/share/repository

            # Wrap the executables in the distribution.
            for f in $out/share/repository/bin/*; do
                mkdir --parents $out/bin
                makeWrapper ${rakudo}/bin/perl6 $out/bin/$(basename $f) \
                    --set PERL6LIB inst\#$out/share/repository \
                    --add-flags "$f"
            done
        '';
    }
