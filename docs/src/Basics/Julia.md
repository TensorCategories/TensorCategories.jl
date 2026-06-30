
## Julia/OSCAR

[Julia](https://julialang.org) is a modern high-performance high-level programming language which, due its type system design and multiple dispatch paradigm, is nicely suited for working with categorical structures. It is open-source and runs on Windows, Linux, and macOS.

!!! note "Julia"
    Julia uses just-in-time compilation (JIT). This is one of the reasons why Julia can be so fast, but it means that the first execution of a function always takes a bit of time (since its code will be compiled)—afterward it is faster. We usually keep a session running on a server.

After starting Julia, you can consider it as a calculator:

```julia-repl
julia> 1+1
2
```

There is one important thing you need to know:

```julia-repl
julia> 2^64
0
```

The explanation is that every object in Julia is of a certain *type*, and without further specification an integer is considered of type 64-bit integer:

```julia-repl
julia> typeof(2)
Int64
```

We can convert integers to `BigInt` type which allows computing with arbitrarily large integers:


```julia-repl
julia> BigInt(2)^64
18446744073709551616
```

Except for this, however, there is not much algebra in Julia. This is where the [OSCAR](https://www.oscar-system.org/) computer algebra system comes into play. OSCAR can be installed as follows:

```julia-repl
julia> using Pkg

julia> Pkg.add("Oscar")
```

OSCAR can then be loaded with:

```julia-repl
julia> using Oscar

```

You can then do serious computer algebra like:

```julia-repl
julia> R,x = polynomial_ring(ZZ, "x")
(Univariate polynomial ring in x over ZZ, x)

julia> f = x^2 + 2*x + 1
x^2 + 2*x + 1

julia> f^2
x^4 + 4*x^3 + 6*x^2 + 4*x + 1
```

The object `ZZ` here is the ring $\mathbb{Z}$ of integers in OSCAR. Check out the [documentation](https://docs.oscar-system.org/stable/) of OSCAR for more information. OSCAR is where we take all our computer algebra from.

Next, you can install and load TensorCategories.jl with:

```julia-repl
julia> using Pkg

julia> Pkg.add("TensorCategories")

julia> using TensorCategories
```

In all the example computations below we assume you have called

```julia-repl
julia> using TensorCategories, Oscar
```

!!! note "Base rings"
    Like in formal mathematics, TensorCategories.jl and Oscar require a *base ring* for the computations. This is different to other systems like Mathematica which, by default, treat symbolic variables as representing "generic" complex numbers. While OSCAR also supports the [field of complex numbers](https://docs.oscar-system.org/stable/Nemo/complex/) and the [algebraic closure of the rationals](https://docs.oscar-system.org/stable/NumberTheory/abelian_closure/), we can also work over [number fields](https://docs.oscar-system.org/stable/Hecke/manual/number_fields/intro/).  This is not just more efficient but also mathematically interesting because some constructions, like the Drinfeld center, can look different when restricted to a number field instead of the whole complex numbers: simple objects may decompose after scalar extension to the complex numbers (there are simply more scalars one can use for a change of basis). While this "fine structure" is natural and important from a mathematical perspective, it may be unusual from a physics perspective. We do not want to go into the mathematical details at this point but when we say "split" it means things look exactly the same after extending to the complex numbers, and we have functionality to do this splitting. For applications in physics we also support conversion of our exact algebraic data into complex floating point numbers (for example for $F$-matrices).