# [Tambara–Yamagami and Ising categories](@id tambara-yamagami-data)

Tambara–Yamagami categories are the basic nonpointed extensions of the
pointed category $\operatorname{Vec}_A$ by one simple object $m$. In the split
setting, categories with these fusion rules are classified by a finite
abelian group $A$, a nondegenerate symmetric bicharacter $\chi$, and
$\tau\in k^\times$ satisfying $\tau^2=|A|^{-1}$
[TAMBARA1998692; Theorem 3.2](@citet). The Ising fusion rules occur for
$A=C_2$.

Let $A$ be a finite abelian group and
$\chi:A\times A\to k^\times$ a nondegenerate symmetric bicharacter. The simple
objects are the elements of $A$ and one object $m$,
with
```math
a\otimes b=ab,\quad a\otimes m=m=m\otimes a,\quad
m\otimes m=\bigoplus_{a\in A}a.
```

The explicit normalization below is the one used in
[gelaki2009centers; §4A, pp. 974–975](@citet).

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
The group simples are ordered by `elements(A)`. Their printed names are the
strings `a1`, `a2`, and so on, followed by `m`; these names do not print the
group elements themselves.

These associator blocks agree exactly with the cited formulas after the
translation $\tau=1/s$; no further gauge change is being suppressed. The
constructor installs all-one pivotal components. With the package's chosen
duality this makes the categorical dimension of $m$ equal to the supplied
square root $s$, so its sign is part of the pivotal data. This pivotal
normalization is an additional package choice rather than part of the cited
monoidal formula comparison.

The field must contain the bicharacter values and the chosen nonzero square
root. In particular, its characteristic cannot divide $|A|$. The constructor
does not verify every bicharacter or parameter hypothesis: supplied data must
satisfy them.

The available positional forms distinguish which data are supplied. In
`tambara_yamagami(K,A)`, both the bicharacter and $s$ are chosen in $K$;
`tambara_yamagami(K,A,s)` fixes $s$ and chooses the bicharacter, while
`tambara_yamagami(K,A,chi)` fixes the bicharacter and chooses $s$. The full
form `tambara_yamagami(K,A,s,chi)` uses both supplied choices. The calls
`tambara_yamagami(A)` and `tambara_yamagami(n1,n2,...)` make both automatic
choices over a generated number field; the integer arguments are the abelian
invariants used to construct $A$. The field-first integer form is
`tambara_yamagami(K,n1,n2,...)`. Without a field argument, the generated number
field contains the required roots of unity and square root; the constructor
does not use the algebraic closure itself.

Every automatic choice produces one category, rather than enumerating all
Tambara–Yamagami categories for $A$. These general constructors supply no
braiding. The Ising-specific constructor below separately attempts to add one.

For the trivial group, use the full call `tambara_yamagami(K,A,s,chi)` with an
explicitly supplied $\chi$; the automatic bicharacter overload does not
currently support this case.

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

## [Ising](@id ising-data)

The Ising category is the rank-three Tambara–Yamagami category for $A=C_2$.
In physics its noninvertible simple object is the Ising or Majorana anyon, and
the nontrivial invertible object is the fermion. The package uses labels
$(\mathbb 1,\chi,X)$ for these three objects.

`ising_category()` uses $\mathbb Q(\sqrt2)$ and is unbraided because this field
does not contain a primitive fourth root of unity. `ising_category(K)` chooses
a square root of $2$ in $K$, while `ising_category(K,s)` uses the supplied root
$s^2=2$; both use $q=1$ and attempt to install the corresponding braiding.
The overload `ising_category(K,q)` instead chooses the square root and uses the
specified integer $q$. The labels are $(\mathbb 1,\chi,X)$ in that order. Its
associators are the Tambara–Yamagami formulas above for $A=C_2$ and
$\chi(g,g)=-1$. The all-one stored pivotal components refer to the package's
chosen duality, not to all dimensions being one.

`ising_category(K,s,q)` attempts to supply a braiding. To distinguish the
program argument from the quadratic form in the reference, write
$\varepsilon\in\{1,-1\}$ for the integer passed as `q`. Put
$\xi=\varepsilon\zeta_4$, where `root_of_unity(K,4)` supplies $\zeta_4$, and choose
$\alpha$ with $\alpha^2=(1+\xi)/s$. The implementation
uses
```math
c_{\chi,\chi}=-1,\qquad c_{\chi,X}=c_{X,\chi}=\xi,\qquad
c_{X,X}=\alpha\,\mathrm{id}_{\mathbb 1}\oplus
\alpha\xi^{-1}\,\mathrm{id}_{\chi}.
```
This is the specialization of
[galindo2022trivializing; Theorem 4.9, Eq. (4.14), and Example 4.13](@citet)
with $A=C_2$, $\tau=1/s$, and $Q(\chi)=\xi$; the scalar $\alpha$ is the same in
both formulas.
Thus the two summands of $c_{X,X}$ occur in the package's order
$(\mathbb 1,\chi)$.
If construction of the braiding data fails, for example because the field lacks
the required roots, the constructor returns the underlying monoidal category.
Check `is_braided(C)`; absence of a braiding does not by itself diagnose the
cause. The constructor does not check that the supplied integer is
$\varepsilon=\pm1$, and an attempted installation is not itself a hexagon
check. Supply one of the two stated values and verify `hexagon_axiom(C)`
whenever braiding data are present. The choices of $\xi$ and $\alpha$ are part
of these data.

```@example ty
L, z = cyclotomic_field(16)
I = ising_category(L)
@assert is_braided(I)
@assert pentagon_axiom(I) && hexagon_axiom(I)
@assert dim(I[3])^2 == 2
smatrix(I)
show(stdout, MIME"text/plain"(), smatrix(I)); println() # hide
```
