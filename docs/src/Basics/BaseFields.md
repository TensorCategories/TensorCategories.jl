```@meta
DocTestSetup = :(using TensorCategories, Oscar)
```

# [Base fields and exact computation](@id base-fields)

For a linear category, the coefficient field or ring is part of the input. It
specifies the available scalars, how equality is decided, and which algebra
algorithms can be used. The interface calls it the `base_ring`, even when the
mathematics requires a field. A method accepting `::Ring` does not imply that
its algorithm works over every ring.

## Exact scalars and number fields

Ordinary division of Julia integers produces floating-point numbers. For exact
rational arithmetic, work in `QQ`:

```jldoctest
julia> a = QQ(1)/3;

julia> 3*a == 1
true

julia> parent(a) == QQ
true
```

A **number field** is a finite extension of $\mathbb Q$. OSCAR presents it by
an algebraic generator and a polynomial relation. For example, to use a square
root of $2$ exactly, construct $K=\mathbb Q(s)$ with $s^2=2$. The supplied
Ising constructor is used here only to show that a category retains this field;
its categorical operations appear in [A first computation](@ref first-category).

```@example fields
using TensorCategories, Oscar
K, s = quadratic_field(2)
@assert s^2 == 2
C = ising_category(K, s)
@assert base_ring(C) == K
base_ring(C)
```

The element $s$ is an algebraic generator; inside the abstract field it is not
the *positive* square root. That distinction requires an embedding into the
complex numbers.

Useful coefficient domains include `QQ`, number fields,
`algebraic_closure(QQ)` for algebraic numbers, and `GF(p)` for a prime field.
The field returned as the first component of `abelian_closure(QQ)` contains the
abelian algebraic extensions, not all algebraic numbers. The second component
constructs its distinguished roots of unity. Support for an operation can be
narrower than this list.

## Algebraic closure and fields of definition

The usual characteristic-zero theory of
[fusion categories](@ref tensor-conventions) works over an
algebraically closed field $k$. In particular, the endomorphism algebra of every
simple object is then $k$, so semisimple categories satisfy the
[split condition defined below](@ref splitting-over-field).
[EGNO; §4.16](@citet) use this setting for most of their treatment and discuss
arbitrary fields separately.

OSCAR can work exactly over the algebraic closure
$\overline{\mathbb Q}$:

```jldoctest
julia> Qbar = algebraic_closure(QQ)
Algebraic closure of rational field
```

This is an exact field of algebraic numbers, not a floating-point model of
$\mathbb C$. For a [multifusion category](@ref tensor-conventions) over an
algebraically closed field of characteristic zero, it is large enough in
principle: the category descends to an algebraic number field
[EGNO; Corollary 9.1.8](@cite).

For computations, however, it is usually preferable to retain a reasonably
small number field containing the structural coefficients. This keeps the
field of definition visible and generally gives smaller exact linear-algebra
problems. It also exposes the different complex realizations of the same
algebraic data. The algebraic closure remains useful when roots must be chosen
or objects must be split, but not every package algorithm supports every exact
field equally well.

## Complex embeddings of number fields

An abstract number field does not by itself choose a copy inside $\mathbb C$.
A complex embedding
$\iota\colon K\hookrightarrow\mathbb C$ chooses a complex root of the defining
polynomial as the image of the generator. Thus $\mathbb Q(s)$ with $s^2=2$ has
two complex embeddings, sending $s$ to $\sqrt2$ and $-\sqrt2$. OSCAR returns
their values as certified [complex balls](@ref numerical-computations); the
predicate `overlaps` tests whether two such enclosures intersect. It enumerates
the embeddings with `complex_embeddings`:

```@example fields
embeddings = complex_embeddings(K)
@assert length(embeddings) == 2
@assert overlaps(embeddings[1](s), -embeddings[2](s))
length(embeddings)
```

The exact field element $s$ and its value $\iota(s)$ play different roles.
TensorCategories.jl stores structural coefficients in the exact field. A
complex embedding selects their numerical realization. This choice can
determine which realization is
unitary and which signs or phases appear in
[$F$- and $R$-symbols](@ref f-conventions).

