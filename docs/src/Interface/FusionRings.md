# [Computing with fusion rings](@id computing-fusion-rings)

This page applies the preceding [Grothendieck-ring conventions](@ref grothendieck-rings).
It first constructs the ring of a category, then enters fusion rules without a
categorification, and finally compares a non-split category with its splitting
field.

## The Ising ring

The Ising category has simples $(\mathbb 1,\chi,X)$, with
$\chi^2=\mathbb 1$, $\chi X=X$, and $X^2=\mathbb 1+\chi$.

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

The Frobenius--Perron dimensions are $1,1,\sqrt2$, and their squared sum is
$4$. The main ring operations are:

| Operation | Result |
|:---|:---|
| `basis(R)`, `R[i]` | Distinguished basis elements |
| `rank(R)` | Number of basis elements |
| `one(R)`, `zero(R)` | Ring identity and zero |
| `R(ZZ.(coeffs))` | Element with coefficient vector $(a_1,\ldots,a_r)$ supplied as `coeffs` |
| `coefficients(r)` | Coefficient vector of a ring element |
| `multiplication_table(R)` | Integer array `N[i,j,l]` |
| `involution(r)` | Dual class, when the involution is stored |
| `fpdim(r)` | Additive Frobenius--Perron dimension |

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

Thus $\operatorname{FPdim}(t)=(1+\sqrt5)/2$. No associator or coefficient
field for a categorification was needed. A category with this ring additionally
requires the structural data described under
[Skeletal fusion categories](@ref skeletal-fusion).
The constructor converts the supplied table and unit coordinates to integers;
it does not itself certify nonnegativity, associativity, the unit equations, or
the based-ring identities. These are assumptions on directly entered data.

## A non-split representation ring

Over $\mathbb F_2$, the group $C_3$ has two irreducible representations: the
trivial representation and a two-dimensional representation $V$ with
endomorphism field $\mathbb F_4$. The category is semisimple, and

```math
[V]^2=2[\mathbb 1]+[V].
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
Grothendieck ring. The category's Frobenius--Perron dimension is
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
