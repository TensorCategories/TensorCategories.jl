# Fibonacci fusion rules

The constructor `fibonacci_category(K,a=1)` uses labels $(\mathbb 1,\tau)$ and the rule
$\tau\otimes\tau=\mathbb 1\oplus\tau$. It selects the $a$-th root $r$ of
$x^2-x-1$ returned by OSCAR
and sets $b=-r$. A complex realization also requires a field embedding.

The only nonidentity associator block is
```math
A_{\tau,\tau,\tau}^{\tau}=
\begin{pmatrix}b&b\\1&-b\end{pmatrix},\qquad b^2+b=1.
```
This is the actual stored row-coordinate matrix, not the commonly displayed
symmetric gauge. The no-field constructor makes $\mathbb Q(\sqrt5)$.

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

For the positive root $b$, conjugation by
$\operatorname{diag}(1,1/\sqrt b)$ changes this block to the symmetric form
with diagonal entries $b,-b$ and off-diagonal entries $\sqrt b$.
See the Fibonacci and Yang–Lee entries of [rowell2009classification](@cite),
§5.3.

The constructor supplies no braiding.
