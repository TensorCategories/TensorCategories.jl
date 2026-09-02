# [Conventions for F- and R-symbols](@id f-conventions)

This page fixes the mathematical meaning of every row, column, and dictionary
index used for F- and R-symbols. The conventions apply to a split skeletal
fusion category; the preceding page explains why the splitting hypothesis is
needed.

For the pentagon and hexagon equations in Bonderson's convention, use
`F_symbols(C; convention=:bonderson)` and
`R_symbols(C; convention=:bonderson)`. The default keyword retains the
historical TensorCategories dictionary packing for compatibility with existing
data files.

## Binary fusion bases

Let $\mathcal C$ be a split fusion category over a field $k$, and fix an
ordered set of simple representatives

```math
(S_1,\ldots,S_r).
```

The implementation uses the order returned by `simples(C)`. For simple objects
$a,b,e$, put

```math
V_{ab}^{e}=\operatorname{Hom}_{\mathcal C}(a\otimes b,e),
\qquad
N_{ab}^{e}=\dim_k V_{ab}^{e},
```

and choose an ordered projection basis

```math
p^{ab}_{e,\mu}:a\otimes b\longrightarrow e,
\qquad 1\leq \mu\leq N_{ab}^{e}.
```

These binary bases determine bases for the two projection spaces of a triple
tensor product. For a fixed output simple $d$, define

```math
L_{e,\mu,\nu}
=p^{ec}_{d,\nu}\circ
  \bigl(p^{ab}_{e,\mu}\otimes\operatorname{id}_c\bigr)
:(a\otimes b)\otimes c\longrightarrow d
```

and

```math
R_{f,\rho,\sigma}
=p^{af}_{d,\sigma}\circ
  \bigl(\operatorname{id}_a\otimes p^{bc}_{f,\rho}\bigr)
:a\otimes(b\otimes c)\longrightarrow d.
```

The left paths are ordered lexicographically as $(e,\mu,\nu)$, with $\nu$
varying fastest. The right paths are ordered as $(f,\rho,\sigma)$, with
$\sigma$ varying fastest. Intermediate simples follow the order of
`simples(C)`.

## The associator matrix

Let

```math
\alpha_{a,b,c}:(a\otimes b)\otimes c
   \longrightarrow a\otimes(b\otimes c)
```

be the associator. Its block with output $d$ is the matrix $A=A^{abc}_d$
defined by

```math
R_{f,\rho,\sigma}\circ\alpha_{a,b,c}
=\sum_{e,\mu,\nu}
 A^{abc}_d[(e,\mu,\nu),(f,\rho,\sigma)]
 L_{e,\mu,\nu}.
\tag{1}
```

Thus rows are left paths and columns are right paths. In the documentation's
index notation, the stored block is `C.ass[a,b,c,d]`. Its size is

```math
\left(\sum_e N_{ab}^{e}N_{ec}^{d}\right)
\times
\left(\sum_f N_{bc}^{f}N_{af}^{d}\right).
```

Associativity of the fusion rules makes the two numbers equal.

Choose splitting bases composition-dual to the projection bases, and let
$L^{e,\mu,\nu}$ and $R^{f,\rho,\sigma}$ be the induced triple-product
splittings. Equation (1) is equivalent to

```math
\alpha_{a,b,c}\circ L^{e,\mu,\nu}
=\sum_{f,\rho,\sigma}
 A^{abc}_d[(e,\mu,\nu),(f,\rho,\sigma)]
 R^{f,\rho,\sigma}.
\tag{2}
```

Equation (2) is the input-first F-move convention of
[bonderson2007thesis](@citet), Eq. (2.6), and
[bonderson2008interferometry](@citet), Eq. (2.14). In particular, the
dictionary returned by
`F_symbols(C; convention=:bonderson)` has keys

```julia
[a,b,c,d,e,f]                  # multiplicity-free
[a,b,c,d,e,mu,nu,f,rho,sigma] # general case
```

and its value is the corresponding entry of $A$ in (1) and (2).

The package stores matrices for row coordinates: whenever the represented
composition is defined,

```julia
matrix(g ∘ f) == matrix(f) * matrix(g)
```

A reader who instead represents splitting-space vectors by columns therefore
uses $A^{\mathsf T}$ as the matrix of the associator. This transpose is only a
coordinate convention. It is neither an inverse nor a complex conjugate, and
composition-dual bases need not be Hermitian-adjoint bases.

## The braiding matrix

For simple objects $a,b,d$, let $B=B^{ab}_d$ be defined by

```math
p^{ba}_{d,\nu}\circ c_{a,b}
=\sum_{\mu}
 B^{ab}_d[\mu,\nu]p^{ab}_{d,\mu}.
\tag{3}
```

In composition-dual splitting bases this is

```math
c_{a,b}\circ s_{ab}^{d,\mu}
=\sum_{\nu}B^{ab}_d[\mu,\nu]s_{ba}^{d,\nu}.
\tag{4}
```

This is Eq. (2.54) of [bonderson2007thesis](@citet). The row index $\mu$
labels the input basis of $\operatorname{Hom}(a\otimes b,d)$, and the column
index $\nu$ labels the output basis of
$\operatorname{Hom}(b\otimes a,d)$. With the same index notation, the
structural matrix is `C.braiding[a,b,d]`, and
`R_symbols(C; convention=:bonderson)` uses keys

```julia
[a,b,d]       # multiplicity-free
[a,b,d,mu,nu] # general case
```

