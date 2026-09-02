# [Catalogue of categories](@id category-catalogue)

The catalogue lists concrete models, categories supplied by structural data,
and partial implementations.

| Family | Entry point | Representation and scope |
|:---|:---|:---|
| [AnyonWiki](AnyonWiki.md) | `anyonwiki(r,m,n,i,a,b,p)` | Artifact data with explicit identifiers |
| [AnyonWiki split centers](AnyonWiki.md#Precomputed-centers) | `anyonwiki_center(r,m,n,i,a,b,p)` | Precomputed split skeletal fusion categories for available entries of rank at most 5 |
| [Cocycle-twisted graded spaces](../ConcreteExamples/VectorSpaces.md#Cocycle-twists) | `graded_vector_spaces(K,G,ω)` | Same objects, modified associator |
| [Convolution categories](../ConcreteExamples/CoherentSheaves.md#Convolution) | `convolution_category(K,X)` | Equivariant sheaves on $X\times X$ |
| [Dihedral constructions](../ConcreteExamples/UqSl2.md#Dihedral-cell-categories) | `I2(m,K)`, `I2subcategory(m,K)` | Recoupling models |
| [E₆ candidate data](OtherExamples.md#E) | `E6subfactor()` | Rank 3, fusion multiplicity 2; associators do not satisfy the pentagon |
| [Equivariant coherent sheaves](../ConcreteExamples/CoherentSheaves.md) | `coherent_sheaves(K,X)` | Representations of orbit stabilizers |
| [Extended Haagerup](Haagerup.md#Extended-Haagerup) | `TensorCategories.extended_haagerup(K)` | **Fusion rules only**; no supplied associators |
| [Fibonacci fusion rules](Fibonacci.md) | `fibonacci_category(K,a)` | Two algebraic associator choices |
| [Finite-dimensional vector spaces](../ConcreteExamples/VectorSpaces.md) | `vector_spaces(K)` | Basis vectors and matrices |
| [Finite-group representations](@ref representations) | `representation_category(K,G)` | Action matrices and intertwiners |
| [Finite sets](../ConcreteExamples/Sets.md) | `Sets()` | Legacy finite-sets-and-maps model |
| [Generic quantum sl₂ representations](../ConcreteExamples/UqSl2.md#Generic-sl-representation-rules) | `sl2_representations(K,q)` | Sparse simple-multiplicity model; not a root-of-unity module category |
| [Graded vector spaces](../ConcreteExamples/VectorSpaces.md#Finite-group-gradings) | `graded_vector_spaces(K,G)` | Degrees and degree-preserving matrices |
| [Haagerup H₁, H₂, H₃](Haagerup.md) | `haagerup_H1()`, `haagerup_H2()`, `haagerup_H3()` | Stored exact data |
| [Haagerup H₃ center](Haagerup.md) | `haagerup_H3_center()` | Stored skeletal center |
| [Ising](TambaraYamagami.md#Ising) | `ising_category(K,s,q)` | TY for $A=C_2$; optional braiding |
| [SU(3)₃ subcategory](@ref su3-subcategory) | `TensorCategories.su_3_3_subcategory(K)` | Rank 4, multiplicity 2; not exported |
| [Tambara–Yamagami](TambaraYamagami.md) | `tambara_yamagami(K,A,s,χ)` | Explicit bicharacter formulas |
| [Vercleyen–Slingerland examples](OtherExamples.md#Vercleyen–Slingerland-imports) | `cat_fr_8122(n)`, `cat_fr_9143()` | Rank-eight and rank-nine datasets |
| [Verlinde](../ConcreteExamples/UqSl2.md#Verlinde-categories) | `verlinde_category(K,m,l,t)` | Lazy recoupling data; parameters require care |

Categories obtained by general constructions—centers, opposites, products,
semisimplifications, module categories, equivariantizations, and tensor powers—
are described in [Further constructions](../Interface/BasicConstructions.md).
Their availability is governed by the input model's operations.

## Choosing a model

Use concrete vector spaces or representations when the underlying linear
algebra is the natural input. Use `SixJCategory` when fusion and associator
data are supplied, or after extracting them from a supported concrete model.

The individual entries describe coefficient fields, labels, parameters, and
available operations.
