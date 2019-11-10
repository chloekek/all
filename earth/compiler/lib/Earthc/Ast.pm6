unit module Earthc::Ast;

class BasicBlock {…}
class SubroutineDefinition {…}
role Type {…}
role Value {…}

################################################################################
# Definitions

class Definitions
{
    has SubroutineDefinition:D %.subroutines;

    #| Define a new subroutine. Croak if a subroutine with the given name
    #| already exists. The body must be a routine. It will be called by
    #| C<finalize>. This gives it a chance to wait for all subroutines to be
    #| defined before trying to emit call instructions for them.
    method define-subroutine(
        ::?CLASS:D:
        Str:D               :$name!,
                            :@parameters!,
        Earthc::Ast::Type:D :$return-type!,
                            :&body!,
        --> Nil
    )
    {
        die ｢Redefinition｣ if %!subroutines{$name}:exists;
        %!subroutines{$name} = SubroutineDefinition.new(
            :@parameters, :$return-type, :&body,
        );
    }

    #| After providing all definitions, call this subroutine. This will
    #| resolve the thunks that you passed for the subroutine bodies in
    #| C<define-subroutine>.
    method finalize(::?CLASS:D: --> Nil)
        is export
    {
        for %!subroutines.values -> $v {
            $v.body = $v.body.();
        }
    }
}

class SubroutineDefinition
{
    # TODO: The names should be registers, not strings.
    has @.parameters;

    has Type $.return-type;

    # For an elaboration on why this is mutable, see the documentation for the
    # C<finalize> routine.
    has $.body is rw;
}

################################################################################
# Instructions

role Instruction
{
}

class CallInstruction
    does Instruction
{
    has Str     $.callee;
    has Value:D @.arguments;
}

class ReturnInstruction
    does Instruction
{
    has Value $.value;
}

################################################################################
# Values

role Value
{
    # TODO: Add abstract type method.
}

class RegisterValue
    does Value
{
    has Int $.register;
    # TODO: Include type of register.
}

class BlobValue
    does Value
{
    has Blob $.bytes;
}

################################################################################
# SSA

class Ssa
{
    has BasicBlock:D %.basic-blocks{Int:D};
}

class BasicBlock
{
    has @.instructions;
}

#| SsaBuilder allows you to append instructions onto basic blocks, and basic
#| blocks onto SSAs.
#|
#| SsaBuilder also takes care of checking types and inserting coercions.
class SsaBuilder
{
    # TODO: Must be aware of signature of enclosing subroutine.

    has Ssa        $.ssa;
    has BasicBlock $!current;
    has Int        $!next;

    submethod BUILD(--> Nil)
    {
        $!ssa     = Ssa.new;
        $!current = BasicBlock.new;
        $!next    = 0;
        $!ssa.basic-blocks{$!next++} = $!current;
    }

    method !build(::?CLASS:D: Instruction:D $instruction --> Value:D)
    {
        my $register = $!next++;
        $!current.instructions.push($register => $instruction);
        RegisterValue.new(:$register);
    }

    method build-call(::?CLASS:D: Str:D $callee, @arguments --> Value:D)
    {
        # TODO: Insert coercions.
        my $instruction = CallInstruction.new(:$callee, :@arguments);
        self!build($instruction);
    }

    method build-return(::?CLASS:D: Value:D $value --> Value:D)
    {
        # TODO: Insert coercion.
        my $instruction = ReturnInstruction.new(:$value);
        self!build($instruction);
    }
}

################################################################################
# Types

role Type
{
}

class FundamentalType
    does Type
{
    has Str $.which;
}
