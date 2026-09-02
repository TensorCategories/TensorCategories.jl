# Equivariant sheaves and convolution

These are concrete models using stabilizer representations, not F-symbol
tables. For a finite $G$-set $X$, a $G$-equivariant sheaf is stored by one
representation of $G_x$ for each chosen orbit representative $x$.
The constructor is `coherent_sheaves(K,X)`, with the **field first**.

Morphisms are lists of intertwiners. The ordinary tensor product is pointwise
on stalks. This gives
$\operatorname{Coh}_G(X)\simeq\prod_x\operatorname{Rep}_K(G_x)$ as tensor categories.
The tensor unit has one simple summand for each orbit (in the usual split
semisimple setting); it need not be simple.

```@example sheaves
using TensorCategories, Oscar
G = symmetric_group(3)
X = gset(G,[1,2,3])
K = GF(7)
C = coherent_sheaves(K,X)
S = simples(C)
@assert length(S) == 2  # stabilizer of a point is C₂
@assert all(Y -> int_dim(End(only(stalks(Y)))) == 1, S)
length(S)
```

We use a finite splitting field here because simple enumeration in the
representation backend is currently supported over finite fields. Construction
of specified representations and Hom computations have broader field support.

Over characteristic zero, semisimplicity follows from the stabilizers.
In positive characteristic the exact condition is semisimplicity of their
representation categories. Requiring the characteristic not to divide $|G|$
is sufficient but need not be necessary for a particular action.
Some property predicates use the sufficient condition on $|G|$;
they do not determine whether all stabilizer representations split over $K$.

## Convolution

`convolution_category(K,X)` for a `GSet` models sheaves on $X\times X$ with product
```math
(A\star B)_{x,z}=\bigoplus_{y\in X} A_{x,y}\otimes B_{y,z}.
```
Equivalently, it is
$p_{13*}(p_{12}^*A\otimes p_{23}^*B)$, where the first operation
is pushforward and the other two are pullbacks.
The implementation builds exactly these functors. The unit is supported on
the diagonal. It is simple for a transitive action in the split setting;
otherwise this is a multifusion model.

```@example sheaves
D = convolution_category(K,X)
T = simples(D)
@assert length(T) == 3  # diagonal: Rep(C₂); off-diagonal: Rep(1)
length(T)
```

The pointwise symmetric braiding does not give a braiding for convolution.
For details of this model see [Liam](@cite), and for the general tensor-category
framework use [EGNO](@cite).
