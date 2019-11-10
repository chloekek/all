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
    has @.parameters;
    has Type $.return-type;

    # For an elaboration on why this is mutable, see the documentation for the
    # C<finalize-definitions> routine.
    has $.body is rw;
}

################################################################################
# Statements

role Instruction
{
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

#| SsaBuilder resembles IRBuilder in LLVM.
class SsaBuilder
{
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

    method build-return(::?CLASS:D: Value:D $value --> Value:D)
    {
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
