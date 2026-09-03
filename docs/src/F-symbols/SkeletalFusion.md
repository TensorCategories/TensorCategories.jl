# [Skeletal fusion categories](@id skeletal-fusion)

Let $\mathcal C$ be a split fusion category over a field $k$, and choose
representatives $S_1,\ldots,S_r$ of its simple objects. Decompositions into
these simples give a skeletal linear model: objects become multiplicity
vectors, morphisms become blocks of matrices over $k$, and the tensor structure
is described by fusion rules and $F$-symbols. TensorCategories.jl implements this
model as `SixJCategory`. We use the definitions of semisimple and fusion
categories in [EGNO; Chapters 1, 2, and 4](@citet). The reconstruction in
terms of multiplicity vectors, matrix blocks, and fusion rules is described in
[maeurer2026thesis; §1.7](@citet).

The type name `SixJCategory` is historical. The model allows arbitrary fusion
multiplicities, and its associator entries need not be literal Wigner
$6j$-symbols.

## Objects and morphisms

An object

```math
\label{eq:skeletal-object-decomposition}
X=\bigoplus_{i=1}^r S_i^{\oplus m_i}
```

is represented by the vector $(m_1,\ldots,m_r)$ of nonnegative integers. In
the implementation this vector is `X.components`, and `C[i]` denotes the
chosen representative $S_i$. The zero object has all multiplicities zero, and
direct sums add multiplicity vectors.

To keep formulas and code legible, the manual also uses a simple label such as
$a$ for its position in `simples(C)` when it occurs inside an array access.
Thus `C.ass[a,b,c,d]` means the block indexed by the positions of the four
simples $a,b,c,d$; Julia code must of course supply the corresponding integers.

A `SixJCategory` is mutable, and its objects retain that particular category as
their parent. Two independently constructed categories can carry identical
arrays without being the same parent; transport objects explicitly between
them.

If

```math
\label{eq:skeletal-target-decomposition}
Y=\bigoplus_{i=1}^r S_i^{\oplus n_i},
```

then

```math
\label{eq:skeletal-homspace}
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
[Fiber functors and semisimple coordinates](@ref fiber-functors).

## Fusion rules

The fusion multiplicities are the structure constants of the
[Grothendieck ring](@ref grothendieck-rings) in its simple-object basis:

```math
\label{eq:skeletal-fusion-rule}
S_i\otimes S_j\cong
\bigoplus_l S_l^{\oplus N_{ij}^{\,l}},
\qquad
N_{ij}^{\,l}
=\dim_k\operatorname{Hom}_{\mathcal C}(S_i\otimes S_j,S_l).
```

The integer array `C.tensor_product[i,j,l]` stores $N_{ij}^{\,l}$. By
bilinearity,

```math
\label{eq:skeletal-tensor-multiplicity}
[X\otimes Y:S_l]=\sum_{i,j}m_i n_jN_{ij}^{\,l}.
```

The simple unit has a distinguished index $u$ and satisfies

```math
\label{eq:skeletal-unit-fusion}
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
\label{eq:skeletal-associativity-dimensions}
\sum_eN_{ab}^{\,e}N_{ec}^{\,d}
=\sum_fN_{bc}^{\,f}N_{af}^{\,d}.
```

The two bracketings of a triple tensor product therefore have the same
multiplicity vector. Their identification by the associator

```math
\label{eq:skeletal-associator-map}
\alpha_{a,b,c}:(a\otimes b)\otimes c
\longrightarrow a\otimes(b\otimes c)
```

is nevertheless part of the monoidal data. Its block on the copies of $d$ is
the invertible matrix `C.ass[a,b,c,d]`, using the index convention introduced
above. Its entries are the $F$-symbols. These matrices must satisfy the pentagon
equation and the chosen [unit normalization](@ref unit-normalization);
skeletality does not make them identity matrices.

A braiding supplies matrices stored as `C.braiding[a,b,d]`. Their entries are
the $R$-symbols. They represent the maps $a\otimes b\to b\otimes a$ and satisfy
the two hexagon equations with the associator. A pivotal or spherical structure
is further data and cannot be recovered from $F$- and $R$-symbols alone.

Conversely, arrays of plausible dimensions do not yet define a fusion
category. The fusion multiplicities must give an associative unital fusion
ring with duals. Every associator block must be an invertible matrix of the
prescribed size, the unit blocks must have the normalization fixed on the next
page, and all pentagon equations must hold. Braiding requires invertible blocks
of the prescribed sizes satisfying both hexagon equations. Pivotal and
spherical structures require their own coherence conditions.

The call `six_j_category(K,N,names)` creates a mutable container with fusion
array $N$, identity associator blocks of the required sizes, and all-one
pivotal components. The names argument may be omitted, in which case the
labels are `X1`, `X2`, and so on. The shorter call
`six_j_category(K,names)` sets only the coefficient ring, rank, labels, and
all-one pivotal components; a subsequent
`set_tensor_product!` call installs the fusion array and initializes the
identity associator blocks. Neither form sets the tensor unit or certifies any
coherence axiom. After entering data, use `pentagon_axiom(C)`,
`hexagon_axiom(C)`, and the relevant checked structural predicates.

These initializer methods accept a Julia `Ring`, but the split fusion-category
interpretation on this page and algorithms that use dimensions of Hom spaces
require $K$ to be a field. The initializer does not check that $N$ is a
nonnegative, associative, unital fusion table or that the number of supplied
names matches its rank.

The next page fixes the [basis order and matrix conventions](@ref f-conventions)
before any examples are constructed. The
[worked examples](@ref working-with-fusion-data) then build an Ising category,
read individual coefficients, and extract a skeleton from graded vector
spaces.
