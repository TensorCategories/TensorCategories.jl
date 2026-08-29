# Preserve the full suite for Pkg.test() and direct local runs. CI explicitly
# selects the quick suite; reject typos instead of silently skipping coverage.
suite = get(ENV, "TENSORCATEGORIES_TEST_SUITE", "full")
suite in ("quick", "full") ||
    error("TENSORCATEGORIES_TEST_SUITE must be quick or full; got $(repr(suite))")

@info "Running TensorCategories tests" suite
include("$suite.jl")
