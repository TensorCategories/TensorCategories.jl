# [Anyons, CFT, and tensor-category language](@id physics-bridge)

This page translates between terminology common in anyon physics, rational
conformal field theory, and tensor-category theory. It also gives a short route
from a familiar anyon model to the package interface. The categorical language
used here follows [EGNO](@cite); the anyon conventions and fusion-tree language
follow [bonderson2007thesis](@cite), Chapter 2.

## A dictionary in both directions

In a unitary anyon model one usually works with a unitary braided fusion
category equipped with compatible duality and spherical or ribbon data. The
general package interface does not assume that every category has all these
structures.

| Anyon or CFT terminology | Tensor-category and package terminology |
|:---|:---|
| topological charge, particle type, primary label | simple object $a$ |
| vacuum charge | tensor unit $\mathbb 1$, returned by `one(C)` |
| antiparticle or conjugate charge | dual object $a^*$, returned by `dual(a)` |
| fusion | tensor product $a\otimes b$ |
| fusion multiplicity | $N_{ab}^{c}=\dim_k\operatorname{Hom}(a\otimes b,c)$ in the split case |
| fusion channel $c$ | simple summand $c$ of $a\otimes b$ |
| fusion space | $V_{ab}^{c}=\operatorname{Hom}(a\otimes b,c)$ in the package's projection convention |
| splitting space | $\operatorname{Hom}(c,a\otimes b)$; composition-dual to a chosen projection basis |
| fusion tree | basis obtained by iterating binary fusion spaces |
| $F$-move | associator written in two fusion-tree bases |
| exchange or elementary braid | braiding; its binary fusion-space matrix gives the R-symbols |
| topological spin | twist eigenvalue $\theta_a$ |
| quantum dimension | categorical dimension `dim(a)` for the chosen pivotal/spherical structure |
| fusion-rule dimension | Frobenius--Perron dimension `fpdim(a)` |
| total quantum dimension $\mathcal D$ | $\sqrt{\dim(\mathcal C)}$ for a unitary spherical fusion category |
| modular $S$ and $T$ data | `normalized_smatrix(C)` and the twist matrix `tmatrix(C)`, with the normalization below |

To keep mathematical labels and code aligned, throughout this manual the same
letters also denote the corresponding integer positions when they occur inside
an array subscript or dictionary key. Thus, if $a,b,c$ are simple objects, the
`a`, `b`, and `c` in `multiplication_table(C)[a,b,c]` are their positions in
`simples(C)`, rather than the object values themselves.

For a split fusion category the integers $N_{ab}^{c}$ are stored in this
multiplication table. In a non-split category the endomorphism division
algebras enter the multiplicity formula; see
[Grothendieck rings](@ref grothendieck-rings). The distinction between
categorical and Frobenius--Perron dimensions also matters outside the unitary
or pseudounitary setting.

## First anyon computation: Ising

The following AnyonWiki entry is a braided pivotal Ising category. Its artifact
uses generic labels, so we identify the charges from the fusion rules:

```@example physics
using TensorCategories, Oscar
C = anyonwiki(3,1,0,1,1,1,1)
objects = simples(C)
U, Psi, Sigma = objects
u, psi, sigma = eachindex(objects)
@assert U == one(C)
@assert Psi ⊗ Psi == U
@assert Psi ⊗ Sigma == Sigma ⊗ Psi == Sigma
@assert Sigma ⊗ Sigma == U ⊕ Psi
@assert dim(Sigma)^2 == 2
@assert dim(C) == 4
(simples_names(C), dim.(objects))
show(stdout, MIME"text/plain"(),
    (simples_names(C), dim.(objects))); println() # hide
```

Thus the three stored labels represent $(\mathbb 1,\psi,\sigma)$, and the
package's global dimension is

```math
\dim(\mathcal C)=\sum_a d_a^2=4.
```

Physicists usually call $\mathcal D=2$ the total quantum dimension. The method
`dim(C)` returns $\mathcal D^2$, not $\mathcal D$.

The database can be searched before loading a model. The optional attributes
select entries marked by the pinned dataset:

```@example physics
keys = anyonwiki_keys(3,"unitary","modular")
@assert (3,1,0,1,1,1,1) in keys
first(keys,5)
show(stdout, MIME"text/plain"(), first(keys,5)); println() # hide
```

The seven indices and the meaning of these dataset flags are described under
[AnyonWiki](../F-symbols/AnyonWiki.md).

## Fusion spaces are not object dimensions

For three Ising anyons with total charge $\sigma$,

```math
\mathcal H^{\sigma}_{\sigma\sigma\sigma}
=\operatorname{Hom}((\sigma\otimes\sigma)\otimes\sigma,\sigma)
```

has dimension two. Its usual fusion-tree basis is indexed by the intermediate
charges $\mathbb 1$ and $\psi$:

