# [Haagerup categories and data](@id haagerup-data)

The Haagerup subfactor has the smallest finite-depth index above $4$
[grossman2012haagerup; Introduction](@citet). Its Morita equivalence class
contains exactly three fusion categories, denoted $H_1,H_2,H_3$
[grossman2012haagerup; Theorem 1.4](@cite). The constructors on this page
include exact database records, a formula model, precomputed centers, and
legacy or fusion-ring-only entries. For each constructor, the entry states
which structural data are supplied and which identification with the
literature is known.

The default constructors load the following stored data:

| Constructor | Rank | Coefficients and data source |
|:---|:---|:---|
| `haagerup_H1()` | 4 | The `Haagerup_H1` artifact over $\mathbb Q[t]/(t^4+t^3-t^2+t+1)$; fusion ring identified, exact associator gauge unverified |
| `haagerup_H2()` | 6 | `anyonwiki(6,1,2,8,2,0,1)` over $\mathbb Q[t]/(t^4+t^3-t^2+t+1)$ |
| `haagerup_H3()` | 6 | `anyonwiki(6,1,2,8,1,0,1)` over $\mathbb Q[t]/(t^4-t^3-t^2-t+1)$ |
| `haagerup_H3_center()` | 12 | The `center_haagerup` artifact over its stored degree $48$ number field |
| `numeric_unitary_center_H3()` | 12 | Stored $F$- and $R$-symbol CSV files over `AcbField`; default precision 64 bits, requested precision capped at 107 bits |

## [The $H_1$ artifact](@id haagerup-h1)

The loader `haagerup_H1()` returns a rank-four category over
$\mathbb Q(\theta)$, where
$\theta^4+\theta^3-\theta^2+\theta+1=0$, with labels
$(\mathbb 1,\nu,\eta,\mu)$. The artifact supplies associators and all-one
pivotal components, but no braiding or complex embedding. Its fusion table
agrees with [maeurer2026thesis; §5.2, Table 2, p. 89](@citet), and with
[barter2022associators; §V, Eq. (53), p. 13](@citet) after reordering that
paper's $(\mathbb 1,\mu,\eta,\nu)$ to the package order. The artifact contains
a separate exact quartic-field associator. The cited literature identifies the
fusion ring, but it gives no change of fusion bases from this artifact gauge to
the published unitary `H1Data.m` gauge.

## [The $H_2$ and $H_3$ loaders](@id haagerup-h2-h3)

The referenced $H_2$ and $H_3$ loaders use the labels
$(\mathbb 1,\alpha,\alpha^*,\rho,\alpha\rho,\alpha^*\rho)$. They have the same
fusion rules but different associators. Both AnyonWiki keys have braiding
index zero, so these two loaders supply no $R$-symbols. Their common fusion
ring can be written

```math
\label{eq:haagerup-fusion-rules}
\alpha^3=\mathbb 1,\qquad
\alpha\rho=\rho\alpha^{-1},\qquad
\rho^2=\mathbb 1+\rho+\alpha\rho+\alpha^2\rho.
```

Their identification is described in [maurer2026haagerup; §1](@citet) and,
with the keys and fusion rings printed explicitly, in
[maeurer2026thesis; §5.2, Tables 2–3,
pp. 89–91](@citet). Their literal $F$-symbol source is the corresponding
[anyonwiki2023](@cite) record, decoded as described on the
[AnyonWiki page](@ref anyonwiki-data); no entrywise change of fusion basis to
the unitary formula gauges in the literature is recorded.
The records also supply the dataset's all-one pivotal coefficients. The cited
formula presentations do not identify these coefficients with their own
pivotal gauges.

The $H_2$ entry stores the complex embedding that sends its displayed generator
to approximately $0.651387818866+0.758744956776i$. The $H_3$ entry sends its
generator to the real root approximately $1.722083805739$.
The displayed generator $t$ is the archive generator. In the minimal-field
notation of [maurer2026haagerup; after Remark 4.13, p. 22](@citet), write
$a=-t$ for $H_2$ and $b=-t$ for $H_3$. These generators are denoted
$\alpha$ and $\beta$, respectively, in that reference; they are unrelated to
the simple-object label $\alpha$ above. The substitution changes
$t^4+t^3-t^2+t+1$ into
$a^4-a^3-a^2-a+1$, and changes
$t^4-t^3-t^2-t+1$ into
$b^4+b^3-b^2+b+1$. This identifies the two presentations of the coefficient
fields. The exact $F$-symbols remain identified by the pinned AnyonWiki record
described above.
The latter is the small-field exact presentation in
[maeurer2026thesis; §5.2, p. 91](@citet), which is not in a unitary gauge; the
Wolf constructor below is a separate unitary presentation.
The call `haagerup_H3(algebraic_closure(QQ))` extends the latter exact model to
OSCAR's algebraic closure, choosing roots compatibly with this stored complex
embedding. The overload `haagerup_H3(:splitting_field)` is currently
unavailable; construct the algebraic closure explicitly as above.

