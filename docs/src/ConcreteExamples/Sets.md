# [Finite sets](@id finite-sets)

Finite sets provide the smallest concrete model in the catalogue and are useful
for experimenting with universal constructions before linear algebra enters.
The constructor is intended to model the category of finite sets and all maps
described in [EGNO; Example 2.3.1, p. 26](@citet), subject to the current
limitations below. The implementation represents both the sets and their maps
by ordinary Julia data.

`Sets()` models finite sets and functions. An object `SetObject([1,2,3])`
stores a Julia set. For objects $X$ and $Y$, `SetMorphism(X,Y,f)` constructs
a map from a Julia function `f`, storing its values in a dictionary.

`product(X,Y)` forms the Cartesian product, and `coproduct(X,Y)` forms a
disjoint union. Passing `true` as the third argument returns the object
together with its projections or inclusions, respectively. These are
categorical products and coproducts; this model has no linear structure
over a coefficient field.

The cited example also carries its Cartesian symmetric monoidal structure.
The present model implements `product` and `coproduct`, but it does not supply
the package's monoidal interface: tensor product, tensor unit, associator, and
braiding are unavailable.

!!! warning "Current scope"
    This model is suitable for experimenting with products and
    coproducts. Its equality and invertibility methods do not yet enforce the
    usual set-theoretic conditions, and a dictionary input need not define a
    total map. Verify maps independently before using composition or `inv`.
