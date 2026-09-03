# Developing and building the manual

Use a separate Julia environment for development. From a checkout:

```julia
import Pkg
Pkg.activate("dev"; shared=true)
Pkg.develop(path=pwd())
Pkg.add("Revise")
```

Then start Julia in that environment and load `Revise` before `TensorCategories`.
Changes to methods can usually be loaded into the running process; changes to
types may require a restart. A local OSCAR checkout can also be registered with
`Pkg.develop(path=...)`.

## Tests

The repository provides quick and full suites. From an environment containing
this checkout and its test dependencies:

```sh
TENSORCATEGORIES_TEST_SUITE=quick julia --project=@dev test/runtests.jl
julia --project=@dev test/runtests.jl
```

Here `@dev` selects the shared environment created above; an absolute path
can select another environment. The default suite is full.

## Documentation

Set up the documentation environment from the repository root:

```sh
julia --project=docs -e 'using Pkg; Pkg.develop(path=pwd()); Pkg.instantiate()'
julia --project=docs docs/make.jl local
```

Open `docs/build/index.html`. The `local` argument disables pretty URLs so
relative links work when opening files directly.
Ordinary builds do not deploy. CI passes `deploy` explicitly and Documenter
decides whether its deployment conditions are satisfied.

Documentation examples are executable. Named `@example` blocks share state
within a page.

The build treats warnings as failures, including broken internal references and
failed examples. Publication enforcement for every implementation docstring is
disabled: the API appendix is a curated map to the principal public operations,
while mathematical hypotheses and conventions belong in the manual. This does
not relax other Documenter warnings. Use Julia help mode, for example `?center`,
and `methods(center)` to inspect exact signatures in the installed version.
