# [Conventions for $F$-, $R$-, and $P$-symbols](@id f-conventions)

Scalar structural data arise only after bases have been chosen in the binary
fusion spaces. This page first fixes those bases and the induced bases for
triple tensor products. It then defines the matrices representing the
associator, braiding, and pivotal structure. Only after each matrix has been
defined do we attach the corresponding symbol notation.

These mathematical choices are separate from the dictionary layout used by
the data-exchange functions. The discussion applies to a split skeletal fusion
category; the preceding page explains the model and why the splitting
hypothesis is needed.

## Binary fusion bases

Let $\mathcal C$ be a split fusion category over a field $k$, and fix an
ordered set of simple representatives

```math
\label{eq:ordered-simple-representatives}
(S_1,\ldots,S_r).
```

The implementation uses the order returned by `simples(C)`. For simple objects
$a,b,e$, put

```math
\label{eq:binary-fusion-space}
V_{ab}^{e}=\operatorname{Hom}_{\mathcal C}(a\otimes b,e),
\qquad
N_{ab}^{e}=\dim_k V_{ab}^{e},
```

and choose an ordered projection basis

```math
\label{eq:binary-projection-basis}
p^{ab}_{e,\mu}:a\otimes b\longrightarrow e,
\qquad 1\leq \mu\leq N_{ab}^{e}.
```

Let

```math
\label{eq:binary-splitting-basis}
s_{ab}^{e,\mu}:e\longrightarrow a\otimes b
```

be the composition-dual splitting basis. Thus

```math
\label{eq:composition-dual-bases}
p^{ab}_{e,\mu}\circ s_{ab}^{e,\nu}
=\delta_{\mu,\nu}\operatorname{id}_e,
\qquad
\sum_{e,\mu}s_{ab}^{e,\mu}\circ p^{ab}_{e,\mu}
=\operatorname{id}_{a\otimes b}.
```

These binary bases determine bases for the two projection spaces of a triple
tensor product. For a fixed output simple $d$, define

```math
\label{eq:left-triple-projection}
L_{e,\mu,\nu}
=p^{ec}_{d,\nu}\circ
  \bigl(p^{ab}_{e,\mu}\otimes\operatorname{id}_c\bigr)
:(a\otimes b)\otimes c\longrightarrow d
```

and

```math
\label{eq:right-triple-projection}
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
\label{eq:associator-map}
\alpha_{a,b,c}:(a\otimes b)\otimes c
   \longrightarrow a\otimes(b\otimes c)
```

be the associator. Its block with output $d$ is the matrix $A=A^{abc}_d$
defined by

```math
\label{eq:associator-projection-bases}
R_{f,\rho,\sigma}\circ\alpha_{a,b,c}
=\sum_{e,\mu,\nu}
 A^{abc}_d[(e,\mu,\nu),(f,\rho,\sigma)]
 L_{e,\mu,\nu}.
```

Thus rows are left paths and columns are right paths. In the documentation's
index notation, the stored block is `C.ass[a,b,c,d]`. Its size is

```math
\label{eq:associator-block-size}
\left(\sum_e N_{ab}^{e}N_{ec}^{d}\right)
\times
\left(\sum_f N_{bc}^{f}N_{af}^{d}\right).
```

Associativity of the fusion rules makes the two numbers equal.

Let $L^{e,\mu,\nu}$ and $R^{f,\rho,\sigma}$ be the triple-product splittings
induced by the composition-dual binary bases. Equation
$\eqref{eq:associator-projection-bases}$ is equivalent to

```math
\label{eq:associator-splitting-bases}
\alpha_{a,b,c}\circ L^{e,\mu,\nu}
=\sum_{f,\rho,\sigma}
 A^{abc}_d[(e,\mu,\nu),(f,\rho,\sigma)]
 R^{f,\rho,\sigma}.
```

The entries of $A^{abc}_d$ are the **$F$-symbols** in this manual. Explicitly,

```math
\label{eq:F-symbol-definition}
\left[F^{abc}_d\right]_{(e,\mu,\nu),(f,\rho,\sigma)}
:=A^{abc}_d[(e,\mu,\nu),(f,\rho,\sigma)].
```

