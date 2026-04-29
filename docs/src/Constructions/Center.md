```@meta 
DocTestSetup = quote 
    using TensorCategories, Oscar
end
```

# [The Center Construction](@id center)

Let ``\mathcal C`` be a monoidal category. The __Drinfeld center__ of ``\mathcal C`` is
a category whose objects are tuples ``(X,\gamma)`` such that ``X \in \mathcal C`` and
``\{\gamma_Z \colon X \otimes Z \to Z \otimes X \mid Z \in \mathcal C\}`` is a natural isomorphism such that

```@raw html
<img src="https://i.upmath.me/svg/%5Cbegin%7Btikzcd%7D%0A%09%26%20(Y%20%5Cotimes%20X)%20%5Cotimes%20Z%20%5Car%5Br%2C%20%22a_%7BY%2CX%2CZ%7D%22%5D%20%26%20Y%20%5Cotimes%20(X%20%5Cotimes%20Z)%20%5Car%5Bdr%2C%20%22%5Cid_Y%20%5Cotimes%20%5Cgamma_X(Z)%22%5D%20%26%20%5C%5C%0A%20%20%20%20%20%20%20%20(X%20%5Cotimes%20Y)%20%5Cotimes%20Z%20%5Car%5Bur%2C%20%22%5Cgamma_X(Y)%20%5Cotimes%20%5Cid_Z%22%5D%20%5Car%5Bdr%2C%20%22a_%7BX%2CY%2CZ%7D%22%5D%20%26%20%26%20%26%20Y%20%5Cotimes%20(Z%20%5Cotimes%20X)%20%5C%5C%0A%20%20%20%20%20%20%20%20%20%20%20%20%26%20X%20%5Cotimes%20(Y%20%5Cotimes%20Z)%20%5Car%5Br%2C%20%22%5Cgamma_X(Y%20%5Cotimes%20Z)%22%5D%20%26%20(Y%20%5Cotimes%20Z)%20%5Cotimes%20X%20%5Car%5Bur%2C%20%22a_%7BY%2CZ%2CX%7D%22%5D%20%20%26%0A%5Cend%7Btikzcd%7D" alt="\begin{tikzcd}
	&amp; (Y \otimes X) \otimes Z \ar[r, &quot;a_{Y,X,Z}&quot;] &amp; Y \otimes (X \otimes Z) \ar[dr, &quot;\id_Y \otimes \gamma_X(Z)&quot;] &amp; \\
        (X \otimes Y) \otimes Z \ar[ur, &quot;\gamma_X(Y) \otimes \id_Z&quot;] \ar[dr, &quot;a_{X,Y,Z}&quot;] &amp; &amp; &amp; Y \otimes (Z \otimes X) \\
            &amp; X \otimes (Y \otimes Z) \ar[r, &quot;\gamma_X(Y \otimes Z)&quot;] &amp; (Y \otimes Z) \otimes X \ar[ur, &quot;a_{Y,Z,X}&quot;]  &amp;
\end{tikzcd}" /></p>
```

commutes for all ``Y,Z \in \mathcal C`` and ``\gamma_{\mathbb 1} = \mathrm{id}_X``.

# Computing the Center

The Drinfeld center can be computed explicitly for many fusion categories using the algorithm described in [maurer2024computing](@cite). Any fusion category implementing the corresponding interface is supported. 


## Example

```jldoctest ising
I = ising_category()
C = center(I)
simples(C)

# output
5-element Vector{CenterObject}:
 Central object: 𝟙
 Central object: 𝟙
 Central object: 𝟙 ⊕ χ
 Central object: 2⋅χ
 Central object: 4⋅X
```

Who is familiar with the center of the Ising category will notice that this looks odd. In fact this is because we define the Ising category over the field ``\mathbb Q (\sqrt{2})``and not ``\mathbb C``. In this case the endomorphism spaces are division algebras of dimension greater than one. 

```jldoctest ising
base_ring(I)

# output
Number field with defining polynomial x^2 - 2
  over rational field
```

```jldoctest ising 
r = endomorphism_ring(C[4])

# output
Matrix algebra of dimension 2 over Number field of degree 2 over QQ
```

```jldoctest ising 
is_simple(r) 

# output 
true
```

## Supported categories

In general all split fusion categories implementing the fusion category interface are supported. As ground fields we support all numberfield types from Oscar, i.e. all subtypes of `NumField`, the algebraic numbers `QQBarField`, the complex numbers `CalciumField` and the arbitrary precision complex ball numbers `AcbField`.

!!! warning If using `AcbField` as a grounf field, keep in mind to check the precision and increase it if the behaviour seems unexpected. Performing algebraic operations with numeric types is generally hard and multiple magnitudes of precision can be lost in single operations introducing error.  

# Centers of the AnyonWiki

Currently we are working at the task to compute all centers of multiplicity free fusion categories up to rank seven. At the moment all centers to rank 5 are available and some of rank six. Access them via 

```@docs 
anyonwiki_center
```

```jldoctest
C = anyonwiki_center(3,1,0,2,1,1,1)

print_multiplication_table(C)

# output
8×8 Matrix{String}:
 "(𝟙, γ)"        "(X2, γ)"       …  "(X2 ⊕ X3, γ)"
 "(X2, γ)"       "(𝟙, γ)"           "(𝟙 ⊕ X3, γ)"
 "(𝟙 ⊕ X2, γ)"   "(𝟙 ⊕ X2, γ)"      "(𝟙 ⊕ X3, γ) ⊕ (X2 ⊕ X3, γ)"
 "(X3, γ1)"      "(X3, γ1)"         "(𝟙 ⊕ X3, γ) ⊕ (X2 ⊕ X3, γ)"
 "(X3, γ2)"      "(X3, γ2)"         "(𝟙 ⊕ X3, γ) ⊕ (X2 ⊕ X3, γ)"
 "(X3, γ3)"      "(X3, γ3)"      …  "(𝟙 ⊕ X3, γ) ⊕ (X2 ⊕ X3, γ)"
 "(𝟙 ⊕ X3, γ)"   "(X2 ⊕ X3, γ)"     "(X2, γ) ⊕ (𝟙 ⊕ X2, γ) ⊕ (X3, γ1) ⊕ (X3, γ2) ⊕ (X3, γ3)"
 "(X2 ⊕ X3, γ)"  "(𝟙 ⊕ X3, γ)"      "(𝟙, γ) ⊕ (𝟙 ⊕ X2, γ) ⊕ (X3, γ1) ⊕ (X3, γ2) ⊕ (X3, γ3)"
```

## F- and R-Symbols

We can export the ``F``- and ``R``-symbols as Dicts via the methods 

```@docs
F_symbols
R_symbols
numeric_F_symbols
numeric_R_symbols
```

```@autodocs
Modules = [TensorCategories]
Pages = ["Center.jl", "CenterChecks.jl", "Induction.jl"]
```