# [Fusion categories and splitting](@id tensor-conventions)

This page combines the linear, abelian, semisimple, monoidal, and rigid
structures introduced separately on the preceding pages. The definitions in
[EGNO; §4.1](@citet) initially fix an algebraically closed field, without a
characteristic-zero hypothesis, and [EGNO; §4.16](@cite) explains what changes
over an arbitrary field. The weak fusion terminology used here follows
[maurer2024computing; §2.1](@citet).

## Weak fusion, fusion, and multi variants

A **weak fusion category** over a field $k$ is a finite semisimple $k$-linear
rigid monoidal category with finite-dimensional Hom spaces, $k$-bilinear tensor
product, and simple tensor unit. The package uses **weak multifusion category**
for the analogous structure in which the tensor unit need not be simple.

An object $S$ is **scalar** if the canonical map

```math
\label{eq:simple-endomorphism-field-map}
k\longrightarrow\operatorname{End}_{\mathcal C}(S)
```

is an isomorphism. A weak multifusion category is **multifusion** when all its
simple objects are scalar, and a weak fusion category is **fusion** under the
same condition. Equivalently, the latter is a split weak fusion category. Over
an algebraically closed field, finite-dimensional division algebras are scalar,
so the distinction between weak fusion and fusion disappears. The adjective
“weak” concerns splitting over the coefficient field; it does not weaken
associativity, semisimplicity, or rigidity.

The non-split setting is needed even when one starts with a split fusion
category: its Drinfeld center need not be split over the same coefficient
field. When the global dimension is nonzero, the center is nevertheless a
weak fusion category, and passing to a splitting field produces a split fusion
category [maurer2024computing; Theorem 2.1 and §5](@cite). Thus non-split
categories arise naturally during categorical constructions, even when the
input category is split over its field of definition.

There is a separate issue over an imperfect field. Some treatments require a
(multi)fusion category to be separable. For finite semisimple categories this
condition is automatic over a perfect field, including every finite field, but
can be stronger than semisimplicity over an imperfect field
[sanford2025fusion; Definition 2.9 and the discussion on pp. 3--4](@cite). The
package predicates and this manual use the semisimple convention of
[maurer2024computing; §2.1](@citet).

The corresponding structural vocabulary refines the combinations introduced
earlier under [Models and the category interface](@ref interface-philosophy):

| Predicate | Mathematical structure it names |
|:---|:---|
| `is_multiring(C)` | $k$-linear abelian monoidal structure with biexact tensor product |
| `is_ring(C)` | multiring structure and scalar tensor unit, in the standard terminology |
| `is_multitensor(C)` | rigid multiring structure |
| `is_tensor(C)` | rigid ring structure, in the standard terminology |
| `is_semisimple(C)` | semisimplicity over the current coefficient field |
| `is_split_semisimple(C)` | semisimplicity with scalar simple objects |
| `is_weak_multifusion(C)`, `is_weak_fusion(C)` | finite semisimple versions above |
| `is_multifusion(C)`, `is_fusion(C)` | their split versions |

Generic predicates report declared structure or consequences of stronger
declarations. A category-specific method may instead compute an invariant or
enumerate simple objects, so a predicate can be expensive or unsupported over
a particular coefficient field.

For non-split input, the generic `is_tensor` and `is_ring` predicates do not
test the scalar-unit condition: they return `true` for a category declared
weak fusion, even when the simple tensor unit has endomorphism algebra larger
than $k$. Use `is_fusion(C)` or `is_split_semisimple(C)` when an algorithm
requires scalar simple objects.

## Non-split multiplicities

For a simple object $S$, Schur's lemma makes
$D_S=\operatorname{End}_{\mathcal C}(S)$ a finite-dimensional division algebra
over $k$. If $X$ is semisimple, its multiplicity of $S$ is

```math
\label{eq:nonsplit-simple-multiplicity}
[X:S]=\dim_{D_S}\operatorname{Hom}(S,X)
     =\frac{\dim_k\operatorname{Hom}(S,X)}{\dim_k D_S}.
```

Replacing $D_S$ by $k$ gives incorrect multiplicities. The division algebra
need not be commutative. Over a finite field it is a field, but it need not be
the coefficient field itself.

