# Group actions and equivariantization

An action of a finite group consists of tensor autoequivalences $T_g$ and
coherent monoidal natural isomorphisms
```math
\sigma_{g,h}:T_g\circ T_h\longrightarrow T_{gh}.
```
They obey
```math
\sigma_{gh,k}\circ(\sigma_{g,h}\ast\mathrm{id}_{T_k})
=\sigma_{g,hk}\circ(\mathrm{id}_{T_g}\ast\sigma_{h,k}),
```
where $\ast$ denotes whiskering, that is, horizontal composition with the
indicated identity natural transformation, together with the normalized
identity data.
A categorical action therefore contains more data than an action on simple
labels; see
[EGNO; Definitions 2.7.1 and 4.15.1](@cite).

!!! warning "Current scope"
    The implementation of group actions is experimental. Searches for
    autoequivalences and coherence data return candidates rather than complete
    classifications.

`gtensor_action(C,elems,images,monoidal_structure)` stores an ordered list of
group elements, their functors, and a dictionary of structure transformations
indexed by pairs of positions. The same ordering must be used throughout.
The stored format has no separate unit isomorphism, so normalized action data
use $T_e=\mathrm{Id}_{\mathcal C}$ and
$\sigma_{e,g}=\sigma_{g,e}=\mathrm{id}_{T_g}$.
`is_tensor_action` checks the displayed associativity equation for the stored
transformations. Supply `elems` as the complete group-element list, one tensor
autoequivalence in `images` for each entry, and a structure transformation for
every pair. The method does not verify naturality, monoidality, invertibility,
the functor endpoints, identity normalization, or the autoequivalence property;
it checks only the displayed action associativity equation.
`action_by_inner_autoequivalences` constructs candidates from invertible objects;
it does not enumerate all tensor actions.

## Equivariant objects

With this direction of $\sigma$, an equivariant object has isomorphisms
$u_g:T_g(X)\to X$ with $u_e=\mathrm{id}_X$ and
```math
u_g\circ T_g(u_h)=u_{gh}\circ(\sigma_{g,h})_X.
```
This is the direction of the structure maps in
[EGNO; Definition 2.7.2](@citet).
The constructor is `equivariantization(C,T)` (or `equivariantization(C,G,T)`).
The action is an argument; `equivariantization(C)` alone is not the documented
constructor. `equivariant_induction` uses the underlying direct sum
$\bigoplus_{g\in G}T_g(X)$ with its coherent equivariant structure.
An equivariant object stores one structure map for each entry of `T.elements`.
The low-level constructor does not test that these maps are invertible or that
$u_e$ is the identity. `is_equivariant` checks the displayed pairwise
compatibility equation, but it does not add these omitted conditions.
Both `is_tensor_action` and `is_equivariant` use represented equality and are
currently intended for exact coefficient fields.

In characteristic dividing $|G|$, equivariantization need not be semisimple.
Fusion-category algorithms and $F$-symbol extraction therefore require a
separate semisimplicity determination in this case.

## Crossed products

For a `SixJCategory` with a supplied action `T`, call
`gcrossed_product(C,T)` or `C ⋊ T`. The resulting skeletal category uses
```math
(X,g)\otimes(Y,h)=(X\otimes T_g(Y),gh).
```
This is [EGNO; Definition 4.15.5 and Eq. (4.22)](@citet).
Its associator depends on both $\sigma$ and the tensorators of $T_g$.
The constructor supplies this crossed product; it does not add the further
data of a braided $G$-crossed extension.
It assumes that `T` is a coherent action on `C` and does not call
`is_tensor_action` or a pentagon check. The result supplies no braiding and no
verified pivotal structure; check the action before construction and run
`pentagon_axiom` on the result when coherence matters.

The [API reference](../API.md) lists the principal public names for the
framework and these constructions. Use Julia help mode or `methods(name)` for
the exact signatures in the installed version.

The [category catalogue](@ref category-catalogue) is the reference guide to
the concrete models, skeletal categories, and datasets distributed with the
package.
