# [A first computation](@id first-category)

Start with an existing category. No F-symbol input or Julia type definitions
are needed to use its objects and morphisms.

```@example first
using TensorCategories, Oscar
K, s = quadratic_field(2)
C = ising_category(K, s)
u, chi, X = simples(C)
@assert u == one(C)
@assert X ⊗ X == u ⊕ chi
X ⊗ X
```

`simples(C)` returns representatives of simple isomorphism classes. The names
`u`, `chi`, and `X` are Julia variables. The category supplies their tensor
product; the same operation is used for representations and graded spaces.

## Objects and morphisms

An object has a parent category; a morphism has a domain and codomain.

```@example first
f = id(X)
@assert parent(X) === C
@assert domain(f) == X && codomain(f) == X
@assert compose(f, f) == f
int_dim(End(X))
```

`compose(f,g)` means first $f$, then $g$: it returns $g\circ f$.
The infix `∘` has its usual mathematical order.

Direct sums can return both the object and its structure maps:

```@example first
Y, i, p = direct_sum(u, chi)
@assert p[1] ∘ i[1] == id(u)
@assert i[1] ∘ p[1] + i[2] ∘ p[2] == id(Y)
int_dim(Hom(Y, Y))
```

`u ⊕ chi` returns only the object. `Hom(Y,Y)` is a vector space of morphisms;
`basis(Hom(Y,Y))` returns actual morphisms.

## An associator

The associator maps $(X\otimes X)\otimes X$ to $X\otimes(X\otimes X)$. The two objects are equal
in this skeletal model, but the associator is not the identity.

```@example first
a = associator(X, X, X)
@assert a != id((X ⊗ X) ⊗ X)
@assert matrix(a) == inv(s)*matrix(K, [1 1; 1 -1])
matrix(a)
show(stdout, MIME"text/plain"(), matrix(a)); println() # hide
```

These coordinates are explained in [Matrix realizations](@ref matrix-realizations)
and [F-symbol conventions](@ref f-conventions). An associator is part of the
category; it cannot simply be omitted from a composite.

Continue with [Working with categories](@ref interface-philosophy).
For a new concrete model, use the [implementation tutorial](@ref implementing-matrices).
For supplied fusion data, use [Fusion categories from data](@ref skeletal-fusion).
The [catalogue](@ref category-catalogue) lists the existing implementations.
