unit module Quartzc::Grammar;

use Quartzc::Ast;

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
        ‘sub’ $<name>=<identifier>
        ‘(’ [ $<parameter-type>=<type> $<parameter-name>=<identifier> ]* %% ‘,’
            ‘-->’ $<return-type>=<type> ‘)’
        $<body> = <block>
    }

    ############################################################################
    # Statements

    proto rule statement {*}

    rule statement:sym<expression>
    {
        <expression> ‘;’
    }

    rule statement:sym<return>
    {
        ‘return’ <expression> ‘;’
    }

    ############################################################################
    # Expressions

    proto rule expression {*}

    rule expression:sym<variable>
    {
        <identifier>
    }

    rule expression:sym<do>
    {
        ‘do’ <block>
    }

    rule expression:sym<...> { ‘...’ || ‘…’ }
    rule expression:sym<!!!> { ‘!!!’ }
    rule expression:sym<???> { ‘???’ }

    ############################################################################
    # Blocks

    rule block
    {
        ‘{’ <statement>* ‘}’
    }

    ############################################################################
    # Types

    proto rule type {*}

    token type:sym<fundamental>
    {
        || u? [ byte || short || int || long || cent ]
        || float || double || real
    }
}

my class Actions
{
    method TOP($/)
    {
        make $<definition>.map(*.made);
    }

    ############################################################################
    # Definitions

    method definition:sym<subroutine>($/)
    {
        my @parameters = $<parameter-type>.map(*.made) Z
                         $<parameter-name>.map(~*);
        make Quartzc::Ast::SubroutineDefinition.new(
            name        => ~$<name>,
            parameters  => @parameters,
            return-type => $<return-type>.made,
            body        => $<body>.made,
        );
    }

    ############################################################################
    # Statements

    method statement:sym<expression>($/)
    {
        make Quartzc::Ast::ExpressionStatement.new(
            expression => $<expression>.made,
        );
    }

    method statement:sym<return>($/)
    {
        make Quartzc::Ast::ReturnStatement.new(
            value => $<expression>.made,
        );
    }

    ############################################################################
    # Expressions

    method expression:sym<variable>($/)
    {
        make Quartzc::Ast::VariableExpression.new(
            variable => ~$/,
        );
    }

    method expression:sym<do>($/)
    {
        make Quartzc::Ast::DoExpression.new(
            block => $<block>.made,
        );
    }

    method expression:sym<...>($/) { make self!stub(‘...’) }
    method expression:sym<!!!>($/) { make self!stub(‘!!!’) }
    method expression:sym<???>($/) { make self!stub(‘???’) }
    method !stub(Str:D $which)
    {
        Quartzc::Ast::StubExpression.new(:$which);
    }

    ############################################################################
    # Blocks

    method block($/)
    {
        make Quartzc::Ast::Block.new(
            statements => $<statement>.map(*.made),
        );
    }

    ############################################################################
    # Types

    method type:sym<fundamental>($/)
    {
        make Quartzc::Ast::FundamentalType.new(
            which => ~$/,
        );
    }
}

sub parse-quartz(Str() $source)
    is export
{
    Grammar.parse($source, actions => Actions).made;
}
