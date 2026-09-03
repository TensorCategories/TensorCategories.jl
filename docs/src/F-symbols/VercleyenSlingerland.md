# [Experimental Vercleyen–Slingerland imports](@id vercleyen-slingerland-data)

These two examples arise from the “song” construction of
[vercleyen2023low; §5.1, Examples (3)–(4), pp. 10–11](@citet), which
generalizes Tambara–Yamagami and Haagerup–Izumi fusion rings. The rank-eight
ring is obtained from a crossed product of a Tambara–Yamagami category. The
rank-nine ring is categorifiable, but it is not of Tambara–Yamagami or
Haagerup–Izumi type and does not belong to the crossed-product families
considered there.

These constructors expose bundled associator files for experimental use. Treat
the files as candidate matrices: pentagon coherence and a translation of their
channel ordering to a published $F$-symbol convention are not supplied.

`cat_fr_8122(n)` has the fusion ring
```math
\label{eq:vercleyen-slingerland-rank-eight-label}
FR^{8,1,2}_2=
\left[\mathbb Z_3\mathrel{\trianglelefteq}D_3\right]^{\mathrm{Id}}_{1\mid0},
```
which is entry 155 in Example 5.1(3) of the cited paper. Its multiplication
table agrees with that description. The historical source directory is named
`FR_8211`, but that name is a typo and is not the mathematical identifier.
The constructor loads the $n$-th of 96 bundled files corresponding to the
paper's ancillary file `CategorificationsFR_8_1_2_2.wdx`. Its coefficient
field is $\mathbb Q(\zeta_{24})$ and its label order is
$(e,a,b,aba,t,s,ba,ab)$. It installs the imported associator blocks and retains
the skeletal constructor's default all-one pivotal components, without
validating those components against the associators. It supplies no braiding.
The argument must satisfy $1\leq n\leq96$.

`cat_fr_9143()` has the fusion ring
```math
\label{eq:vercleyen-slingerland-rank-nine-label}
FR^{9,1,4}_3=
\left[\mathbb Z_2\mathrel{\trianglelefteq}\mathbb Z_6\right]^\alpha_{1\mid0},
\qquad \alpha(g)=g^{-1},
```
which is entry 305 in Example 5.1(4). Its multiplication table likewise agrees
with the published ring. The constructor loads one candidate corresponding to
the ancillary file `CategorificationsFR_9_1_4_3.wdx` over OSCAR's algebraic
closure `QQBarField()`, with labels
$(g_0,g_3,t_2,t_1,t_0,g_4,g_2,g_5,g_1)$. It installs fusion rules,
associator blocks, a tensor unit, and an all-one pivotal candidate, but no
braiding.

The paper and its ancillary files identify the fusion rings and the source of
the candidate coefficients, but they do not specify the row and column bases
used by the repository import. The small-block ordering is therefore not
identified, and the imported ordering differs from the
[AnyonWiki dictionary format](@ref symbol-data). These constructors provide
the published fusion rings and bundled candidate matrices, but not verified
$F$-symbol presentations of the cited categorifications.
