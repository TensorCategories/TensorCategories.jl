```@meta
DocTestSetup = :(using TensorCategories, Oscar)
```

# [Base fields and exact computation](@id base-fields)

A field is part of the input. It specifies the available scalars, how equality
is decided, and which algebra algorithms can be used. The interface calls it
the `base_ring`, even when the mathematics requires a field. A method accepting
`::Ring` does not imply that its algorithm works over every ring.

## Exact scalars

Ordinary division of Julia integers produces floating-point numbers. For exact
rational arithmetic, work in `QQ`:

```jldoctest
julia> a = QQ(1)/3;

julia> 3*a == 1
true

julia> parent(a) == QQ
true
```

To use a square root of 2 exactly, construct a number field:

```@example fields
using TensorCategories, Oscar
K, s = quadratic_field(2)
@assert s^2 == 2
C = ising_category(K, s)
@assert base_ring(C) == K
base_ring(C)
```

The element $s$ is a chosen algebraic generator. A choice of positive real
square root requires an embedding into the complex numbers. Scalar extension
applies one field embedding to every coefficient of the structural maps.

Useful coefficient domains include `QQ`, number fields, `QQBarField()` for
algebraic numbers, and `GF(p)` for a prime field. OSCAR's abelian closure of
`QQ` contains the abelian algebraic extensions, not all algebraic numbers.
Support for an operation can be narrower than this list.

## Parents and embeddings

`K(3)` constructs a scalar in `K`. Independently constructed isomorphic fields
do not automatically identify their chosen roots. Specify the intended embedding
when extending scalars:

```julia
D = extension_of_scalars(C, L; embedding = iota)
```

Here `iota` maps the old field into `L`. An embedding, a change of basis, and a
change of pivotal structure are different operations.

## Numerical evaluation

Keep exact data for algebraic constructions and evaluate it afterwards when a
numerical matrix is wanted:

```@example fields
e = first(complex_embeddings(K))
numeric_data = numeric_F_symbols(C, e; precision = 128)
@assert length(numeric_data) == length(F_symbols(C))
e(s)
show(stdout, MIME"text/plain"(), e(s)); println() # hide
```

Inspect `e(s)` to see which embedding was selected. Precision is measured in
bits. Complex balls represent enclosures; overlapping balls do not prove exact
equality. Higher working precision cannot recover data lost through earlier
rounding. Numerical evaluation does not itself supply a unitary structure. The
full numerical workflow is described under
[Numerical computations](@ref numerical-computations).

## Why the field changes the answer

A simple object can decompose after scalar extension. In the finite semisimple
setting, *split* means that the endomorphism algebra of each simple is the base
field. The familiar identification of simple endomorphisms with scalars needs
this hypothesis; see [EGNO](@citet), §4.16, pp. 87–88.

The Ising category above is split, but its center need not split over the same
field. This is a result about that field, not an incomplete center calculation.
The [center tutorial](@ref ising-center) follows scalar extension and splitting.

Positive characteristic introduces a separate issue: a category can fail to be
semisimple. Changing the coefficient field does not repair this failure.
See [Splitting and categorical structures](@ref tensor-conventions).
