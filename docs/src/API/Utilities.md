# Rings, serialization, and utilities

These exported docstrings are grouped by their source files. For explanatory
material, return to the [manual and API index](../API.md).

The [Grothendieck-ring chapter](@ref grothendieck-rings) explains the
decategorified structures, multiplication conventions, and ring constructors.

```@autodocs
Modules = [TensorCategories]
Private = false
Pages = [
    "AliasMacro.jl",
    "DecategorifiedFramework/GrothendieckRing.jl",
    "DecategorifiedFramework/ZPlusRings.jl",
    "DecategorifiedFramework/multiplication_table.jl",
    "Serialization/symbols_to_csv.jl",
    "TensorCategories.jl",
    "Utility/QuantumIntegers.jl",
    "Utility/Serialization.jl",
]
```
