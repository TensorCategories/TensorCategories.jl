#=----------------------------------------------------------
    Compute pivotal structures for SixJCategories 
----------------------------------------------------------=#

function pivotal_structures(C::SixJCategory)
    @assert is_multifusion(C) 

    n = rank(C) 

    K = base_ring(C) 

    # The unit is a sum of distinct unit simples; use its SUPPORT, not
    # membership of an index in the coefficient vector [0,1,0,...].
    all(c -> c in (0,1),C.one) || throw(ArgumentError("invalid unit multiplicities"))
    nvars = n - sum(C.one)
    if nvars == 0
        return is_spherical(C,K.(ones(Int,n))) ? [K.(ones(Int,n))] : Vector{elem_type(K)}[]
    end
    Kx, variables = polynomial_ring(K,nvars+1)
    x = copy(variables[1:nvars])

    piv = [C.one[s] != 0 ? Kx(1) : popfirst!(x) for s ∈ 1:n]

    C_x = six_j_category(Kx, multiplication_table(C))
    set_associator!(C_x, [change_base_ring(Kx, m) for m ∈ C.ass])
    set_one!(C_x, C.one)
    set_pivotal!(C_x, piv)

    # Invertibility is part of the definition of a pivotal structure.
    eqs = [prod(piv)*last(variables)-1]
    for i ∈ 1:n, j ∈ 1:n

        eq = matrix(pivotal(C_x[i]) ⊗ pivotal(C_x[j])) - matrix(double_dual_monoidal_structure(C[i],C[j])) * matrix(pivotal(C_x[i] ⊗ C_x[j]))

        append!(eqs, filter!(!=(0), collect(matrix(eq))[:]))
    end
    I = ideal(eqs)
    dim(I) <= 0 || throw(ArgumentError("positive-dimensional pivotal solution scheme is unsupported"))
    sols = real_solutions_over_base_field(I)

    return [[p(s...) for p ∈ piv] for s ∈ sols]
end

spherical_structures(C::SixJCategory) = filter(p -> is_spherical(C,p), pivotal_structures(C))