# Tensor products and duality

We use the directions in [EGNO](@citet), Chapters 2 and 4.
Tensor products act on objects and morphisms; `one(C)` is the unit.

```math
a_{X,Y,Z}:(X\otimes Y)\otimes Z\longrightarrow X\otimes(Y\otimes Z).
```

`associator(X,Y,Z)` returns this map; `inv_associator` returns its inverse.
Write parentheses explicitly. A skeletal category need not have identity
associators even when these endpoint objects are equal.

## Units and coherence

The supplied tensor-category algorithms use normalized units: tensoring with
the unit is identified with the original object, with identity unit constraints.
`SixJCategory` also normalizes associators with a unit input to identities.
`set_associator!(...; check=true)` checks supplied unit blocks, not the full
pentagon.

Use `pentagon_axiom(C)` for associator coherence in supported finite models,
and `hexagon_axiom(C)` for a supplied braiding. Randomized checks sample
instances; they are not exhaustive checks.

## Duality

`dual(X)` denotes the left dual $X^*$, with
```math
\operatorname{ev}_X:X^*\otimes X\longrightarrow\mathbb1,\qquad
\operatorname{coev}_X:\mathbb1\longrightarrow X\otimes X^*.
```
One triangle equation in code is
```julia
(id(X) ⊗ ev(X)) ∘ associator(X, dual(X), X) ∘
    (coev(X) ⊗ id(X)) == id(X)
```

The dual object alone does not determine these maps. Generic semisimple
fallbacks have splitting assumptions; concrete representations supply dualities
directly.

## Pivotal and braided structures

`pivotal(X)` represents a map $X\to X^{**}$. These maps and the dualities determine
pivotal traces. Equality of left and right dimensions alone does not check
pivotal monoidality. In supported models, `is_pivotal(C; check=true)` and
`is_spherical(C; check=true)` check the specified structures.

`braiding(X,Y)` represents a map $X\otimes Y\to Y\otimes X$. The twist convention is
$\theta_X=u_X^{-1}j_X$, where $j$ is pivotal and $u$ is the Drinfeld morphism
[EGNO](@cite), §8.10. `smatrix(C)` is the **unnormalized** trace of double braiding.
`normalized_smatrix(C)` is separate and involves a square-root choice.
The stored coefficients are described under [Structural data](@ref symbol-data).

