# [Structural data and data exchange](@id symbol-data)

A `SixJCategory` stores fusion multiplicities, associator blocks, a unit,
optional braiding and pivotal data, and sometimes a complex embedding. These
structures have different mathematical roles. In particular, $F$- and $R$-symbols
do not determine a pivotal or spherical structure.

The structural matrices are independent of the dictionary convention used for
export. Changing the `convention` keyword changes only the association between
dictionary keys and matrix entries.

Three mechanisms serve different purposes:

| Mechanism | Stored data | Intended use |
|:---|:---|:---|
| `save_fusion_category` and `load_fusion_category` | A self-contained symbol archive over $\mathbb Q$ or an absolute simple number field defined over $\mathbb Q$ | Exact TensorCategories fusion data and database-compatible archives |
| OSCAR `save` and `load` | The category and its structural matrices directly | Native persistence without translating matrices to $F$- and $R$-symbol dictionaries |
| `numeric_symbols_to_csv` and `load_numeric_fusion_category` | Decimal approximations to $F$-symbols and, optionally, $R$-symbols | Numerical coefficient interchange |

The comma-separated values (CSV) format is not a lossless serialization of a
numerical category. It does not store pivotal data or ball radii; these
distinctions are detailed below.

## Inspecting structural data

In the index notation used throughout the documentation, `C.ass[a,b,c,d]` is
the associator block defined in the [conventions section](@ref f-conventions).
Some constructors compute these blocks lazily;
`TensorCategories.six_j_symbol(C,a,b,c,d)` obtains a block without assuming
that it has already been materialized. The analogous accessor for a braiding
block is `TensorCategories.r_symbol(C,a,b,d)`.

`P_symbols(C)` returns the components of the stored pivotal structure
$X\to X^{**}$. It does not return categorical dimensions. The functions
`twists(C)` and `smatrix(C)` depend on both the braided and pivotal data. The
$S$-matrix returned by `smatrix(C)` is unnormalized; `normalized_smatrix(C)`
also makes a square-root choice.

## Dictionaries with mathematical path indices

Use `convention=:bonderson` when dictionary keys should name the mathematical
fusion paths directly. In a multiplicity-free category,

```julia
F_symbols(C; convention=:bonderson)[[a,b,c,d,e,f]]
```

is the coefficient $\mathcal F^{abc}_d[e,f]$ defined on the
[conventions section](@ref f-conventions). With fusion multiplicities, the key is

```julia
[a,b,c,d,e,mu,nu,f,rho,sigma]
```

and the value is

```math
\label{eq:bonderson-F-dictionary-entry}
A^{abc}_d[(e,\mu,\nu),(f,\rho,\sigma)].
```

Similarly,

```julia
R_symbols(C; convention=:bonderson)[[a,b,d,mu,nu]]
```

is the coefficient $B^{ab}_d[\mu,\nu]$ of the braiding map defined there. The
multiplicity-free key is `[a,b,d]`.

These functions return ordinary Julia dictionaries. A dictionary does not
carry its convention, so code that passes dictionaries independently of a
category must retain the convention separately.

## The default column-major packing

The default is `convention=:column_major_packing`. This is the dictionary
format used by TensorCategories data files. It is a serialization
layout, not another mathematical $F$-move.

For a multiplicity-free associator block $A=A^{abc}_d$, the key is
`[a,b,c,d,f,e]`. Let

```math
\label{eq:admissible-intermediate-lists}
E=(e_1,\ldots,e_q),\qquad T=(f_1,\ldots,f_q)
```

be the increasing lists of admissible left and right intermediate simples.
If `D = F_symbols(C)`, then

```math
\label{eq:column-major-F-packing}
\mathsf D[a,b,c,d,f_s,e_r]=A_{s,r}.
```

The suffix $(f_s,e_r)$ therefore does not directly name the row and column of
$A$. Swapping the final two key positions is not a general conversion because
the admissible lists $E$ and $T$ need not coincide.

With fusion multiplicities, the key is

```julia
[a,b,c,d,f,sigma,rho,e,mu,nu]
```

and the exporter loops in the order
$(e,f,\nu,\mu,\rho,\sigma)$ while consuming the entries of $A$ in Julia's
column-major order. Here

```math
\label{eq:fusion-multiplicity-index-ranges}
1\leq\mu\leq N_{ab}^{e},\quad
1\leq\nu\leq N_{ec}^{d},\quad
1\leq\rho\leq N_{bc}^{f},\quad
1\leq\sigma\leq N_{af}^{d}.
```

The following rule reconstructs any block without interpreting the suffix as a
fusion path. Fix $a,b,c,d$, and sort the keys in that block as follows:

| Key length | Julia sorting key |
|:---|:---|
| 6 | `key[[6,5]]` |
| 10 | `key[[8,5,10,9,7,6]]` |

Write the resulting list as $k_1,\ldots,k_{q^2}$, where $q$ is the common
number of left and right paths. Then

