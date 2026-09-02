# sl₂, Verlinde, and dihedral models

## Generic sl₂ representation rules

`sl2_representations(K,q)` models the generic semisimple highest-weight
representation category, with labels $V_0,V_1,\ldots$ and
```math
V_i\otimes V_j=\bigoplus_{r=0}^{\min(i,j)}V_{i+j-2r}.
```
Use characteristic zero and $q=1$ or generic $q$ (not a root of unity).
This is not a construction of the full representation category at roots of
unity or in positive characteristic. The constructor does not validate all
these restrictions.

Here `C[i]` denotes $V_i$ with its mathematical, zero-based label;
this is an exception to the simple-list indexing of finite skeletal categories.

```@example sl2
using TensorCategories, Oscar
C = sl2_representations(QQ,QQ(1))
@assert C[1]⊗C[1] == C[0]⊕C[2]
decompose(C[1]⊗C[1])
```

There are infinitely many simples. Use `simples(C,n)` for the first $n$;
do not pass this category to a finite-fusion enumeration algorithm.

## Verlinde categories

`verlinde_category(m)` has rank $m+1$, with labels $X_0,\ldots,X_m$.
The default field is $\mathbb Q(\zeta_{4m+8})$ and the implementation first
chooses a $(2m+4)$th root $z$. Julia `C[1]` is $X_0$ here.
The fusion rule is
```math
X_a\otimes X_b=
\bigoplus_{\substack{c=|a-b|\\c\equiv a+b\;(\mathrm{mod}\,2)}}^{
\min(a+b,\,2m-a-b)} X_c.
```

The full signature is `verlinde_category(K,m,l=1,t=1)`.
The associator uses the Temperley–Lieb recoupling function
`tl_six_j_symbol(q,b,a,d,c,f,e)`, with quantum integers generated from
$z^l+z^{-l}$ and ascending admissible channels $e,f$.
The braiding is supplied when the field contains a square root $w$ of $z$:
```math
R^{ab}_c=(-1)^{(a+b-c)/2}(w^t)^{(a(a+2)+b(b+2)-c(c+2))/2}.
```
The sign and exponent follow the source function `lambda`.
Not every choice of $l,t$ gives compatible associators and braiding.
The constructor does not check the pentagon or hexagon identities.

```@example verlinde
using TensorCategories, Oscar
C = verlinde_category(2)
@assert length(simples(C)) == 3
@assert is_isomorphic(C[2]⊗C[2], C[1]⊕C[3])[1]
@assert pentagon_axiom(C)
@assert hexagon_axiom(C)
dim.(simples(C))
```

Associators and braiding blocks are generated lazily. Use `associator`,
`braiding`, or `six_j_symbols` rather than reading uninitialized entries
of `C.ass` immediately after construction.

## Dihedral cell categories

`I2(m)` has $2(m-1)$ simple labels, corresponding to alternating words beginning
with $s$ or $t$. Its unit has two summands.
`I2subcategory(m)` retains $\lfloor m/2\rfloor$ labels
$B_s,B_{sts},\ldots$, with simple unit $B_s$.
The default coefficient field is $\mathbb Q(\zeta_{2m})$.

Both use the same Temperley–Lieb recoupling routine. Their labels describe
dihedral cell-category models. Evaluation and coevaluation in the full `I2`
model are incomplete; it does not currently supply a complete rigid structure.
