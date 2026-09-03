# [Numerical computations](@id numerical-computations)

A numerical computation begins with a choice of coefficient field, just as an
exact computation does. This page explains the scalar model used by
TensorCategories.jl: arbitrary-precision ball arithmetic, comparison at a chosen
working precision, and the mathematical conclusions that ball enclosures can
support. These points do not depend on a particular category model.

The later chapter on [numerical fusion categories](@ref numerical-fusion-categories)
applies this scalar model to $F$- and $R$-symbols, coherence, unitarity, and
modularity. After defining Drinfeld centers and half-braidings, the
[center chapter](@ref numerical-centers) applies the same model to numerical
center computations.

## Arbitrary-precision ball arithmetic

`ArbField(p)` and `AcbField(p)` provide real and complex ball arithmetic with a
user-selected working precision of $p$ bits. A ball records a midpoint together
with an error radius, and arithmetic propagates the enclosure. This is
arbitrary-precision arithmetic in the sense that $p$ may be chosen as large as
needed. A particular field, category, and computation nevertheless use one
chosen working precision. The implementation does not automatically increase
that precision unless an algorithm explicitly says so. The arithmetic model is
described by [johansson2017arb](@citet). Its use for numerical center and
$F$- and $R$-symbol computations in TensorCategories.jl is described in
[maeurer2026thesis; §5.2.3](@citet).

For example, this constructs a real ball field with $128$ bits of working
precision:

```@example numerical_scalars
using Oscar
R = ArbField(128)
x = sqrt(R(2))
@assert contains_zero(x^2 - R(2))
precision(R)
```

This differs from ordinary `Float64` arithmetic in two ways: the working
precision is not restricted to 53 binary digits, and uncertainty is part of
the scalar. The common numerical comparisons recognize `ArbField`, `AcbField`,
and `ComplexField` as ball coefficient fields; a category-specific algorithm
can have narrower coefficient-field methods. In an `ArbField(p)` or
`AcbField(p)`, the chosen precision belongs to the field and therefore to the
category over that field. `ComplexField()` instead uses Nemo's mutable global
ball precision. For reproducible category computations, prefer `AcbField(p)`;
conversions produced by `numeric` use it.

## Exact and numerical models

Exact scalars and numerical balls answer different questions. Exact fields
support algebraic equality and symbolic field operations. Numerical fields
support high-precision analytic and linear-algebra computations and retain an
enclosure for every result. When exact source data are available, keep them and
construct a new numerical model for each numerical computation. The exact
source records the algebraic object; the numerical model records one
approximation at one chosen working precision.

For a supported object `E`, `numeric(E,p)` requests a numerical realization at
approximately $p$ bits. Conversions can use additional internal precision
(guard bits), so the precision of the resulting base field is authoritative.
For a [skeletal fusion category](@ref skeletal-fusion) over a number field,
this conversion uses the complex embedding stored with the category;
the abstract number field alone does not determine a numerical realization.
The [numerical $F$-symbol workflow](@ref numerical-fusion-categories) explains how to
supply an embedding explicitly when one is not already stored. Increasing the
precision of a field cannot recover information already lost through decimal
or low-precision input.

## Equality and overlap

Structural equality `==` remains an equivalence relation. It is not replaced by
ball overlap, because overlap is not transitive. Numerical algorithms instead
use explicit tests such as `overlaps(x,y)` or `contains_zero(x)` at the point
where the mathematics asks whether two enclosures are compatible or whether a
quantity may vanish.

## Rigorous enclosures versus exact algebra

Ball arithmetic makes the **enclosure** rigorous, provided the input balls
rigorously enclose the intended coefficients. Suppose that a ball $B$ contains
an exact quantity $b$. Then

- If $0\notin B$, then the exact quantity satisfies $b\neq0$;
- disjoint balls containing $b$ and $c$ prove $b\neq c$; but
- if $0\in B$, or if two balls overlap, this does not prove equality.

Thus a numerical calculation can produce an exact mathematical conclusion. For
example, a determinant ball excluding zero certifies nonvanishing. This does not
make every ball-valued computation an exact symbolic computation: the scalar is
still represented by an enclosure rather than by an exact algebraic expression.

How this distinction applies to categorical identities and structural
predicates is explained under
[Numerical fusion categories](@ref numerical-fusion-categories).

Continue with [A first computation](@ref first-category).