Scalar extension can require splitting idempotents to obtain all new simple
objects. Changing coefficients and enumerating the new simples are distinct
steps. For supported centers, the [center tutorial](@ref ising-center) explains
`extension_of_scalars` and `split`; the construction table separately explains
the role of [`karoubian_envelope`](BasicConstructions.md).

These multiplicities are the structure constants of the
[Grothendieck ring](@ref grothendieck-rings). Over a non-splitting field they
give a weak fusion ring.

## [Scalar extension and algorithmic splitting](@id algorithmic-splitting)

Let $k\hookrightarrow K$ be a field extension. Extending the coefficients of
a finite $k$-linear category first gives a category $\mathcal C\otimes_k K$
with the same objects and

```math
\label{eq:categorical-scalar-extension-hom}
\operatorname{Hom}_{\mathcal C\otimes_k K}(X,Y)
=\operatorname{Hom}_{\mathcal C}(X,Y)\otimes_k K.
```

This operation can create idempotent endomorphisms whose images were not
objects of the original category. The scalar extension relevant here is
therefore the idempotent completion

```math
\label{eq:categorical-scalar-extension-karoubi}
\mathcal C\boxtimes_k K
=\operatorname{Kar}(\mathcal C\otimes_k K).
```

An object of the completion may be represented by a pair $(X,e)$ with
$e\in\operatorname{End}_{\mathcal C\otimes_k K}(X)$ idempotent; it represents
the image of $e$. A field $K$ is a **splitting field** for $\mathcal C$ when
every simple object of $\mathcal C\boxtimes_k K$ has endomorphism ring $K$.
This construction, including its agreement with a Deligne scalar extension,
is developed in [maurer2024computing; §5.1](@cite).

The decomposition problem is reduced to finite-dimensional algebra. If

```math
X\cong\bigoplus_i S_i^{\oplus m_i},
\qquad D_i=\operatorname{End}_{\mathcal C}(S_i),
```

then

```math
\label{eq:endomorphism-algebra-decomposition}
\operatorname{End}_{\mathcal C}(X)
\cong\prod_i\operatorname{Mat}_{m_i}(D_i).
```

Direct-sum decompositions of $X$ correspond to systems of orthogonal
idempotents in this algebra. Algorithmically, one computes
$\operatorname{End}(X)$, decomposes it, and realizes suitable primitive
idempotents as images in the category. Over a splitting field, the semisimple
algebras $D_i\otimes_k K$ are products of full matrix algebras over $K$;
images of primitive idempotents then give split simple summands.

Thus the basic splitting procedure for a finite semisimple category is:

1. compute representatives $S_i$ of its simple objects and their algebras
   $D_i=\operatorname{End}(S_i)$;
2. choose one extension $k\hookrightarrow K$ that splits all the $D_i$;
3. extend objects, morphisms, and structural maps from $k$ to $K$; and
4. decompose each $D_i\otimes_k K$ and take the images of primitive
   idempotents, retaining one representative of every resulting simple.

The procedure is not specific to any particular construction of a category.
Its implementation does depend on the chosen model: the model must support
scalar extension, computation and decomposition of endomorphism algebras, and
images of idempotents. The currently available operations and their precise
scope are listed under
[Products, scalar extension, and related constructions](BasicConstructions.md).

## [Dagger structures and unitarity](@id unitary-categories)

For categories realized over $\mathbb C$, a dagger sends
$f:X\to Y$ to $f^\dagger:Y\to X$, is conjugate-linear and involutive, reverses
composition, and is compatible with tensor products. A unitary fusion category
has a compatible positive dagger structure. After orthonormal bases have been
chosen in the fusion spaces, its associator matrices are unitary. If the
category also has a compatible braiding, its braiding matrices are unitary as
well. In arbitrary bases these structural maps need not be represented by
unitary matrices [bonderson2007thesis; Chapter 2](@cite).

For the later [skeletal $F$-symbol model](@ref skeletal-fusion), implemented by
`SixJCategory`, `dagger(f)` takes conjugate transposes of the stored matrix
blocks. The predicate `is_unitary(C)` tests the supplied pivotal structure,
dimensions, and associator matrices in these stored bases; it does not test the
braiding matrices or search for a change of gauge. Exact coefficients in an
abstract number field do not by themselves specify complex conjugation or
positivity; the current method therefore returns `false` over $\mathbb Q$,
ordinary number fields, and finite fields. Use a chosen complex realization
when asking this predicate about characteristic-zero algebraic data. The
[numerical fusion-category chapter](@ref numerical-fusion-categories) states
the precise working-precision interpretation.

