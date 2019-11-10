unit module Quartzc::Grammar;

my grammar Grammar
{
    rule TOP
    {
        <definition>*
    }

    token identifier
    {
        <[ A .. Z a .. z _ \- ]>
        <[ A .. Z a .. z 0 .. 9 _ \- ]>*
    }

    ############################################################################
    # Definitions

    proto rule definition {*}

    rule definition:sym<subroutine>
    {
        ‘sub’ <identifier>
        ‘(’ [ <type> <identifier> ]* %% ‘,’ ‘-->’ <type> ‘)’
        <block>
    }

    ############################################################################
    # Statements

    proto rule statement {*}

    rule statement:sym<expression>
    {
        <expression> ‘;’
    }

    ############################################################################
    # Expressions

    proto rule expression {*}

    rule expression:sym<variable>
    {
        <identifier>
    }

    ############################################################################
    # Blocks

    rule block
    {
        ‘{’ <statement>* ‘}’
    }

    ############################################################################
    # Types

    proto rule type {*}

    rule type:sym<fundamental>
    {
        || byte  || short  || int  || long  || cent
        || ubyte || ushort || uint || ulong || ucent
        || float || double || real
    }
}

my class Actions
{
}

sub parse-quartz(Str() $source)
    is export
{
    Grammar.parse($source, actions => Actions);
}
