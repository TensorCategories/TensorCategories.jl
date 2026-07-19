# Developing

Here is some basic information for developing and advanced usage.


## Julia environment

We will set up a versatile Julia environment that allows working with different Julia versions, project environments (development and release), and that can also be used on High Performance Clusters with inhomogeneous hardware. The latter is challenging with Julia due to, e.g., precompile caches that should not be mixed across different CPU types. We got the key ideas from the [Julia on HPC Clusters](https://juliahpc.github.io/) documentation. 

We will store everything into a folder we call here `$JULIA_DIR`. For a local installation you can simply use `~/.julia`. For a cluster installation you should follow [these guidelines](https://juliahpc.github.io/user_gettingstarted/#place_the_julia_depot_on_the_parallel_file_system) for choosing a location.


### Juliaup

[Juliaup](https://github.com/JuliaLang/juliaup) is the official version manager for Julia. It allows multiple Julia versions to be installed side by side, provides a simple way to switch between them or select a specific version when starting Julia, and keeps installed versions up to date. Juliaup manages the Julia executables themselves, while packages and package environments continue to be managed separately through Julia's built-in package manager (Pkg).

```bash
mkdir -p $JULIA_DIR/julia-depot
mkdir -p $JULIA_DIR/juliaup-depot
```

In `.basrc` put:

```bash
export JULIA_DEPOT_PATH="$JULIA_DIR/julia-depot"
export JULIAUP_DEPOT_PATH="$JULIA_DIR/juliaup-depot"
```

Then source this with:

```bash
source ~/.bashrc
```

Now, install Juliaup with:

```bash
curl -fsSL https://install.julialang.org | sh -s -- --path "$JULIA_DIR/juliaup"
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

```bash
juliaup update release
```

### CPU Target (HPC)

This section is only relevant for HPC environments with inhomogeneous hardware. To avoid precompilation cache conflicts across different CPU architectures you should always set the [`JULIA_CPU_TARGET`](https://docs.julialang.org/en/v1.10-dev/manual/environment-variables/#JULIA_CPU_TARGET) environment variable to a value that is generic enough to cover all the types of CPUs that you're targeting ([reference](https://juliahpc.github.io/user_faq/#how_can_i_force_julia_to_compile_code_for_a_heterogeneous_cluster)). You should also do this before adding any packages.

For a SLURM cluster you can log into a node from a partition `PART` and output the Julia CPU target name as follows:

```bash
srun --partition=PART --nodes=1 --ntasks=1 --cpus-per-task=1 --time=00:00:30 --mem=8G julia -e 'println(Sys.CPU_NAME)'
```

For the [RPTU HPC 'Elwetritsch'](https://hpc.rz.rptu.de/elwetritsch/hardware.shtml) we get the following:

| partition                | target         |
| -----------              | --------       |
| haswell-256, haswell-64s | haswell        |
| skylake-96, skylake-384  | skylake-avx512 |
| epyc-256                 | znver2         |
| epyc-768                 | znver5         |

So, ignoring the older haswells, an appropriate choice here would be:

```bash
export JULIA_CPU_TARGET="generic;skylake-avx512,clone_all;znver2,clone_all"
```


### Project Environments

It is useful to have separate project environments for releases and development.

First, we create the release environment.

```bash
mkdir -p "$JULIA_DIR/projects/rel"
julia --project="$JULIA_DIR/projects/rel"
```

```julia
using Pkg
Pkg.add("Oscar")
Pkg.add("TensorCategories")
Pkg.instantiate()
```

Add the executable script `~/bin/jlrel` to start the release environment:

```bash
#!/bin/bash

exec julia \
    --project="$JULIA_DIR/projects/rel" \
    "$@"
```

Make the script executable with `chmod +x jlrel` and add `~/bin` to `PATH` in `.bashrc`.

Now, we set up the development environment. Clone both the TensorCategories.jl and OSCAR repositories:

```bash
cd /data
git clone git@github.com:TensorCategories/TensorCategories.jl.git
git clone git@github.com:oscar-system/Oscar.jl.git
```

```bash
mkdir -p "$JULIA_DIR/projects/dev"
julia --project="$JULIA_DIR/projects/dev"
```

```julia
using Pkg
Pkg.develop(path=expanduser("/data/Oscar.jl"))
Pkg.develop(path=expanduser("/data/TensorCategories.jl"))
Pkg.add("Revise")
Pkg.instantiate()
```

Executable script `~/bin/jldev`:

```bash
#!/bin/bash

exec julia \
    --project="$JULIA_DIR/projects/dev"
    "$@"
```

### Sysimage

One can speed up startup time and first-call time in Julia by creating a "sysimage" with [PackageCompiler](https://julialang.github.io/PackageCompiler.jl/dev/). This is especially useful (also essential) for distributed computing, not just on an HPC. Here is how this works.

First, create a directory for sysimages:

```bash
mkdir -p "$JULIA_DIR/sysimages"
```

We use the release environment we created above. First install PackageCompiler:

```julia-repl
julia> using Pkg

julia> Pkg.add("PackageCompiler")
```

Now, we create the sysimage:

```julia-repl
julia> using PackageCompiler, TensorCategories, Oscar

julia> create_sysimage(
           ["TensorCategories", "Oscar"],
           sysimage_path = "$JULIA_DIR/sysimages/TC-sysimage-0.6.0.so",
           precompile_execution_file = joinpath(pkgdir(TensorCategories), "computations", "center_paper", "paper_code_listings.jl"),
           cpu_target = "$JULIA_CPU_TARGET"
       )
```

Here, `cpu_target` is only necessary for an HPC environment, and you should set it to the same value as `JULIA_CPU_TARGET` from above (this is not inherited). 

The `precompile_execution_file` file is a file with instructions that are "representative" to what you want to run and which are then precompiled; the example file covers most of the main functions of TensorCategories.jl. 

The compilation takes around 1 hour and the sysimage file size is about 3GB. On an HPC you should compile on a node. Request a node with:

```bash
salloc --time=03:00:00 --partition=PART --mem=32G
```

Then run the above compilation.

You can use the sysimage with the `--sysimage` command line argument. We do this with an executable script `~/bin/tc`:

```bash
#!/bin/bash

exec julia \
    --project="$JULIA_DIR/projects/rel" \
    --sysimage="$JULIA_DIR/sysimages/TC-sysimage-0.6.0.so" \
    "$@"
```


## Building documentation

Initialize the docs environment:

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


