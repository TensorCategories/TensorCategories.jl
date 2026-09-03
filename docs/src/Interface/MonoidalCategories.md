# Tensor products, associators, and duality

The monoidal interface uses the conventions of
[EGNO; Chapters 2 and 4](@citet).

## Tensor products and the unit

The calls `tensor_product(X,Y)` and `X ⊗ Y` return $X\otimes Y$. Tensor product
also acts on morphisms: for $f:X\to X'$ and $g:Y\to Y'$,

```math
f\otimes g:X\otimes Y\longrightarrow X'\otimes Y'.
```

It must satisfy the interchange law

```math
(f'\circ f)\otimes(g'\circ g)
=(f'\otimes g')\circ(f\otimes g).
```

The call `one(C)` returns the tensor unit $\mathbb 1$. In a general monoidal
category, natural isomorphisms
$l_X:\mathbb 1\otimes X\to X$ and $r_X:X\otimes\mathbb 1\to X$ satisfy the
triangle axiom together with the associator
[EGNO; Definition 2.2.8, p. 25](@cite). TensorCategories.jl uses a unit-strict
presentation: tensoring with $\mathbb 1$ returns the corresponding represented
object, and the unit identifications are identities rather than separate maps
in the public interface. The associator itself is not assumed to be trivial.
This is the convention used by [maurer2024computing; §2, pp. 4--5](@citet).

## Associators and coherence

The associator has direction

```math
a_{X,Y,Z}:(X\otimes Y)\otimes Z\longrightarrow X\otimes(Y\otimes Z).
```

`associator(X,Y,Z)` returns this map, and `inv_associator(X,Y,Z)` returns its
inverse. Write parentheses explicitly: even when the two bracketings are equal
as represented objects, their associator need not be the identity.

Skeletal $F$-symbol models impose the corresponding unit normalization on their
associator blocks; see [Unit normalization](@ref unit-normalization).

For a category argument, `pentagon_axiom(C)` enumerates `simples(C)` and checks
every quadruple of simple objects. Over an exact coefficient field, this proves
coherence on all objects in the supported finite semisimple additive models,
where the structural maps extend from direct sums of simples. Over a numerical
ball field the enumeration is still exhaustive, but a successful comparison
has the [working-precision meaning](@ref numerical-fusion-categories) explained
later. During a long computation,
`randomized_pentagon_axiom(C,n)` instead samples $n$ simple-object quadruples;
it is not an exhaustive substitute for the complete check.

## Duality

`dual(X)` and `left_dual(X)` denote the chosen left dual $X^*$, with evaluation
and coevaluation

```math
\operatorname{ev}_X:X^*\otimes X\longrightarrow\mathbb 1,
\qquad
\operatorname{coev}_X:\mathbb 1\longrightarrow X\otimes X^*.
```

One triangle identity is written in the package's composition convention as

```julia
(id(X) ⊗ ev(X)) ∘ associator(X, dual(X), X) ∘
    (coev(X) ⊗ id(X)) == id(X)
```

The dual object alone does not determine these maps. A rigid category also has
chosen right duality data

```math
\widetilde{\operatorname{ev}}_X:
X\otimes{}^*X\longrightarrow\mathbb 1,
\qquad
\widetilde{\operatorname{coev}}_X:
\mathbb 1\longrightarrow{}^*X\otimes X.
```

The methods `right_dual(X)`, `right_ev(X)`, and `right_coev(X)` expose this
data. In the generic implementation they transport the left duality through a
supplied pivotal isomorphism; a category without such a pivotal structure must
provide category-specific methods. The generic `ev` and `coev` reconstruction
is available only for a [multifusion category](@ref tensor-conventions), hence
in the split finite semisimple setting. Concrete representations can supply
duality maps directly without using that fallback.

## [Pivotal and spherical structures](@id pivotal-braided)

