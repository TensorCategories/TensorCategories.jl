# [Implementation checklist and generic methods](@id interface-checklist)

Start with the structures your model actually supports. A property predicate is
a declaration used by dispatch and algorithms; it is not a request to construct
missing operations.

| Structure | Operations to provide or obtain from valid fallbacks |
|:--|:--|
| Category | `parent`, `domain`, `codomain`, object/morphism equality, `id`, `compose` |
| Linear category | `base_ring`, morphism addition and scalar multiplication, `zero_morphism`, a finite basis for `Hom` |
| Additive category | `zero(C)`, binary `direct_sum` with inclusions and projections |
| Abelian category | `kernel` with inclusion, `cokernel` with projection |
| Monoidal category | tensor product on objects **and** morphisms, `one(C)`, `associator` and its inverse |
| Rigid category | `dual`, `ev`, `coev`, with triangle identities |
| Semisimple category | effective `decompose` and simple representatives where enumeration is finite |
| Split fusion category | finite split semisimple tensor structure, simple unit; coherent associators and dualities |
| Pivotal/spherical category | specified pivotal maps and the required coherence/trace properties |
| Braided category | `braiding` and the two hexagon identities |

An operation can be primitive in one model and derived in another. For example,
`image(f)` can be computed as the kernel of the cokernel, while a representation
model can compute it directly by linear algebra. Generic coordinate routines
typically need faithful matrices and usable Hom bases. Having objects with
numeric fields is not sufficient.

## Return values are part of the interface

`kernel(f)` and `cokernel(f)` return pairs, not just objects.
`direct_sum(X,Y)` returns an object and two lists of structural maps.
`is_isomorphic(X,Y)` returns a Boolean and a morphism witness; use its first
entry as a condition. See the worked [matrix implementation](../Implementing/MatrixCategory.md).

Do not implement two fallbacks in terms of each other. Test each primitive
before testing operations that depend on it. Read the implementation of a
fallback before relying on its hypotheses; split semisimple coordinate
algorithms are not general algorithms for non-split abelian categories.

## Mathematical checks

Test identities that are independent of the chosen implementation: identity
and associativity of composition, biproduct equations, rank–nullity and kernel
universal properties, tensor interchange, pentagons, duality triangles, and
hexagons. Include zero objects, rectangular matrices, and repeated simple
summands. A nonsymmetric associator and a fusion multiplicity greater than one
detect errors that an Ising-only test cannot.

`pentagon_axiom(C)` and `hexagon_axiom(C)` exhaust the simple inputs in supported
finite models.

For API signatures and source links, use the [API reference](../API.md).
