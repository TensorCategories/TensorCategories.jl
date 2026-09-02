# Hom spaces and linear algebra

Composition in a $k$-linear category is bilinear. Algorithms need effective
representations of the Hom spaces they use, usually finite-dimensional ones.

| Operation | Result |
|:---|:---|
| `Hom(X,Y)` | An `AbstractHomSpace` for maps $X\to Y$ |
| `End(X)` | `Hom(X,X)` |
| `basis(H)` | A vector of basis morphisms |
| `int_dim(H)` | Dimension as a Julia integer |
| `zero_morphism(X,Y)` | The zero map |
| `a*f + b*g` | A linear combination of parallel maps |
| `express_in_basis(f,H)` | Coordinates in `basis(H)` |
| `endomorphism_ring(X)` | An associative algebra representing `End(X)` |

The last operation includes multiplication. Dimension alone does not determine
the algebra structure.

```@example homs
using TensorCategories, Oscar
V = vector_spaces(QQ)
X, Y = VectorSpaceObject(V, 2), VectorSpaceObject(V, 3)
H = Hom(X, Y)
@assert int_dim(H) == 6
B = basis(H)
f = 2*B[1] - B[end]
c = express_in_basis(f, H)
@assert sum(c[i]*B[i] for i in eachindex(B)) == f
c
```

A Hom basis is a choice, not an invariant. Changing fusion-space bases changes
[F- and R-symbols](@ref f-conventions). Keep a common set of bases for related
structural maps.

## Implementing the linear structure

Implement addition, scalar multiplication, zero maps, `Hom`, and its basis.
`HomSpace(X,Y,B)` is an existing wrapper for a supplied basis `B`. Custom Hom
spaces can subtype `AbstractHomSpace` and implement `domain`, `codomain`,
`basis`, and `base_ring`.

Generic `express_in_basis` uses `matrix(f)` and linear algebra. A model without
matrix access needs its own coordinate method. Coordinates in each Hom space
do not by themselves specify a functor on objects to vector spaces.

For a non-split simple $S$, its multiplicity in $X$ is the dimension of
$\operatorname{Hom}(S,X)$ over $\operatorname{End}(S)$, not generally its
dimension over $k$.
See [Splitting](@ref tensor-conventions).

Continue with [Matrix realizations and fiber functors](@ref matrix-realizations).
