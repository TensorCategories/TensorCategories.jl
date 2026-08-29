# Split a specified finite family, without enumerating an ambient category.
# For an indecomposable over a finite field, End(X)/rad End(X) is a finite
# division algebra and hence a finite field. Its relative degree is the
# splitting degree of X.
function _residue_end_algebra(X::Object)
    A = endomorphism_ring(X)
    quo(A,radical(A))[1]
end

function _finite_splitting_degree(decompositions; max_degree)
    required = ZZ(1)
    for dec in decompositions, (X,_) in dec
        int_dim(End(X)) == 1 && continue
        D = _residue_end_algebra(X)
        for (A,_) in decompose(D)
            required = lcm(required,ZZ(dim(center(A)[1])))
            required <= max_degree || throw(ArgumentError(
                "splitting needs relative degree $required, exceeding max_degree=$max_degree"))
        end
    end
    Int(required)
end

# Center scalar extension normally enumerates all simples. A family split only
# needs a compatible empty target parent for the specified objects.
_splitting_base_change(C::Category,L,e) =
    extension_of_scalars(C,L;embedding=e)
_splitting_base_change(C::CenterCategory,L,e) =
    _extension_of_scalars(C,L;embedding=e)
_splitting_base_change(C::Semisimplification,L,e) =
    Semisimplification(_splitting_base_change(category(C),L,e))

function _splitting_base_change(C::TensorPowerCategory,L,e)
    D = _splitting_base_change(category(C),L,e)
    generators = isempty(C.generator) ? Object[zero(D)] :
        [extension_of_scalars(X,L,D;embedding=e) for X in C.generator]
    tensor_power_category(generators)
end

"""
    split(objects::AbstractVector{<:Object}; max_degree=64, check=false)
    split(X::Object; max_degree=64, check=false)

Split the indecomposable summands of a finite family over one finite extension
of their common finite base field. The relative extension degree is computed
from the semisimple residue endomorphism algebras and must not exceed
`max_degree`. Already split families keep their field and parent. This method
does not enumerate a tensor closure or the simples of the ambient category.

The result records the source and target categories, field embedding, relative
degree, extended objects, their decompositions, and
`absolutely_indecomposable=true`. For nonsemisimple objects, absolute
indecomposability does not imply simplicity. The degree construction proves
the flag; `check=true` additionally recomputes all residue algebras afterward.
"""
function split(objects::AbstractVector{<:Object};
               max_degree::Integer=64,check::Bool=false)
    isempty(objects) && throw(ArgumentError("at least one object is required"))
    max_degree >= 1 || throw(ArgumentError("max_degree must be positive"))
    C,F = parent(first(objects)),base_ring(first(objects))
    all(X -> parent(X) === C,objects) ||
        throw(ArgumentError("objects must share one parent instance"))
    is_finite(F) ||
        throw(ArgumentError("this splitting method requires a finite base field"))

    decompositions = decompose.(objects)
    d = _finite_splitting_degree(decompositions;max_degree)
    L = d == 1 ? F :
        GF(ZZ(characteristic(F)),Base.checked_mul(Int(degree(F)),d))
    e = _scalar_extension_embedding(F,L)
    D = d == 1 ? C : _splitting_base_change(C,L,e)
    extended = d == 1 ? collect(objects) :
        [extension_of_scalars(X,L,D;embedding=e) for X in objects]
    decompositions = d == 1 ? decompositions : decompose.(extended)

    if check
        for dec in decompositions, (X,_) in dec
            (int_dim(End(X)) == 1 || dim(_residue_end_algebra(X)) == 1) ||
                error("a summand did not become absolutely indecomposable")
        end
    end
    (; source_category=C,category=D,field=L,embedding=e,
       extension_degree=d,objects=extended,decompositions,
       absolutely_indecomposable=true)
end

split(X::Object;kwargs...) = split([X];kwargs...)

function extension_of_scalars(X::TensorPowerObject,L::Field,
                              D::TensorPowerCategory;
                              embedding=_scalar_extension_embedding(base_ring(X),L))
    TensorPowerObject(D,
        extension_of_scalars(object(X),L,category(D);embedding))
end

function extension_of_scalars(f::TensorPowerMorphism,L::Field,
                              D::TensorPowerCategory;
                              embedding=_scalar_extension_embedding(base_ring(f),L))
    morphism(extension_of_scalars(domain(f),L,D;embedding),
             extension_of_scalars(codomain(f),L,D;embedding),
             extension_of_scalars(morphism(f),L,category(D);embedding))
end

function extension_of_scalars(X::SemisimplifiedObject,L::Field,
                              D::Semisimplification;
                              embedding=_scalar_extension_embedding(base_ring(X),L))
    semisimplify(
        extension_of_scalars(object(X),L,category(D);embedding),D)
end

function extension_of_scalars(f::SemisimplifiedMorphism,L::Field,
                              D::Semisimplification;
                              embedding=_scalar_extension_embedding(base_ring(f),L))
    semisimplify(
        extension_of_scalars(morphism(f),L,category(D);embedding),D)
end