Equation $\eqref{eq:associator-splitting-bases}$ replaces a left-associated
splitting tree by a linear
combination of right-associated splitting trees; this change of basis is the
**$F$-move**. The first multi-index in $\eqref{eq:F-symbol-definition}$ labels
the input tree and the second labels the output tree. This is the convention used in
[bonderson2008interferometry; Eq. (2.14)](@citet) and
[barkeshli2019symmetry; Eq. (10)](@citet). Both references work with unitary
anyon models and orthonormal splitting bases. The same coefficient convention
makes sense for the composition-dual bases used here over an arbitrary
splitting field.

The function `F_symbols(C; convention=...)` returns all admissible
coefficients, including zeros, as a Julia dictionary. The two accepted
dictionary conventions are:

| `convention` | Keys |
|:---|:---|
| `:bonderson` | `[a,b,c,d,e,f]` without multiplicities and `[a,b,c,d,e,mu,nu,f,rho,sigma]` in general |
| `:column_major_packing` | `[a,b,c,d,f,e]` without multiplicities and `[a,b,c,d,f,sigma,rho,e,mu,nu]` in general |

With `convention=:bonderson`, the value is precisely the entry in
$\eqref{eq:F-symbol-definition}$ named by the two fusion paths in the key. The
default is `convention=:column_major_packing`, the layout used by
TensorCategories data files. In that layout the suffix records the order used
to pack the entries of $A$ in Julia column-major order: for fixed $a,b,c,d$,
the keys are traversed in the nested order
$(e,f,\nu,\mu,\rho,\sigma)$ and matched with successive entries of `vec(A)`.
The key suffix is therefore not a pair of direct fusion-path indices. The
[data exchange page](@ref symbol-data) gives the equivalent entry-by-entry
reconstruction rule. Changing `convention` changes the dictionary keys and
their interpretation, not the matrix $A$, the chosen bases, or the gauge.
`numeric_F_symbols` uses the same keyword.

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
\label{eq:braiding-projection-bases}
p^{ba}_{d,\nu}\circ c_{a,b}
=\sum_{\mu}
 B^{ab}_d[\mu,\nu]p^{ab}_{d,\mu}.
