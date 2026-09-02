# Group actions and equivariantization

This part of the package is experimental. In particular, searches for
autoequivalences and coherence data are not complete classifications.

An action of a finite group consists of tensor autoequivalences $T_g$ and
coherent monoidal natural isomorphisms
```math
\sigma_{g,h}:T_g\circ T_h\longrightarrow T_{gh}.
```
It is more than an action on simple labels; see [EGNO](@cite), §§2.7 and 4.15.

`gtensor_action(C,elems,images,monoidal_structure)` stores an ordered list of
group elements, their functors, and a dictionary of structure transformations
indexed by pairs of positions. The same ordering must be used throughout.
`is_tensor_action` checks the implemented action equations.
`action_by_inner_autoequivalences` constructs candidates from invertible objects;
it does not enumerate all tensor actions.

## Equivariant objects

With this direction of $\sigma$, an equivariant object has maps
$u_g:T_g(X)\to X$ with
```math
u_g\circ T_g(u_h)=u_{gh}\circ(\sigma_{g,h})_X.
```
The constructor is `equivariantization(C,T)` (or `equivariantization(C,G,T)`).
The action is an argument; `equivariantization(C)` alone is not the documented
constructor. `equivariant_induction` uses the underlying direct sum
$\bigoplus_{g\in G}T_g(X)$ with its coherent equivariant structure.

In characteristic dividing $|G|$, equivariantization need not be semisimple.
Check this before using fusion-category algorithms or F-symbol extraction.

## Crossed products

The implemented crossed-product construction uses
```math
(X,g)\otimes(Y,h)=(X\otimes T_g(Y),gh).
```
Its associator depends on both $\sigma$ and the tensorators of $T_g$.
An action alone does not specify every notion of a braided G-crossed extension:
do not confuse the crossed product with such additional structures.
