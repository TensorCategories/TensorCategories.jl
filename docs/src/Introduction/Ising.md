
## Example: Implementing the Ising fusion category

Users are completely free in how exactly they want to model a category in TensorCategories.jl. The basic idea is that one needs to define functions for all relevant data like direct sums and tensor products of objects and morphisms, etc. Here the multiple dispatch paradigm of Julia is the key. The general framework is described in detail in the chapter [Interface](@ref interface-philosophy). For encoding a fusion category via $F$-symbols (the associators in a choice of basis) we provide an own convenient structure called `SixJCategory`. Of course, the relevant data needs to be known explicitly (in some form), we cannot do magic.

Let us demonstrate this in an explicit example. Let $\mathcal{C}'$ be the famous Ising fusion category. This is a fusion category over the complex numbers with three simple objects denoted by $\mathbb 1$, $\chi$, and $X$. The multiplication is given by $\chi \otimes \chi = 1$, $\chi \otimes X = X \otimes \chi = X$ and $X \otimes X = \mathbb 1 \oplus \chi$, The Ising category is a special case of Tambara–Yamagami fusion categories [TAMBARA1998692](@cite). The non-trivial associators of $\mathcal{C}'$ are given by

```math
\begin{aligned}
    a_{\chi, X, \chi} &= (-1)\mathrm{id}_{X} \\
    a_{X,\mathbb 1,X} &= \mathrm{id}_{\mathbb 1} \oplus (-1)\mathrm{id}_\chi \\
    a_{X,\chi,X} &= (-1)\mathrm{id}_{\mathbb 1}\oplus \mathrm{id}_\chi \\
    a_{X,X,X} &= \frac{1}{\sqrt{2}}\begin{pmatrix}1 & 1 \\ 1 & -1\end{pmatrix}\mathrm{id}_{2X} \;,
\end{aligned}
```

see [TAMBARA1998692](@cite). It follows that $\mathcal{C}'$ can be defined over the number field $\mathbb{Q}(\sqrt{2})$, i.e., it has a $\mathbb{Q}(\sqrt{2})$-*rational form* $\mathcal{C}$. This is a fusion category over $\mathbb{Q}(\sqrt{2})$. More generally, this can be done over any field $K$ containing an element $a \in J$ with $a^2 = 2$. The following code shows how to implement the Ising fusion category in TensorCategories.jl in this generality.

```julia
function ising_category(K::Ring, a::RingElem)
    C = six_j_category(K,["𝟙", "χ", "X"])
    
    # Multiplication table of the Grothendieck ring
    M = zeros(Int,3,3,3)
    M[1,1,:] = [1,0,0]
    M[1,2,:] = [0,1,0]
    M[1,3,:] = [0,0,1]
    M[2,1,:] = [0,1,0]
    M[2,2,:] = [1,0,0]
    M[2,3,:] = [0,0,1]
    M[3,1,:] = [0,0,1]
    M[3,2,:] = [0,0,1]
    M[3,3,:] = [1,1,0]

    set_tensor_product!(C,M)

    # The associators
    set_associator!(C,2,3,2, matrices(-id(C[3])))
    set_associator!(C,3,2,3, matrices((id(C[1])) ⊕ (-id(C[2]))))
    z = zero(matrix_space(K,0,0))
    set_associator!(C,3,3,3, [z, z, inv(a)*matrix(K,[1 1; 1 -1])])

    # Furher information
    set_one!(C,[1,0,0])
    set_spherical!(C, [K(1) for s in simples(C)])
    set_name!(C, "Ising fusion category")
    return C
end
```

Here, the function `matrices` gives a matrix representation of a morphism in a category according to the decomposition of the domain and codomain into simple objects. The function `id` gives the identity morphism on an object. This functionality is already internal to the special type `six_j_category`. We note that the Ising category (in this generality) and many other examples are already implemented in TensorCategories.jl.

