# HMathParser
Mathematical parser and evaluator made in pure Lua

# Licensing
HMathParser is distibuted under MIT license and I do not apply any more restrictions to this project.

# Feedback
This software is built as part of HFSoftware, and if you have any question or want to help with development - you could always join HFSoftware discord server and talk to me (if I am not busy). The same is for any licensing questions - if you are not sure about restrictions of license, feel free to ask. HFSoftware Discord server: https://discord.gg/dDzK7vS

# Syntax

HMathParser evaluates expressions based on AST (Abstract Syntax Tree). It supports enclosed expressions (using `()`), variables, binary and prefix operators, functions calls and other things.

All input expressions are splitted by `;`, so `1 + 2; 32 + 34` will be two expressions. Result is based on last evaluated expression.

Variables are marked with `$` prefix. There are some constants (variables) provided by the execution context automatically:
- `$pi` - pi constant;
- `$e` - Euler's constant;

Functions should be called as identifier with arguments: `FunctionName(arg1, arg2, ...)`. Function name should not have `$` before it.
Functions that are provided automatically:
 - `abs(a)` - returns an absolute value of `a`;
 - `sin(a)` - returns sine of `a` (`a` is radians!);
 - `cos(a)` - returns cosine of `a` (`a` is radians!);
 - `tan(a)` - returns tangent of `a` (`a` is radians!);
 - `sinh(a)` - returns hyperbolic sine of `a`;
 - `cosh(a)` - returns hyperbolic cosine of `a`;
 - `tanh(a)` - returns hyperbolic tangent of `a`;
 - `deg(a)` - returns degree value of `a` (`a` is radians);
 - `rad(a)` - returns radiant value of `a` (`a` is degrees);
 - `exp(a)` - returns `e^a` (`e` is Euler's constant);
 - `floor(a)` - returns `a` rounded to floor;
 - `ceil(a)` - returns `a` rounded to ceil;
 - `random()` - returns random value from range `(0; 1)`
 - `random(a)` - returns random value from range `[1; a]`
 - `random(a, b)` - returns random value from range `[a; b]`
 - `sqrt(a)` - returns square root of `a`;
 - `ln(a)` - returns natural logarithm of `a`;
 - `log10(a)` - returns decimal logarithm of `a`;
 - `log(a, b)` - returns logarithm of `a` by `b` base
 - `min(...)` - returns minimal of all passed arguments;
 - `max(...)` - returns maximum of all passed arguments;

Binary operators (listed in the descendance of priority):
 - `a ** b`, `a ^ b` - power operator;
 - `a band b`, `a & b` - bit AND operator;
 - `a bor b`, `a | b` - bit OR operator;
 - `a xor b`, `a ~^ b` - bit XOR operator;
 - `a shl b`, `a << b` - bit SHL operator (shift left);
 - `a shr b`, `a >> b` - bit SHR operator (shift right);
 - `a * b` - multiplication operator;
 - `a / b` - division operator;
 - `a div b`, `a // b` - floor division operator;
 - `a updiv b`, `a /^ b` - ceil division operator;
 - `a mod b`, `a % b` - modulo operator;
 - `a + b` - addition operator;
 - `a - b` - subtraction operator;
 - `a == b`, `a != b` - equality comparison operators;
 - `a > b`, `a >= b`, `a < b`, `a <= b` - comparison operators;
 - `a and b`, `a && b` - boolean AND operator;
 - `a or b`, `a || b` - boolean OR operator;
 - `a xor b` - boolean XOR operator;
 - `a = b` - assignment operator, `a` must be a variable (see variables format);
 
Prefix operators:
 - `-a` - unary minus operator;
 - `bnot a`, `~a` - bit NOT operator;
 - `not a`, `!a` - boolean NOT operator;
