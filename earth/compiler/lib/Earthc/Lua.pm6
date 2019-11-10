unit module Earthc::Lua;

use Earthc::Ast;

################################################################################
# Definitions

multi translate(Earthc::Ast::Definitions $e --> Nil)
    is export
{
    for $e.subroutines.kv -> $k, $v {
        translate($k, $v);
    }
}

multi translate(Str:D $name, Earthc::Ast::SubroutineDefinition:D $e)
    is export
{
    # TODO: Names of parameters should be registers, not strings.
    say qq｢function {mangle $name}()｣;

    # First declare all registers.
    for $e.body.basic-blocks.values.map(|*.instructions».key) {
        say qq｢    local {mangle $_}｣;
    }

    # Then translate the basic blocks.
    translate $e.body;

    say qq｢end｣;
}

################################################################################
# Instructions

multi translate(Int:D $id, Earthc::Ast::CallInstruction:D $e)
    is export
{
    my $arguments = $e.arguments.map(&translate).join(｢, ｣);
    say qq｢    {mangle $id} = {mangle $e.callee}($arguments)｣;
}

multi translate(Int:D $id, Earthc::Ast::ReturnInstruction:D $e)
    is export
{
    # Return statements may not be followed by other statements. But we do want
    # to generate such code, since we use gotos for control flow. The solution
    # is to wrap the return statement in a block, so that it is the last
    # statement in the block.
    say qq｢    do return {translate $e.value} end｣;
}

################################################################################
# Values

multi translate(Earthc::Ast::RegisterValue:D $e --> Str:D)
{
    mangle $e.register;
}

multi translate(Earthc::Ast::BlobValue:D $e --> Str:D)
{
    ｢"｣ ~ $e.bytes.map({sprintf ｢\x%02X｣, $_}).join ~ ｢"｣;
}

################################################################################
# SSA

multi translate(Earthc::Ast::Ssa:D $e --> Nil)
    is export
{
    for $e.basic-blocks.kv -> $k, $v {
        translate $k, $v;
    }
}

multi translate(Int:D $id, Earthc::Ast::BasicBlock:D $e)
    is export
{
    say qq｢    ::{mangle $id}::｣;
    translate .key, .value for $e.instructions;
}

################################################################################
# Mangling

multi mangle(Int:D $id --> Str:D)
    is export
{
    qq｢_$id｣;
}

multi mangle(Str:D $name --> Str:D)
    is export
{
    $name;
}
