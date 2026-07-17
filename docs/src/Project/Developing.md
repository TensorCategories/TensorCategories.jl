# Developing

Here is some basic information for developing.

## Juliaup

[Juliaup](https://github.com/JuliaLang/juliaup) is the official version manager for Julia. It allows multiple Julia versions to be installed side by side, provides a simple way to switch between them or select a specific version when starting Julia, and keeps installed versions up to date. Juliaup manages the Julia executables themselves, while packages and package environments continue to be managed separately through Julia's built-in package manager (Pkg).

Install Juliaup with:

```bash
curl -fsSL https://install.julialang.org | sh
```

Juliaup supports different "channels" of Julia versions. One can select a default channel, and then when entering `julia` the version from the default channel is started. After installation of Juliaup the "release" channel is selected as default. You can check this with:

```bash
juliaup status
```

To additionally install the lts channel do:

```bash
juliaup add lts
```

To run a specific version without changing the default:

```bash
julia +lts
```

Update the release version:

```
juliaup update release
```

If you need to install Julia into a different path, add the following lines to your `.basrhc` *before* the Juliaup installation:

```bash
export JULIAUP_DEPOT_PATH=/data/juliaup
export JULIA_DEPOT_PATH=/data/julia
```

## Environments

It is useful to have separate environments for development and releases.

```bash
mkdir -p ~/julia-envs/dev
mkdir -p ~/julia-envs/rel
```

We first clone both the TensorCategories.jl and OSCAR repositories:

```bash
cd ~
git clone git@github.com:TensorCategories/TensorCategories.jl.git
git clone git@github.com:oscar-system/Oscar.jl.git
```

Now we set up the development environment:

```bash
julia --project=~/julia-envs/dev
```

Then:

```julia
using Pkg
Pkg.develop(path=expanduser("~/Oscar.jl"))
Pkg.develop(path=expanduser("~/TensorCategories.jl"))
Pkg.add("Revise")
Pkg.instantiate()
```

Set up the release environment:

```bash
julia --project=~/julia-envs/rel
```

```julia
using Pkg
Pkg.add("Oscar")
Pkg.add("TensorCategories")
Pkg.instantiate()
```

It makes sense to add executable scripts for starting the respective environment. In, say, `~/bin` add the scripts `jldev` and `jlrel`:

```bash
#!/bin/bash

exec julia \
    --project="$HOME/julia-envs/dev" \
    "$@"
```

```bash
#!/bin/bash

exec julia \
    --project="$HOME/julia-envs/rel" \
    "$@"
```

Make them executable:

```
chmod +x jldev jlrel
```

In `.bashrc` add `~/bin` to `PATH`.

## Building documentation

Only once initialize the docs environment:

```bash
cd ~/TensorCategories.jl
julia --project=docs
```
 
```julia
using Pkg
Pkg.develop(path=pwd())
Pkg.instantiate()
```

Then build the docs with:

```bash
julia --project=docs docs/make.jl
```

When working on a remote machine, clone the built documentation to the local machine for viewing:

```bash
rsync -avz --delete remote:~/TensorCategories.jl/docs/build/ tc-docs
```

On the local machine it's best to serve the documentation via little web server:

```julia
python3 -m http.server 8000
```

Then open:

```
http://localhost:8000
```

For convenience, add a script `serv.sh` for starting the server:

```bash
python3 -m http.server 8000
```

Moreover, a script `pull.sh` to pull the documentation from the server:

```bash
rsync -avz --delete --exclude='/pull.sh' --exclude='/serv.sh' remote:~/TensorCategories.jl/docs/build/ .
```


## Sysimage

One can speed up startup time and first-call time in Julia by creating a "sysimage" with [PackageCompiler](https://julialang.github.io/PackageCompiler.jl/dev/). This is especially useful for distributed computing. Here is how this works.

It is probably useful to use the release environment we created above. Then:

```julia-repl
julia> using Pkg

julia> Pkg.add("PackageCompiler")

julia> using PackageCompiler, TensorCategories

julia> create_sysimage(
           ["TensorCategories"],
           sysimage_path = "~/julia-sysimages/TC-sysimage-0.6.0.so",
           precompile_execution_file = joinpath(pkgdir(TensorCategories), "computations", "center_paper", "paper_code_listings.jl"),
       )
```

The `precompile_execution_file` file is a file with instructions that are "representative" to what you want to run and which are then precompiled; the example file covers most of the main functions of TensorCategories.jl. You can then use this sysimage with:

```bash
jlrel --sysimage ~/julia-sysimages/TC-sysimage-0.6.0.so
```

It makes sense to create an executable script to start the sysimage. Create `~/bin/tc`:

```bash
#!/bin/bash

exec julia \
    --project="$HOME/julia-envs/rel" \
    --sysimage="$HOME/julia-sysimages/TC-sysimage-0.6.0.so" \
    "$@"
```

Make it executable:

```
chmod +x tc
```

In `.bashrc` add `~/bin` to `PATH`.


## Cluster computation

For computations on a cluster, one should use sysimages as explained above to reduce compilation time. But if the cluster has inhomogeneous hardware, things get a bit more complicated. In `create_sysimage` one can specify CPU targets with the `cpu_target` option. By default, this is `native` ([reference](https://julialang.github.io/PackageCompiler.jl/stable/refs.html)), meaning it is optimized for the machine on which you do the compilation. If this does not match the hardware on the cluster, you need to specify the correct CPU targets. You can list the available targets with `julia -C help`. See also [here](https://docs.julialang.org/en/v1/devdocs/sysimg/#sysimg-multi-versioning) for more information.

So, for example, to create a sysimage specifically for AMD Zen 2 CPUs (e.g. AMD EPYC 7262) use:

```julia-repl
julia> create_sysimage(
           ["TensorCategories"],
           sysimage_path = "~/julia-sysimages/TC-sysimage-0.6.0-znver2.so",
           precompile_execution_file = joinpath(pkgdir(TensorCategories), "computations", "center_paper", "paper_code_listings.jl"),
           cpu_target = "znver2"
       )
```

Then create the executable script `~/bin/tc-znver2`:

```bash
#!/bin/bash

exec julia \
    --project="$HOME/julia-envs/rel" \
    --sysimage="$HOME/julia-sysimages/TC-sysimage-0.6.0-znver2.so" \
    "$@"
```

Check out the [SLURM Quick Start User Guide](https://slurm.schedmd.com/quickstart.html) and the [SLURM Reference Sheet](https://docs.nesi.org.nz/Getting_Started/Cheat_Sheets/Slurm-Reference_Sheet). You can find an [example SLURM script](https://github.com/TensorCategories/TensorCategories.jl/blob/master/computations/center_paper/anyonwiki_db_check.slurm) in the repository.