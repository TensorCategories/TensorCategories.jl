# Running tests

The test entry point supports two suites. With no environment variable it runs
the **full** suite, so `Pkg.test()` and direct local runs retain the existing
comprehensive behavior.

| Suite | Intended use | Current coverage |
| --- | --- | --- |
| `quick` | Every push and pull request | Finite-dimensional vector spaces, skeletal fusion arithmetic, and exact associator coherence for the Ising and `I2(5)` fixtures. |
| `full` | Locally before releases or substantial mathematical changes | Every active test previously included by `test/runtests.jl`: examples, centers, centralizers, module categories, group actions, equivariantization, AnyonWiki, and the quick checks. |

From the repository root:

```sh
# Quick feedback
TENSORCATEGORIES_TEST_SUITE=quick julia --project=. --startup-file=no test/runtests.jl

# Full validation (explicitly overrides a quick setting in the environment)
TENSORCATEGORIES_TEST_SUITE=full julia --project=. --startup-file=no test/runtests.jl
```

Alternatively, from Julia:

```julia
using Pkg
withenv("TENSORCATEGORIES_TEST_SUITE" => "full") do
    Pkg.test()
end
```

Invalid suite names fail immediately rather than silently omitting coverage.
No previously active test has been removed from the full suite; tests whose
includes were already commented out remain dormant.

## GitHub Actions

Push and pull-request runs select **quick** on the existing Julia 1.11/1.12 and
Ubuntu/macOS matrix. Open **Actions → Runtests → Run workflow** to run **full**
manually on a release-candidate branch or tag. A manual full run is not
cancelled by a later push, while superseded automatic runs are cancelled.

Only full runs collect and upload coverage, so a quick result does not replace
the comprehensive coverage report. The upload uses `CODECOV_TOKEN` when that
repository secret is configured; otherwise Codecov must permit tokenless
uploads. Dependencies and compilation artifacts are cached. A fresh job may
still spend substantial time installing and compiling Oscar: “quick” refers to
the selected test workload, not a guaranteed CI wall-clock duration.
