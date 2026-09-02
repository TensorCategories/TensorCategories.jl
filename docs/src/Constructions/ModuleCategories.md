# Algebra objects and internal modules

The conventions are those of [EGNO](@citet), Chapter 7. The explicit
construction and the algorithms implemented here are developed in
[maeurer2026thesis](@cite), Chapter 3.
An algebra object has maps $m:A\otimes A\to A$ and $u:\mathbb 1\to A$, satisfying
```math
m\circ(m\otimes\mathrm{id}_A)
=m\circ(\mathrm{id}_A\otimes m)\circ a_{A,A,A}.
```
The unit equations use normalized unit constraints.
`AlgebraObject(C,A,m,u)` stores the data; `is_algebra` checks the equations.

A right action has direction $M\otimes A\to M$, and a left action has direction
$A\otimes M\to M$.
Bimodules have commuting left and right actions.
The following example uses the unit algebra, so its modules recover the
original category:

```@example modules
using TensorCategories, Oscar
C = ising_category()
U = one(C)
A = AlgebraObject(C,U,id(U),id(U))
@assert is_algebra(A)
M = category_of_right_modules(A)
F = free_right_module(C[3],A)
@assert is_isomorphic(object(F),C[3])[1]
object(F)
```

`category_of_left_modules(A)`, `category_of_right_modules(A)`, and
`category_of_bimodules(A)` construct the corresponding parents.
Free modules use tensoring with the algebra. The relative tensor product of
a right and left module is a coequalizer; bimodules acquire their tensor
product this way. A category of right modules is not automatically monoidal.

## Computing simple modules

If $\mathcal C$ is fusion and $A$ is separable, the category of right
$A$-modules is semisimple. Every simple module occurs in a free module
$X_i\otimes A$ for some simple $X_i\in\mathcal C$. Accordingly, `simples(M)`
constructs the free modules on the simple objects, decomposes them, and removes
duplicate isomorphism classes. This is Algorithm 7 of
[maeurer2026thesis](@cite), §3.4. The analogous construction applies to left
modules and, with both algebras separable, to bimodules.

Separability is the hypothesis that makes this an exhaustive semisimple
decomposition algorithm. Constructing `category_of_right_modules(A)` itself
does not assert separability.

## Separability and searches

An algebra is separable if multiplication splits as an **A-bimodule** map.
Commutativity requires a supplied braiding and means $m\circ c_{A,A}=m$.
An étale algebra is commutative and separable; connectedness is an additional
condition, not part of the word “étale” here.

`algebra_structures`, `separable_algebra_structures`,
`commutative_algebra_structures`, and `etale_algebra_structures` search for
structures on a fixed underlying object. The polynomial systems can have
positive-dimensional solution spaces. These searches do not generally
classify all algebras up to isomorphism, and an empty sampled result is not a
proof of nonexistence.
