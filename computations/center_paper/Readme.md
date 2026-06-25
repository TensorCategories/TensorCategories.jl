# Computations in our paper on computing the center

In this folder we have scripts, additional information, and tests regarding the computations involved in our paper:

Mäurer, F. & Thiel, U. (2024). Computing the center of a fusion category. https://arxiv.org/abs/2406.13438


## Center of AnyonWiki categories

With the scripts in this folder you can (re)compute the centers of the [multiplicity-free fusion categories](https://anyonwiki.github.io/pages/Lists/losmffc.html) from the [AnyonWiki](https://anyonwiki.github.io/). The AnyonWiki introduced a labeling system for these categories in the form $\mathrm{FC}^{a,b,c}_{d,e,f,g}$, see the [conventions](https://anyonwiki.github.io/pages/Lists/Conventions.html). The first entry $a$ is the rank of the category; the two last entries $f$ and $g$ correspond to different braidings and pivotal structures, respectively. 

The corresponding category can be loaded into TensorCategories.jl with the command

```julia
anyonwiki(a,b,c,d,e,f,g)
```

So, in TensorCategories.jl we use a single 7-tuple as key. With the command `anyonwiki_keys(n)` you can get a list of all the keys from the AnyonWiki of rank $\leq n$. Since different braidings and pivotal structures do not change the center, we can pick one entry among the 5-tuples given by the first 5 entries. In the script we do this deterministically as follows:

```julia
codes_all = sort!(
    collect(unique(c -> c[1:5], anyonwiki_keys(5)));
    by = c -> Tuple(c[1:5])
)
```

In this folder there are three scripts starting with `anyonwiki_center` going through all these categories. The core computations that are done in the scripts are computing the center (over a defining number field), find a splitting field of this category and extend to it, compute the F-symbols and save them (numerically in the numeric script), and do a randomized check on the pentagon axiom of the center:

```julia
C = anyonwiki(cat...)
Z = center(C)

local Z2
local Z3

simples(Z)
Z2 = split(Z)[1]
Z3 = six_j_category(Z2) #This involves computation of F-symbols

save_fusion_category(Z3, dir, filename)

randomized_pentagon_axiom(Z2, 3)
randomized_pentagon_axiom(Z3, 3)
```

You can start the scripts with

```bash
julia anyonwiki_center.jl --threads=N
```

and

```bash
julia anyonwiki_center_numerically.jl --threads=N
```

where N is the number of threads. This uses internal threading of TensorCategories.

> [!WARNING]
> If you interrupt the script with `Ctrl+C` there will still be worker processes. You can kill all Julia processes with `pkill julia`. 

There is also a more advanced script `anyonwiki_center_dist.jl` for distributed computation. It has several options:

* `--workers`: The number of separate processes (each working on one category). Notice that each worker is a Julia process that needs to load TensorCategories and OSCAR, so this will take some time. The default is 1.
* `--threads`: The number of threads for each worker. This uses the internal threading of TensorCategories. The default is 1.
* `--first`: The entry number in `codes_all` where to start the computation. The default is 1.
* `--last`: The entry in `codes_all` where to stop the computation. The default is the last entry.

The `--first` and `--last` option help to resume computations, potentially with different workers and threads.

So, an example call would be:

```bash
julia anyonwiki_centers_dist.jl --workers 4 --threads 4 --first 1 --last 40
```

The script saves timings in the table `output/anyonwiki_centers_dist/timings_all.tsv`. We have added our timings to `timings_all.tsv` in the main folder.

We have stored the centers also in our database. You can load it with the command:

```julia
anyonwiki_center(a,b,c,d,e,f,g)
```

## Further code from the paper

All code that was given in the paper is also listed in the file `paper_code_listings.jl`.