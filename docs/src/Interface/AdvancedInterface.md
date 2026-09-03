# Functors and natural transformations

A functor must specify what it does to both objects and morphisms. Giving only
a map on isomorphism classes, or only a
[Grothendieck-ring homomorphism](@ref grothendieck-rings), does not specify a
functor on the category.

Additional adjectives refer to additional compatibility:

| Functor | Additional requirement |
|:---|:---|
| additive | preserves finite direct sums |
| $k$-linear | acts linearly on every Hom space |
| exact | preserves short exact sequences |
| monoidal | has coherent tensor and unit isomorphisms |
| tensor | an exact faithful $k$-linear monoidal functor between multiring categories |

The last row follows [EGNO; Definition 4.2.5](@citet); some authors use “tensor
functor” without the exactness or faithfulness requirements.

The generic constructor below stores object and morphism maps; it does not
infer any of these stronger properties from the Julia functions supplied to
it.

```@example functors
using TensorCategories, Oscar
C = vector_spaces(QQ)
F = functor(C,C,X -> X,f -> f)
X = VectorSpaceObject(C,2)
f = morphism(X,X,matrix(QQ,[1 1; 0 1]))
@assert domain(F) == C && codomain(F) == C
@assert F(id(X)) == id(F(X))
@assert F(f ∘ f) == F(f) ∘ F(f)
F(f)
```

`functor(C,D,obj_map,mor_map)` stores the two maps, with source `domain(F)` and
target `codomain(F)`. A custom subtype of `TensorCategories.AbstractFunctor`
can instead implement call methods. The constructor does not check the identity
and composition laws. Functor composition has the same order as morphism
composition: `compose(F,G)` means $G\circ F$.

A natural transformation $\eta:F\Rightarrow G$ has components
$\eta_X:F(X)\to G(X)$ satisfying

```math
\label{eq:natural-transformation-naturality}
G(f)\circ\eta_X=\eta_Y\circ F(f)
\qquad(f:X\to Y).
```

An additive natural transformation stores components on specified
indecomposables and extends them using direct-sum decompositions. `Nat(F,G)`
solves naturality equations in supported finite additive models whose listed
indecomposables generate all objects under finite direct sums. It requires
finite Hom bases, effective direct-sum decompositions and coordinates, additive
functors, and the same base field for source and target. Semisimplicity is not a
formal requirement of this solver.
A component on a non-split simple $S$ must satisfy naturality with respect to
its whole endomorphism algebra:
```math
\label{eq:natural-transformation-simple-test}
G(d)\circ\eta_S=\eta_S\circ F(d)
\qquad\bigl(d\in\operatorname{End}(S)\bigr).
```
An arbitrary matrix at each simple does not suffice. When $F=G$, this says
that the component commutes with the induced endomorphisms.

## Tensor structure is extra data

A monoidal functor has tensorators
```math
\label{eq:monoidal-functor-tensorator}
J_{X,Y}:F(X)\otimes F(Y)\longrightarrow F(X\otimes Y),
```
satisfying the associator compatibility [EGNO; §2.4](@cite).
The implemented solvers require additive $k$-linear behavior, strictly
unit-preserving functors, and normalized unit tensorators. The implementation
checks the source and target categories and the image of the unit, but does not
verify additivity or $k$-linearity of the supplied functor. These are not
solvers for arbitrary unit constraints.

`monoidal_structure_candidates(F; check=false)` searches for candidates between
split fusion categories. This can sample a positive-dimensional solution
scheme and is not a complete classification. An empty result does not prove
nonexistence. The solved equations already impose coherence; `check=true`
re-evaluates the monoidal-functor axiom on each returned candidate.
`monoidal_structures(F)` currently restricts its generic complete solver to the
normalized case in which the source fusion category has exactly one simple
object.

## Functors between skeletal models

The later [skeletal fusion model](@ref skeletal-fusion) is implemented by
`SixJCategory`. For two such categories, `functor(C,D,images)` stores the chosen
images of the simple objects of $C$ and uses semisimple block formulas on
objects and morphisms. This is a low-level constructor: supply exactly one
object of $D$ for each simple of $C$, with compatible parents and functor laws.
These conditions are assumed rather than checked. Coherent tensorators remain
additional data, and compatibility of the images with the fusion rules is
required before such tensorators can exist. The monoidal-structure methods
above can search for that data. The returned functor does not declare
`is_additive`, so the generic `Nat(F,G)` solver does not accept it directly.

Continue with [Fiber functors and semisimple coordinates](@ref fiber-functors).