You can now play around with this category. We can choose as $K$, for example, the algebraic closure of $\mathbb{Q}$, which is also available in OSCAR via `algebraic_closure(QQ)`. But we can also work over the number field $K = \mathbb{Q}(\sqrt{2})$, which is what we will do.

```julia-repl
julia> K,r2 = quadratic_field(2)
(Real quadratic field defined by x^2 - 2, sqrt(2))

julia> C = ising_category(K,r2)
Ising fusion category

julia> simples(C)
3-element Vector{SixJObject}:
 𝟙
 χ
 X

# You can access the i-th simple object also by C[i]
# Let's compute the Frobenius-Perron dimension of X
julia> f = fpdim(C[3])
{a2: 1.41421}

julia> typeof(f)
QQBarFieldElem
```

## Example: Computing the center of the Ising fusion category

Let $\mathcal{C}$ be the Ising fusion category over $\mathbb{Q}(\sqrt{2})$. It is known from general theory that the center $\mathcal{Z}(\mathcal{C})$ is a semisimple tensor category—more precisely, it is what we call a *weak* pre-modular category, see [maurer2024computing](@cite). The *weak* means that it may not split, and this is exactly what will happen here. Let's compute this.

```julia-repl
julia> Z = center(C)
Drinfeld center of Fusion Category with 3 simple objects

julia> S = simples(Z)
5-element Vector{CenterObject}:
Central object: 1
Central object: 1
Central object: 1 ⊕ 𝜒
Central object: 2·𝜒
Central object: 4·X
```

We note that the `center` function at first only creates an empty structure for the center—the first real computational effort is in the `simples` function which computes the simple objects of the center. We have described the algorithm in our paper [maurer2024computing](@cite).

!!! note "Randomized computations"
    We remark that the computation of the center involves randomized parts (the MeatAxe specifically), so e.g., the ordering of the simples, the form of the precise half-braidings, and thus the basis of endomorphism spaces we compute below may differ from the exact output given here.

We can see that $\mathcal{Z}(\mathcal{C})$ has five non-isomorphic simple objects. Objects in the center are of the form $(Z,\gamma)$, where $Z \in \mathcal{C}$ is an object and $\gamma$ is a half-braiding for $Z$. We only display the underlying object $Z$ here and say that $(Z,\gamma)$ is a central object *over* $Z$. So, for example there is simple central object over $2 \chi = \chi \oplus \chi$. We can look at the explicit half-braiding:

```julia-repl
julia> half_braiding(Z[4])
3-element Vector{TensorCategories.SixJMorphism}:

 Morphism with
Domain: 2⋅χ
Codomain: 2⋅χ
Matrices: 0 by 0 empty matrix, [1 0; 0 1], 0 by 0 empty matrix
 Morphism with
Domain: 2⋅𝟙
Codomain: 2⋅𝟙
Matrices: [-1 0; 0 -1], 0 by 0 empty matrix, 0 by 0 empty matrix
 Morphism with
Domain: 2⋅X
Codomain: 2⋅X
Matrices: 0 by 0 empty matrix, 0 by 0 empty matrix, [0 -1//2; 2 0]
```

Now we address the non-split phenomenon: We show that two of the simple objects of $\mathcal{Z}(\mathcal{C})$ are not split over $\mathbb{Q}(\sqrt{2})$, and examine over which fields they will split. To do so we examine the endomorphism spaces. The central object lying over $2\cdot \chi$ will split if there is an endomorphism that is a zero-divisor, i.e. if there is a morphism with a non-trivial eigenvalue: this will yield a projector to a direct summand. Thus, we take a non-trivial endomorphism and consider the splitting field for its minimal polynomial.

```julia-repl
julia> H = End(S[4]) 
Vector space of dimension 2 over Real quadratic field defined by x^2 - 2.

julia> minpoly.(basis(H)) # minimal polynomials of basis morphisms
2-element Vector{AbstractAlgebra.Generic.Poly{nf_elem}}:
 x - 1
 x^2 + 1//4
```