```

In composition-dual splitting bases this is

```math
\label{eq:braiding-splitting-bases}
c_{a,b}\circ s_{ab}^{d,\mu}
=\sum_{\nu}B^{ab}_d[\mu,\nu]s_{ba}^{d,\nu}.
```

The entries of $B^{ab}_d$ are the **$R$-symbols**:

```math
\label{eq:R-symbol-definition}
\left[R^{ab}_d\right]_{\mu,\nu}:=B^{ab}_d[\mu,\nu].
```

Equation $\eqref{eq:braiding-splitting-bases}$ is the **$R$-move** induced by
the braiding. The row index $\mu$ labels the input basis of
$\operatorname{Hom}(a\otimes b,d)$, and the column index $\nu$ labels the output basis of
$\operatorname{Hom}(b\otimes a,d)$. This is the convention used in
[bonderson2008interferometry; Eqs. (2.31)--(2.32)](@citet); see also
[barkeshli2019symmetry; Eqs. (27)--(28)](@citet). With the same index notation,
the structural matrix is `C.braiding[a,b,d]`.

The function `R_symbols(C; convention=...)` returns all admissible
coefficients, including zeros. In the direct convention,

```julia
R_symbols(C; convention=:bonderson)[[a,b,d,mu,nu]]
```

is $B^{ab}_d[\mu,\nu]$; in the multiplicity-free case the key is `[a,b,d]`.
The default `:column_major_packing` convention uses the same key shapes, but
stores $B^{ab}_d[\nu,\mu]$ under `[a,b,d,mu,nu]`. Thus the two multiplicity
indices are transposed in the default dictionary layout. This is a packing
rule, not an inverse braiding or a change of gauge. `numeric_R_symbols` uses
the same keyword.

Both functions return an ordinary `Dict`, which does not retain the selected
convention. Code that stores or passes the dictionary separately from the
category must therefore retain the convention as accompanying metadata.

The order of $a$ and $b$ matters. The inverse of $B^{ab}_d$ represents the
inverse map from $b\otimes a$ to $a\otimes b$; it is not generally
$B^{ba}_d$.

## Pivotal coefficients

A pivotal structure is a monoidal natural isomorphism

```math
\label{eq:pivotal-structure-map}
j:\operatorname{id}_{\mathcal C}\Longrightarrow(-)^{**}
```

[EGNO; Definition 4.7.7](@cite). In the skeletal model the chosen duality has
$S_i^{**}=S_i$. Since $S_i$ is split simple, the component of $j$ is a scalar:

```math
\label{eq:P-symbol-definition}
j_{S_i}=P_i\operatorname{id}_{S_i},\qquad P_i\in k^\times.
```

TensorCategories.jl calls the scalars $P_i$ **$P$-symbols**. They are stored as
`C.pivotal[i]`, and `P_symbols(C)` returns the dictionary
`Dict([i] => P_i)`. This function name refers specifically to the components
in $\eqref{eq:P-symbol-definition}$; the term “pivotal symbols” is also used elsewhere for different data
attached to trivalent fusion spaces.

The coefficients $P_i$ are additional structure: they are not determined by
the $F$- or $R$-symbols. They must make $j$ monoidal. If

```math
\label{eq:double-dual-tensorator}
\phi_{X,Y}:(X\otimes Y)^{**}\longrightarrow X^{**}\otimes Y^{**}
```

is the package's monoidal structure of the double-dual functor, the required
identity is

```math
\label{eq:pivotal-monoidality}
j_X\otimes j_Y=\phi_{X,Y}\circ j_{X\otimes Y}.
```

The initializer `six_j_category` sets $P_i=1$ for every simple object, and
`set_pivotal!` replaces these components. Validation is explicit: use
`is_pivotal(C; check=true)` to check
$\eqref{eq:pivotal-monoidality}$. Sphericality is the
additional equality of the left and right pivotal traces and can be checked
with `is_spherical(C; check=true)`. Since a $P$-symbol dictionary has one
scalar per simple object rather than matrix entries indexed by fusion paths,
`P_symbols` has no `convention` keyword.

## [Unit normalization](@id unit-normalization)

`SixJCategory` uses strict unit constraints in its skeletal coordinates. The
normalized convention requires every associator block with a unit input to be
an identity matrix, and the public `associator` function treats such inputs as
strict. The low-level setters accept `check=false` for prevalidated input. With
`check=true`, `set_one!` and `set_associator!` check unit normalization. The
full pentagon is checked separately by `pentagon_axiom(C)`.

## Pentagon and hexagon equations

In a multiplicity-free category, write
$\mathcal F^{abc}_d[e,f]$ for the coefficient in
$\eqref{eq:associator-splitting-bases}$, and write $\mathcal R^{ab}_d$ for the
coefficient in $\eqref{eq:braiding-splitting-bases}$. With inadmissible fusion paths
interpreted as zero, the pentagon equation is

```math
\label{eq:pentagon-multiplicity-free}
\mathcal F^{fcd}_e[g,l]\,\mathcal F^{abl}_e[f,k]
=\sum_h
  \mathcal F^{abc}_g[f,h]\,
  \mathcal F^{ahd}_e[g,k]\,
  \mathcal F^{bcd}_k[h,l].
