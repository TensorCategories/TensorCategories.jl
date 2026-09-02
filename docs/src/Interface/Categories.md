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
`SixJCategory` is mutable and parent identity matters: independently constructed
categories are different parents. Transport objects explicitly between them.

## Composition and matrices

For $f:X\to Y$ and $g:Y\to Z$, `compose(f,g)` returns $g\circ f$.
The matrix models use **row vectors**: a morphism matrix has one row per source
basis vector and one column per target basis vector. Thus

```math
M_{g\circ f}=M_f M_g.
```

```@example composition
using TensorCategories, Oscar
V = vector_spaces(QQ)
X = VectorSpaceObject(V, 2)
Y = VectorSpaceObject(V, 3)
Z = VectorSpaceObject(V, 1)
f = morphism(X, Y, matrix(QQ, [1 0 2; 0 1 3]))
g = morphism(Y, Z, matrix(QQ, 3, 1, [1, 2, 3]))
@assert matrix(g ∘ f) == matrix(f)*matrix(g)
matrix(compose(f, g))
show(stdout, MIME"text/plain"(), matrix(compose(f, g))); println() # hide
```

The [matrix realization](@ref matrix-realizations) need not preserve tensor
products.

## Equality and isomorphism

`X == Y` means equality in the chosen representation. In the implemented linear
models, `is_isomorphic(X,Y)` returns `(true,f)` with $f:X\to Y$ an isomorphism,
or `(false,nothing)`. Destructure this result: a tuple is not a Boolean.

```@example composition
ok, h = is_isomorphic(X, X)
@assert ok && inv(h) ∘ h == id(X)
ok
```

`product(X,Y)` returns the product object and projections; `coproduct(X,Y)`
returns the coproduct and injections. In additive categories use
[direct sums](AbelianCategories.md) when both families of maps are needed.
