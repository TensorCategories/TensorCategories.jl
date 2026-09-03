# Algebra objects and internal modules

The conventions are those of [EGNO; Chapter 7](@citet). The explicit
construction and the algorithms implemented here are developed in
[maeurer2026thesis; Chapter 3](@citet).
An algebra object has maps $m:A\otimes A\to A$ and $u:\mathbb 1\to A$, satisfying
```math
m\circ(m\otimes\mathrm{id}_A)
=m\circ(\mathrm{id}_A\otimes m)\circ a_{A,A,A}.
```
With the normalized unit constraints used by the package, the unit equations
are
```math
m\circ(u\otimes\mathrm{id}_A)=\mathrm{id}_A
=m\circ(\mathrm{id}_A\otimes u).
```
These are [EGNO; Definition 7.8.1 and Eqs. (7.10)--(7.11)](@citet), after
using the package's strict unit constraints.
`AlgebraObject(C,A,m,u)` stores the data; `is_algebra` checks the equations.
The constructor does not verify that `C`, $A$, and the domains and codomains of
$m$ and $u$ are compatible. Supply both maps in the parent category of $A$,
with exactly the indicated sources and targets.

A right action $r:M\otimes A\to M$ and a left action
$\ell:A\otimes M\to M$ satisfy
```math
r\circ(r\otimes\mathrm{id}_A)
=r\circ(\mathrm{id}_M\otimes m)\circ a_{M,A,A},
```
and
```math
\ell\circ(m\otimes\mathrm{id}_M)
=\ell\circ(\mathrm{id}_A\otimes\ell)\circ a_{A,A,M},
```
respectively. Their unit equations are
$r\circ(\mathrm{id}_M\otimes u)=\mathrm{id}_M$ and
$\ell\circ(u\otimes\mathrm{id}_M)=\mathrm{id}_M$ under the same normalized
identifications [EGNO; Definition 7.8.5 and Eqs. (7.12)--(7.13)](@citet).
The current `is_right_module` and `is_left_module` methods
check the displayed associativity equations. The `is_bimodule` method also
checks the compatibility equation below. None of these predicates checks the
separate unit equations for manually supplied actions.
Together with `is_algebra`, they compare morphisms by structural equality and
do not provide a ball-overlap branch for independently supplied numerical
structure maps.

For an $(A,B)$-bimodule, the compatibility between the left action $\ell$ and
right action $r$ is
```math
r\circ(\ell\otimes\mathrm{id}_B)
=\ell\circ(\mathrm{id}_A\otimes r)\circ a_{A,M,B}.
```
This is [EGNO; Definition 7.8.25 and Eq. (7.18)](@citet).
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
product this way [EGNO; Definition 7.8.21 and Eq. (7.16)](@citet). A category
of right modules is not automatically monoidal.

An algebra is **separable** when its multiplication splits as an
$A$-bimodule map [EGNO; Definition 7.8.29](@citet). This is the hypothesis used
by the simple-module algorithm below.

## Computing simple modules

If $\mathcal C$ is fusion and $A$ is separable, the category of right
$A$-modules is semisimple [EGNO; Proposition 7.8.30](@citet). Every simple
module occurs in a free module
$X_i\otimes A$ for some simple $X_i\in\mathcal C$. Accordingly, `simples(M)`
constructs the free modules on the simple objects, computes their minimal
subquotients, and removes duplicate isomorphism classes. Under the separability
hypothesis these subquotients are direct summands. This is Algorithm 7 of
[maeurer2026thesis; §3.4](@citet). The analogous construction applies to left
modules and, with both algebras separable, to bimodules.

Separability is the hypothesis that makes this an exhaustive semisimple
decomposition algorithm. Constructing `category_of_right_modules(A)` itself
does not assert separability.

## Commutativity and structure searches

Commutativity requires a supplied braiding and means $m\circ c_{A,A}=m$.
In the terminology used by `etale_algebra_structures` and
[EGNO; §8.27.2, p. 263](@citet), an étale algebra is commutative and separable;
connectedness is a separate condition. This differs from
[maeurer2026thesis; Definition 3.3.23](@citet), where “étale” includes
connectedness.

`algebra_structures`, `separable_algebra_structures`,
`commutative_algebra_structures`, and `etale_algebra_structures` search for
structures on a fixed underlying object. The polynomial systems can have
positive-dimensional solution spaces. These searches do not generally
classify all algebras up to isomorphism, and an empty sampled result is not a
proof of nonexistence.

Continue with [Group actions and equivariantization](GroupActions.md).
