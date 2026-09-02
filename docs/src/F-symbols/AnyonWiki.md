# AnyonWiki and stored centers

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

The available keys are those in the pinned dataset. They identify stored
solutions with particular labels and bases; they do not classify categories up
to tensor equivalence. The dataset and its construction are described in
[vercleyen2024lowrankmultiplicityfreefusioncategories](@cite).

```@example anyonwiki
using TensorCategories, Oscar
C = anyonwiki(2,1,0,1,1,1,1)
@assert length(simples(C)) == 2
@assert pentagon_axiom(C)
@assert hexagon_axiom(C)
(base_ring(C), dim.(simples(C)))
```

The loader reads a number field and a chosen complex embedding, then F-, R-,
and pivotal data. It uses the dictionary decoder described in
[data exchange](Data.md). Changing only the embedding changes numerical
interpretation, whereas scalar extension requires an actual field map.
An artifact's exact data need not coincide with a later revision of the website.

## Precomputed centers

`anyonwiki_center(r,m,n,i,a,b,p)` loads a precomputed split skeletal fusion
category. These centers are further fusion categories that are directly
available from the package; calling the loader does not run the center
algorithm.
The current lookup implements ranks up to 5; it does not search arbitrary
ranks or compute a missing entry automatically.
These data are results of the computations described in
[maurer2024computing](@cite) and [maeurer2026thesis](@cite), §5.1.

A saved split skeleton supplies fusion rules and structural matrices. By
contrast, `center(anyonwiki(...))` constructs the center over the same defining
field as the loaded AnyonWiki category, and that center need not split over
this field. Its objects explicitly carry half-braidings in the original
category. Use this construction when those maps, rather than only F/R data,
are needed. Availability of one stored center does not imply that all parameter
choices for that ring have a saved entry.
