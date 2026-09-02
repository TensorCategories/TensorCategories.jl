# [Working with categories](@id interface-philosophy)

TensorCategories.jl represents categories, objects, and morphisms as Julia
values. A categorical construction calls operations on those values, such as
`Hom`, `direct_sum`, and `associator`. Different categories can implement those
operations in entirely different ways.

A [representation](../ConcreteExamples/Representations.md) can be stored by
group-action matrices. A
[graded vector space](../ConcreteExamples/VectorSpaces.md) can be stored by a
basis and its degrees. A [split fusion category](@ref tensor-conventions) can
instead be described by simple multiplicities and
[F-symbols](@ref skeletal-fusion). **F-symbols are one input model; they are not
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

## Structures and hypotheses

The abstract types do not form a hierarchy of additive, abelian, and tensor
categories. Structures are implemented by methods and predicates. A category
can be linear without being monoidal, or monoidal without being abelian.

Algorithms use the structures and operations provided by the category.
For example, semisimple decomposition uses finite-dimensional Hom spaces and
linear algebra over the coefficient field. The
[scalar F-symbol model](@ref skeletal-fusion) also requires split simple
objects.

The interface chapters proceed from less structure to more: objects, morphisms,
and composition; linear coordinates and matrix realizations; additive and
abelian operations; tensor products and duality; and finally fusion and
splitting. An earlier interface does not require the later structures. The
[implementation tutorial](@ref implementing-matrices) supplies all the code for
a small model. The API reference records individual methods.

Our terminology and conventions follow [EGNO](@cite). For non-split
categories, we use the extensions described under
[Splitting and categorical structures](@ref tensor-conventions).
The generic framework and the center, skeletonization, and module algorithms
implemented by the package are developed in [maeurer2026thesis](@cite),
Introduction and Chapters 2--4.
