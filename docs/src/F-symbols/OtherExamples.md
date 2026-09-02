# Other supplied fusion data

## E₆

`E6subfactor()` uses algebraic numbers and labels $(\mathbb 1,x,y)$, with
```math
x^2=1+2x+y,\qquad xy=yx=x,\qquad y^2=1.
```
The implementation contains explicit blocks of sizes 1, 2, and 6, including
complex roots of unity. Its source points to [hong2008exotic](@cite) for the
recoupling data.

!!! warning "Incorrect associator data"
    The current constructor fails the pentagon on $(x,x,x,x)$ and does not
    define a monoidal category.

The $6$-by-$6$ block uses $\zeta_{24}^{-3}$ in entries where
[hong2008exotic](@cite), §8.1, p. 1069, prints
$\exp(-\pi i/3)=\zeta_{24}^{-4}$. That reference orders its channels as
$\mathbb 1$, $y$, then the four $x$ channels; the package uses the order described in
[F-symbol conventions](@ref f-conventions). No braiding is supplied.

## [SU(3)₃ subcategory](@id su3-subcategory)

`TensorCategories.su_3_3_subcategory(K)` is loaded but not exported. The default
field is $\mathbb Q(\zeta_{12})$. Labels are
$(\mathbb 1,8,10,\overline{10})$, with
$8^2=\mathbb 1+2\cdot8+10+\overline{10}$.
It supplies associators and braiding, including a $7$-by-$7$ associator block.
The source is [ardonne2010clebsch](@cite), Appendix B.3, pp. 35–36,
equations (82)–(92). The $7$-by-$7$ array is the
displayed matrix (87), whose rows use the left intermediate channel. These
arrays are real orthogonal; the [conventions page](@ref f-conventions) explains
why the paper's projection convention and the package's splitting convention
give the same arrays in this gauge.

The complex embedding needs separate attention. Write $\iota$ for the element
returned by `TensorCategories.root_of_unity(K,4)`; this routine chooses a
primitive root, not a distinguished positive-imaginary complex root.
For $8\otimes8\to8$, the code stores $\operatorname{diag}(\iota,-\iota)$,
while Eq. (89) prints $\operatorname{diag}(-i,i)$ at
$q=\exp(2\pi i/6)$. With $\iota\mapsto i$, the arrays are inverse.
With $\iota\mapsto-i$ and the chosen square root of $3$ mapping to $+\sqrt3$,
they agree.
The default constructor does **not** install a complex embedding.
Consequently the bare number-field data do not fix one of these complex
realizations.

For the default field, this translation is the exact automorphism
$\zeta_{12}\mapsto\zeta_{12}^{-1}$. It fixes every associator coefficient and reverses the two
nonreal braiding eigenvalues. No change of F-symbol gauge is required:

```@example su3root
using TensorCategories, Oscar
C = TensorCategories.su_3_3_subcategory()
K = base_ring(C)
σ = hom(K,K,inv(gen(K)))
@assert !isdefined(C,:embedding)
@assert all(σ(x)==x for A in C.ass for x in A)
B = C.braiding[2,2,2]
@assert σ(B[1,1]) == -B[1,1]
@assert σ(B[2,2]) == -B[2,2]
nothing # hide
```

To compare with the paper over the algebraic complex numbers, choose the
embedding explicitly:

```@example su3root
Kbar = QQBarField()
zpaper = (sqrt(Kbar(3))-sqrt(Kbar(-1)))/2
e = complex_embedding(K,AcbField()(zpaper))
Cpaper = complex_embedding(C,e)
@assert Cpaper.ass[2,2,2,2][1,2] == inv(sqrt(Kbar(3)))
@assert Cpaper.braiding[2,2,2] ==
        matrix(Kbar,[-sqrt(Kbar(-1)) 0; 0 sqrt(Kbar(-1))])
nothing # hide
```

This is the rank-four subcategory, not the entire SU(3)₃ category.
It is braided but not modular. Its multiplicity-two fusion space is illustrated
in the [worked examples](@ref working-with-fusion-data).

## Vercleyen–Slingerland imports

`cat_fr_8122(n)` loads `asso_n.jl` from the rank-eight `FR8211` dataset.
The available indices are `1:96`, and the field is $\mathbb Q(\zeta_{24})$.
The index selects a data file.

`cat_fr_9143()` loads one rank-nine solution over algebraic numbers with labels
$(g_0,g_3,t_2,t_1,t_0,g_4,g_2,g_5,g_1)$.

The source is [VercleyenSingerland](@cite). These loaders use their own channel ordering,
which differs from the [AnyonWiki dictionary format](@ref symbol-data).
