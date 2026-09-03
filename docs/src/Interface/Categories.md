# Objects, morphisms, and composition

The three basic kinds of values are categories, objects, and morphisms,
represented by subtypes of `Category`, `Object`, and `Morphism`.

## Parents and endpoints

For an object $X$, `parent(X)` returns its category. For a morphism $f$,
`domain(f)` and `codomain(f)` return its source and target, and `parent(f)` is
inferred from `domain(f)`. A morphism constructor must therefore ensure that
its codomain belongs to the same category; the generic `parent(f)` method does
not perform that check. A linear category also supplies `base_ring(C)`.

The parent category is part of the represented data. Two objects that print in
the same way need not be compatible if they belong to different category
values or use different coefficient fields. When a construction changes the
parent, use the model-specific functor or scalar-extension operation supplied
for that construction.

## Composition

For $f:X\to Y$ and $g:Y\to Z$, `compose(f,g)` returns $g\circ f$.
The infix form `g ∘ f` has the usual mathematical order. The call `id(X)`
returns $\operatorname{id}_X$; every category implementation must satisfy the
identity and associativity laws for these represented morphisms.

For an endomorphism $f$, `composition_power(f,n)` accepts a nonnegative Julia
`Int` $n$ and returns $f^n$, with exponent zero equal to the identity. The operation
`inv(f)` returns a represented inverse when the model can compute one and
otherwise throws an error. Its available keywords are model-dependent; the
generic Hom-space solver has `check=false` by default and rechecks both inverse
identities when called with `check=true`.

Categories need not come with matrices. When a concrete model supplies
`matrix(f)`, its coordinate and composition conventions are explained under
[Matrix coordinates](@ref matrix-realizations).

## Equality and isomorphism

`X == Y` and `f == g` mean equality in the chosen representation, including the
parent or endpoints when the model implements those checks. Object equality is
not isomorphism. Where isomorphism testing is supported,
`is_isomorphic(X,Y)` returns `(true,f)` with $f:X\to Y$ an isomorphism, or
`(false,nothing)`. Assign the two entries separately; the tuple itself is not a
Boolean.

For example, in the supplied category of finite-dimensional vector spaces:

```@example composition
using TensorCategories, Oscar
V = vector_spaces(QQ)
X = VectorSpaceObject(V, 2)
ok, h = is_isomorphic(X, X)
@assert ok && inv(h) ∘ h == id(X)
ok
```

## Products and coproducts

In additive models, the generic `product(X,Y)` returns the product object and
its projections, while the generic `coproduct(X,Y)` returns the coproduct and
its injections. The [finite-set model](@ref finite-sets) returns only the
object unless its optional third argument is `true`. In additive categories use
[direct sums](AbelianCategories.md) when both families of maps are needed.

Continue with [Hom spaces and linear algebra](LinearCategories.md).