```@example haagerup
using TensorCategories, Oscar
H = haagerup_H3()
@assert length(simples(H)) == 6
@assert H[2] ⊗ H[3] == one(H)
@assert H[4] ⊗ H[4] == H[1] ⊕ H[4] ⊕ H[5] ⊕ H[6]
@assert !is_braided(H)
base_ring(H)
```

## [Exact $H_3$ center archive](@id haagerup-exact-center)

`haagerup_H3_center()` loads the split rank-twelve skeleton computed in
[maurer2026haagerup; §3.2, pp. 11–13](@citet) and
[maeurer2026thesis; §5.2.2, pp. 93–94](@citet). The archive includes $F$-,
$R$-, and pivotal data. It displays its simples as underlying $H_3$ objects
equipped with half-braiding labels. In its stored order, these correspond to

```math
\label{eq:haagerup-center-simple-order}
(\mathbb 1,\pi_1,\pi_2,\sigma_0,\sigma_1,\sigma_2,
\mu_1,\ldots,\mu_6).
```

The underlying objects of the first three entries are respectively
$\mathbb 1$,
$\mathbb 1\oplus\rho\oplus\alpha\rho\oplus\alpha^*\rho$, and
$2\mathbb 1\oplus\rho\oplus\alpha\rho\oplus\alpha^*\rho$; those of the
$\sigma_i$ are
$\alpha\oplus\alpha^*\oplus\rho\oplus\alpha\rho\oplus\alpha^*\rho$, and
those of the $\mu_i$ are $\rho\oplus\alpha\rho\oplus\alpha^*\rho$.

The coefficient field is $K_Z=\mathbb Q[t]/(p_Z(t))$, where the artifact
records

```math
\label{eq:haagerup-center-polynomial}
\begin{aligned}
p_Z(t)={}&t^{48}-t^{47}+2t^{46}-2t^{45}+2t^{44}-t^{43}-t^{42}
 +4t^{41}-8t^{40}+12t^{39}\\
&-15t^{38}+15t^{37}-10t^{36}+51t^{35}-31t^{34}+57t^{33}
 -27t^{32}+2t^{31}+59t^{30}\\
&-141t^{29}+229t^{28}-313t^{27}+342t^{26}-285t^{25}+85t^{24}
 +285t^{23}+342t^{22}\\
&+313t^{21}+229t^{20}+141t^{19}+59t^{18}-2t^{17}-27t^{16}
 -57t^{15}-31t^{14}-51t^{13}\\
&-10t^{12}-15t^{11}-15t^{10}-12t^9-8t^8-4t^7-t^6+t^5
 +2t^4+2t^3+2t^2+t+1.
\end{aligned}
```

If

```math
\label{eq:haagerup-number-field}
K_H=\mathbb Q[u]/(u^4-u^3-u^2-u+1)
```

is the defining field of `haagerup_H3()`, then
$K_Z\cong K_H(\zeta_{39})$
[maeurer2026thesis; §5.2, Eqs. (5.5)–(5.6), p. 91](@cite). The polynomial
$p_Z$ records the particular field generator used by the archive.

The loader chooses the complex embedding whose image of $t$ is the root
nearest $1.29+0.25i$.
The exact archive is not in a unitary gauge
[maurer2026haagerup; Remark 3.1, p. 13](@citet). This does not affect its
pentagon and hexagon identities, but it distinguishes this presentation from
the numerical unitary archive below.

## [Numerical center archive](@id haagerup-numerical-center)

The CSV files used by `numeric_unitary_center_H3` are the published numerical
data discussed in [maeurer2026thesis; §5.2.3, pp. 94–96](@citet). They were
computed from the degree $16$ unitary Wolf presentation, beginning with
$512$-bit balls; the source computation ended with a rigorous error bound of
$107$ bits. The distributed CSV records decimal centers rather than the
original ball radii. The loader parses those decimals into a new `AcbField` at
the requested precision, so its output does not reproduce the original
certifying balls. The files use the historical `:column_major_packing` layout.
In the thesis notation, their ten index columns are

```math
\label{eq:haagerup-dictionary-index-order}
(i,j,k,l,n,\delta,\gamma,m,\alpha,\beta),
```

