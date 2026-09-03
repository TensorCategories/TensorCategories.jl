# $\mathfrak{sl}_2$, Verlinde, and dihedral models

## [Generic $\mathfrak{sl}_2$ representation rules](@id generic-sl2-models)

The generic semisimple representation theory of
$U_q(\mathfrak{sl}_2)$ is the infinite precursor of the finite
$\mathrm{SU}(2)$ Verlinde categories below. This constructor realizes its
Clebsch–Gordan rules in the Kauffman–Lins trivalent recoupling basis; it does
not store matrices for a quantum-group action.

`sl2_representations(K,q)` constructs a skeletal model of the fusion rules and
recoupling coefficients. It has infinitely many simple labels and is therefore
not a fusion category. Under the usual generic semisimplicity assumptions its
simple labels are $V_0,V_1,\ldots$, with
```math
V_i\otimes V_j=\bigoplus_{r=0}^{\min(i,j)}V_{i+j-2r}.
```
This is the quantum Clebsch–Gordan rule of
[huang2017embedding; Proposition 5.7](@citet); see also
[kassel1995quantum; Chapter VII, §7, pp. 157–162](@citet).
For this categorical interpretation, take $K$ to be a field of characteristic
zero and $q\in K^\times$ to be either $1$ or generic, rather than a root of
unity. All quantum integers and theta-net denominators used by a requested
recoupling block must be nonzero. This is not a construction of the full
representation category at roots of unity or in positive characteristic. The
constructor does not validate these restrictions.

The call `sl2_representations(K)` uses $q=1$, while the zero-argument call uses
the algebraic complex numbers and $q=1$.

The current model supports finite direct sums, $\operatorname{Hom}$ spaces,
tensor products of nonzero objects, and recoupling associators. It does not
implement duals, evaluation and coevaluation, a braiding, or pivotal and
spherical structures. Those rigid operations remain unavailable despite the
current `is_tensor(C)` declaration.

An object stores a sparse vector of simple multiplicities. A morphism stores
one matrix block for each represented simple label, with rows indexed by source
copies and columns by target copies; `matrix(f)` forms their block diagonal
matrix. Tensor products of blocks use `kronecker_product`, with the coordinate
from the right factor varying fastest. Object equality compares the parent and
the occupied multiplicities; morphism equality also compares endpoints and
occupied blocks. When constructing a morphism from an array or dictionary of
blocks, supply compatible indices, sizes, coefficient fields, and endpoints;
the low-level constructor assumes these conditions.

The argument `q` fixes the quantum integers through $[2]=q+q^{-1}$. For
external labels $i,j,k$, output label $w$, ascending left channel $m$, and
ascending right channel $n$, the stored entry in the row indexed by $m$ and
column indexed by $n$ is
```math
\left\{\begin{matrix}j&i&n\\w&k&m\end{matrix}\right\}_{\!\mathrm{KL}}.
```
This is exactly the recoupling coefficient defined in
[kauffman1994temperley; Chapter 9, §§9.10–9.12, pp. 93–101](@citet), with
the argument order shown above.

Here `C[i]` denotes $V_i$ with its mathematical, zero-based label;
this is an exception to indexing by position in `simples(C)` for finite
skeletal categories.

```@example sl2
using TensorCategories, Oscar
C = sl2_representations(QQ,QQ(1))
@assert C[1]⊗C[1] == C[0]⊕C[2]
decompose(C[1]⊗C[1])
```

Use `simples(C,n)` for the first $n$ simple objects. Algorithms that require a
finite set of simples do not apply to this category.

## [Verlinde categories](@id verlinde-models)

The $\mathrm{SU}(2)$ Verlinde categories are root-of-unity semisimplifications
that occur in Wess–Zumino–Witten conformal field theory and in
$\mathrm{SU}(2)$ Chern–Simons anyon models. This constructor directly installs
the resulting skeletal fusion rules and Temperley–Lieb recoupling coefficients;
it does not construct the semisimplification from quantum-group modules.

For an integer $m\geq 0$, `verlinde_category(m)` has rank $m+1$, with labels
$X_0,\ldots,X_m$.
The default field is $\mathbb Q(\zeta_{4m+8})$ and the implementation first
chooses a root $z$ of order $2m+4$. Julia `C[1]` is $X_0$ here.
The fusion rule is
```math
X_a\otimes X_b=
\bigoplus_{\substack{c=|a-b|\\c\equiv a+b\;(\mathrm{mod}\,2)}}^{
\min(a+b,\,2m-a-b)} X_c.
```
It is the level-$m$ $\mathrm{SU}(2)$ fusion rule: equation (1) of
[taylor2006sixj](@citet) becomes the displayed formula after setting
$r=m+2$ and replacing each half-integer label $j$ by $2j$.

