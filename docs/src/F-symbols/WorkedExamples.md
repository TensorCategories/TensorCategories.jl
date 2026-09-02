# [Working with fusion data](@id working-with-fusion-data)

We now construct a category from its fusion rules and associators, read F- and
R-symbols as coefficients of morphisms, and extract them from a concrete model.
All matrices use the [conventions of the preceding page](@ref f-conventions).

## Building Ising explicitly

The Ising fusion rules, with simples $(\mathbf 1,\chi,X)$ in this order, are
```math
\chi^2=1,\qquad \chi X=X\chi=X,\qquad X^2=1+\chi.
```
Over $K=\mathbb Q(\sqrt 2)$, choose $s\in K$ with $s^2=2$. The nonidentity
associator blocks are
$A^{\chi X\chi}_X=[-1]$, $A^{X\chi X}_{\chi}=[-1]$, and
```math
A[X,X,X,X]=\frac1s
\begin{pmatrix}1&1\\1&-1\end{pmatrix}.
```
The rows and columns of the last block correspond to the intermediate simples
$\mathbf 1,\chi$. These data give the constructor `ising_category(K,s)`; see
[Tambara–Yamagami and Ising](TambaraYamagami.md) for the general formulas.

To enter the data, initialize the fusion array, specify the unit at index 1,
and replace the three nonidentity associator blocks:

```@example buildising
using TensorCategories, Oscar
K, s = quadratic_field(2)
N = zeros(Int,3,3,3)
N[1,1,1] = N[1,2,2] = N[2,1,2] = 1
N[1,3,3] = N[3,1,3] = N[2,3,3] = N[3,2,3] = 1
N[2,2,1] = N[3,3,1] = N[3,3,2] = 1
C = six_j_category(K, N, ["1", "chi", "X"])
set_one!(C, 1; check=true)
set_associator!(C,2,3,2,3, matrix(K,1,1,[-1]))
set_associator!(C,3,2,3,2, matrix(K,1,1,[-1]))
set_associator!(C,3,3,3,3, inv(s)*matrix(K,[1 1; 1 -1]))
@assert pentagon_axiom(C)
D = ising_category(K,s)
@assert C.ass == D.ass
C[3] ⊗ C[3]
```

The constructor initializes identity associator blocks and all-one pivotal
components. For general fusion rules the identity blocks need not satisfy the
pentagon; here `pentagon_axiom(C)` checks the completed associator.
Calling `set_tensor_product!` again resets the associator blocks to identities.

Either root of $s^2=2$ gives monoidal data over $K$. No braiding has been
specified in this construction.

## Reading an associator matrix

Let $t$ be the nonunit simple of the [Fibonacci category](Fibonacci.md).
Since $t\otimes t\cong\mathbf 1\oplus t$, each triple-product projection
space with target $t$ has two basis vectors, ordered by the intermediate
simples $\mathbf 1,t$. We construct these projections explicitly and apply
the defining equation

```math
R_v\circ\alpha_{t,t,t}=\sum_u A_{u,v}L_u.
```

```@example fconventions
using TensorCategories, Oscar
C = fibonacci_category()
t = C[2]
S = simples(C)
L = [q ∘ (p ⊗ id(t)) for e in S
     for p in basis(Hom(t⊗t,e)) for q in basis(Hom(e⊗t,t))]
R = [q ∘ (id(t) ⊗ p) for f in S
     for p in basis(Hom(t⊗t,f)) for q in basis(Hom(t⊗f,t))]
A = C.ass[2,2,2,2]
@assert A != transpose(A)
for v in eachindex(R)
    @assert R[v] ∘ associator(t,t,t) ==
            sum(A[u,v]*L[u] for u in eachindex(L))
end
A
show(stdout, MIME"text/plain"(), A); println() # hide
```

## Fusion multiplicities and braiding

The rank-four [SU(3)₃ subcategory](@ref su3-subcategory) has simples
$(\mathbf 1,8,10,\overline{10})$. The rule
$8\otimes8\cong\mathbf 1\oplus2\cdot8\oplus10\oplus\overline{10}$ gives two
basis vectors in $\operatorname{Hom}(8\otimes8,8)$. For the triple product
with target $8$, the intermediate simple $8$ contributes four paths, one for
each pair of binary basis indices. Together with the paths through
$\mathbf 1,10,\overline{10}$, this gives a seven-dimensional block.

In the code below, `x = C[2]` represents the simple $8$. We form the projection
bases and read both the associator and the braiding in these coordinates:

```@example fmultiplicity
using TensorCategories, Oscar
C = TensorCategories.su_3_3_subcategory()
x = C[2]
S = simples(C)
@assert int_dim(Hom(x⊗x,x)) == 2
L = [q ∘ (p ⊗ id(x)) for e in S
     for p in basis(Hom(x⊗x,e)) for q in basis(Hom(e⊗x,x))]
R = [q ∘ (id(x) ⊗ p) for f in S
     for p in basis(Hom(x⊗x,f)) for q in basis(Hom(x⊗f,x))]
A = C.ass[2,2,2,2]
@assert size(A) == (7,7)
@assert A[3,6] == 1//2 && A[6,3] == -1//2
for v in eachindex(R)
    @assert R[v] ∘ associator(x,x,x) ==
            sum(A[u,v]*L[u] for u in eachindex(L))
end
P = basis(Hom(x⊗x,x))
B = C.braiding[2,2,2]
for j in eachindex(P)
    @assert P[j] ∘ braiding(x,x) ==
            sum(B[i,j]*P[i] for i in eachindex(P))
end
@assert TensorCategories.dict_to_associator(F_symbols(C)) == C.ass
nothing # hide
```

Here the left channel order is
$(\mathbf 1),(8,1,1),(8,1,2),(8,2,1),(8,2,2),(10),(\overline{10})$, where the
two indices attached to $8$ specify the inner and outer projection bases,
respectively.

## Extracting from an existing model

The category of $C_2$-graded vector spaces is already available as a concrete
model. Its skeletal realization is obtained by choosing its two simple graded
lines and computing the associator in decomposition bases:

```@example skeleton
using TensorCategories, Oscar
G = cyclic_group(2)
V = graded_vector_spaces(QQ,G)
S = six_j_category(V)
@assert length(simples(S)) == 2
@assert pentagon_axiom(S)
multiplication_table(S)
```

The same conversion, also available as `skeletonize(V)`, applies to a split
fusion category whose implementation supports decomposition and the necessary
Hom-space operations. The resulting symbols use the Hom bases chosen by the
input model. The concrete model remains available for computations on graded
vectors and matrices.