whereas [maeurer2026thesis; §5.2.3.1](@citet) prints the mathematical projection
labels as
$(i,j,k,l,m,n,\beta,\alpha,\gamma,\delta)$. The default loader reads the
published files in their actual historical layout. The relation between the
thesis's projection-inverse matrices and the package's structural matrices is
given in [$F$-symbol conventions](@ref f-conventions).

The CSV archive does not contain pivotal components. The loader therefore
retains the skeletal initializer's unchecked all-one pivotal components;
verify the pivotal or spherical identities at the chosen working precision
before using dimensions, twists, or the $S$-matrix.

The numerical loader uses the same compact simple names
$(\mathbb 1,\pi_1,\pi_2,\sigma_0,\sigma_1,\sigma_2,\mu_1,\ldots,\mu_6)$ as
above. Unlike the exact archive, it stores no explicit half-braidings or
underlying $H_3$ objects.

The optional precision argument is positional: for example,
`numeric_unitary_center_H3(96)` requests $96$ bits. Requests above $107$ bits
are capped because the source computation certifies only $107$ bits, even
though the files print additional decimal digits. The constructor loads the
files with the numerical loader's default `check=false`; it does not run the
pentagon or hexagon checks automatically.

## [Wolf formulas and conventions](@id haagerup-wolf-formulas)

[osborne2019h3; Figure 1, Theorem 3.1, and Appendix B,
pp. 2–3 and 16–23](@citet) supply a real solution
with two signs $p_1,p_2\in\{\pm1\}$. The package contains a separate,
unexported formula implementation
`TensorCategories.unitary_haagerup_H3_wolf`. Its keyword defaults are
`p1=1` and `p2=1`.

The default coefficient argument constructs the degree $16$ number field
defined by the polynomial in [osborne2019h3; Theorem 3.1](@citet). A supplied
field must contain the required square roots. The constructor installs the
fusion rules, tensor unit, and associators, retains the skeletal initializer's
unchecked all-one pivotal components, and supplies no braiding.

With the embedding and radical choices that make the paper's radicals positive
real, a matrix in the reference must be transposed to obtain the package's
structural-matrix direction, as explained under
[$F$-symbol conventions](@ref f-conventions). The formula file implements this
translation. For each of the four sign pairs, every nonzero block agrees
entrywise with Appendix B after this transpose, including the paper's channel
order. The intended inputs satisfy $p_1,p_2\in\{\pm1\}$; the constructor does
not validate this restriction or install the positive-real embedding.

## [Legacy $H_2$ data](@id haagerup-auxiliary-data)

Unitary gauges make the adjoint operation transparent and are particularly
useful for numerical and anyonic calculations. The following table is a
legacy package artifact whose precise mathematical gauge is unknown.

The exported constructor `unitary_haagerup_H2()` loads a separate legacy exact
associator table over the degree $8$ number field defined by
$1+x^2-x^4+x^6+x^8$. The table is decoded using the historical
`:column_major_packing` layout, after which the constructor transposes every
decoded matrix once more before storing it. The chosen embedding sends $x$ to
approximately $-0.908677010512+0.417499809062i$. The constructor declares
all-one pivotal components and supplies no braiding. It is not the data path
used by `haagerup_H2()`.

Despite its name, neither a source nor an explicit change of fusion bases
identifies this table, including that extra transpose, with the unitary $H_2$
presentations in
[barter2022associators; §V, pp. 13–14](@citet) or
[huang2020transparent; §5.2.1, p. 16](@citet). Its precise gauge provenance and
declared pivotal structure therefore remain unverified.

## [Extended Haagerup](@id extended-haagerup)

The Extended Haagerup subfactor is another exceptional finite-depth example.
Its two even parts have ranks six and eight; the package records only the
rank-six $M$–$M$ fusion ring constructed by
[bigelow2012extended](@citet).

The extended-Haagerup helper `TensorCategories.extended_haagerup(K)` supplies
the six labels

```math
\label{eq:haagerup-izumi-simple-order}
(\mathbb 1,f^{(2)},f^{(4)},f^{(6)},P',Q')
```

and the fusion rules of the $M$–$M$ even part in
[bigelow2012extended; Appendix A, Table 13, p. 78](@citet). In the displayed
order, the multiplication table in the implementation agrees entry by entry
with that table. The $N$–$N$ even part has eight simple objects and is not
returned by this constructor.

Only these fusion rules are supplied; extended-Haagerup associators are not
implemented. In particular, the returned object records the Grothendieck-ring
multiplicities but is not a verified monoidal category. Its identity
associator blocks and all-one pivotal components are placeholders inherited
from the skeletal initializer, not structural data for the extended-Haagerup
category.
