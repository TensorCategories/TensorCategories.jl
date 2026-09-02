```@meta
DocTestSetup = :(using TensorCategories, Oscar)
```

# [Base fields and exact computation](@id base-fields)

A field is part of the input. It specifies the available scalars, how equality
is decided, and which algebra algorithms can be used. The interface calls it
the `base_ring`, even when the mathematics requires a field. A method accepting
`::Ring` does not imply that its algorithm works over every ring.

## Fusion categories and algebraic closure

The usual characteristic-zero theory of fusion categories works over an
algebraically closed field $k$. In particular, the endomorphism algebra of every
simple object is then $k$, so semisimple categories are split. EGNO adopts this
setting for most of its treatment and discusses arbitrary fields separately in
§4.16 [EGNO](@cite).

OSCAR can work exactly over the algebraic closure
$\overline{\mathbb Q}$:

```jldoctest
julia> Qbar = algebraic_closure(QQ)
Algebraic closure of rational field
```

This is an exact field of algebraic numbers, not a floating-point model of
$\mathbb C$. For characteristic-zero fusion categories it is large enough in
principle: every multifusion category can be defined over an algebraic number
field; see [EGNO](@citet), Corollary 9.1.8.

For computations, however, it is usually preferable to retain a reasonably
small number field containing the structural coefficients. This keeps the
field of definition visible and generally gives smaller exact linear-algebra
problems. It also exposes the different complex realizations of the same
algebraic data. The algebraic closure remains useful when roots must be chosen
or objects must be split, but not every package algorithm supports every exact
field equally well.

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

A **number field** is a finite extension of $\mathbb Q$. OSCAR presents it by
an algebraic generator and a polynomial relation. For example, to use a square
root of $2$ exactly, construct $K=\mathbb Q(s)$ with $s^2=2$:

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
OSCAR's `abelian_closure(QQ)` contains the abelian algebraic extensions, not all
algebraic numbers. Support for an operation can be narrower than this list.

## Number fields and complex embeddings

An abstract number field does not by itself choose a copy inside $\mathbb C$.
A complex embedding
$\iota\colon K\hookrightarrow\mathbb C$ chooses a complex root of the defining
polynomial as the image of the generator. Thus $\mathbb Q(s)$ with $s^2=2$ has
two complex embeddings, sending $s$ to $\sqrt2$ and $-\sqrt2$. OSCAR enumerates
them with `complex_embeddings`:

```@example fields
embeddings = complex_embeddings(K)
@assert length(embeddings) == 2
@assert overlaps(embeddings[1](s), -embeddings[2](s))
length(embeddings)
```

The exact field element $s$ and its value $\iota(s)$ play different roles.
TensorCategories.jl stores structural coefficients in the exact field. A
complex embedding selects their numerical realization, represented by
certified complex balls. This choice can determine which realization is
unitary and which signs or phases appear in F- and R-symbols.

`K(3)` constructs a scalar in `K`. Independently constructed isomorphic fields
do not automatically identify their chosen roots. Specify the intended embedding
when extending scalars:

```julia
D = extension_of_scalars(C, L; embedding = iota)
```

Here `iota` maps the old field into `L`, and scalar extension applies it to every
coefficient of the structural maps. An embedding, a change of basis, and a
change of pivotal structure are different operations.

## Galois conjugation

Let the structural coefficients lie in a number field $K$. Applying a field
embedding to every coefficient preserves the polynomial pentagon and hexagon
equations. The resulting solution is called a **Galois conjugate**. Its fusion
multiplicities are unchanged, while its embedded F- and R-symbols, pivotal
dimensions and twists when present, and unitarity properties can change.
Different embeddings become restrictions of automorphisms after passing to a
normal closure; the field $K$ itself need not be Galois. Thus Galois conjugation
is more general than ordinary complex conjugation. Galois-conjugate data need
not define equivalent complex fusion categories. EGNO uses this coefficientwise
action in the proof of Proposition 9.6.5 [EGNO](@cite).

The standard rank-two example is the pair of Fibonacci and Yang–Lee
realizations: they have the same fusion rule
$\tau\otimes\tau=\mathbb 1\oplus\tau$, but the two roots of the defining
quadratic equation give a unitary realization and its nonunitary Galois
conjugate [rowell2009classification](@cite), §5.3. The
[Fibonacci catalogue entry](../F-symbols/Fibonacci.md) shows how this choice
appears in the package.

Choosing an embedding and enlarging the coefficient field should be
distinguished. The former selects a conjugate realization of the coefficients;
the latter can also create new direct-sum decompositions of objects.

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

## Splitting over the chosen field

A simple object can decompose after scalar extension. In the finite semisimple
setting, *split* means that the endomorphism algebra of each simple is the base
field. The familiar identification of simple endomorphisms with scalars needs
this hypothesis; see [EGNO](@citet), §4.16, pp. 87–88. A category can be split
over a number field even though that field is not algebraically closed. When it
is not split, a simple object may instead have a finite-dimensional division
algebra over the base field as its endomorphism algebra. This is the main source
of the additional phenomena over non-algebraically closed fields
[sanford2025fusion](@cite).

The distinction is computationally important. The scalar F-symbol model assumes
split simples and chosen bases of their fusion spaces. The general category
interface can also represent non-split categories, but multiplicities,
decomposition, scalar extension, and center computations must then retain the
simple endomorphism algebras. Treating them as copies of the base field gives
wrong multiplicities.

The Ising category above is split, but its center need not split over the same
field. This is a result about that field, not an incomplete center calculation.
The [center tutorial](@ref ising-center) follows scalar extension and splitting.
The terminology used by the package is summarized under
[Splitting and categorical structures](@ref tensor-conventions); the center
algorithms over non-splitting fields are developed by
[maurer2024computing](@citet), §2.1.

Positive characteristic introduces a separate issue: a category can fail to be
semisimple. Changing the coefficient field does not repair this failure.
