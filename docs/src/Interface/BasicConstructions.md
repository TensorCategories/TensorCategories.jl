# Products, opposites, and scalar extension

The package supplies several constructions on category models. Their
mathematical meanings differ, even when objects have similar printed forms.

| Construction | Meaning |
|:--|:--|
| `opposite_category(C)` | Reverse morphisms; use `opposite_object` and `opposite_morphism` |
| `product_category(C,D)` | Objects and morphisms are pairs |
| `C ⊠ D` | Deligne tensor product in supported finite linear settings |
| `extension_of_scalars(C,L; embedding=...)` | Transport coefficients along a specified field map |
| `six_j_category(C)` | Choose split semisimple coordinates and retain tensor structure |
| `center(C)` | Adjoin half-braidings, not just new coordinates |
| `semisimplify(C)` | Quotient by negligible morphisms in supported pivotal settings |

The Deligne product and categorical product are different: for finite split
semisimple categories, simples of the Deligne product are pairs of simples,
while the additive categorical product has simples supported in one factor.

Scalar extension can change simple objects and endomorphism algebras.
For split skeletal input it can transport coefficient arrays directly;
a non-split model may also require idempotent splitting. Always specify a
field embedding when several choices exist, and recheck semisimplicity and
nonzero denominators when changing characteristic.

Each construction requires the corresponding operations on its input categories;
see the [API reference](../API.md) for the available methods.
