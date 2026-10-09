# Exact randomization inference with uncertain record identities

Does an experimental conclusion survive every linkage allowed by the candidate
records and an identity-error budget?

For completely randomized experiments whose assignment and outcome files cover the
same units once, this code computes the minimum and maximum Fisher p-values over
feasible one-to-one linkages, returns the linkages attaining them, and finds the
smallest number of changed identities that removes rejection. Every feasible linkage
shares one randomization distribution, so the largest p-value comes from the
smallest attainable absolute treatment contrast, which an integer program finds.

The test is valid when the candidate set and error budget contain the true linkage.
The maximum p-value is the robust test; picking the minimum after seeing outcomes is
not a valid test. Method, proofs and simulations are in the
[paper](manuscript/paper.pdf).

## Example

```r
source("R/core.R")
source("R/graph.R")
source("R/information.R")

z <- c(1, 1, 1, 1, 0, 0, 0, 0)
y <- z
accepted <- c(2L, 1L, 3:8)
groups <- c(1, 1, 2, 3, 2, 4, 3, 4)
graph <- outer(groups, groups, "==")

fit <- graph_information_test(y, z, graph, accepted, trusted_error_budget = 2)
fit[c("lower", "upper", "p_min", "p_max")]
fit$least_favorable_map

graph_breakdown_budget(y, z, graph, accepted, alpha = .05)
```

`graph_breakdown_budget()` returns the first identity budget at which the robust test
fails to reject, with a linkage that attains it.

## Reproduce

Requires R, the packages in `renv.lock` (`renv::restore()`), and LaTeX.

```sh
make methods   # tests, lint, both simulations, paper
make report    # rebuild the paper from committed results
```

- `R/`: p-value extrema and witnesses (`information.R`), linkage bounds (`graph.R`),
  the binary accuracy-only comparator (`accuracy.R`).
- `scripts/`: the controlled design, the identifier simulation, and table rendering.
- `results/`: outputs the paper reads.
- `tests/`: checks against exhaustive enumeration of linkages and assignments.
