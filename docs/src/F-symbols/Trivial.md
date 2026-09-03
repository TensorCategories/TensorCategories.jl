# [Trivial fusion category](@id trivial-fusion-data)

The rank-one fusion category is the split skeletal presentation of
$\operatorname{Vec}_K$, the category of finite-dimensional $K$-vector spaces
from [EGNO; Example 2.3.3, p. 26](@citet). Its only simple object is the tensor
unit, and its fusion and associativity constraints are trivial.

The intended entry point is `trivial_fusion_category(K)`, where $K$ must be a
field, for the rank-one split skeletal fusion category over $K$. At present
this constructor throws an error before returning a category and is therefore
unavailable. The intended model has the tensor unit as its only simple object
and the identity associator. Although $\operatorname{Vec}_K$ has its standard
symmetric braiding, the intended code presently installs no braiding data.
