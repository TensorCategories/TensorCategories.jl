# [Numerical fusion categories](@id numerical-fusion-categories)

This chapter applies the
[numerical coefficient-field model](@ref numerical-computations) to fusion
categories and their skeletal data. The category interface is
unchanged: objects, morphisms, associators, braidings, and structural predicates
use the same public functions as over exact fields. Their numerical
implementations use ball comparisons and linear algebra at the precision of the
category's base field.

## Passing from exact to numerical fusion data

When exact structural data are available, retain the exact category as the
source and create a numerical copy for the expensive computation. AnyonWiki
entries carry a chosen complex embedding, so they provide convenient exact
sources for this conversion. The following key is an Ising presentation:

```@example numerical_category
using TensorCategories, Oscar
E = anyonwiki(3,1,0,1,1,1,1)
C = numeric(E,128)
K = base_ring(C)
@assert K isa AcbField
precision(K)
```

Here `anyonwiki(...)` loads the exact skeletal category from the packaged
database, and `numeric` applies its stored embedding. The seven key components
and the stored structures are described under [AnyonWiki](AnyonWiki.md).

The argument of `numeric(E,p)` controls the target approximation precision;
omitting $p$ uses $64$ bits. The conversion may use additional guard bits, so
the value returned by
`precision(base_ring(C))` is the working precision of the resulting category.
One may also request numerical AnyonWiki data directly:

```julia
C = anyonwiki(AcbField(128),3,1,0,1,1,1,1)
```

For a precision study, construct a fresh numerical category from the exact
source at each precision. The [general numerical page](@ref numerical-computations)
explains why changing the field later cannot recover information already lost
through approximate input.

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

Inspect `e(s)` to see which embedding was selected. Numerical evaluation does
not itself supply a unitary structure. See
[Base fields and exact computation](@ref base-fields) for number fields,
complex embeddings, and Galois conjugation, and
[Numerical computations](@ref numerical-computations) for the interpretation
of ball enclosures.

## Coherence at the working precision

For a categorical equation $f=g$, the numerical implementation asks whether
the computed enclosures for the matrices of $f$ and $g$ are compatible at the
working precision. The categorical formula is the same as over an exact field;
only the scalar comparison changes. The ordinary pentagon and hexagon
predicates select this numerical comparison automatically:

```julia
pentagon_axiom(C)
hexagon_axiom(C)
```

No separate numerical category interface is needed. A return value of `true`
means that the package accepts the equation at the chosen working precision:
the relevant matrix enclosures overlap. This is compatibility of the computed enclosures, not
a proof that the residual is exactly zero. Nor does it prove that the input
balls contain a simultaneous exact solution of all coherence equations;
interval dependencies prevent that conclusion from zero containment alone.

To prove that independently supplied approximate $F$- and $R$-symbols arise
from, or enclose, the structure constants of an exact fusion category, one
needs additional mathematics, such as exact algebraic reconstruction or a
validated existence-and-uniqueness argument for the polynomial equations. Such
certification is not currently performed by
TensorCategories.jl. When a numerical category is obtained from exact source
data, retain that source: it supplies the exact algebraic information, while
the ball computation supplies rigorous enclosures and may certify separated
properties such as nonvanishing.

## Unitarity and modularity

The mathematical definitions and the package's scope are given under
[dagger structures and unitarity](@ref unitary-categories) and
[premodular categories](@ref premodular-categories). For a category over a
numerical field, `is_unitary(C)` tests the supplied structure in its stored
fusion bases at the working precision. For `SixJCategory`, the package's
[skeletal $F$-symbol model](@ref skeletal-fusion), this includes the
chosen spherical structure, agreement of categorical and Frobenius--Perron
dimensions, and unitarity of the associator matrices. It does not search for a
different gauge in which a nonunitary set of matrices might become unitary,
and it does not separately test the braiding matrices.

When a unitary category is skeletonized using orthonormal bases of its binary
fusion spaces, the resulting associator matrices are unitary
[maeurer2026thesis; §4.2.4](@cite). This explains the orthonormal-basis choice
in the [numerical center workflow](@ref numerical-centers); the predicate
`is_unitary(C)` itself checks the stored gauge rather than changing it.

Similarly, for a numerical `SixJCategory` that is fusion, braided, and
spherical, `is_modular(C)` evaluates the determinant of the $S$-matrix and
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

## Precision studies

A numerical result should be tested at more than one precision when it will be
used as mathematical evidence. A typical workflow is:

1. construct the numerical category from the exact or independently supplied
   source at $p$ bits;
2. compute the desired skeletal or modular data;
3. check the relevant coherence, dimension, unitarity, and nondegeneracy
   identities;
4. repeat from the source at a larger precision, such as $2p$ bits; and
5. compare fusion rules and gauge-invariant quantities.

Raw $F$- and $R$-symbol entries depend on simple labels and fusion bases. They need
not agree entry by entry after a computation chooses a different gauge. The
[convention page](@ref f-conventions) specifies the matrix directions, while
the [data exchange page](@ref symbol-data) specifies the dictionary layouts and
file metadata.

Numerical CSV files are coefficient-interchange files, not lossless
serializations of ball data: they store decimal real and imaginary parts and do
not preserve the input ball radii. A nondefault convention is recorded in a
header, while the default output is headerless and therefore carries
no explicit convention metadata. Their format and loader options are documented
under [Structural data and data exchange](@ref symbol-data).

The later [Drinfeld-center chapter](@ref center) first defines half-braidings
and the center construction, and then gives the corresponding
[numerical center workflow](@ref numerical-centers).

Continue with [Structural data and data exchange](@ref symbol-data) for exact
and numerical formats and their convention handling.
