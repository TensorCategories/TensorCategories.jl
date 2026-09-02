# [Grothendieck rings](@id grothendieck-rings)

The Grothendieck ring is the decategorified form of a tensor category: direct
sums become addition, tensor products become multiplication, and objects are
replaced by their classes. For a fusion category, its multiplication table is
exactly the table of fusion rules.

## Classes of objects

For an abelian category of finite-length objects, the Grothendieck group
$\operatorname{Gr}(\mathcal C)$ has a generator $[X]$ for each isomorphism
class, with relations
```math
[Y]=[X]+[Z]
\quad\text{for every exact sequence }0\longrightarrow X\longrightarrow Y
\longrightarrow Z\longrightarrow0.
```
Its basis consists of the classes of simple objects, and
$[X]=\sum_i[X:S_i][S_i]$, where $[X:S_i]$ is a composition multiplicity.
This is [EGNO](@citet), Definition 1.5.8, p. 5.

When tensor product is exact in both variables, it induces multiplication
$[X][Y]=[X\otimes Y]$, with identity $[\mathbb 1]$. Associativity follows from the
associator, since isomorphic objects have equal classes [EGNO](@cite), §4.5,
pp. 71–72.

The **split Grothendieck ring** instead imposes only the direct-sum relations
$[X\oplus Y]=[X]+[Y]$. In a Krull–Schmidt category its basis consists of classes
of indecomposable objects. For semisimple categories the two constructions
agree, and the coefficients of $[X]$ are its simple-summand multiplicities.

The function `split_grothendieck_ring(C)` implements the direct-sum
construction in models with finite indecomposable enumeration and tensor-product
decomposition. Here “split” refers to the relations, not to a splitting field:
the function also applies to supported non-split semisimple categories.
For nonsemisimple input it does not impose relations from nonsplit exact
sequences.

## Positive bases and fusion rings

Write $b_i=[S_i]$. In the semisimple case the fusion rules are
```math
b_i b_j=\sum_l N_{ij}^{\,l}b_l,\qquad
N_{ij}^{\,l}=[S_i\otimes S_j:S_l]\in\mathbb Z_{\geq0}.
```
Thus $\operatorname{Gr}(\mathcal C)$ is a ring over $\mathbb Z$ with a
distinguished basis whose structure constants are nonnegative integers.
[EGNO](@citet), Definition 3.1.1, p. 49, calls this a **$\mathbb Z_+$-ring**.
The identity must also have nonnegative coordinates. Such a ring is *unital*
when its identity is a basis element. Every $\mathbb Z_+$-ring already has an
identity.

The positive cone $\sum_i\mathbb Z_{\geq0}b_i$ records actual objects of a
semisimple category.
The ring also contains virtual classes with negative coefficients. Its
coefficient ring is $\mathbb Z$ even when the category is defined over a field of
positive characteristic.

For a split semisimple rigid category, duality induces a basis permutation
$b_i^*=[S_i^*]$ and an anti-involution $(xy)^*=y^*x^*$. Let $I_0$ be the
indices occurring in the unit and set
$\tau(\sum_i a_ib_i)=\sum_{i\in I_0}a_i$. Then
```math
\tau(b_i b_j)=\delta_{i,j^*}.
```
These are the **based-ring** conditions. A based ring of finite rank is a
**multifusion ring**; it is a **fusion ring** when the unit is a basis element
[EGNO](@cite), Definitions 3.1.3 and 3.1.7, pp. 49–50. In particular, the
Grothendieck ring of a fusion category is a fusion ring [EGNO](@cite),
Proposition 4.9.1, pp. 76–77.

With simple unit $b_u=1$, the last equation reads
$N_{ij}^{\,u}=\delta_{i,j^*}$.
A braiding makes the ring commutative, but commutativity alone does not specify
a braiding.

## Fusion matrices and Frobenius–Perron dimensions

For fixed $i$, the slice `N[i,:,:]` has entries
```math
(M_i)_{j,l}=N_{ij}^{\,l}.
```
It is the matrix of left multiplication by $b_i$ in row coordinates:
if $x$ has coefficient row $v$, then $b_ix$ has coefficient row $vM_i$.