```

This is the multiplicity-free specialization of the standard indexed pentagon
equation in [barkeshli2019symmetry; Eq. (12)](@citet). The two hexagon
equations, in the same convention, are

```math
\label{eq:hexagon-positive-multiplicity-free}
\mathcal R^{ca}_e\,
\mathcal F^{acb}_d[e,g]\,
\mathcal R^{cb}_g
=\sum_f
\mathcal F^{cab}_d[e,f]\,
\mathcal R^{cf}_d\,
\mathcal F^{abc}_d[f,g]
```

and

```math
\label{eq:hexagon-negative-multiplicity-free}
(\mathcal R^{ac}_e)^{-1}\,
\mathcal F^{acb}_d[e,g]\,
(\mathcal R^{bc}_g)^{-1}
=\sum_f
\mathcal F^{cab}_d[e,f]\,
(\mathcal R^{fc}_d)^{-1}\,
\mathcal F^{abc}_d[f,g].
```

These agree with [bonderson2007thesis; Eqs. (2.57)--(2.58)](@citet), with the label
order and $R$-symbol superscripts used here.

Equations $\eqref{eq:hexagon-positive-multiplicity-free}$ and
$\eqref{eq:hexagon-negative-multiplicity-free}$ result by suppressing the
multiplicity indices in those full equations. The compact formulas printed as
[bonderson2007thesis; Eqs. (2.78)--(2.79)](@citet) reverse the ordered
superscripts of the $R$-symbols relative to the defining $R$-move in Eq. (2.54) and
the full hexagon equations. The convention here follows Eq. (2.54),
Eqs. (2.57)--(2.58), and the categorical hexagon.

Equations $\eqref{eq:pentagon-multiplicity-free}$--$\eqref{eq:hexagon-negative-multiplicity-free}$
display the multiplicity-free scalar form. With fusion
multiplicities, the coherence conditions are the same pentagon and hexagon
identities between structural morphisms, using the full matrices and all four
binary-basis indices. The methods `pentagon_axiom(C)` and `hexagon_axiom(C)`
evaluate those morphism equations without a multiplicity-free assumption.

## Changes of fusion bases

A gauge transformation changes the basis of every binary fusion space
$V_{ab}^{e}$. It consequently changes both triple-product bases. If

```math
\label{eq:gauge-basis-change}
L'_u=\sum_s L_sU_{s,u},
\qquad
R'_v=\sum_t R_tV_{t,v},
```

then the associator block in the new bases is

```math
\label{eq:associator-gauge-change}
A'=U^{-1}AV.
```

The matrices $U$ and $V$ are assembled from the binary basis changes, block by
block over the intermediate channels. The same binary basis choices determine
the transformation of $B$. Consequently, raw $F$- and $R$-symbol entries are not
gauge invariants. The corresponding entrywise formulas for changes of binary
splitting bases are
[bonderson2007thesis; Eqs. (2.75)--(2.76)](@citet).

## Relation to other published conventions

The definitions in $\eqref{eq:F-symbol-definition}$ and
$\eqref{eq:R-symbol-definition}$ are the published anyon conventions cited above.
Other sources may instead use projection trees, reverse the associator,
or place the output coordinate first. Those choices change the displayed
matrix without changing the underlying structural morphism.

The fusion spaces in [osborne2019h3; §2, p. 2, and §4, pp. 3--4](@citet) are
$\operatorname{Hom}(d,a\otimes b)$. Its associator map is written in column
coordinates with the output channel as the first matrix index. With
composition-dual bases and matching labels, that matrix is $A^{\mathsf T}$.
This explains the transpose between the package's structural matrices and the
convention used for the $H_3$ formulas in that reference.

In [maeurer2026thesis; Eqs. (1.58)--(1.59), (1.65), and Algorithm 6](@citet),
the $F$- and $R$-matrices are defined on projection trees by

```math
\label{eq:thesis-F-projection-matrix}
L_u\circ\alpha^{-1}=\sum_vM^{F}_{u,v}R_v.
```

```math
\label{eq:thesis-R-projection-matrix}
p^{ab}_{d,\mu}\circ c_{a,b}^{-1}
=\sum_\nu M^{R}_{\mu,\nu}p^{ba}_{d,\nu}.
```

There is also an index-order translation in the multiplicity case. The thesis
prints the left projection tree with multi-index $(m,\beta,\alpha)$, whereas
the corresponding path in this manual is ordered as
$(e,\mu,\nu)=(m,\alpha,\beta)$. The thesis's right multi-index
$(n,\gamma,\delta)$ has the same order as
$(f,\rho,\sigma)$. After applying this relabeling, so that both matrices are
indexed by the same ordered projection trees, the projection-inverse matrices
are related to the structural matrices in
$\eqref{eq:associator-projection-bases}$ and
$\eqref{eq:braiding-projection-bases}$ by

```math
\label{eq:projection-inverse-conversion}
M^{F}=(A^{-1})^{\mathsf T},
\qquad
M^{R}=(B^{-1})^{\mathsf T}.
```

Thus, in the package's row-coordinate realization, the associator block
corresponding to the thesis matrix $M^F$ is
$A=(M^F)^{-\mathsf T}$, and similarly $B=(M^R)^{-\mathsf T}$ for the
braiding.

The $F$-symbol convention in [ardonne2010clebsch; Eq. (2)](@citet) has the
same projection direction as $M^F$. The dictionary conventions described
above change the association of keys with entries of $A$ and $B$; they do not
apply the inverse-transpose operation in
$\eqref{eq:projection-inverse-conversion}$.

These comparisons concern mathematical matrix conventions. The dictionary
packing used by the database is a separate software format,
described on the [data exchange page](@ref symbol-data).

The [worked examples](@ref working-with-fusion-data) apply these equations to
explicit categories. The exact key packing and serialization metadata are
specified under [Data exchange](@ref symbol-data).