with value $B^{ab}_d[\mu,\nu]$.

The order of $a$ and $b$ matters. The inverse of $B^{ab}_d$ represents the
inverse map from $b\otimes a$ to $a\otimes b$; it is not generally
$B^{ba}_d$.

## Pentagon and hexagon equations

In a multiplicity-free category, write
$\mathcal F^{abc}_d[e,f]$ for the coefficient in (2), and write
$\mathcal R^{ab}_d$ for the coefficient in (4). With inadmissible fusion paths
interpreted as zero, the pentagon equation is

```math
\mathcal F^{fcd}_e[g,l]\,\mathcal F^{abl}_e[f,k]
=\sum_h
  \mathcal F^{abc}_g[f,h]\,
  \mathcal F^{ahd}_e[g,k]\,
  \mathcal F^{bcd}_k[h,l].
\tag{5}
```

This is the multiplicity-free form of Eqs. (2.9) and (2.77) in
[bonderson2007thesis](@citet). The two hexagon equations, in the same
convention, are

```math
\mathcal R^{ca}_e\,
\mathcal F^{acb}_d[e,g]\,
\mathcal R^{cb}_g
=\sum_f
\mathcal F^{cab}_d[e,f]\,
\mathcal R^{cf}_d\,
\mathcal F^{abc}_d[f,g]
\tag{6}
```

and

```math
(\mathcal R^{ac}_e)^{-1}\,
\mathcal F^{acb}_d[e,g]\,
(\mathcal R^{bc}_g)^{-1}
=\sum_f
\mathcal F^{cab}_d[e,f]\,
(\mathcal R^{fc}_d)^{-1}\,
\mathcal F^{abc}_d[f,g].
\tag{7}
```

They are Eqs. (2.57) and (2.58) in
[bonderson2007thesis](@citet). These formulas are useful independent checks
that labels, matrix directions, and the order of the R-symbol superscripts have
been translated correctly.

## Unit normalization

`SixJCategory` uses strict unit constraints in its skeletal coordinates. Every
associator block with a unit input is an identity matrix. The keywords
`set_one!(...; check=true)` and `set_associator!(...; check=true)` check this
normalization. They do not check the full pentagon; use `pentagon_axiom(C)` for
that.

## Changes of fusion bases

A gauge transformation changes the basis of every binary fusion space
$V_{ab}^{e}$. It consequently changes both triple-product bases. If

```math
L'_u=\sum_s L_sP_{s,u},
\qquad
R'_v=\sum_t R_tQ_{t,v},
```

then the associator block in the new bases is

```math
A'=P^{-1}AQ.
```

The matrices $P$ and $Q$ are assembled from the binary basis changes, block by
block over the intermediate channels. The same binary basis choices determine
the transformation of $B$. Consequently, raw F- and R-symbol entries are not
gauge invariants.

## Relation to other published conventions

The convention in (2) agrees with the splitting diagrams in
[bonderson2007thesis](@cite) and [bonderson2008interferometry](@cite), after
matching simple labels and binary bases. The latter reference assumes
unitarity; equations (1) and (2) also make sense over a general splitting field
without a Hermitian structure.

The fusion spaces in [osborne2019h3](@cite) are
$\operatorname{Hom}(d,a\otimes b)$. Its associator map is written in column
coordinates with the output channel as the first matrix index. With
composition-dual bases and matching labels, that matrix is $A^{\mathsf T}$.
This explains the transpose between the package's structural matrices and the
convention used for the $H_3$ formulas in that reference.

In [maeurer2026thesis](@citet), Eqs. (1.58)--(1.59) and Algorithm 6, the
F-matrix is defined on projection trees by

```math
L_u\circ\alpha^{-1}=\sum_vM^{F}_{u,v}R_v.
```

Equation (1.65) of the same reference defines the R-matrix by

```math
p^{ab}_{d,\mu}\circ c_{a,b}^{-1}
=\sum_\nu M^{R}_{\mu,\nu}p^{ba}_{d,\nu}.
```

Relative to the structural matrices in (1) and (3), these projection-inverse
matrices are

```math
M^{F}=(A^{-1})^{\mathsf T},
\qquad
M^{R}=(B^{-1})^{\mathsf T}.
\tag{8}
```

Thus, in the package's row-coordinate realization, the associator block
corresponding to the thesis matrix $M^F$ is
$A=(M^F)^{-\mathsf T}$, and similarly $B=(M^R)^{-\mathsf T}$ for the
braiding.

The F-symbol convention in Eq. (2) of [ardonne2010clebsch](@citet) has the
same projection direction as $M^F$. The two `convention` keywords below
change the association of dictionary keys with entries of $A$ and $B$; they
do not apply the inverse-transpose operation in (8).

These comparisons concern mathematical matrix conventions. The historical
dictionary packing used by the database is a separate software format,
described on the [data exchange page](@ref symbol-data).

## The two convention keywords

| Keyword | Meaning |
|:---|:---|
| `:bonderson` | Direct mathematical path indices as in (1)–(4) |
| `:column_major_packing` | Historical dictionary packing used by existing TensorCategories data files |

The default is `:column_major_packing` for compatibility with existing data.
Neither keyword changes the structural matrices, the binary bases, or the
gauge. The return value is an ordinary `Dict` and does not carry its convention;
the caller must retain that information.

The [worked examples](@ref working-with-fusion-data) apply these equations to
explicit categories. The exact key packing and serialization metadata are
specified under [Data exchange](@ref symbol-data).
