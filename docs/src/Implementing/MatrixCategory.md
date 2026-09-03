# [Implementing a matrix category](@id implementing-matrices)

We implement finite-dimensional vector spaces over a field, with objects
represented by their dimensions and morphisms by row-coordinate matrices.
The package already supplies this category; reimplementing a small version
makes the interface visible.

The complete example below is also available as a
[Julia file](matrix_category.jl). It is a separate module so its names do not
collide with the built-in vector spaces. Save it and use `include` to load it.

## Reading the implementation

The `module MatrixCategoryTutorial ... end` block creates a namespace for the
tutorial types. Its `export` line lists the names made available by
`using .MatrixCategoryTutorial`; it does not make them part of
TensorCategories.jl.

`struct MatCategory <: Category` declares a concrete subtype of the package's
abstract `Category` type. Its field `base_ring` specifies a particular
coefficient field. The object and morphism fields match the default `parent`,
`domain`, and `codomain` methods. The constructor written inside `MatObject`
is an *inner constructor*: it checks that the dimension is nonnegative and then
uses `new(C,n)` to create the value. `MatElem` is OSCAR's abstract type for a
matrix element; it allows the same morphism type to store matrices over
different coefficient fields.

The example makes its representation-level equality explicit. Two
`MatCategory` values are equal only when they contain the identical coefficient
field object, tested with `===`; no field isomorphism or coercion is inferred.
Objects are equal when their parents and dimensions agree, and morphisms are
equal when their endpoints and matrices agree. The `morphism` constructor
always checks the parent, coefficient field, and the
$\dim(X)\times\dim(Y)$ matrix size. Composition checks its middle endpoint and,
in the row-coordinate convention, stores $M_fM_g$ for `compose(f,g)`.

Writing `TensorCategories.compose(...) = ...` adds a method to the existing
generic function. It does not replace other categories' implementations. We
qualify extended names explicitly; alternatively use `import` before defining
an unqualified method. `using` alone is not permission to extend an imported
function without qualification. Operations owned by Julia itself are extended
in the same way: for example, `Base.:(==)` extends equality, `Base.:+` and
`Base.:*` extend the infix arithmetic operations, and `Base.zero` extends
`zero(C)`.

The Hom basis consists of elementary matrices. The direct sum uses coordinate
inclusions and projections. Kernels and cokernels reuse existing vector-space
linear algebra and then reconstruct objects in our category. Finally, the
Kronecker product supplies the tensor product in a compatible lexicographic
basis, with the coordinate from the right tensor factor varying fastest, so the
associator matrix is the identity.

```@eval
using Markdown
Markdown.parse("```julia\n" * read("matrix_category.jl", String) * "\n```")
```

## Using generic operations

```@example implementation
using TensorCategories, Oscar
include("matrix_category.jl")
using .MatrixCategoryTutorial
C = MatCategory(QQ)
X, Y = MatObject(C, 2), MatObject(C, 3)
f = morphism(X, Y, matrix(QQ, [1 0 0; 0 0 0]))
K, i = kernel(f)
Q, p = cokernel(f)
@assert int_dim(K) == 1 && int_dim(Q) == 2
@assert is_zero(f ∘ i) && is_zero(p ∘ f)
I, j = image(f)  # inherited: kernel of the cokernel
@assert int_dim(I) == 1
int_dim(Hom(X,Y))
```

The expected dimensions here follow from rank–nullity. We also check the
biproduct identities, including zero objects:

```@example implementation
for (A,B) in ((X,Y), (zero(C),X), (X,zero(C)))
    D, incl, proj = direct_sum(A,B)
    @assert proj[1] ∘ incl[1] == id(A)
    @assert proj[2] ∘ incl[2] == id(B)
    @assert is_zero(proj[1] ∘ incl[2]) && is_zero(proj[2] ∘ incl[1])
    @assert incl[1] ∘ proj[1] + incl[2] ∘ proj[2] == id(D)
end
B = basis(Hom(X,Y))
h = 3*B[1] - B[end]
c = express_in_basis(h, Hom(X,Y))
@assert sum(c[r]*B[r] for r in eachindex(B)) == h
@assert matrix(f ⊗ id(X)) == kronecker_product(matrix(f),matrix(id(X)))
@assert associator(X,Y,X) == id((X⊗Y)⊗X)
nothing # hide
```

## Structures not implemented in this example

The example declares the ring-category structure implemented above: the tensor
product is biexact and its unit is scalar. Finite-dimensional vector spaces are
also split semisimple, rigid, and symmetric, but this small implementation does
not enumerate its simple objects or implement decomposition, duality, or
braiding. It therefore does not declare those additional structures. A
categorical property and an effective implementation of it are distinct.

The preceding [interface checklist](@ref interface-checklist) records the
operations required at each structural level. The next page explains how the
same design models graded spaces and group representations without $F$-symbol
input.

Continue with [Concrete models: graded spaces and representations](ConcreteModels.md).
