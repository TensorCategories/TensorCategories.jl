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

## Separate development and release environments

It is useful to have separate development and release environments. 

```bash
mkdir -p ~/julia-envs/dev
mkdir -p ~/julia-envs/rel
```

Now set up the development environment:

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
alias jldev='julia --project=$HOME/julia-envs/dev'
alias jlrel='julia --project=$HOME/julia-envs/rel'
```

## Building documentation

Once initialize the docs environment:

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
rsync -avz --delete remote:~/TensorCategories.jl/docs/build/ TC-docs
```