## [Premodular and modular categories](@id premodular-categories)

Following [maurer2024computing; §2.4](@citet), a **premodular weak fusion
category** is a braided spherical weak fusion category. For representatives
$X_1,\ldots,X_r$ of its simple objects, the implementation uses the
unnormalized entries

```math
\label{eq:categorical-s-matrix}
S_{ij}=\operatorname{Tr}\!\left(
c_{X_i,X_j}\circ c_{X_j,X_i}
\right).
```

The displayed endomorphism acts on $X_j\otimes X_i$. By cyclicity of the
spherical trace, this is the usual trace of the double braiding on
$X_i\otimes X_j$.

It is **modular** when this matrix is invertible. For split fusion categories
over an algebraically closed field of characteristic zero, this is the standard
definition [EGNO; Definitions 8.13.1, 8.13.2, and 8.13.4](@cite). The weak
terminology extends the same matrix condition to non-splitting fields.

For a weak fusion category with non-scalar
$\operatorname{End}(\mathbb 1)$, categorical traces take values in that
endomorphism field. The current matrix routines require the traces and twists
below to be representable by scalars in the declared coefficient field. The
generic `is_modular` predicate imposes the stronger split-fusion hypothesis in
any case.

In supported finite models, the package methods use the following conventions:

- `smatrix(C)` returns the unnormalized trace matrix $S$ in the ordering
  `simples(C)`;
- `normalized_smatrix(C)` returns
  $S/\sqrt{\dim(\mathcal C)}$ and therefore requires a choice of square root;
- `tmatrix(C)` is the diagonal matrix of twist scalars, and therefore requires
  each represented twist on the chosen simples to be a scalar multiple of the
  identity over the coefficient field; and
- the generic `is_modular(C)` method first requires `is_fusion(C)`,
  `is_braided(C)`, and `is_spherical(C)` to report `true`, and then tests
  whether `smatrix(C)` is invertible.

The later [Drinfeld-center construction](@ref center), implemented by
`CenterCategory`, has a construction-specific method. If $\mathcal C$ is a
pivotal fusion category and $\dim(\mathcal C)\ne0$, then its Drinfeld center is
a premodular weak fusion category, and it is modular when it splits
[maurer2024computing; Theorem 2.1](@cite). The method therefore tests that the
computed center is fusion and spherical rather than recomputing the determinant
of its $S$-matrix.

The split restriction is part of the current public predicate. A non-split weak
fusion category may be modular in the mathematical sense above even though
`is_modular(C)` returns `false`. When `smatrix(C)` is represented as a matrix
over the coefficient field, modularity in the weak sense can instead be tested
by checking that its determinant is nonzero. The [anyon and CFT bridge](@ref
physics-bridge) compares the package's normalization with common physics
conventions.

## [Positive characteristic](@id positive-characteristic-fusion)

The characteristic can change both semisimplicity and splitting. The example
uses the [concrete representation model](@ref representations), whose full
constructor description appears later in the catalogue:

```@example characteristic
using TensorCategories, Oscar
G = cyclic_group(3)
C = representation_category(GF(2), G)
@assert is_semisimple(C) && is_weak_fusion(C)
@assert !is_split_semisimple(C)
D = representation_category(GF(3), G)
@assert !is_semisimple(D)
(is_weak_fusion(C), is_weak_fusion(D))
```

The first case is semisimple by Maschke's theorem. The irreducible factor
$x^2+x+1$ over $\mathbb F_2$ gives a two-dimensional simple with endomorphism
field $\mathbb F_4$. In characteristic $3$, the same group's representation
category is not semisimple.

A fusion category in positive characteristic can have a nonsemisimple center
when its global dimension vanishes. Existence of the center alone does not
imply modularity or applicability of every center algorithm
[maurer2024computing; Theorem 2.1 and §2.5](@cite).

Continue with [Grothendieck rings](@ref grothendieck-rings).