A pivotal structure is a monoidal natural isomorphism
$j_X:X\to X^{**}$. The method `pivotal(X)` returns its component. Together with
the chosen duality, it determines left and right pivotal traces. Following
[EGNO; Definition 4.7.14 and Theorem 4.7.15, p. 75](@citet), the pivotal
structure is spherical when $\dim(X)=\dim(X^*)$ for every object $X$; this
condition implies equality of the left and right pivotal traces of every
endomorphism. In supported models,
`is_pivotal(C; check=true)` and `is_spherical(C; check=true)` check the supplied
structure; equality of dimensions alone does not establish pivotal coherence.
The generic pivotal check verifies invertibility and tensor compatibility on
the chosen simple representatives. It assumes that the supplied components are
natural; in particular, it does not test naturality against non-scalar
endomorphisms of a non-split simple.
The generic checked spherical predicate is implemented for split semisimple
categories: it first verifies pivotal coherence and then compares left and right
dimensions on the chosen simple representatives. A non-split model needs a
category-specific method; the generic predicate otherwise returns `false` even
when a spherical structure exists mathematically.

For the later [skeletal fusion model](@ref skeletal-fusion), implemented by
`SixJCategory`, `pivotal_structures(C)` solves for pivotal components when $C$
is multifusion. The current solver supports only zero-dimensional solution
schemes over coefficient fields handled by its polynomial solver; it raises an
error when the solution scheme is positive-dimensional. This routine searches
for structures, whereas `is_pivotal` checks one already stored or supplied.

## Traces and dimensions

For an endomorphism $f:X\to X$, `left_trace(f)` and `right_trace(f)` use the
chosen duality and pivotal structure. The abbreviation `tr(f)` means the left
trace. These traces are endomorphisms of the tensor unit. The scalar returned
by `dim(X)` therefore requires the trace to be a multiple of
$\operatorname{id}_{\mathbb 1}$ over the coefficient field. This is automatic
when the unit is scalar, as it is in a fusion category; a weak fusion model
with non-scalar unit needs a category-specific scalar convention.

With that hypothesis, the package conventions are

```math
\dim(X)=\dim_L(X),
\qquad
|X|^2=\dim(X)\dim(X^*).
```

The corresponding calls are `dim(X)` and
`TensorCategories.squared_norm(X)`. The package makes the latter expression
available for any object for which the two dimensions can be computed. In the
standard terminology, the squared norm is defined for a simple object and is
independent of the chosen isomorphism to its double dual; for a simple $X$ in a
pivotal category it agrees with the product displayed above
[EGNO; Definition 7.21.2, p. 179](@cite). In a spherical category
$|X|^2=\dim(X)^2$.

For a [multifusion category](@ref tensor-conventions) with simple
representatives $S_i$, the generic category dimension is

```math
\dim(\mathcal C)=\sum_i |S_i|^2,
```

which is returned by `dim(C)` when the requisite pivotal dimensions are
available. This agrees with the pivotal-independent categorical dimension of
[EGNO; Definition 7.21.3, p. 179](@cite). It is the quantity used later to
normalize the $S$-matrix and is distinct from the Frobenius--Perron dimension,
which depends only on the [Grothendieck ring](@ref grothendieck-rings).

## Braiding

`braiding(X,Y)` returns

```math
c_{X,Y}:X\otimes Y\longrightarrow Y\otimes X.
```

A braiding must satisfy both hexagon equations with the chosen associator. For a
category argument, `hexagon_axiom(C)` checks all triples in `simples(C)`; as for
the pentagon, this is an all-object check in the supported finite semisimple
additive models. Given a pivotal structure, the package's twist convention is
$\theta_X=u_X^{-1}j_X$, where $j_X:X\to X^{**}$ is the pivotal isomorphism
and $u_X:X\to X^{**}$ is the Drinfeld isomorphism
[EGNO; §8.10](@cite). Braiding and pivotal structure alone do not yet supply
the finiteness and semisimplicity hypotheses needed for a finite $S$-matrix.
Premodular and modular fusion categories, including the package's $S$-matrix
normalization, are defined on the next page.

Continue with [Fusion categories and splitting](@ref tensor-conventions).
