# Objects, morphisms, and composition

The three abstract types are `Category`, `Object`, and `Morphism`.
Define concrete subtypes for a new model.

## Parents and endpoints

The default `parent(X::Object)` reads its `parent` field. Default `domain(f)`
and `codomain(f)` read fields of those names. Supply methods instead when a
representation uses other fields. `parent(f)` is inferred from its domain.

`base_ring(C)` reads a `base_ring` field when present; linear objects and
morphisms inherit the field from their category.

The same printed name or component vector need not mean the same object.
The parent is part of the represented object: independently constructed
mutable category values can define different parents even when they print
identically. Transport objects explicitly between them.

## Composition

For $f:X\to Y$ and $g:Y\to Z$, `compose(f,g)` returns $g\circ f$.
The infix form `g ∘ f` has the usual mathematical order. Categories need not
come with matrices. When a concrete model supplies `matrix(f)`, its coordinate
and composition conventions are explained under
[Matrix realizations and fiber functors](@ref matrix-realizations).

## Equality and isomorphism

`X == Y` means equality in the chosen representation. In the implemented linear
models, `is_isomorphic(X,Y)` returns `(true,f)` with $f:X\to Y$ an isomorphism,
or `(false,nothing)`. Destructure this result: a tuple is not a Boolean.

For example, in the supplied category of finite-dimensional vector spaces:

```@example composition
using TensorCategories, Oscar
V = vector_spaces(QQ)
X = VectorSpaceObject(V, 2)
ok, h = is_isomorphic(X, X)
@assert ok && inv(h) ∘ h == id(X)
ok
```

`product(X,Y)` returns the product object and projections; `coproduct(X,Y)`
returns the coproduct and injections. In additive categories use
[direct sums](AbelianCategories.md) when both families of maps are needed.

Continue with [Hom spaces and linear algebra](LinearCategories.md).
