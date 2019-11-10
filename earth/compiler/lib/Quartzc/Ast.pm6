unit module Quartzc::Ast;

class Block {…}
role Expression {…}

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

class IfStatement
    does Statement
{
    has Expression $.condition;
    has Block      $.if-true;
    has Block      $.if-false;
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

class StubExpression
    does Expression
{
    has Str $.which;
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
