# Developing

Here is some basic information for developing.

## Juliaup

[Juliaup](https://github.com/JuliaLang/juliaup) is the official version manager for Julia. It allows multiple Julia versions to be installed side by side, provides a simple way to switch between them or select a specific version when starting Julia, and keeps installed versions up to date. Juliaup manages the Julia executables themselves, while packages and package environments continue to be managed separately through Julia's built-in package manager (Pkg).

Install with:

```bash
curl -fsSL https://install.julialang.org | sh
```

Install the latest stable release:

```bash
juliaup add release
```

Set the default:

```bash
juliaup default release
```

Then

```bash
julia
```

starts the default version. To run a specific version without changing the default:

```bash
julia +lts
```

Update the release version:

```
juliaup update release
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

Add Bash aliases:

```bash
alias jldev='julia --project=~/julia-envs/dev'
alias jlrel='julia --project=~/julia-envs/rel'
```

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

One can speed up startup time and first-call time in Julia by creating a "sysimage" with [PackageCompiler](https://julialang.github.io/PackageCompiler.jl/dev/). Here is how this works.

It is probably useful to use the release environment we created above. Then:

```julia-repl
julia> using Pkg

julia> Pkg.add("PackageCompiler")

julia> using PackageCompiler

julia> create_sysimage(
    ["TensorCategories"],
    sysimage_path = "~/julia-sysimages/TC-sysimage-0.6.0.so",
    precompile_execution_file = "~/TensorCategories.jl/computations/center_paper/paper_code_listings.jl",
)
```

The `precompile_execution_file` file is a file with instructions that are "representative" to what you want to run. You can then use this sysimage with:

```bash
jlrel --sysimage /home/thiel/julia-sysimages/TC-sysimage-0.6.0.so
```

It makes sense to create an alias in `.bashrc`:

```bash
alias tc="jlrel --sysimage /home/thiel/julia-sysimages/TC-sysimage-0.6.0.so"
complete -f tc # make Bash complete only filenames for the tc command/alias
```