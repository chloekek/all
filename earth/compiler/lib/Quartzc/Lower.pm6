unit module Quartzc::Lower;

use Earthc::Ast;
use Quartzc::Ast;

################################################################################
# Definitions

multi lower(
    Earthc::Ast::Definitions:D $d,
    Quartzc::Ast::SubroutineDefinition:D $q,
    --> Nil
)
    is export
{
    $d.define-subroutine(
        name        => $q.name,
        parameters  => $q.parameters.map({ lower($d, $_[0]), $_[1] }),
        return-type => lower($d, $q.return-type),
        body        => {
            my $b = Earthc::Ast::SsaBuilder.new;
            my $result = lower($d, $b, $q.body);
            $b.build-return($result);
            $b.ssa;
        },
    );
}

################################################################################
# Statements

multi lower(
    Earthc::Ast::Definitions:D $d,
    Earthc::Ast::SsaBuilder:D $b,
    Quartzc::Ast::ExpressionStatement:D $q,
    --> Earthc::Ast::Value:D
)
    is export
{
    lower($d, $b, $q.expression);
}

multi lower(
    Earthc::Ast::Definitions:D $d,
    Earthc::Ast::SsaBuilder:D $b,
    Quartzc::Ast::IfStatement:D $q,
    --> Earthc::Ast::Value:D
)
    is export
{
    my $condition   = lower($d, $b, $q.condition);
    my $if-true-bb  = $b.new-block;
    my $if-false-bb = $b.new-block;
    my $end-if      = $b.new-block;
    $b.build-conditional-branch($condition, $if-true-bb, $if-false-bb);

    $b.set-block($if-true-bb);
    my $if-true-v = lower($d, $b, $q.if-true);
    $b.build-unconditional-branch($end-if);

    $b.set-block($if-false-bb);
    my $if-false-v = lower($d, $b, $q.if-false);
    $b.build-unconditional-branch($end-if);

    $b.set-block($end-if);

    # TODO: Insert φ instruction???
    $if-true-v;
}

multi lower(
    Earthc::Ast::Definitions:D $d,
    Earthc::Ast::SsaBuilder:D $b,
    Quartzc::Ast::LoopStatement:D $q,
    --> Earthc::Ast::Value:D
)
    is export
{
    my $loop = $b.new-block;
    $b.build-unconditional-branch($loop);
    $b.set-block($loop);
    lower($d, $b, $q.body);
    $b.build-unconditional-branch($loop);
}

multi lower(
    Earthc::Ast::Definitions:D $d,
    Earthc::Ast::SsaBuilder:D $b,
    Quartzc::Ast::ReturnStatement:D $q,
    --> Earthc::Ast::Value:D
)
    is export
{
    my $value = lower($d, $b, $q.value);
    $b.build-return($value);
}

################################################################################
# Expressions

multi lower(
    Earthc::Ast::Definitions:D $d,
    Earthc::Ast::SsaBuilder:D $b,
    Quartzc::Ast::VariableExpression:D $q,
    --> Earthc::Ast::Value:D
)
    is export
{
    # TODO: Look up register for variable somewhere. We probably want a scope
    # class for keeping track of local variables for this. How would such a
    # scope class relate to Earthc::Ast::Definitions?
    Earthc::Ast::RegisterValue.new(register => 0);
}

multi lower(
    Earthc::Ast::Definitions:D $d,
    Earthc::Ast::SsaBuilder:D $b,
    Quartzc::Ast::DoExpression:D $q,
    --> Earthc::Ast::Value:D
)
    is export
{
    lower($d, $b, $q.block);
}

multi lower(
    Earthc::Ast::Definitions:D $d,
    Earthc::Ast::SsaBuilder:D $b,
    Quartzc::Ast::StubExpression:D $q,
    --> Earthc::Ast::Value:D
)
    is export
{
    # TODO: Include source position in message.
    my $message = ｢Stub code executed｣.encode;
    my @arguments = Earthc::Ast::BlobValue.new(bytes => $message);
    given $q.which {
        when ‘...’ { … } # TODO: Build instruction that returns error value.
        when ‘!!!’ { $b.build-call(‘PANIC’, @arguments) }
        when ‘???’ { $b.build-call(‘DEBUG’, @arguments) }
    }
}

################################################################################
# Blocks

multi lower(
    Earthc::Ast::Definitions:D $d,
    Earthc::Ast::SsaBuilder:D $b,
    Quartzc::Ast::Block:D $q,
    --> Earthc::Ast::Value:D
)
    is export
{
    my $r; # TODO: Return unit from an empty block.
    $r = lower $d, $b, $_ for $q.statements;
    $r;
}

################################################################################
# Types

multi lower(
    Earthc::Ast::Definitions:D $d,
    Quartzc::Ast::FundamentalType:D $q,
    --> Earthc::Ast::FundamentalType:D
)
    is export
{
    Earthc::Ast::FundamentalType.new(which => $q.which);
}
