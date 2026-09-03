# [Fibonacci categories](@id fibonacci-data)

The Fibonacci category is the simplest nonpointed rank-two fusion category.
Tensor powers of its nontrivial simple object have Fibonacci multiplicities,
and its positive unitary realization is a standard anyon model for topological
quantum computation. Its other algebraic realization is the nonunitary
Yang–Lee Galois conjugate [rowell2009classification; p. 4 and §5.3.2](@citet).

The constructor `fibonacci_category(K)` uses labels $(\mathbb 1,\tau)$ and the
rule $\tau\otimes\tau=\mathbb 1\oplus\tau$. An optional second positional
argument selects the $a$-th root $r$ of $x^2-x-1$ returned by OSCAR:
`fibonacci_category(K,a)`. The default is $a=1$, and the constructor sets
$b=-r$. The field $K$ must contain the selected root. A complex realization
also requires a field embedding.

The only nonidentity associator block is
```math
A_{\tau,\tau,\tau}^{\tau}=
\begin{pmatrix}b&b\\1&-b\end{pmatrix},\qquad b^2+b=1.
```
This is the actual stored row-coordinate matrix, not the commonly displayed
symmetric gauge. The overload `fibonacci_category(a)` uses the same root
selector over $\mathbb Q(\sqrt5)$, with `fibonacci_category()` again taking
$a=1$.
The constructor retains the skeletal model's all-one pivotal components; for
both algebraic roots these pass the package's exact pivotal check.

```@example fibonacci
using TensorCategories, Oscar
C = fibonacci_category()
A = C.ass[2,2,2,2]
b = A[1,1]
@assert b^2 + b == 1
@assert A == matrix(base_ring(C),[b b; 1 -b])
@assert A^2 == identity_matrix(base_ring(C),2)
@assert pentagon_axiom(C)
@assert !is_braided(C)
A
show(stdout, MIME"text/plain"(), A); println() # hide
```

The two algebraic roots give the two familiar rank-two categorifications after
choosing an embedding. To identify the positive Fibonacci realization versus
its nonunitary Galois conjugate, inspect the root and pivotal dimensions under
that embedding.

For the positive root $b$, put $D=\operatorname{diag}(1,1/\sqrt b)$. Then
```math
D^{-1}A_{\tau,\tau,\tau}^{\tau}D
=\begin{pmatrix}b&\sqrt b\\ \sqrt b&-b\end{pmatrix}.
```
The resulting symmetric matrix is precisely the positive unitary Fibonacci
gauge displayed in [rowell2009classification; §5.3.2](@citet), after
$b=\varphi^{-1}$. Thus the implementation agrees with the underlying fusion
category in that reference by an explicit change of fusion basis.

The constructor supplies no braiding. In particular, it does not implement the
$R$-symbols of the complete modular category displayed in that reference.