`K(3)` constructs a scalar in `K`. Independently constructed isomorphic fields
do not automatically identify their chosen roots. Specify the intended
embedding when extending scalars.

The schematic call `extension_of_scalars(C, L; embedding=iota)` uses a chosen
map `iota` from the old field into `L` and applies it to every coefficient of
the structural maps. The concrete construction of `L` and `iota` depends on the
coefficient fields. An embedding, a change of basis, and a change of
[pivotal structure](@ref pivotal-braided) are different operations.

## Galois conjugation

Let the structural coefficients lie in a number field $K$. Applying a field
embedding to every coefficient preserves the polynomial pentagon and hexagon
equations. The resulting solution is called a **Galois conjugate**. Its fusion
multiplicities are unchanged, while its embedded $F$- and $R$-symbols, pivotal
dimensions and twists when present, and unitarity properties can change.
Different embeddings become restrictions of automorphisms after passing to a
normal closure; the field $K$ itself need not be Galois. Thus Galois conjugation
is more general than ordinary complex conjugation. Galois-conjugate data need
not define equivalent complex fusion categories. This coefficientwise action
is used in the proof of [EGNO; Proposition 9.6.5](@citet).

The standard rank-two example is the pair of Fibonacci and Yang–Lee
realizations: they have the same fusion rule
$\tau\otimes\tau=\mathbb 1\oplus\tau$, but the two roots of the defining
quadratic equation give a unitary realization and its nonunitary Galois
conjugate [rowell2009classification; pp. 3--4](@cite). The
[Fibonacci catalogue entry](../F-symbols/Fibonacci.md) shows how this choice
appears in the package.

These operations are distinct: choosing an embedding selects a conjugate
realization of the coefficients, whereas enlarging the coefficient field can
also create new direct-sum decompositions of objects.

## [Splitting over the chosen field](@id splitting-over-field)

For a simple object $S$, Schur's lemma says that
$D_S=\operatorname{End}_{\mathcal C}(S)$ is a division algebra. The
Hom-finiteness assumption makes $D_S$ finite-dimensional over the base field
$k$. In the finite semisimple setting, *split* means
that the canonical map $k\to D_S$ is an isomorphism for every simple $S$. This
is automatic over an algebraically closed field, but not over a number field.
The familiar identification of simple endomorphisms with scalars therefore
requires the split hypothesis [EGNO; §4.16, pp. 87--88](@cite).

A category can be split over a number field even though that field is not
algebraically closed. When it is not split, a simple object can decompose after
a suitable scalar extension. The division algebras $D_S$ are the main source
of the additional phenomena over non-algebraically closed fields
[sanford2025fusion](@cite).

The distinction is computationally important. The scalar
[$F$-symbol model](@ref skeletal-fusion) assumes split simples and chosen bases of
their fusion spaces. The general category interface can also represent
non-split categories, but multiplicities,
decomposition, scalar extension, and center computations must then retain the
simple endomorphism algebras. Treating them as copies of the base field gives
wrong multiplicities.

The Ising category above is split, but its center need not split over the same
field. This is a result about that field, not an incomplete center calculation.
The [center tutorial](@ref ising-center) follows scalar extension and splitting.
The terminology used by the package is summarized under
[Fusion categories and splitting](@ref tensor-conventions) and follows
[maurer2024computing; §2.1](@citet). The center algorithm and the subsequent
splitting of central objects are developed in
[maurer2024computing; §§4--5](@cite).

TensorCategories.jl also supports coefficient fields of positive
characteristic, such as `GF(p)`. This is an important feature: the
characteristic is part of the mathematical input and can change semisimplicity,
splitting, and the behavior of categorical constructions. In positive
characteristic a category can fail to be semisimple, independently of whether
its simple objects are split. Enlarging the coefficient field within the same
characteristic does not repair such a failure of semisimplicity.
The [characteristic example](@ref positive-characteristic-fusion) later in the
manual shows both phenomena for representations of a cyclic group.

Continue with [Numerical computations](@ref numerical-computations).
