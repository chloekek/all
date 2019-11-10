unit module Hello;

sub hello(Str() $who) is export
{
    say qq｢Hello, $who!｣;
}
