```@meta 
DocTestSetup = quote 
    using TensorCategories, Oscar
end
```

# Group Actions on fusion categories

!!! warning This section is highly experimental and may yield unexpected results. Use with caution.

Let ``\mathcal C`` be a fusion category and ``G`` finite group. A `group action` of ``G`` on ``\mathcal C`` is given by a monoidal functor 

```math
T \colon \mathrm{Cat}(G) \to \mathrm{Aut}_{\otimes}(\mathcal C),~~~g \mapsto T_g \colon \mathcal C \to \mathcal C,
```

i.e. each group element is mapped to an autoequivalence of ``\mathcal C`` and for each pair of group elements ``g,h`` we have a monoiodal natural transformation 

```math
\sigma_{g,h} \colon T_g\circ T_h \to T_{g,h}.
```

We follow the construction of a group action with the example of the Ising category.

```jldoctest ising 
I = ising_category()
G = cyclic_group(2)
aut = autoequivalences(I)
```

As a first step we computed the autoequivalences. Note that this method at the moment is supported only for some categories not all. A general way to compute autoequivalences are the `inner autoequivalences` given by ``V \mapsto X \otimes V \otimes X^\ast`` for some invertible ``X``.

```@docs 
inner_autoequivelance
inner_autoequivalences
action_by_inner_autoequivalences
```

Next we figure out which autoequivalence is non-trivial and define the tensor action.

```jldoctest ising 
a,b = aut    

if length(monoidal_natural_transformations(a,identity_as_monoidal_functor(I))) == 0
    a,b = b,a
end

# the monoidal structure is given by a Dict 
monoidal_str = Dict(
    (1,1) => id(a),
    (1,2) => id(b),
    (2,1) => id(b),
    (2,2) => monoidal_natural_transformations(b∘b, a)[1] # the nontrivial monoidal structure on the identity functor
)

T = gtensor_action(I, elements(G), [a,b], monoidal_str)
```

## Equivariantization 

Let ``\mathcal C`` be a monoidal category with an action ``T`` by a group ``G``. An equivariant object is a tuple ``(X,u)`` such that ``X``is an object and a family of isomorphisms ``u_g \colon T_g(X) \to X`` compatible with the action. The equivariant objects form a category ``\mathcal C^G`` called **equivariantization** of ``\mathcal C``.  

### Induction 

There is a canonical forgetful functor ``F \colon \mathcal C^G \to \mathcal C``. This forgetful functor admits a left adjoint ``I_G`` given by 

```math 
I_g(X) = \bigoplus\limits_{g \in G} T_g(X)
```
and structure maps 

```math 
u_g \colon \sum\limits_{h} \iota_h \circ (\sigma_{g,h})_X \circ T_g(p_h)\;. 
```

The induction is implemented for fusion categories by the method `equivariant_induction`.

```@docs 
equivariant_induction
```

### Computation

We can compute the equivariantization of a fusion category with a given ``G``-action explicitly. We follow the example of the Ising category with its non-trivial ``\mathbb Z_2``-action from earlier. The resulting category of type `Equivariantization` allows for all the operations available for fusion categories, including computation of ``F``-symbols.

```jldoctest ising 
E = equivariantization(I)
simples(E)
```

## ``G``-Crossed Extensions

Given a fusion category ``\mathcal C`` and ``G``-action ``T``we can define the **``G``-crossed product** ``\mathcal C \ltimes G`` of ``\mathcal C`` and ``G``, see [EGNO; 4.15.5](@cite). This category has the same objects as ``\mathcal C \boxtimes \mathrm{Vec}_G`` but with alternative tensor product 

```math 
(X\boxtimes g) \otimes (Y \boxtimes h) := (X \otimes T_g(Y)) \boxtimes gh
```

and the associativity is given by 

```math 
(X \otimes T_g(Y)) \otimes T_{gh}(Z) \xrightarrow{a_{X,T_(Y),T_{gh}(Z)}} X \otimes (T_g(Y) \otimes T_{gh(Z)}) \xrightarrow{\mathrm{id}_X \otimes \left(\mathrm{id}_{T_g(Y)} \otimes \left(\sigma_{g,h}\right)_{Z}\right)} \cdots \\
\cdots \to X \otimes (T_g(Y) \otimes T_g(T_h(Z))) \xrightarrow{\mathrm{id}_X \otimes \mu_{Y,T_h(Z)}} X \otimes (T_g(Y \otimes T_h(Z)))
``` 