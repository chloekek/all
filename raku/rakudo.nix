{stdenv, fetchgit, perl}:
let
    moar-version   = "2019.07.1";
    nqp-version    = "2019.07.1";
    rakudo-version = "2019.07.1";

    moar = stdenv.mkDerivation {
        name = "moar-${moar-version}";
        version = moar-version;

        src = fetchgit {
            url = "https://github.com/MoarVM/MoarVM.git";
            rev = moar-version;
            sha256 = "0j3cgmzq7w4b0q0fsks6vijcd2j668pqsdivxzhm6kn0y2i5dvr3";
        };

        buildInputs = [perl];

        configureScript = "perl ./Configure.pl";
    };

    nqp = stdenv.mkDerivation {
        name = "nqp-${nqp-version}";
        version = nqp-version;

        src = fetchgit {
            url = "https://github.com/perl6/nqp.git";
            rev = nqp-version;
            sha256 = "0jrwiim5gn5l804rhqydq047sk8xczy3mid17d6m5ysjjv8qh7ll";
        };

        buildInputs = [perl];

        configureScript = "perl ./Configure.pl";
        configureFlags = ["--backends=moar" "--with-moar=${moar}/bin/moar"];
    };

    rakudo = stdenv.mkDerivation {
        name = "rakudo-${rakudo-version}";
        version = rakudo-version;

        src = fetchgit {
            url = "https://github.com/rakudo/rakudo.git";
            rev = rakudo-version;
            sha256 = "0p53gqr6xqvhyy8m7szfdl42sm1xjzgyq3a7pwmyfydyzmpwwchw";
        };

        buildInputs = [perl];

        configureScript = "perl ./Configure.pl";
        configureFlags = ["--backends=moar" "--with-nqp=${nqp}/bin/nqp"];
    };

in
    rakudo
