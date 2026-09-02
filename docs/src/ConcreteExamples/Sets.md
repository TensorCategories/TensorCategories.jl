# Finite sets

`Sets()` models finite sets and functions. An object `SetObject([1,2,3])`
stores a Julia set. For objects `X` and `Y`, `SetMorphism(X,Y,f)` constructs
a map from a Julia function `f`, storing its values in a dictionary.

`product(X,Y)` forms the Cartesian product, and `coproduct(X,Y)` forms a
disjoint union. Passing `true` as the third argument returns the object
together with its projections or inclusions, respectively. These are
categorical products and coproducts; this model has no linear structure
over a coefficient field.

!!! warning "Object equality"
    The current object equality method compares `X.set` with itself instead
    of with `Y.set`. Thus `X == Y` does not distinguish different sets in
    this implementation.