```math
\label{eq:column-major-F-reconstruction}
A_{r,s}=\mathsf D[k_{r+q(s-1)}].
```

The $R$-symbol dictionary uses `[a,b,d]` in the multiplicity-free case. With
multiplicities it uses `[a,b,d,mu,nu]` and stores

```math
\label{eq:column-major-R-packing}
\mathsf R[a,b,d,\mu,\nu]=B^{ab}_d[\nu,\mu].
```

Thus the two multiplicity indices are transposed relative to the direct
mathematical convention. This is not an inverse braiding or a change of gauge.

The two layouts can be checked on an asymmetric Fibonacci associator block:

```@example packing
using TensorCategories, Oscar
C = fibonacci_category()
A = C.ass[2,2,2,2]
D = F_symbols(C)
@assert D[[2,2,2,2,1,2]] == A[1,2]
@assert D[[2,2,2,2,1,2]] != A[2,1]
@assert TensorCategories.dict_to_associator(D) == C.ass
nothing # hide
```

For pentagon and hexagon formulas, use the direct coefficients returned by
`convention=:bonderson`; the equations are stated on the
[conventions section](@ref f-conventions).

## Exact symbol archives

`save_fusion_category(C,path,name; convention=...)` writes the coefficient
field, simple labels, unit, pivotal data, the available $F$- and $R$-symbol
dictionaries, and a stored complex embedding when one is present. The loader
decodes the associator blocks and reconstructs the fusion multiplicities from
their dimensions together with the stored tensor unit. The archive convention
defaults to `:column_major_packing`.
The category must have a name, a specified tensor unit, and pivotal data. The
parent directory `path` must exist, and the target directory
`joinpath(path,name)` must not already exist. The current field format supports
$\mathbb Q$ and absolute simple number fields
represented by a defining polynomial over $\mathbb Q$; it is not a general
archive format for relative number fields, `QQBarField`, or fields of positive
characteristic. Use native OSCAR serialization for those coefficient fields.
New symbol archives record

```julia
symbol_format_version = 1
symbol_convention = :bonderson # or :column_major_packing
```

and `load_fusion_category` uses this metadata automatically:

```@example save_symbols_category
using TensorCategories, Oscar
C = anyonwiki(3,1,0,1,1,1,1)
mktempdir() do dir
    save_fusion_category(C,dir,"ising"; convention=:bonderson)
    D = load_fusion_category(joinpath(dir,"ising"))
    @assert multiplication_table(D) == multiplication_table(C)
    @assert pentagon_axiom(D) && hexagon_axiom(D)
end
nothing # hide
```

Existing TensorCategoriesDatabase archives without convention metadata are
interpreted as `:column_major_packing`. They do not need to be rewritten. For
an untagged external archive,
`load_fusion_category(path; convention=:bonderson)` declares the convention.
If metadata are present, a conflicting keyword raises an error.

Loading reconstructs the stored arrays but does not certify the pentagon,
hexagon, or pivotal axioms. Apply the corresponding predicates when an archive
is not already a trusted package artifact.

The narrower helpers `TensorCategories.save_F_symbols` and
`TensorCategories.save_R_symbols` write coefficient vectors together with
comments naming the field and convention. Calling `include` on such a file
returns vectors of field coefficients, not a self-contained category; use
`save_fusion_category` when the archive should be loadable on its own. Both
helpers default to `convention=:column_major_packing`. Their field-description
format likewise assumes $\mathbb Q$ or an absolute simple number field over
$\mathbb Q$.

The lower-level `TensorCategories.save_symbols`,
`TensorCategories.load_F_symbols`, and `TensorCategories.load_R_symbols`
operate on prearranged dictionaries or block files. They do not provide the
self-contained metadata protocol above, and the readers do not infer a layout
from file comments. Pass the same `convention` explicitly when writing and
reading such data. The writer's optional positional `chunk` argument defaults
to zero; every one of these low-level functions defaults to
`convention=:column_major_packing`.

## Native OSCAR serialization

`save(file,C)` stores the structural matrices directly, together with the
coefficient field, labels, and fusion rules, as well as any unit, pivotal data,
braiding, and complex embedding that are present. `load(file)` reconstructs the
category:

```@example savecategory
using TensorCategories, Oscar
C = ising_category()
mktempdir() do dir
    file = joinpath(dir,"ising.json")
    save(file,C)
    D = load(file)
    @assert D.ass == C.ass
    @assert multiplication_table(D) == multiplication_table(C)
end
nothing # hide
```

The loaded category is a new parent. Its objects have coordinates relative to
that parent, even when all stored structural matrices agree with those of $C$.
Native loading also reconstructs the stored data without rerunning their
coherence checks.

## Numerical $F$- and $R$-symbol files

