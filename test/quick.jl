using TensorCategories
using Oscar, Test

# Keep the per-push suite bounded. These exact tests exercise basic linear
# category operations, skeletal fusion arithmetic, and associator coherence
# without invoking center computations or database-based integration tests.
include("VectorSpacesTest/VSTest.jl")
include("SixJCategoryTests/RingCatTests.jl")
include("InterfaceTests.jl")