For a fusion ring, the **Frobenius–Perron dimension** of $b_i$ is the
spectral radius of $M_i$. Extending additively gives the unique ring
homomorphism to $\mathbb R$ taking strictly positive values on the distinguished
basis [EGNO](@cite), Definition 3.3.3 and Proposition 3.3.6, pp. 53–54.
Consequently,
```math
\operatorname{FPdim}(X\otimes Y)
=\operatorname{FPdim}(X)\operatorname{FPdim}(Y).
```
These dimensions depend only on the fusion rules. They need not lie in the
category's base field and do not require a pivotal structure. In contrast,
`dim(X)` uses the chosen duality and pivotal data.

The package computes `fpdim(r)` from the integer multiplication matrices
and returns an exact algebraic number. For a fusion ring $R$,
```math
\operatorname{FPdim}(R)=\sum_i\operatorname{FPdim}(b_i)^2,
```
which is also `fpdim(C)` for a split fusion category with Grothendieck ring $R$.

## Non-split categories

If $D_l=\operatorname{End}(S_l)$ is larger than the base field $k$, the
multiplicity is
```math
N_{ij}^{\,l}
=\frac{\dim_k\operatorname{Hom}(S_l,S_i\otimes S_j)}
       {\dim_k D_l}.
```
This is the division used by `multiplication_table(C)` and
`coefficients(X,simples(C))` in the generic semisimple implementation.

For a weak fusion category with $\operatorname{End}(\mathbb 1)=k$, rigidity gives
```math
N_{ij}^{\,u}=\dim_k D_i\,\delta_{i,j^*}.
```
Thus the coefficient of the unit in $[S_i][S_i^*]$ can exceed one.
The resulting ring is a **weak fusion ring** in the sense of [EGNO](@cite),
§3.8, p. 63; see also [maurer2024computing](@cite), §2.1.

For such a category the total Frobenius–Perron dimension is
```math
\operatorname{FPdim}(C)
=\sum_i\frac{\operatorname{FPdim}(S_i)^2}{\dim_k D_i},
```
as in [maurer2024computing](@cite), §5.3, equation (5.3). The category method `fpdim(C)`
includes these endomorphism-algebra factors. The ring method `fpdim(R)`
always sums the squares without these factors, so it does not give `fpdim(C)`
in the non-split case.

## From fusion rules to categories

Decategorification retains the tensor-product multiplicities but not the
associator maps. In a skeletal model, the ring determines the multiplicity
vector of a tensor product; F-symbols specify the associator in fusion-space
bases and must satisfy the pentagon equation. Braiding and pivotal structures
are further data. This is the passage from fusion rings to their
categorifications discussed in [EGNO](@cite), §§4.9–4.10.

For example, $\operatorname{Gr}(\operatorname{Vec}_k(G))=\mathbb Z[G]$, with
one basis element for each group element.
A 3-cocycle twist changes the associator but leaves this ring unchanged.
For $\operatorname{Rep}_k(G)$, decategorification gives the representation ring, computed
from tensor products of representations. Neither concrete model requires
F-symbols to compute its Grothendieck ring.

An exact tensor functor induces a ring homomorphism $[X]\mapsto[F(X)]$.
In particular, a fiber functor to vector spaces induces the integer dimension
homomorphism $[X]\mapsto\dim_k F(X)$. The categorical meaning of a fiber functor
is discussed under [Matrices and fiber functors](@ref matrix-realizations).

## Computing with the Ising ring

The Ising category has simples $(\mathbb 1,\chi,X)$, with
$\chi^2=\mathbb 1$, $\chi X=X$, and $X^2=\mathbb 1+\chi$. We can perform these
calculations directly in its Grothendieck ring:

```@example grothising
using TensorCategories, Oscar
C = ising_category()
S = simples(C)
R = split_grothendieck_ring(C)
u, chi, x = basis(R)
@assert u == one(R)
@assert chi*chi == u && chi*x == x
@assert x*x == u+chi
@assert involution(x) == x
x*x
show(stdout, MIME"text/plain"(), x*x); println() # hide
```

The basis of `R` follows the simple-object order of `C`. To obtain the class
of an object, pass its integer multiplicities to `R`:

