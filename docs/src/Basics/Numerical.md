# [Numerical computations](@id numerical-computations)

Numerical categories are a first-class use case. They are particularly useful
for large center computations and for fusion data arising in mathematical
physics, where F- and R-symbols are often manipulated numerically. The public
category interface remains the same as for exact coefficients; comparisons and
linear algebra use methods appropriate to the coefficient field. The unitary
fusion-space construction used for centers is developed in
[maeurer2026thesis](@cite), §§4.2.4--4.3, and its numerical application to the
Haagerup center is described in §5.2.3.

## Arbitrary-precision ball arithmetic

`ArbField(p)` and `AcbField(p)` provide real and complex ball arithmetic with a
user-selected working precision of $p$ bits. A ball records a midpoint together
with an error radius, and arithmetic propagates the enclosure. This is
arbitrary-precision arithmetic in the sense that $p$ may be chosen as large as
needed. A particular field, category, and computation nevertheless use one
chosen working precision. The implementation does not automatically increase
that precision unless an algorithm explicitly says so. The arithmetic model is
described by [johansson2017arb](@cite).

This differs from ordinary `Float64` arithmetic in two ways: the working
precision is not restricted to 53 binary digits, and uncertainty is part of
the scalar. The numerical branches of the package recognize `ArbField`,
`AcbField`, and `ComplexField`; conversions produced by `numeric` normally use
`AcbField`.

## Exact and numerical models

When exact structural data are available, retain the exact category as the
source and create a numerical copy for the expensive computation. Exact data
support algebraic equality and exact field operations. Numerical data support
high-precision linear algebra and give answers relative to the selected
precision.

```@example numerical_category
using TensorCategories, Oscar
E = anyonwiki(3,1,0,1,1,1,1)
C = numeric(E,128)
K = base_ring(C)
@assert K isa AcbField
precision(K)
```

The argument of `numeric(E,p)` controls the target approximation precision.
The conversion may use additional guard bits, so
`precision(base_ring(C))` is the authoritative working precision of the
resulting category. One may also request numerical AnyonWiki data directly:

```julia
C = anyonwiki(AcbField(128),3,1,0,1,1,1,1)
```

To study stability, construct a fresh numerical category from the exact source
at each precision. Raising the precision of a field cannot restore information
that was already lost when decimal or low-precision data were imported.

## Evaluating exact fusion data

Exact data over a number field do not by themselves choose a complex
realization. Select a complex embedding and then evaluate the structural data
at the required precision:

```@example numerical_evaluation
using TensorCategories, Oscar
K, s = quadratic_field(2)
C = ising_category(K, s)
e = first(complex_embeddings(K))
numeric_data = numeric_F_symbols(C, e; precision = 128)
@assert length(numeric_data) == length(F_symbols(C))
e(s)
show(stdout, MIME"text/plain"(), e(s)); println() # hide
```

Inspect `e(s)` to see which embedding was selected. Precision is measured in
bits. Complex balls represent enclosures; overlapping balls do not prove exact
equality. Higher working precision cannot recover data lost through earlier
rounding. Numerical evaluation does not itself supply a unitary structure. See
[Base fields and exact computation](@ref base-fields) for number fields,
complex embeddings, and Galois conjugation.

## Equality and overlap

Structural equality `==` remains an equivalence relation. It is not replaced by
ball overlap, because overlap is not transitive. Numerical algorithms instead
use explicit tests such as `overlaps(x,y)` or `contains_zero(x)` at the point
where the mathematics asks whether two enclosures are compatible or whether a
quantity may vanish.

For a categorical equation $f=g$, the numerical question is whether the
computed matrices for $f$ and $g$ agree at the working precision. The pentagon
and hexagon predicates select this numerical comparison automatically:

```julia
pentagon_axiom(C)
hexagon_axiom(C)
```

No separate numerical category interface is needed.

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

This distinction is particularly important for coherence equations. A small
pentagon or hexagon residual containing zero says that the supplied numerical
data satisfy the equation at the chosen working precision. It does not prove
that the residual is exactly zero. Nor does it prove that the input balls
contain a simultaneous exact solution of all coherence equations; interval
dependencies prevent that conclusion from zero containment alone.

