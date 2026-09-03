# Fusion data and databases

These entry points provide skeletal categories, fusion rules, or stored symbol
data. Consult the [catalogue](../F-symbols/Examples.md) before using an entry:
it records coefficient fields, conventions, provenance, and whether the entry
is complete, partial, legacy, or experimental.

| Family | Principal entry points | Catalogue entry |
|:---|:---|:---|
| AnyonWiki | `anyonwiki`, `anyonwiki_keys`, `anyonwiki_center` | [AnyonWiki](../F-symbols/AnyonWiki.md) |
| Dihedral models | `I2`, `I2subcategory` | [$\mathfrak{sl}_2$, Verlinde, and dihedral models](../ConcreteExamples/UqSl2.md) |
| $E_6$ candidate data | `E6subfactor` | [$E_6$](../F-symbols/E6.md) |
| Extended Haagerup $M$--$M$ fusion rules | `TensorCategories.extended_haagerup` | [Haagerup](../F-symbols/Haagerup.md) |
| Fibonacci | `fibonacci_category` | [Fibonacci](../F-symbols/Fibonacci.md) |
| Haagerup data | `haagerup_H1`, `haagerup_H2`, `haagerup_H3`, `haagerup_H3_center`, `numeric_unitary_center_H3`, `unitary_haagerup_H2`, `TensorCategories.unitary_haagerup_H3_wolf` | [Haagerup](../F-symbols/Haagerup.md) |
| Ising | `ising_category` | [Tambara–Yamagami and Ising](../F-symbols/TambaraYamagami.md) |
| $\mathrm{SU}(3)_3$ subcategory | `TensorCategories.su_3_3_subcategory` | [$\mathrm{SU}(3)_3$](../F-symbols/SU3_3.md) |
| Tambara–Yamagami | `tambara_yamagami` | [Tambara–Yamagami and Ising](../F-symbols/TambaraYamagami.md) |
| Trivial fusion category (currently unavailable) | `trivial_fusion_category` | [Trivial fusion category](../F-symbols/Trivial.md) |
| Vercleyen–Slingerland candidate data | `cat_fr_8122`, `cat_fr_9143` | [Vercleyen–Slingerland data](../F-symbols/VercleyenSlingerland.md) |
| Verlinde models | `verlinde_category` | [$\mathfrak{sl}_2$, Verlinde, and dihedral models](../ConcreteExamples/UqSl2.md) |

The qualified names in the table are loaded by the package but are not
exported. Use them only after reading their dedicated entries.
