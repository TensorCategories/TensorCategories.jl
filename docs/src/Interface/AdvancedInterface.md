# Functors and natural transformations

A functor must specify what it does to both objects and morphisms. Giving only
a map on isomorphism classes, or only a
[Grothendieck-ring homomorphism](@ref grothendieck-rings), does not
specify a tensor functor.

```@example functors
using TensorCategories, Oscar
C = vector_spaces(QQ)
F = functor(C,C,X -> X,f -> f)
X = VectorSpaceObject(QQ,2)
f = morphism(X,X,matrix(QQ,[1 1; 0 1]))
@assert F(id(X)) == id(F(X))
@assert F(f ∘ f) == F(f) ∘ F(f)
F(f)
```

`functor(C,D,obj_map,mor_map)` stores the two maps. A custom subtype of
`TensorCategories.AbstractFunctor` can instead implement call methods.
The constructor does not check the identity and composition laws.
Functor composition has the same
order as morphism composition: `compose(F,G)` means $G\circ F$.

An additive natural transformation stores components on specified
indecomposables and extends them using direct-sum decompositions.
`Nat(F,G)` solves naturality equations in supported finite additive models.
A component on a non-split simple must commute with its whole endomorphism
algebra; an arbitrary matrix at each simple does not suffice.

## Tensor structure is extra data

A monoidal functor has tensorators
```math
J_{X,Y}:F(X)\otimes F(Y)\longrightarrow F(X\otimes Y),
```
satisfying the associator compatibility [EGNO](@cite), §2.4.
The implemented solvers use strictly unit-preserving functors and normalized
unit tensorators. They are not solvers for arbitrary unit constraints.

`monoidal_structure_candidates(F; check=true)` searches for candidates between
split fusion categories. This can sample a positive-dimensional solution
scheme and is not a complete classification. An empty result does not prove
nonexistence. `monoidal_structures(F)` currently restricts its generic complete
solver to the normalized rank-one case.

A `SixJFunctor` encodes an additive map using images of simples.
A tensor functor additionally requires coherent tensorators.
