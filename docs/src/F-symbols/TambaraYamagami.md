# Tambara–Yamagami and Ising categories

Let $A$ be a finite abelian group and
$\chi:A\times A\to k^\times$ a nondegenerate symmetric bicharacter. The simple
objects are the elements of $A$ and one object $m$,
with
```math
a\otimes b=ab,\quad a\otimes m=m=m\otimes a,\quad
m\otimes m=\bigoplus_{a\in A}a.
```

The classification originates with [TAMBARA1998692](@cite). The formulas below
use [gelaki2009centers](@cite), §4A, pp. 974–975.

## The square-root parameter

The constructor `tambara_yamagami(K,A,s,chi)` takes $s^2=|A|$.
In the cited paper the parameter satisfies $\tau^2=|A|^{-1}$.
The translation is $\tau=1/s$. With the package's row-coordinate convention, the
nontrivial blocks are
```math
a_{a,m,b}=\chi(a,b)\mathrm{id}_m,\qquad
a_{m,a,m}|_b=\chi(a,b)\mathrm{id}_b,\qquad
(a_{m,m,m})_{a,b}=\frac{1}{s\chi(a,b)}.
```
The remaining blocks are identity blocks in the chosen skeletal ordering.
Simple labels use `elements(A)` followed by the label $m$.

The field must contain the bicharacter values and the chosen nonzero square
root. In particular, its characteristic cannot divide $|A|$. The constructor
does not verify every bicharacter or parameter hypothesis: supplied data must
satisfy them.

`tambara_yamagami(K,A)` chooses a bicharacter and a square root. This is a choice
of category, not an enumeration of all TY categories for $A$. The default field
is a number field constructed to contain the needed roots, not the algebraic
closure itself.

```@example ty
using TensorCategories, Oscar
K, s = quadratic_field(2)
A = abelian_group(PcGroup,[2])
C = tambara_yamagami(K,A,s)
@assert length(simples(C)) == 3
@assert C[3] ⊗ C[3] == C[1] ⊕ C[2]
@assert C.ass[3,3,3,3] == inv(s)*matrix(K,[1 1; 1 -1])
@assert pentagon_axiom(C)
nothing # hide
```

## Ising

`ising_category()` uses $\mathbb Q(\sqrt2)$. `ising_category(K,s)` uses the supplied root
$s^2=2$, with labels $(\mathbb 1,\chi,X)$ in that order. Its associators are the TY formulas
above for $A=C_2$ and $\chi(g,g)=-1$. The all-one stored pivotal components refer to
the package's chosen duality, not to all dimensions being one.

`ising_category(K,s,q)` attempts to supply a braiding, where $q\in\{1,-1\}$.
Put $\xi=q\zeta_4$, where `root_of_unity(K,4)` supplies $\zeta_4$, and choose
$\alpha$ with $\alpha^2=(1+\xi)/s$. The implementation
uses
```math
c_{\chi,\chi}=-1,\qquad c_{\chi,X}=c_{X,\chi}=\xi,\qquad
c_{X,X}=\alpha\,\mathrm{id}_{1}\oplus\alpha\xi^{-1}\,\mathrm{id}_{\chi}.
```
If the field does not supply the needed roots, the constructor returns the
monoidal category without a braiding; `is_braided(C)` reports whether braiding
data are present. The choices of $\xi$ and $\alpha$ are part of these data.

```@example ty
L, z = cyclotomic_field(16)
I = ising_category(L)
@assert is_braided(I)
@assert pentagon_axiom(I) && hexagon_axiom(I)
@assert dim(I[3])^2 == 2
smatrix(I)
show(stdout, MIME"text/plain"(), smatrix(I)); println() # hide
```

[rowell2009classification](@citet), §5.3, provides reference modular data with
its stated label, root, and normalization choices.
