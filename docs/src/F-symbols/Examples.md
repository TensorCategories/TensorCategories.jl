# [Catalogue of categories](@id category-catalogue)

This chapter is a lookup guide to the models and datasets distributed with the
package. It includes complete category implementations, constructors from
structural data, and entries providing a specified subset of the categorical
structure. The
table is ordered alphabetically by family; its detailed pages are independent
reference entries rather than a sequence of prerequisites.

Each linked entry gives the mathematical context, a precise literature or
dataset reference, and the relation between that presentation and the current
implementation. Entries that provide only fusion rules or imported associator
data without complete basis metadata are marked accordingly.

## Choosing a model

A concrete model retains the objects and morphisms from the mathematical
realization, as in vector spaces, graded spaces, representations, and
equivariant sheaves. Use such a model when that linear algebra is part of the
problem. A `SixJCategory` retains a split semisimple skeleton together with
fusion multiplicities and structural matrices; use it when $F$-symbols are the
input or desired output. Some further models store only fusion rules or simple
multiplicities. They support only the operations stated in their entries.

Database keys and constructor parameters select stored presentations, rather
than tensor-equivalence classes. Each entry supports the structures stated on
its detailed page.

Here an **artifact** is a versioned data archive installed by Julia for a
particular package release. Loading an artifact reads the pinned copy shipped
with that release; it does not query the current version of an external
database.

## Available models and data

| Family | Entry point | Representation and scope |
|:---|:---|:---|
| [AnyonWiki](@ref anyonwiki-data) | `anyonwiki(r,m,n,i,a,b,p)` | Exact decoding of a pinned artifact record into the package's structural-matrix convention |
| [AnyonWiki split centers](@ref anyonwiki-centers) | `anyonwiki_center(r,m,n,i,a,b,p)` | Precomputed split skeletal braided centers for available AnyonWiki inputs of rank at most 5 |
| [Bicharacter-braided graded spaces](@ref bicharacter-braidings) | `graded_vector_spaces(K,G,χ)` | Trivial associator and a supplied bicharacter braiding for finite abelian $G$ |
| [Cocycle-twisted graded spaces](@ref cocycle-twists) | `graded_vector_spaces(K,G,ω)` | Same objects and tensor product; associator, evaluation, and pivotal scalar depend on $\omega$; braiding is unavailable for a nontrivial twist |
| [Cocycle twists computed with GAP/HAP](@ref hap-cocycle-twists) | `twisted_graded_vector_spaces(K,G,i)` | Backend-generated cocycles; class enumeration and tuple/coefficient translations depend on the installed HAP version |
| [Convolution categories](@ref convolution-models) | `convolution_category(K,X::GSet)` | Standard convolution bifunctor; the detailed entry states the validation status of associator and duality data |
| [Dihedral constructions](@ref dihedral-models) | `I2(m,K)`, `I2subcategory(m,K)` | Published fusion interpretation with Kauffman–Lins recoupling; the full model lacks complete rigidity data |
| [$E_6$ data](@ref e6-data) | `E6subfactor()` | Rank 3, fusion multiplicity 2; associators do not satisfy the pentagon |
| [Equivariant coherent sheaves](@ref equivariant-sheaves) | `coherent_sheaves(K,X)` | Representations of orbit stabilizers |
| [Extended Haagerup](@ref extended-haagerup) | `TensorCategories.extended_haagerup(K)` | $M$–$M$ even-part **fusion rules only**; no supplied associators |
| [Fibonacci categories](@ref fibonacci-data) | `fibonacci_category(K,a)` | Two algebraic associator choices |
| [Finite-dimensional vector spaces](@ref graded-spaces) | `vector_spaces(K)` | Basis vectors and matrices |
| [Finite-group representations](@ref representations) | `representation_category(K,G)` | Action matrices and intertwiners |
| [Finite sets](@ref finite-sets) | `Sets()` | Finite-set model with products and coproducts; current object-equality and dictionary-map validation limitations; no monoidal interface |
| [Generic quantum $\mathfrak{sl}_2$ recoupling model](@ref generic-sl2-models) | `sl2_representations(K,q)` | Sparse simple-multiplicity model; not the semisimple root-of-unity quotient |
| [Graded vector spaces](@ref finite-group-gradings) | `graded_vector_spaces(K,G)` | Degrees and degree-preserving matrices |
| [Haagerup $H_1$ artifact](@ref haagerup-h1) | `haagerup_H1()` | Published $H_1$ fusion ring with an exact artifact associator; no basis change to a published gauge is recorded |
| [Haagerup $H_2$ and $H_3$](@ref haagerup-h2-h3) | `haagerup_H2()`, `haagerup_H3()` | Stored exact AnyonWiki $F$- and pivotal data; no braiding |
| [Haagerup exact $H_3$ center](@ref haagerup-exact-center) | `haagerup_H3_center()` | Exact split center in a nonunitary gauge, with $F$-, $R$-, and pivotal data |
| [Haagerup numerical $H_3$ center](@ref haagerup-numerical-center) | `numeric_unitary_center_H3()` | Decimal approximations to unitary-gauge $F$- and $R$-data; no stored pivotal data |
| [Haagerup $H_3$ formulas](@ref haagerup-wolf-formulas) | `TensorCategories.unitary_haagerup_H3_wolf(K; p1, p2)` | Unexported Wolf-formula implementation; Appendix B blocks are transposed into package coordinates |
| [Additional Haagerup $H_2$ data](@ref haagerup-auxiliary-data) | `unitary_haagerup_H2()` | Exact table whose source does not record a basis change to a published gauge |
| [Ising](@ref ising-data) | `ising_category(K,s,q)` | Tambara–Yamagami for $A=C_2$; optional braiding |
| [$\mathrm{SU}(3)_3$ subcategory](@ref su3-subcategory) | `TensorCategories.su_3_3_subcategory(K)` | Rank 4, multiplicity 2; not exported |
| [Tambara–Yamagami](@ref tambara-yamagami-data) | `tambara_yamagami(K,A,s,χ)` | Explicit bicharacter formulas |
| [Trivial fusion category](@ref trivial-fusion-data) | `trivial_fusion_category(K)` | Intended rank-one constructor; currently unavailable |
| [Vercleyen–Slingerland data](@ref vercleyen-slingerland-data) | `cat_fr_8122(n)`, `cat_fr_9143()` | Fusion rings and ancillary sources identified; the imports lack the basis metadata needed for an entrywise comparison |
| [Verlinde](@ref verlinde-models) | `verlinde_category(K,m,l,t)` | Default $l=t=1$ in Kauffman–Lins conventions; other parameters use package-specific normalizations |

## General constructions

Categories obtained from these models are documented with their respective
constructions: [Drinfeld centers](@ref center),
[products and scalar extension](../Interface/BasicConstructions.md),
[internal module categories](../Constructions/ModuleCategories.md), and
[group actions and equivariantization](../Constructions/GroupActions.md).
Their availability is governed by the operations supplied by the input model.