To turn independently supplied approximate F- and R-symbols into a proof of an
exact fusion category, one needs additional mathematics, such as exact
algebraic reconstruction or a validated existence-and-uniqueness argument for
the polynomial equations. Such certification is not currently performed by
TensorCategories.jl. When a numerical category is obtained from exact source
data, retain that source: it supplies the exact algebraic information, while
the ball computation supplies rigorous enclosures and may certify separated
properties such as nonvanishing.

## Unitarity and modularity

We use the mathematical definitions in [EGNO](@cite). For a category over a
numerical field, `is_unitary(C)` tests the supplied structure in its stored
fusion bases at the working precision. For a `SixJCategory`, this includes the
chosen spherical structure, agreement of categorical and Frobenius--Perron
dimensions, and unitarity of the associator matrices. It does not search for a
different gauge in which a nonunitary set of matrices might become unitary.

Similarly, `is_modular(C)` evaluates the determinant of the S-matrix and
returns `true` when its numerical enclosure excludes zero. If the enclosure
contains zero, the chosen precision does not establish nondegeneracy; rerun the
calculation at higher precision before interpreting the result as a
mathematical obstruction.

For example, the numerical AnyonWiki Ising category is checked through the
same public predicates used for exact categories:

```@example numerical_properties
using TensorCategories, Oscar
C = anyonwiki(AcbField(128),3,1,0,1,1,1,1)
@assert pentagon_axiom(C)
@assert hexagon_axiom(C)
@assert is_unitary(C)
@assert is_modular(C)
nothing # hide
```

The helper `is_unitary_numeric` remains available when code specifically wants
to require a numerical coefficient field, but users normally call
`is_unitary`.

## Numerical centers and skeletonization

A numerical center computation follows the same categorical construction as an
exact one:

```julia
C = numeric(anyonwiki(3,1,0,1,1,1,1),256)
Z = center(C)
simples(Z)
S = skeletonize(Z)
```

For unitary input, numerical skeletonization uses orthonormal fusion-space bases
and computes F- and R-symbols in one common gauge. The resulting skeletal
category can be checked and serialized with the ordinary interface:

```julia
@assert is_unitary(S)
@assert is_modular(S)
@assert pentagon_axiom(S)
@assert hexagon_axiom(S)
```

The complete pentagon test examines every quadruple of simple objects and can
be expensive. `randomized_pentagon_axiom(S,n)` checks $n$ randomly selected
quadruples and is useful during a long computation, but it is not a replacement
for the complete test when final validation is feasible.

For a center $\mathcal Z(\mathcal C)$ of a fusion category, useful independent
checks include the expected global dimension

```math
\dim\mathcal Z(\mathcal C)=(\dim\mathcal C)^2,
```

the fusion rules, unitarity when applicable, nondegeneracy of the S-matrix, and
the pentagon and hexagon equations. These checks probe different parts of the
construction.

## Precision studies

A numerical result should be tested at more than one precision when it will be
used as mathematical evidence. A typical workflow is:

1. construct the numerical category from the exact or independently supplied
   source at $p$ bits;
2. compute the desired category, center, or modular data;
3. check the relevant coherence, dimension, unitarity, and nondegeneracy
   identities;
4. repeat from the source at a larger precision, such as $2p$ bits; and
5. compare fusion rules and gauge-invariant quantities.

Raw F- and R-symbol entries depend on simple labels and fusion bases. They need
not agree entry by entry after a computation chooses a different gauge. The
[convention page](@ref f-conventions) specifies the matrix directions, while
the [data exchange page](@ref symbol-data) specifies the dictionary layouts and
file metadata.

## Numerical symbol files

`numeric_F_symbols` and `numeric_R_symbols` evaluate exact fusion data under a
chosen complex embedding. `numeric_symbols_to_csv` stores the resulting real
and imaginary parts, together with convention metadata when a nondefault
layout is used. `load_numeric_fusion_category` reconstructs the matrices over
the `AcbField` supplied by the caller.

The keyword `check=true` on the loader checks the format, completeness, and
block dimensions. After loading, use `pentagon_axiom`, `hexagon_axiom`,
`is_unitary`, and `is_modular` as appropriate. Saving and loading must preserve
the same F- and R-symbol convention; see
[Structural data and data exchange](@ref symbol-data) for examples.
