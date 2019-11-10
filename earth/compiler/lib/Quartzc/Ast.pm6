unit module Quartzc::Ast;

class Block {…}

################################################################################
# Definitions

role Definition
{
}

class SubroutineDefinition
    does Definition
{
    has $.name;
    has @.parameters;
    has $.return-type;
    has $.body;
}

################################################################################
# Statements

role Statement
{
}

class ExpressionStatement
    does Statement
{
    has $.expression;
}

class ReturnStatement
    does Statement
{
    has $.value;
}

################################################################################
# Expressions

role Expression
{
}

class VariableExpression
    does Expression
{
    has $.variable;
}

class DoExpression
    does Expression
{
    has Block $.block;
}

################################################################################
# Blocks

class Block
{
    has @.statements;
}

################################################################################
# Types

role Type
{
}

class FundamentalType
    does Type
{
    has $.which;
}
