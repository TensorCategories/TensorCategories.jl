# [AnyonWiki and stored centers](@id anyonwiki-data)

AnyonWiki is a computational census of multiplicity-free pivotal fusion
systems of rank at most seven. Its keys distinguish labeled solutions,
including separate choices of associator, braiding, and pivotal structure;
they do not merely name tensor-equivalence classes. The construction and
organization of the census are described in
[vercleyen2024lowrankmultiplicityfreefusioncategories; §§4.4–4.5 and
Appendix 9](@citet), and the archived data themselves are published as
[anyonwiki2023](@citet).

`anyonwiki(r,m,n,i,a,b,p)` loads data from the package's pinned
[AnyonWiki](https://anyonwiki.github.io/) artifact. The seven indices are:

| Index | Meaning |
|:--|:--|
| `r` | Rank |
| `m` | Maximum fusion multiplicity |
| `n` | Number of non-self-dual simples |
| `i` | Fusion-ring index |
| `a` | Associator index |
| `b` | Braiding index; zero means no braiding is loaded |
| `p` | Pivotal-structure index |

The field-first form `anyonwiki(K,r,m,n,i,a,b,p)` is also available.
Number-field, algebraic-closure, and finite-field inputs attempt scalar
extension along a compatible field map. An `AcbField` input evaluates the
stored exact category numerically, using `precision(K)` as the target
approximation precision. The resulting category may use additional guard bits;
its actual working precision is `precision(base_ring(C))`, as explained under
[Numerical fusion categories](@ref numerical-fusion-categories).

The available keys are those in the pinned dataset. The loader labels the
simples $(\mathbb 1,X_2,\ldots,X_r)$ in dataset order; it does not retain more
descriptive names from the source. A key identifies a stored solution with
particular labels and bases, rather than a category up to tensor equivalence.
The constructor reproduces the $F$- and pivotal coefficients from the record
with this key in the pinned TensorCategoriesDatabase artifact, together with
the $R$-coefficients when the braiding index is nonzero. Its
historical dictionaries use `:column_major_packing`; the decoder transposes
the packed arrays into the package's row-coordinate structural matrices. This
reconstructs the pinned artifact record exactly after the stated coordinate
conversion. The pinned artifact fixes the gauge of each entry; individual
entries need not have separately named gauges in the literature.

`anyonwiki_keys(n, attrs...)` lists available keys of rank at most $n$; the
default bound is $n=7$. The optional string filters are `"spherical"`,
`"modular"`, and `"unitary"`, and several filters may be supplied together:

```julia
anyonwiki_keys(5, "modular", "unitary")
```

```@example anyonwiki
using TensorCategories, Oscar
C = anyonwiki(2,1,0,1,1,1,1)
@assert length(simples(C)) == 2
@assert pentagon_axiom(C)
@assert hexagon_axiom(C)
(base_ring(C), dim.(simples(C)))
```

The loader reads an exact coefficient field and a chosen complex embedding,
together with $F$-symbols and pivotal data. When the braiding index is nonzero,
it also reads $R$-symbols. It uses the dictionary decoder described in
[data exchange](Data.md). Changing only the embedding changes numerical
interpretation, whereas scalar extension requires an actual field map.
An artifact's exact data need not coincide with a later revision of the website.

## [Precomputed centers](@id anyonwiki-centers)

Drinfeld centers turn these input fusion categories into braided, and in the
appropriate setting modular, categories. The stored presentations are the
rank-at-most-five census computed by
[maurer2024computing; §7](@citet), rather than centers recomputed when the
loader is called.

`anyonwiki_center(r,m,n,i,a,b,p)` loads a precomputed split skeletal braided
fusion category. The stored centers are themselves fusion categories available
directly from the package; calling the loader does not run the center algorithm.
Each archive supplies its own exact coefficient number field, simple labels,
and structural matrices, together with a complex embedding when one is stored;
this field need not be the defining field of the corresponding AnyonWiki input.
The current lookup covers input AnyonWiki categories with $r\leq5$; the rank of
the resulting center can be larger. It does not search arbitrary input ranks or
compute a missing entry automatically.
The paper and [maeurer2026thesis; §5.1](@citet) describe the construction and
census; the exact matrices for a particular key are fixed by the pinned
artifact because the paper does not print every archived entry.

A saved split skeleton supplies fusion rules and structural matrices. By
contrast, `center(anyonwiki(...))` constructs the center over the same defining
field as the loaded AnyonWiki category, and that center need not split over
this field. Its objects explicitly carry half-braidings in the original
category. Use this construction when those maps, rather than only $F$- and
$R$-symbol data, are needed. Availability of one stored center does not imply
that all AnyonWiki choices with the same fusion-ring index have a saved entry.
