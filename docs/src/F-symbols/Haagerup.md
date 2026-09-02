# Haagerup categories and data

The default constructors load the following stored data:

| Constructor | Rank | Data source |
|:---|:---|:---|
| `haagerup_H1()` | 4 | The `Haagerup_H1` artifact; quartic number field |
| `haagerup_H2()` | 6 | `anyonwiki(6,1,2,8,2,0,1)`; quartic number field |
| `haagerup_H3()` | 6 | `anyonwiki(6,1,2,8,1,0,1)`; quartic number field |
| `haagerup_H3_center()` | 12 | The `center_haagerup` artifact |
| `numeric_unitary_center_H3(acc=64)` | 12 | Stored numerical F/R CSV files; requested precision capped at 107 bits |

H₂ and H₃ use the labels $(\mathbb 1,\alpha,\alpha^*,\rho,\alpha\rho,\alpha^*\rho)$. They have the same fusion rules
but different associators.

For the identification of the AnyonWiki entries and the stored H₃ center, see
[maurer2026haagerup](@cite), §§1 and 3, and [maeurer2026thesis](@cite), §5.2.

## Numerical center archive

The CSV files used by `numeric_unitary_center_H3` are the published numerical
data discussed in [maeurer2026thesis](@citet), §5.2.3. The files use the
historical `:column_major_packing` layout. In the thesis notation, their ten
index columns are

```math
(i,j,k,l,n,\delta,\gamma,m,\alpha,\beta),
```

whereas §5.2.3.1 prints the mathematical projection labels as
$(i,j,k,l,m,n,\beta,\alpha,\gamma,\delta)$. The default loader reads the
published files in their actual historical layout. The relation between the
thesis's projection-inverse matrices and the package's structural matrices is
given in [F-symbol conventions](@ref f-conventions).

## Wolf formulas and conventions

[osborne2019h3](@citet), Theorem 3.1 and Appendix B, supplies a real solution with two signs
$p_1,p_2\in\{\pm1\}$ [osborne2019h3](@cite). The package contains a separate, unexported
formula implementation `TensorCategories.unitary_haagerup_H3_wolf`.

With positive real square roots, each stored block is the transpose of the
corresponding Wolf matrix, as explained under
[F-symbol conventions](@ref f-conventions). Both signs
$p_1,p_2\in\{\pm1\}$ are supported.

## Working with the default data

```@example haagerup
using TensorCategories, Oscar
H = haagerup_H3()
@assert length(simples(H)) == 6
@assert H[2] ⊗ H[3] == one(H)
@assert H[4] ⊗ H[4] == H[1] ⊕ H[4] ⊕ H[5] ⊕ H[6]
@assert !is_braided(H)
base_ring(H)
```

## Extended Haagerup

The extended-Haagerup helper `TensorCategories.extended_haagerup(K)` supplies
only fusion rules; extended-Haagerup associators are not implemented.