`numeric_F_symbols` and `numeric_R_symbols` evaluate the exact symbols of a
category under a chosen or stored complex embedding. Their default precisions
are respectively $128$ and $2048$ bits; pass `precision=...` explicitly when
the two dictionaries will be used together. The `convention` keyword defaults
to `:column_major_packing` and has exactly the same meaning as for the exact
functions. The explicit embedding overload accepts an OSCAR
`AbsSimpleNumFieldEmbedding`; apart from the implemented $\mathbb Q$ coercion,
the category coefficients must belong to that embedding's domain number field:

```@example numeric_symbols_category
using TensorCategories, Oscar
C = anyonwiki(3,1,0,1,1,1,1)
F = numeric_F_symbols(C; convention=:bonderson,precision=128)
R = numeric_R_symbols(C; convention=:bonderson,precision=128)
mktempdir() do dir
    f = joinpath(dir,"F.csv")
    r = joinpath(dir,"R.csv")
    numeric_symbols_to_csv(f,F; convention=:bonderson)
    numeric_symbols_to_csv(r,R; convention=:bonderson)
    D = load_numeric_fusion_category(f,r,AcbField(64); check=true)
    @assert multiplication_table(D) == multiplication_table(C)
end
nothing # hide
```

`numeric_P_symbols` evaluates `P_symbols(C)` under an explicit or stored
embedding and defaults to $2048$ bits. This overload requires the pivotal
coefficients to belong to the number field that is the domain of the
embedding; unlike the corresponding $F$- and $R$-symbol functions, it does not
coerce rational coefficients into that field. A $\mathbb Q$-based category
with the usual rational-number-field embedding is therefore outside its
supported input.
Pivotal dictionaries have keys `[i]` and no `convention` keyword because no
matrix-entry packing is involved.

The CSV files contain label indices followed by real and imaginary parts. A
nondefault convention is written in the header and read automatically.
The default `:column_major_packing` output is headerless for compatibility and
therefore contains no explicit convention metadata. Pass
`convention=:bonderson` when loading a headerless external file in the direct
mathematical convention. $F$- and $R$-symbol files for one category must use the
same convention.

The files contain integer indices, but not a category name, printed
simple-object names, or a complex embedding. The general loader consequently
uses the skeletal initializer's labels `X1`, `X2`, and so on; a specialized
wrapper may replace them after loading.

Both `numeric_symbols_from_csv` and `load_numeric_fusion_category` use
`AcbField(64)` when the field argument is omitted. Their `delimiter` defaults
to `", "`, and their `convention` defaults to `nothing`, meaning “use the
header, or use `:column_major_packing` when there is no header.” The loader also
defaults to `transpose=false`, `unit=nothing`, `pivotal=nothing`, and
`check=false`. `numeric_symbols_from_csv` returns only an ordinary dictionary;
it does not attach the detected convention to that value.

The writer `numeric_symbols_to_csv` also defaults to the delimiter `", "`; its
`convention` defaults to `:column_major_packing` because it must declare the
encoding of the dictionary supplied to it.

The `convention` keyword of `numeric_symbols_to_csv` declares the encoding of
the dictionary it receives; it does not convert that dictionary. Obtain the
dictionary from `numeric_F_symbols` or `numeric_R_symbols` with the same keyword,
as in the example above. Mislabeling a dictionary changes the interpretation of
its keys when it is loaded.

The numerical loader also accepts the compatibility keyword `transpose=true`, which
transposes every structural matrix after the dictionary has been decoded. This
is a separate mathematical operation, not a dictionary convention. Leave it at
the default `false` unless the external matrices are known to require that
post-decoding transpose.

CSV output stores decimal approximations to the real and imaginary parts. It
does not store the radii of the input complex balls, and a real or imaginary
component whose enclosure overlaps zero is written as `0.0`. Loading the file
into an `AcbField` creates new ball values from those decimals, but does not
recover the original enclosures. Do not use a CSV round trip to preserve a
rigorous link to the original exact or ball-valued data.

Files containing $F$- and $R$-symbols also do not determine a pivotal or
spherical structure.
`load_numeric_fusion_category` reconstructs the fusion rules, unit, associator,
and optional braiding. The fusion paths must determine a unique simple tensor
unit. The optional `unit` value is a simple-object index and must agree with
that reconstructed unit. Supply one nonzero component per simple through
`pivotal=...` when pivotal data are part of the intended input; otherwise the
default coefficients $P_i=1$ remain in place and should be checked before they
are used as a pivotal structure.

`load_numeric_fusion_category(...; check=true)` checks dictionary completeness,
block dimensions, and normalization of the stored associators involving the
tensor unit. Coherence and structural properties are separate mathematical
checks; see
[Numerical fusion categories](@ref numerical-fusion-categories).
All admissible entries, including zeros, are needed to reconstruct the fusion
paths.

Continue with [Drinfeld centers and half-braidings](@ref center), where the
general categorical construction is applied before its skeletal $F$- and
$R$-symbols are extracted. The [category catalogue](@ref category-catalogue) is
a later reference section for supplied models and datasets.