The full positional call is `verlinde_category(K,m,l,t)`; omitting the last two
arguments uses $l=t=1$. The cyclotomic-field overload is
`verlinde_category(m,l,t)`, again with $l=t=1$ by default.
For these default values, let $A$ be the bracket parameter of
[kauffman1994temperley; Chapters 6–8, pp. 45–92](@citet). The parameters are
related by
```math
r=m+2,\qquad z=A^2,\qquad w=\sqrt z=A,
\qquad [n]=\frac{z^n-z^{-n}}{z-z^{-1}}.
```
The stored coefficients use the Temperley–Lieb recoupling coefficient
```math
\left\{\begin{matrix}a&b&i\\c&d&j\end{matrix}\right\}_{\!\mathrm{KL}}
=\frac{\operatorname{Tet}[a,b,i;c,d,j] \, (-1)^i[i+1]}
{\Theta(a,d,i)\Theta(b,c,i)}
```
in the trivalent basis of
[kauffman1994temperley; Chapter 9, pp. 93–101](@citet).
Here $\Theta$ and $\operatorname{Tet}$ denote the theta-net and tetrahedral-net
evaluations defined in
[kauffman1994temperley; §§9.10–9.12, pp. 97–99](@citet).
Consequently, for external labels $a,b,c$, output label $d$, ascending left
channel $e$, and ascending right channel $f$, the entry in row $e$ and column
$f$ of the stored associator block is
```math
\left\{\begin{matrix}b&a&f\\d&c&e\end{matrix}\right\}_{\!\mathrm{KL}}.
```
For general $l$, the quantum integers are instead generated from
$z^l+z^{-l}$. The cited Kauffman–Lins presentation identifies the default
$l=1$; the other $l$-values are additional parameter choices whose literature
normalization is unspecified. For the usual semisimple level-$m$ model one
must have
```math
\gcd(l,m+2)=1.
```
Equivalently, the quantum integers $[1],\ldots,[m+1]$ are then all nonzero.
Without this condition, a denominator in the recoupling formulas can vanish.
The constructor does not enforce the condition.

The braiding is supplied when the field contains a square root $w$ of $z$:
```math
R^{ab}_c=(-1)^{(a+b-c)/2}(w^t)^{(a(a+2)+b(b+2)-c(c+2))/2}.
```
For $t=1$ this is the local braiding of
[kauffman2010topological; §10, Figure 39](@citet), with the crossing orientation
shown there. The other square root or the inverse crossing changes the literal
scalar.
The literal braiding comparison is likewise for $t=1$. Not every choice of
$l,t$ gives compatible associators and braiding.
The constructor does not check the pentagon or hexagon identities. It also
retains the skeletal initializer's all-one pivotal components without checking
the pivotal or spherical identities.

```@example verlinde
using TensorCategories, Oscar
C = verlinde_category(2)
@assert length(simples(C)) == 3
@assert is_isomorphic(C[2]⊗C[2], C[1]⊕C[3])[1]
@assert pentagon_axiom(C)
@assert hexagon_axiom(C)
fpdim.(simples(C))
```

Associators and braiding blocks are generated lazily. Use `associator`,
`braiding`, or `six_j_symbols` rather than reading uninitialized entries
of `C.ass` immediately after construction.

## [Dihedral Temperley–Lieb models](@id dihedral-models)

Two-colored Temperley–Lieb categories encode the finite dihedral case of
Soergel calculus. The package supplies a two-summand-unit skeleton and its
simple-unit even sector.

For the finite dihedral parameter $m\geq 3$, `I2(m)` has $2(m-1)$ simple
labels, corresponding to alternating words beginning with $s$ or $t$. Its unit
has two summands. The constructors do not validate this range.
`I2subcategory(m)` retains $\lfloor m/2\rfloor$ labels
$B_s,B_{sts},\ldots$, with simple unit $B_s$.
The default coefficient field is $\mathbb Q(\zeta_{2m})$.
To supply another coefficient field, use the constructors `I2(m,K)` and
`I2subcategory(m,K)`, with the field as the second argument. The supplied field
must contain a primitive $2m$-th root
of unity and the inverses required by the recoupling formulas.

Their labels and fusion rules model the two-colored Temperley–Lieb category at
a root of order $2m$, modulo the negligible part, and their associator blocks
use Kauffman–Lins recoupling coefficients. The two colors, alternating labels,
and relation with finite dihedral Soergel calculus are described in
[elias2016twocolor; §1.4 and Proposition 1.2, pp. 6–7; §4.3, Proposition 4.11
and Remark 4.12, p. 30; §6.4, Theorem 6.29, p. 61](@citet).

The fusion rules of `I2subcategory(m)` are those of the even, or adjoint,
sector $\mathrm{SO}(3)_{m-2}$ of the level-$(m-2)$ $\mathrm{SU}(2)$ category.
This parameter shift is also the one in the identification of the middle
dihedral asymptotic category with $\mathrm{SO}(3)_{m-2}$
[mackaay2023simple; §8(c), equation (8.4)](@cite).

Both constructors use the Kauffman–Lins recoupling matrices and neither supplies
a braiding. `I2subcategory` explicitly installs all-one pivotal components.
The full `I2` model retains default all-one components from the skeletal
initializer, but they are not validated pivotal data. The literature
identification covers the fusion rules and Kauffman–Lins recoupling formulas;
no basis-by-basis equivalence with the cited diagrammatic category, or
identification of the all-one components with its pivotal structure, is fixed.
Evaluation and coevaluation in the full `I2` model are incomplete, so it does
not currently supply a complete rigid structure.
