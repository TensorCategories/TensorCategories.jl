# [Structural data and data exchange](@id symbol-data)

A `SixJCategory` stores fusion multiplicities, associator blocks, a unit,
optional braiding and pivotal data, and sometimes a complex embedding. These
structures have different mathematical roles. In particular, F- and R-symbols
do not determine a pivotal or spherical structure.

The structural matrices are independent of the dictionary convention used for
export. Changing the `convention` keyword changes only the association between
dictionary keys and matrix entries.

## Inspecting structural data

In the index notation used throughout the documentation, `C.ass[a,b,c,d]` is
the associator block defined on the [conventions page](@ref f-conventions).
Some constructors compute these blocks lazily;
`TensorCategories.six_j_symbol(C,a,b,c,d)` obtains a block without assuming
that it has already been materialized. The analogous accessor for a braiding
block is `TensorCategories.r_symbol(C,a,b,d)`.

`P_symbols(C)` returns the components of the stored pivotal structure
$X\to X^{**}$. It does not return categorical dimensions. The functions
`twists(C)` and `smatrix(C)` depend on both the braided and pivotal data. The
S-matrix returned by `smatrix(C)` is unnormalized; `normalized_smatrix(C)`
also makes a square-root choice.

## Dictionaries with mathematical path indices

Use `convention=:bonderson` when dictionary keys should name the mathematical
fusion paths directly. In a multiplicity-free category,

```julia
F_symbols(C; convention=:bonderson)[[a,b,c,d,e,f]]
```

is $\mathcal F^{abc}_d[e,f]$ in Eqs. (1), (2), and (5) of the
[conventions page](@ref f-conventions). With fusion multiplicities, the key is

```julia
[a,b,c,d,e,mu,nu,f,rho,sigma]
```

and the value is

```math
A^{abc}_d[(e,\mu,\nu),(f,\rho,\sigma)].
```

Similarly,

```julia
R_symbols(C; convention=:bonderson)[[a,b,d,mu,nu]]
```

is $B^{ab}_d[\mu,\nu]$ in Eqs. (3) and (4). The multiplicity-free key is
`[a,b,d]`.

These functions return ordinary Julia dictionaries. A dictionary does not
carry its convention, so code that passes dictionaries independently of a
category must retain the convention separately.

## The historical column-major packing

The default is `convention=:column_major_packing`. This is the historical
dictionary format used by TensorCategories data files. It should be understood
as a serialization layout, rather than as another mathematical F-move.

For a multiplicity-free associator block $A=A^{abc}_d$, the key is
`[a,b,c,d,f,e]`. Let

```math
E=(e_1,\ldots,e_q),\qquad T=(f_1,\ldots,f_q)
```

be the increasing lists of admissible left and right intermediate simples.
If `D = F_symbols(C)`, then

```math
\mathsf D[a,b,c,d,f_s,e_r]=A_{s,r}.
\tag{8}
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
A_{r,s}=\mathsf D[k_{r+q(s-1)}].
\tag{9}
```

The R-symbol dictionary uses `[a,b,d]` in the multiplicity-free case. With
multiplicities it uses `[a,b,d,mu,nu]` and stores

```math
\mathsf R[a,b,d,\mu,\nu]=B^{ab}_d[\nu,\mu].
\tag{10}
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
[conventions page](@ref f-conventions).

## Exact symbol archives

`save_fusion_category(C,path,name; convention=...)` writes the coefficient
field, simple labels, fusion rules, unit, pivotal data, and the available F- and
R-symbol dictionaries. New archives record

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

Existing headerless TensorCategoriesDatabase archives are interpreted as
`:column_major_packing`. They do not need to be rewritten. For an untagged
external archive, `load_fusion_category(path; convention=:bonderson)` declares
the convention. If metadata are present, a conflicting keyword raises an
error.

The narrower helpers `save_F_symbols` and `save_R_symbols` write coefficient
vectors together with comments naming the field and convention. Including such
a file returns vectors of field coefficients, not a self-contained category;
use `save_fusion_category` when the archive should be loadable on its own.

## Native OSCAR serialization

`save(file,C)` stores the structural matrices directly, together with the
coefficient field, labels, fusion rules, unit, pivotal data, braiding, and
complex embedding when present. `load(file)` reconstructs the category:

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

## Numerical F- and R-symbol files

`numeric_F_symbols` and `numeric_R_symbols` evaluate an exact dictionary under
a chosen complex embedding. The `convention` keyword has exactly the same
meaning as for the exact functions:

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

The CSV files contain label indices followed by real and imaginary parts. A
nondefault convention is written in the header and read automatically.
Historical headerless CSV files default to `:column_major_packing`; pass
`convention=:bonderson` when loading a headerless external file in the direct
mathematical convention. F- and R-symbol files for one category must use the
same convention.

`load_numeric_fusion_category(...; check=true)` checks dictionary completeness
and block dimensions. Coherence and structural properties are separate
mathematical checks; see [Numerical computations](@ref numerical-computations).
All admissible entries, including zeros, are needed to reconstruct the fusion
paths.

Continue with [Numerical computations](@ref numerical-computations).