```@example physics
H = Hom((Sigma ⊗ Sigma) ⊗ Sigma, Sigma)
@assert int_dim(H) == 2
@assert size(matrix(id(Sigma))) == (1,1)
int_dim(H)
```

The $1\times1$ matrix representing `id(Sigma)` does not say that
$d_\sigma=1$. The matrix belongs to the package's split semisimple coordinate
realization; quantum dimension is categorical trace data. See
[Matrices and fiber functors](@ref matrix-realizations).

## F- and R-symbols

Always specify `convention=:bonderson` when dictionary keys should name the
physical fusion paths directly:

```@example physics
F = F_symbols(C; convention=:bonderson)
R = R_symbols(C; convention=:bonderson)
A = C.ass[sigma,sigma,sigma,sigma]
@assert F[[sigma,sigma,sigma,sigma,u,u]] == A[1,1]
@assert R[[sigma,sigma,u]] == C.braiding[sigma,sigma,u][1,1]
(A, [R[[sigma,sigma,c]] for c in (u,psi)])
show(stdout, MIME"text/plain"(),
    (A, [R[[sigma,sigma,c]] for c in (u,psi)])); println() # hide
```

The integer keys are positions in `simples(C)`: in this entry the positions of
$(\mathbb 1,\psi,\sigma)$ are $(1,2,3)$. The row and column channels of $A$
are $(\mathbb 1,\psi)$. The precise
projection and splitting bases, matrix direction, multiplicity indices, and
braiding direction are fixed on the [F- and R-symbol convention page](@ref f-conventions).
Raw F- and R-symbol entries depend on fusion bases. Fusion rules, dimensions,
twists, and modular data are more useful when comparing gauges.

## S, T, topological spins, and CFT conventions

For a braided spherical category, `smatrix(C)` returns the unnormalized trace
of double braiding. The package defines

```math
S^{\mathrm{norm}}=\frac{1}{\sqrt{\dim(\mathcal C)}}S,
\qquad
T^{\mathrm{cat}}=\operatorname{diag}(\theta_a).
```

The corresponding computations are:

```@example physics
theta = twists(C)
S = smatrix(C)
S_normalized = normalized_smatrix(C)
T = tmatrix(C)
@assert T == diagonal_matrix(theta)
@assert S_normalized == inv(sqrt(dim(C)))*S
@assert is_modular(C)
nothing # hide
```

The square root in `normalized_smatrix(C)` is a choice over a general
coefficient field. In a unitary realization one chooses the positive total
quantum dimension.

For RCFT characters, a common convention is

```math
T^{\mathrm{RCFT}}_{aa}
=\exp\!\left(2\pi i\left(h_a-\frac{c}{24}\right)\right)
=e^{-2\pi i c/24}\theta_a,
\qquad \theta_a=e^{2\pi i h_a}.
```

Consequently, `tmatrix(C)` is the categorical twist matrix
$T^{\mathrm{cat}}$, without the overall central-charge phase. The categorical
data determine the conformal weights only modulo integers, and do not by
themselves provide the value of $c$ needed to restore that phase. The relation
between the fusing and braiding data of RCFT and categorical modular data goes
back to [moore1989classical](@cite).

## Exact and numerical use

The same model can be evaluated over complex balls at a chosen working
precision:

```@example physics
C_numeric = anyonwiki(AcbField(128),3,1,0,1,1,1,1)
@assert pentagon_axiom(C_numeric)
@assert hexagon_axiom(C_numeric)
@assert is_unitary(C_numeric)
@assert is_modular(C_numeric)
S_numeric = normalized_smatrix(C_numeric)
T_numeric = tmatrix(C_numeric)
nothing # hide
```

This is arbitrary-precision ball arithmetic, not exact algebraic equality. The
[numerical computations page](@ref numerical-computations) explains which
conclusions are rigorous and why a residual ball containing zero does not prove
an exact equation.

## Scope and current limitations

A modular tensor category records topological and chiral categorical data; it
is not by itself a complete two-dimensional CFT. TensorCategories.jl does not
construct characters, position-dependent conformal blocks, OPE coefficients,
or modular-invariant partition functions. Full RCFT constructions require
additional data; for example, the approach of [fuchs2002tft](@cite) uses a
symmetric special Frobenius algebra in the modular tensor category.

The package supplies associators, braidings, and local F- and R-symbols, from
which braid actions can be assembled. It currently has no public high-level API
that accepts a braid word and returns its matrix in a chosen multi-anyon
fusion-tree basis. The ordinary `braiding(X,Y)` method is a categorical
structural map, not such a braid-word interface.

Continue with [precise F- and R-symbol conventions](@ref f-conventions),
[numerical computations](@ref numerical-computations), or the
[category catalogue](@ref category-catalogue).