```@example grothising
Y = S[3] ⊗ (S[1] ⊕ S[3])
y = R(ZZ.(coefficients(Y,S)))
@assert y == u+chi+x
coefficients(y)
```

Here `ZZ.(...)` converts each multiplicity to an OSCAR integer. A virtual
class such as `x-u` is also an element of `R`:

```@example grothising
@assert base_ring(R) == ZZ
@assert coefficients(x-u) == ZZ.([-1,0,1])
@assert fpdim(x)^2 == 2 && fpdim(x) > 0
@assert fpdim(R) == 4
fpdim.(basis(R))
```

The dimensions are $1,1,\sqrt2$, and their squared sum is $4$.
The main ring operations are:

| Operation | Result |
|:---|:---|
| `basis(R)`, `R[i]` | Distinguished basis elements |
| `rank(R)` | Number of basis elements |
| `one(R)`, `zero(R)` | Ring identity and zero |
| `R(ZZ.([a₁,…,aᵣ]))` | Element with the specified integer coefficients |
| `coefficients(r)` | Coefficient vector of a ring element |
| `multiplication_table(R)` | Integer array `N[i,j,l]` |
| `involution(r)` | Dual class, when the involution is stored |
| `fpdim(r)` | Additive Frobenius–Perron dimension |

For semisimple rigid input, `split_grothendieck_ring` stores the involution
obtained from the duality permutation.

## Entering a ring without a category

`ZPlusRing` constructs a ring directly from its basis names, multiplication
table, and unit coefficient vector. Its aliases are `ℤ₊Ring` and `ℕRing`.
For the Fibonacci rule $t^2=1+t$:

```@example grothfibonacci
using TensorCategories, Oscar
N = zeros(Int,2,2,2)
N[1,1,1] = N[1,2,2] = N[2,1,2] = 1
N[2,2,1] = N[2,2,2] = 1
R = ZPlusRing(["1","t"], N, [1,0])
t = R[2]
@assert t*t == one(R)+t
d = fpdim(t)
@assert d > 0 && d^2 == 1+d
d
show(stdout, MIME"text/plain"(), d); println() # hide
```

Thus $\operatorname{FPdim}(t)=(1+\sqrt5)/2$. No associator or coefficient field for a
categorification was needed. A category with this ring additionally requires
the structural data described in [Skeletal fusion categories](@ref skeletal-fusion).

## A non-split representation ring

Over $\mathbb F_2$, the group $C_3$ has two irreducible representations: the trivial
representation and a two-dimensional representation $V$ with endomorphism
field $\mathbb F_4$. The category is semisimple, and
```math
[V]^2=2[1]+[V].
```
Indeed, over $\mathbb F_4$ the representation $V$ splits as
$\chi\oplus\chi^{-1}$, so its square is
$2\cdot\mathbb 1\oplus\chi\oplus\chi^{-1}$.

```@example grothnonsplit
using TensorCategories, Oscar
G = cyclic_group(3)
C = representation_category(GF(2),G)
S = simples(C)
R = split_grothendieck_ring(C)
i = only(findall(Y -> int_dim(Y) == 2,S))
V, v = S[i], R[i]
@assert int_dim(End(V)) == 2
@assert v*v == 2*one(R)+v
@assert fpdim(v) == 2
@assert fpdim(C) == 3
@assert fpdim(R) == 5
v*v
show(stdout, MIME"text/plain"(), v*v); println() # hide
```

The coefficient $2$ is an integer multiplicity; it does not vanish in the
Grothendieck ring. The category's Frobenius–Perron dimension is
$1^2+2^2/2=3$, whereas the ring method's unweighted sum is $1^2+2^2=5$.

Over the splitting field, there are three one-dimensional simples:

```@example grothnonsplit
Cs = representation_category(GF(2,2),G)
Rs = split_grothendieck_ring(Cs)
@assert rank(Rs) == 3
@assert all(b -> fpdim(b) == 1,basis(Rs))
@assert fpdim(Rs) == 3
rank(Rs)
```

The field extension changes the simple basis and hence the Grothendieck ring;
its multiplication coefficients are integers over both fields.

Continue with [Functors and natural transformations](AdvancedInterface.md).
