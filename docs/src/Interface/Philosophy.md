# [Models and the category interface](@id interface-philosophy)

TensorCategories.jl represents categories, objects, and morphisms as Julia
values. A categorical construction calls operations on those values, such as
`Hom`, `direct_sum`, and `associator`. Different categories can implement those
operations in entirely different ways.

A [representation](../ConcreteExamples/Representations.md) can be stored by
group-action matrices. A
[graded vector space](../ConcreteExamples/VectorSpaces.md) can be stored by a
basis and its degrees. A [split fusion category](@ref tensor-conventions) can
instead be described by simple multiplicities and
[$F$-symbols](@ref skeletal-fusion). **$F$-symbols are one input model; they are not
required by the general category interface.**

| Value or operation | Meaning |
|:---|:---|
| `C::Category` | A particular category, including choices such as its field |
| `X::Object` | An object in `parent(X)` |
| `f::Morphism` | A map from `domain(f)` to `codomain(f)` |
| `Hom(X,Y)`, `End(X)` | Morphism spaces, where supported |
| `compose(f,g)` | $g\circ f$ |
| `X ⊕ Y`, `X ⊗ Y` | Direct sum and tensor product objects |
| `associator(X,Y,Z)` | The specified rebracketing map |

## Independent structures

The abstract Julia types do not form a hierarchy of linear, abelian, and
monoidal categories. These are independent axes of structure, supplied by
methods and recorded by predicates:

| Structure | Mathematical data or property | Predicate |
|:---|:---|:---|
| linear | Hom spaces are $k$-modules (vector spaces when $k$ is a field) and composition is bilinear | `is_linear(C)` |
| additive | finite biproducts and a zero object | `is_additive(C)` |
| abelian | additive structure, kernels, and cokernels with the abelian axioms | `is_abelian(C)` |
| monoidal | tensor product, unit, and coherent associator and unit constraints | `is_monoidal(C)` |
| rigid | chosen left and right duality data | `TensorCategories.is_rigid(C)` |

Here *linear* is the package's enrichment predicate. In the terminology of
[EGNO; Definition 1.2.2](@citet), a $k$-linear category is additive as well as
enriched in $k$-vector spaces. TensorCategories.jl records these two
requirements separately through `is_linear(C)` and `is_additive(C)`. Likewise,
linearity and monoidality are independent. The operations `X ⊕ Y`, `X ⊗ Y`,
and `associator(X,Y,Z)` are available only when the corresponding structure
has been implemented.

The package also names standard combinations of these axes. A **multiring
category** is a locally finite $k$-linear abelian monoidal category whose tensor
product is $k$-bilinear and exact in each variable. It is a **ring category**
when the canonical map $k\to\operatorname{End}(\mathbb 1)$ is an isomorphism.
A **multitensor category** is a rigid multiring category, and it is a **tensor
category** when it is also a ring category; exactness of tensor product in a
multitensor category follows from rigidity
[EGNO; Definition 4.1.1, Proposition 4.2.1, and Definition 4.2.3](@cite). The
corresponding package predicates are `is_multiring`, `is_ring`,
`is_multitensor`, and `is_tensor`.
Finite semisimple versions, including the distinction between weak fusion and
split fusion categories over a general field, are defined later under
[Fusion categories and splitting](@ref tensor-conventions).

Predicates record declarations or backend-specific information about the
category; generic code cannot prove all categorical axioms merely from the
existence of methods. Algorithms rely on both the declared structure and the
operations needed for the computation. For example, semisimple decomposition
uses finite-dimensional Hom spaces and linear algebra over the coefficient
field, while the [scalar $F$-symbol model](@ref skeletal-fusion) additionally
requires split simple objects.

## Reading the interface chapters

The order of the following pages is chosen to introduce dependencies needed by
later examples; it is not a chain of mathematical implications. Objects and
morphisms come first, followed by linear Hom spaces and optional matrix
coordinates. Additive and abelian operations and monoidal operations are then
introduced as separate structures before the manual combines them in tensor
and fusion categories. Functors follow the structural interfaces, and the last
page distinguishes a faithful linear realization from the stronger notion of a
fiber functor.

Our terminology and conventions follow [EGNO](@citet). For non-split
categories, we use the extensions described under
[Fusion categories and splitting](@ref tensor-conventions). The generic
framework and the center, skeletonization, and module algorithms implemented by
the package are developed in
[maeurer2026thesis; Introduction and Chapters 2--4](@citet).

Continue with [Objects, morphisms, and composition](Categories.md).
