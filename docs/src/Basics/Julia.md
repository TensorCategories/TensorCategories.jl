# Julia and OSCAR

This manual assumes familiarity with categories, but no previous experience with
Julia. We introduce the language features we need as we go. For more about the
language itself, see [Getting Started in the Julia manual](https://docs.julialang.org/en/v1/manual/getting-started/).

Julia's type system and multiple dispatch let us use the same mathematical
operation for quite different representations of categories.

## Starting a session

Install Julia, start it, and enter the following at the REPL prompt:

```julia
import Pkg
Pkg.add("TensorCategories")
```

This installs the package and its dependencies, including
[OSCAR](https://www.oscar-system.org/). In each new session, load them with

```julia
using TensorCategories, Oscar
```

Installing a package and loading it are different operations; you need not
install it again each session.

!!! note "First computations"
    Julia compiles code when it is first needed. Loading packages and running a
    computation for the first time can therefore take longer than repeating it.
    Keep the session open while working through the manual.

## Integers, types, and parents

Julia can be used as a calculator:

```jldoctest
julia> 1 + 1
2

julia> BigInt(2)^64
18446744073709551616
```

Ordinary integer literals have type `Int`, usually a 64-bit machine integer.
Arithmetic can overflow: on a 64-bit system, `2^64` is `0`.
Use `BigInt` or OSCAR's integers `ZZ` for integers of unbounded size.

Every Julia value has a *type*, which determines the applicable methods.
An algebraic element also has a *parent*: for example, a polynomial belongs to
a particular polynomial ring. Elements of distinct rings can have the same
Julia type. The same distinction matters for categories.

## Computer algebra

OSCAR supplies the rings, fields, matrices, groups, and algebra algorithms used
by TensorCategories.jl:

```@example julia
using TensorCategories, Oscar
R, x = polynomial_ring(ZZ, "x")
f = x^2 + 2*x + 1
f^2
show(stdout, MIME"text/plain"(), f^2); println() # hide
```

Here `R, x = ...` assigns two returned values to two variables. The name `x`
denotes an element of `R`, not an unspecified complex number. `ZZ` denotes the
integers and `QQ` the rational field.

## Reading Julia examples

Indices start at **1**. A vector is written `[a, b, c]`; a matrix is written
`[a b; c d]`. A semicolon separates rows. Use `matrix(K, ...)` to construct
an OSCAR matrix over a specified field:

```@example julia
A = matrix(QQ, [1 2; 3 4])
@assert A[1, 2] == 2
size(A)
```

An exclamation mark, as in `set_associator!`, conventionally indicates mutation.
A dot applies an operation elementwise: `dim.(simples(C))` applies `dim` to every
simple object. A trailing semicolon suppresses the display of a result.

Type `?` followed by a name in the REPL for help. Type `\otimes` followed by Tab
to enter `⊗`; `tensor_product(X,Y)` is its spelled-out form. Similarly, `\oplus`
and `\circ` produce `⊕` and `∘`.

Continue with [Base fields](@ref base-fields), then [A first computation](@ref first-category).
