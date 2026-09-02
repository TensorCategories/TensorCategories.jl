# [Splitting and categorical structures](@id tensor-conventions)

[EGNO](@citet), §4.16, discusses arbitrary fields. For non-split terminology
we follow [maurer2024computing](@cite), §2.1.

A **weak fusion category** over $k$ is a finite semisimple $k$-linear rigid
monoidal category with finite-dimensional Hom spaces, bilinear tensor product,
and simple unit. It is **fusion** when each simple is scalar: the canonical map
$k\to\operatorname{End}(S)$ is an isomorphism. This is the split condition. The *multi*
variants allow a nonsimple unit. “Weak” does not relax associativity or rigidity.

## Structural predicates

| Predicate | Meaning |
|:---|:---|
| `is_linear`, `is_additive`, `is_abelian` | Declared or backend-specific structures |
| `is_monoidal`, `is_rigid` | Tensor and duality structures |
| `is_semisimple` | Semisimplicity over the current field |
| `is_split_semisimple` | Semisimplicity with scalar simple endomorphisms |
| `is_weak_fusion`, `is_fusion` | The notions specified above |
| `is_weak_multifusion`, `is_multifusion` | Corresponding multi variants |

Generic methods read declared attributes or consequences of declarations.
Some specialized predicates compute invariants
or enumerate simples; they can be expensive or unsupported over a given field.

## Non-split multiplicities

For a simple object $S$, put $D=\operatorname{End}(S)$. For semisimple $X$,
```math
[X:S]=\dim_D\operatorname{Hom}(S,X)
     =\frac{\dim_k\operatorname{Hom}(S,X)}{\dim_k D}.
```
Replacing $D$ by $k$ gives incorrect multiplicities. Division algebras need not
be commutative. Over finite fields they are fields, but need not be the base field.

Scalar extension can require splitting idempotents to obtain all the new
objects. Changing coefficients and enumerating new simples are distinct steps.
For supported centers see `extension_of_scalars`, `karoubian_envelope`, and
`split` in the [center tutorial](@ref ising-center).

These multiplicities are the structure constants of the
[Grothendieck ring](@ref grothendieck-rings). Over a non-splitting field
they give a weak fusion ring.

## Characteristic

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
field $\mathbb F_4$. In characteristic $3$ the same group's representation category is not
semisimple.

A fusion category in positive characteristic can have a nonsemisimple center
when its global dimension vanishes. Existence of the center alone does not
imply modularity or applicability of every center algorithm.

Continue with [Grothendieck rings](@ref grothendieck-rings).
