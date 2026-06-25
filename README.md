# TensorCategories.jl

<div align="center">
<a href="https://julialang.org/" target="_blank">
<img src="docs/src/assets/logo/logo-notext.svg" alt="Julia Logo" width="100"></img>
</a>
</div>

<br>

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://tensorcategories.github.io/TensorCategories.jl/stable/) [![](https://img.shields.io/badge/docs-dev-blue.svg)](https://tensorcategories.github.io/TensorCategories.jl/dev/) [![](https://github.com/TensorCategories/TensorCategories.jl/actions/workflows/runtests.yml/badge.svg)](https://github.com/TensorCategories/TensorCategories.jl/actions/workflows/runtests.yml) [![](https://codecov.io/gh/TensorCategories/TensorCategories.jl/branch/master/graph/badge.svg?token=axGHAcozx5)](https://codecov.io/gh/TensorCategories/TensorCategories.jl) [![Citation](https://img.shields.io/badge/Citation-arXiv%3A2406.13438-B31B1B?logo=arxiv)](https://arxiv.org/abs/2406.13438)

TensorCategories.jl is an open-source software package for computations with tensor categories, especially fusion categories. Built on the [Julia](https://julialang.org/) programming language and the [OSCAR](https://www.oscar-system.org/) computer algebra system, it is designed to closely follow the standard mathematical framework for tensor categories as presented, for example, in [Tensor Categories](https://math.mit.edu/~etingof/egnobookfinal.pdf) by Etingof, Gelaki, Nikshych, and Ostrik: objects, morphisms, tensor products, associators, and other categorical structures are represented as such, while concrete combinatorial descriptions, such as F-symbols, are also supported. The package supports exact symbolic computations over arbitrary base fields, including number fields and fields of positive characteristic, as well as numerical computations intended for applications in mathematical physics such as anyon models and conformal field theory.

Current highlights include:

* A general, extensible framework for implementing categories together with additional structures, such as additive, linear, abelian, monoidal, tensor, and fusion structures.

* Support for skeletal fusion categories described by F-symbols, including exact and numerical access to F-symbols, R-symbols, pivotal data, and related invariants.

* Integration of fusion-category data from the [AnyonWiki](https://anyonwiki.github.io/), providing access to a large collection of fusion categories.

* A generic algorithm for computing Drinfeld centers of fusion categories, producing explicit central objects with half-braidings rather than only abstract equivalence classes; see [arXiv:2406.13438](https://arxiv.org/abs/2406.13438).

* Computation of the Drinfeld centers, including F-symbols and R-symbols, for all 279 multiplicity-free fusion categories up to rank 5; the results are stored in our [TensorCategoriesDatabase](https://github.com/TensorCategories/TensorCategoriesDatabase). These centers yield new high-rank and not multiplicity-free examples of modular categories, e.g. rank 21 and multiplicity 2.

* Explicit computation of F-symbols, R-symbols, and pivotal coefficients for the Drinfeld center of the Haagerup subfactor; see [arXiv:2601.20012](https://arxiv.org/abs/2601.20012).


## Showcase

Here is a showcase example computing the center $\mathcal{Z}(\mathcal{C})$ of the Ising fusion category $\mathcal{C}$ over the field $\mathbb{Q}(\sqrt{2})$. The computation shows that $\mathcal{Z}(\mathcal{C})$ is *not* split over $\mathbb{Q}(\sqrt{2})$, i.e. some simple objects will decompose after scalar extension to $\mathbb{C}$. We then compute the multiplication table of the fusion ring and the S-matrix of this non-split modular category.

```julia-repl
julia> using TensorCategories, Oscar

julia> K,r2 = quadratic_field(2)
(Real quadratic field defined by x^2 - 2, sqrt(2))

julia> C = ising_category(K,r2)

julia> simples(C)
3-element Vector{SixJObject}:
 𝟙
 χ
 X

julia> Z = center(C)
Drinfeld center of Ising fusion category

julia> S  = simples(Z)
5-element Vector{CenterObject}:
 Central object: 𝟙
 Central object: 𝟙
 Central object: 𝟙 ⊕ χ
 Central object: 2⋅χ
 Central object: 4⋅X

julia> End(S[4])
Vector space of dimension 2 over Real quadratic field defined by x^2 - 2.

julia> print_multiplication_table(S, ["X$i" for i in eachindex(S)])
5×5 Matrix{String}:
 "X1"  "X2"  "X3"            "X4"           "X5"
 "X2"  "X1"  "X3"            "X4"           "X5"
 "X3"  "X3"  "X1 ⊕ X2 ⊕ X4"  "2⋅X3"         "2⋅X5"
 "X4"  "X4"  "2⋅X3"          "2⋅X1 ⊕ 2⋅X2"  "2⋅X5"
 "X5"  "X5"  "2⋅X5"          "2⋅X5"         "4⋅X1 ⊕ 4⋅X2 ⊕ 8⋅X3 ⊕ 4⋅X4"

julia> smatrix(Z)
[        1            1    2    2    4*sqrt(2)]
[        1            1    2    2   -4*sqrt(2)]
[        2            2    0   -4            0]
[        2            2   -4    4            0]
[4*sqrt(2)   -4*sqrt(2)    0    0            0]
```

## Installation

You need to have [Julia](https://julialang.org/downloads/) installed. To install TensorCategories.jl do the following:

```julia-repl
julia> import Pkg
julia> Pkg.add("TensorCategories")
```

This will automatically install all dependencies like [OSCAR](https://www.oscar-system.org/). 


## How to cite

If TensorCategories.jl contributes to your research, please cite the paper that introduced the software:

```bibtex
@misc{MaeurerThiel2024ComputingCenter,
  author        = {M{\"a}urer, Fabian and Thiel, Ulrich},
  title         = {Computing the center of a fusion category},
  year          = {2024},
  eprint        = {2406.13438},
  archivePrefix = {arXiv},
  primaryClass  = {math.RT},
  doi           = {10.48550/arXiv.2406.13438}
}
```

The software itself is archived on Zenodo and can be cited as follows:

```bibtex
@software{Maeurer2026TensorCategories,
  author    = {M{\"a}urer, Fabian},
  title     = {{TensorCategories.jl}},
  year      = {2026},
  publisher = {Zenodo},
  doi       = {10.5281/zenodo.18760250},
  url       = {https://doi.org/10.5281/zenodo.18760250}
}
```

## License

The TensorCategories.jl package is licensed under the GNU General Public License v3.0 or later. 

Copyright (c) 2021 Fabian Mäurer and contributors. 

See [`LICENSE`](LICENSE) for the full license text.
See [`COPYRIGHT`](COPYRIGHT) for copyright information.

## Acknowledgements

TensorCategories.jl was initiated by [**Ulrich Thiel**](https://agag-thiel.math.rptu.de/math/) (RPTU University Kaiserslautern-Landau) within his project A20 "Towards unipotent character sheaves associated to Coxeter groups" (2020–2024) of the SFB-TRR 195 ["Symbolic Tools in Mathematics and their Application"](https://www.computeralgebra.de/sfb/), funded by the German Research Foundation (DFG). The package was created and developed by **Fabian Mäurer** as part of his Master's and PhD work under Thiel's supervision (2021–2026). Its development is currently supported by Thiel's project A20 "Categorical representation theory" (2024–2028) in the SFB-TRR 195. Additional support is provided by the Forschungsinitiative "SymbTools" of the state of Rheinland-Pfalz, in which Thiel is one of the project leaders.

[**Gert Vercleyen**](https://gert-vercleyen.github.io/) contributed to the  integration of the data from his [AnyonWiki](https://anyonwiki.github.io/).

