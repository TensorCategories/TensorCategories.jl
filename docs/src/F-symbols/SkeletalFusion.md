# [Skeletal fusion categories](@id skeletal-fusion)

Let $\mathcal C$ be a split fusion category over a field $k$, and choose
representatives $S_1,\ldots,S_r$ of its simple objects. Decompositions into
these simples give a skeletal linear model: objects become multiplicity
vectors, morphisms become blocks of matrices over $k$, and the tensor structure
is described by fusion rules and F-symbols. TensorCategories.jl implements this
model as `SixJCategory`. We use the definitions of semisimple and fusion
categories from Chapters 1, 2, and 4 of [EGNO](@cite). The reconstruction in
terms of multiplicity vectors, matrix blocks, and fusion rules is described in
[maeurer2026thesis](@cite), §1.7. The next page gives the required translation
between its projection-tree F-matrices and the package's structural matrices.

## Objects and morphisms

An object

```math
X=\bigoplus_{i=1}^r S_i^{\oplus m_i}
```

is represented by the vector $(m_1,\ldots,m_r)$ of nonnegative integers. In
the implementation this vector is `X.components`, and `C[i]` denotes the
chosen representative $S_i$. The zero object has all multiplicities zero, and
direct sums add multiplicity vectors.

A `SixJCategory` is mutable, and its objects retain that particular category as
their parent. Two independently constructed categories can carry identical
arrays without being the same parent; transport objects explicitly between
them.

If

```math
Y=\bigoplus_{i=1}^r S_i^{\oplus n_i},
```

then

```math
\operatorname{Hom}_{\mathcal C}(X,Y)
\cong\bigoplus_{i=1}^r\operatorname{Mat}_{m_i\times n_i}(k).
```

A morphism $f:X\to Y$ is therefore stored as one
$m_i\times n_i$ matrix for each simple $S_i$. These matrices act on row
coordinates, so the block representing $g\circ f$ is the block for $f$
multiplied by the block for $g$.

This description uses
$\operatorname{End}_{\mathcal C}(S_i)=k$. In a non-split semisimple category,
the blocks have coefficients in the division algebras
$\operatorname{End}_{\mathcal C}(S_i)$ instead. `SixJCategory` implements the
split case; see [Fusion and splitting](@ref tensor-conventions) for the
non-split setting.

The matrix blocks describe maps between multiplicity spaces. Their existence
does not require a monoidal fiber functor
$\mathcal C\to\operatorname{Vec}_k$; see
[Matrices and fiber functors](@ref matrix-realizations).

## Fusion rules

The fusion multiplicities are the structure constants of the
[Grothendieck ring](@ref grothendieck-rings) in its simple-object basis:

```math
S_i\otimes S_j\cong
\bigoplus_l S_l^{\oplus N_{ij}^{\,l}},
\qquad
N_{ij}^{\,l}
=\dim_k\operatorname{Hom}_{\mathcal C}(S_i\otimes S_j,S_l).
```

The integer array `C.tensor_product[i,j,l]` stores $N_{ij}^{\,l}$. By
bilinearity,

```math
[X\otimes Y:S_l]=\sum_{i,j}m_i n_jN_{ij}^{\,l}.
```

The simple unit has a distinguished index $u$ and satisfies

```math
N_{ui}^{\,j}=N_{iu}^{\,j}=\delta_{ij}.
```

The program stores this index separately through `set_one!`.

For morphisms, tensor products use Kronecker products of matrix blocks, with
one copy for each binary fusion channel. Coordinates in these copies require a
choice of basis in every space
$\operatorname{Hom}_{\mathcal C}(S_i\otimes S_j,S_l)$.

## Associators and additional structure

Associativity of the fusion rules gives

```math
\sum_eN_{ab}^{\,e}N_{ec}^{\,d}
=\sum_fN_{bc}^{\,f}N_{af}^{\,d}.
```

The two bracketings of a triple tensor product therefore have the same
multiplicity vector. Their identification by the associator

```math
\alpha_{a,b,c}:(a\otimes b)\otimes c
\longrightarrow a\otimes(b\otimes c)
```

is nevertheless part of the monoidal data. Its block on the copies of $d$ is
the invertible matrix `C.ass[a,b,c,d]`, using the index convention introduced
above. Its entries are the F-symbols. These matrices must satisfy the pentagon
equation and the chosen unit normalization; skeletality does not make them
identity matrices.

A braiding supplies matrices stored as `C.braiding[a,b,d]`. Their entries are
the R-symbols. They represent the maps $a\otimes b\to b\otimes a$ and satisfy
the two hexagon equations with the associator. A pivotal or spherical structure
is further data and cannot be recovered from F- and R-symbols alone.

The next page fixes the [basis order and matrix conventions](@ref f-conventions)
before any examples are constructed. The
[worked examples](@ref working-with-fusion-data) then build an Ising category,
read individual coefficients, and extract a skeleton from graded vector
spaces.
