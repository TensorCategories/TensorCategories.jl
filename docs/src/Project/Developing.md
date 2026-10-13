# Developing

This page explains how to install Julia, set up a dedicated development environment named `tc`, and build and serve the manual. The shell commands use Bash on a Unix-like system.


## Julia environment

We will set up Julia with support for different Julia versions and a dedicated TensorCategories development environment. This setup can also be used on High Performance Clusters with inhomogeneous hardware. The latter is challenging with Julia due to, e.g., precompile caches that should not be mixed across different CPU types. We got the key ideas from the [Julia on HPC Clusters](https://juliahpc.github.io/) documentation.

We will store everything in a directory called `$JULIA_DIR`. For a local installation, use `~/.julia`. For a cluster installation, follow [these guidelines](https://juliahpc.github.io/user_gettingstarted/#place_the_julia_depot_on_the_parallel_file_system) to choose a location. Put the following in `~/.bashrc`, replacing the first path if needed:

```bash
export JULIA_DIR="$HOME/.julia"
export JULIA_DEPOT_PATH="$JULIA_DIR/julia-depot"
export JULIAUP_DEPOT_PATH="$JULIA_DIR/juliaup-depot"
```

Load these settings before continuing:

```bash
source ~/.bashrc
```


### Juliaup

[Juliaup](https://github.com/JuliaLang/juliaup) is the official version manager for Julia. It allows multiple Julia versions to be installed side by side, provides a simple way to switch between them or select a specific version when starting Julia, and keeps installed versions up to date. Juliaup manages the Julia executables themselves, while packages and package environments continue to be managed separately through Julia's built-in package manager (Pkg).

```bash
mkdir -p "$JULIA_DEPOT_PATH" "$JULIAUP_DEPOT_PATH"
```

Now, install Juliaup with:

```bash
curl -fsSL https://install.julialang.org | sh -s -- --path "$JULIA_DIR/juliaup"
```

Reload `~/.bashrc` after installation so the Juliaup executables are on `PATH`:

```bash
source ~/.bashrc
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

This section is only relevant for HPC environments with inhomogeneous hardware. To avoid precompilation cache conflicts across different CPU architectures you should always set the [`JULIA_CPU_TARGET`](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_CPU_TARGET) environment variable to a value that is generic enough to cover all the types of CPUs that you're targeting ([reference](https://juliahpc.github.io/user_faq/#how_can_i_force_julia_to_compile_code_for_a_heterogeneous_cluster)). You should also do this before adding any packages.

For a SLURM cluster you can log into a node from a partition `PART` and output the Julia CPU target name as follows:

```bash
srun --partition=PART --nodes=1 --ntasks=1 --cpus-per-task=1 --time=00:00:30 --mem=8G \
julia -e 'println(Sys.CPU_NAME)'
```

For the [RPTU HPC 'Elwetritsch'](https://hpc.rz.rptu.de/elwetritsch/hardware.shtml) an example of partition and CPU target names is:

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


### Development environment

Registered releases can be installed in Julia's default environment by starting
`julia` and running `using Pkg; Pkg.add("TensorCategories")`.

For development, create an environment named `tc` dedicated to TensorCategories.
Clone the repository into `~/TensorCategories.jl`:

```bash
cd "$HOME"
git clone https://github.com/TensorCategories/TensorCategories.jl.git
mkdir -p "$JULIA_DIR/projects/tc"
julia --project="$JULIA_DIR/projects/tc" --startup-file=no
```

If you already have a checkout, use its absolute path in the following call:

```julia
using Pkg
Pkg.develop(path=expanduser("~/TensorCategories.jl"))
Pkg.instantiate()
```

`TensorCategories` is the only direct package dependency of this environment.
OSCAR and the other dependencies are installed automatically. `Pkg.develop`
loads TensorCategories from the checkout, so edits to that checkout are used
when starting a new Julia process.

Create `$JULIA_DIR/projects/tc/startup.jl` with this content:

```julia
using TensorCategories
```

Create `~/bin` with `mkdir -p "$HOME/bin"`, then save the following launcher
as `~/bin/tc`:

```bash
#!/usr/bin/env bash
exec julia \
    --project="$JULIA_DIR/projects/tc" \
    -L "$JULIA_DIR/projects/tc/startup.jl" \
    "$@"
```

Make it executable:

```bash
chmod +x "$HOME/bin/tc"
```

Add `export PATH="$HOME/bin:$PATH"` to `~/.bashrc` and reload it with
`source ~/.bashrc`.

Now `tc` starts Julia in the dedicated environment and loads TensorCategories.
The `-L` option explicitly loads this environment's startup file; Julia does
not automatically load a `startup.jl` from the project directory. The `"$@"`
passes all arguments through, so the same launcher runs scripts or commands:

```bash
tc -e 'println(pkgdir(TensorCategories))'
```

Restart Julia after editing methods or types to load the changes.

### Sysimage

One can speed up startup time and first-call time in Julia by creating a "sysimage" with [PackageCompiler](https://julialang.github.io/PackageCompiler.jl/dev/). This can also be useful for distributed computing, including on an HPC cluster. Here is how this works.

First, create a directory for sysimages:

```bash
mkdir -p "$JULIA_DIR/sysimages"
```

Use Julia's default environment for the sysimage, keeping the development
environment dedicated to TensorCategories. Start it with:

```bash
julia
```

Then install the registered TensorCategories release and PackageCompiler:

```julia-repl
julia> using Pkg

julia> Pkg.add(["TensorCategories", "PackageCompiler"])
```

Now, we create the sysimage:

```julia-repl
julia> using PackageCompiler, TensorCategories

julia> create_sysimage(
           ["TensorCategories"];
           sysimage_path = joinpath(ENV["JULIA_DIR"], "sysimages", "TC-sysimage.so"),
           precompile_execution_file = joinpath(pkgdir(TensorCategories), "computations", "center_paper", "paper_code_listings.jl"),
           cpu_target = get(ENV, "JULIA_CPU_TARGET", "native")
       )
```

Here, `cpu_target` is only necessary for an HPC environment, and you should set it to the same value as `JULIA_CPU_TARGET` from above (this is not inherited).

The `precompile_execution_file` file is a file with instructions that are "representative" to what you want to run and which are then precompiled; the example file covers most of the main functions of TensorCategories.jl.

Compilation time and sysimage size depend on the workload and machine. On an HPC you should compile on a node. Request a node with:

```bash
salloc --time=03:00:00 --partition=PART --ntasks=1 --cpus-per-task=16 --mem=32G
```

Then run the above compilation.

Use the sysimage with the `--sysimage` command line argument:

```bash
julia --sysimage="$JULIA_DIR/sysimages/TC-sysimage.so"
```

The filename above is for Linux. Use the appropriate shared-library extension
on other platforms. Packages compiled into a sysimage use the versions built
into it; rebuild the sysimage after updating those packages. Use the development
launcher `tc` without this release sysimage when editing TensorCategories.


## Building documentation

Initialize the docs environment:

```bash
cd "$HOME/TensorCategories.jl"
julia --project=docs --startup-file=no
```

```julia
using Pkg
Pkg.develop(path=pwd())
Pkg.instantiate()
```

Then build the docs with:

```bash
julia --project=docs --startup-file=no docs/make.jl
```

Build from the repository root using the dedicated `docs/Project.toml`
environment. The generated site is written to `docs/build/`.

To view it locally, serve that directory:

```bash
python3 -m http.server 8000 --bind 127.0.0.1 --directory docs/build
```

Then open [http://localhost:8000](http://localhost:8000). Stop the server
with Ctrl+C.

Alternatively, build with `julia --project=docs --startup-file=no docs/make.jl local`
and open `docs/build/index.html` directly. The `local` argument disables pretty
URLs so relative links work when opening files directly.

Ordinary builds do not deploy. CI passes `deploy` explicitly and Documenter
decides whether its deployment conditions are satisfied.

### Viewing documentation built on a remote machine

Copy the built documentation to the local machine:

```bash
rsync -avz --delete remote:~/TensorCategories.jl/docs/build/ tc-docs/
```

Serve the copied site from the directory containing `tc-docs`:

```bash
python3 -m http.server 8000 --bind 127.0.0.1 --directory tc-docs
```

Then open [http://localhost:8000](http://localhost:8000).

For convenience, save a script `serv.sh` inside `tc-docs` for starting the server:

```bash
#!/usr/bin/env bash
cd -- "$(dirname -- "$0")"
exec python3 -m http.server 8000 --bind 127.0.0.1
```

Save a script `pull.sh` in the same directory to update the documentation:

```bash
#!/usr/bin/env bash
cd -- "$(dirname -- "$0")"
rsync -avz --delete --exclude='/pull.sh' --exclude='/serv.sh' remote:~/TensorCategories.jl/docs/build/ .
```

Make both scripts executable with `chmod +x tc-docs/serv.sh tc-docs/pull.sh`.

## Tests

Run the quick or full suite from the repository root in the dedicated development
environment:

```bash
cd "$HOME/TensorCategories.jl"
TENSORCATEGORIES_TEST_SUITE=quick tc -e 'using Pkg; Pkg.test("TensorCategories")'
tc -e 'using Pkg; Pkg.test("TensorCategories")'
```

The default suite is full. `Pkg.test` prepares the package's test dependencies
in a temporary environment, keeping the development environment dedicated to
TensorCategories.

## Documentation checks

Documentation examples are executable. Named `@example` blocks share state
within a page.

The build treats warnings as failures, including broken internal references and
failed examples. Publication enforcement for every implementation docstring is
disabled: the API appendix is a curated map to the principal public operations,
while mathematical hypotheses and conventions belong in the manual. This does
not relax other Documenter warnings. Use Julia help mode, for example `?center`,
and `methods(center)` to inspect exact signatures in the installed version.
