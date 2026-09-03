# [Equivariant sheaves and convolution](@id equivariant-sheaves)

An equivariant vector bundle on an orbit is determined by its fiber at one
point together with the action of the stabilizer. Decomposing a finite $G$-set
into orbits therefore reduces its equivariant bundles to a product of
stabilizer representation categories. For a homogeneous space of a linear
algebraic group over an algebraically closed field of characteristic zero, this
equivalence is written explicitly in
[asok2006equivariant; Example 2.3 and Eqs. (2.3)–(2.5), p. 1089](@citet).
The implementation applies the same orbit–stabilizer construction to abstract
finite $G$-sets over its supported coefficient fields, with one chosen
representative and stabilizer for each orbit.

These are concrete models using stabilizer representations, not $F$-symbol
tables. For a finite $G$-set $X$, a $G$-equivariant sheaf is stored by one
representation of $G_x$ for each chosen orbit representative $x$.
The constructor is `coherent_sheaves(K,X)`, with the **field first**.
When `X` is an ordinary unacted Julia collection, the same call equips it with
the trivial action; pass a `GSet` to retain a specified action.

Morphisms are lists of intertwiners. The ordinary tensor product is pointwise
on stalks. For one chosen representative $x$ of each orbit, this gives an
equivalence of tensor categories

```math
\operatorname{Coh}_G(X)\simeq
\prod_{[x]\in X/G}\operatorname{Rep}_K(G_x).
```

The tensor unit has one simple summand for each orbit (in the usual split
semisimple setting); it need not be simple.
Duality, the symmetric braiding, and the spherical structure are computed
stalkwise.

```@example sheaves
using TensorCategories, Oscar
G = symmetric_group(3)
X = gset(G,[1,2,3])
K = GF(7)
C = coherent_sheaves(K,X)
S = simples(C)
@assert length(S) == 2  # stabilizer of a point is C₂
@assert all(Y -> int_dim(End(only(stalks(Y)))) == 1, S)
length(S)
```

We use a finite splitting field here because simple enumeration in the
representation backend is currently supported over finite fields. Construction
of specified representations and Hom computations have broader field support.

In characteristic zero, the representation category of each stabilizer is
semisimple by Maschke's theorem, and hence so is the sheaf category. In positive
characteristic the exact condition is semisimplicity of these stabilizer
representation categories. Requiring the characteristic not to divide $|G|$
is sufficient but need not be necessary for a particular action.
The current `is_semisimple` and `is_multifusion` methods use arithmetic tests
involving $|G|$ and the characteristic rather than examining the stabilizers.
They neither determine splitting over $K$ nor handle characteristic zero
correctly. When these properties matter, test the stabilizer representation
categories over the chosen field.

## [Convolution](@id convolution-models)

Convolution composes equivariant kernels on $X$, just as matrix multiplication
sums over the middle index. The intended category is the standard
$\operatorname{Coh}_G(X\times X)$ of
[ostrik2014multifusion; Example 2.7(iii), p. 125](@citet).
That reference works over an algebraically closed field of characteristic zero.
The implementation accepts broader coefficient fields; the multifusion
interpretation then requires the relevant stabilizer representation categories
to be split semisimple.

`convolution_category(K,X)` for a `GSet` models sheaves on $X\times X$ with product
```math
(A\star B)_{x,z}=\bigoplus_{y\in X} A_{x,y}\otimes B_{y,z}.
```
Equivalently, it is
$p_{13*}(p_{12}^*A\otimes p_{23}^*B)$, where the first operation
is pushforward and the other two are pullbacks.
The public tensor product calls the stored pullback, pointwise tensor-product,
and pushforward functors in exactly this order. The unit constructor installs
trivial stabilizer representations on the diagonal orbits. It is simple for a
transitive action in the split semisimple setting; in the corresponding
nontransitive setting this is a multifusion model.

The convenience call `convolution_category(K,G,X)` first constructs the
$G$-set from the supplied action data `X`. The two-argument overload with an
ordinary unacted Julia set is currently unavailable; pass a `GSet`, or pass
the acting group explicitly.

The current `is_semisimple` and `is_fusion` methods for this constructor use the
same arithmetic test involving $|G|$ and the characteristic. They do not test
transitivity, splitting of the stabilizer representations, or the
characteristic-zero case. When the distinction between fusion and multifusion
is needed, inspect the tensor unit and the simple endomorphism algebras.

```@example sheaves
D = convolution_category(K,X)
T = simples(D)
@assert length(T) == 3  # diagonal: Rep(C₂); off-diagonal: Rep(1)
length(T)
```

The pointwise symmetric braiding does not give a braiding for convolution.
The displayed pullback–tensor–pushforward formula and diagonal unit are those of
[ostrik2014multifusion; Example 2.7(iii), p. 125](@cite). The transport between
chosen orbit representatives, associator, and duality have no documented
identification with specified stabilizer conjugations in that model. The
constructor is therefore experimental and should not be treated as a verified
rigid or spherical realization of the convolution category.
