# Outcome-blind identifier validation

Phase: final ; 960 evaluations; 13 failures.

Identifiers and accepted assignments precede treatment and outcome generation.
True-graph containment follows the bounded corruption mechanism. Both robust
methods receive the same oracle-known identity-error budget: a privileged input,
not an estimated real-data accuracy guarantee. All donor outcomes are conserved.

Completed solves are exact; a solver failure receives conservative p=1. Graph p-values are
maximized over candidate-compatible bijections; accuracy-only p-values use the
closed-form binary success-count support. Every saved endpoint witness is checked.

summary.csv reports rejection rates with Wilson 95% intervals and paired power
differences with Monte Carlo standard errors. Zero estimated MCSE when every
paired difference is zero does not prove a zero population difference. Null
rejection frequencies are noisy diagnostics, not a proof of test size. No
failed run is excluded from rejection rates. Graph widths summarize completed solves only.
The three ILP calls each have a three-second time limit; exact_completion reports
the successful fraction. Computational fallback can reverse the theoretical power ordering.

| n | Noise | Baseline | Effect | Oracle | Graph | Accuracy | Gain (MCSE) | Failures |
|---:|---:|:---|---:|---:|---:|---:|:---|---:|
| 40 | 0.25 | geographic | 0.00 | 0.025 | 0.000 | 0.000 | 0.000 (0.000) | 0 |
| 80 | 0.25 | geographic | 0.00 | 0.025 | 0.000 | 0.000 | 0.000 (0.000) | 0 |
| 40 | 0.75 | geographic | 0.00 | 0.000 | 0.000 | 0.000 | 0.000 (0.000) | 0 |
| 80 | 0.75 | geographic | 0.00 | 0.075 | 0.000 | 0.000 | 0.000 (0.000) | 0 |
| 40 | 0.25 | uniform | 0.00 | 0.025 | 0.000 | 0.000 | 0.000 (0.000) | 0 |
| 80 | 0.25 | uniform | 0.00 | 0.075 | 0.000 | 0.000 | 0.000 (0.000) | 1 |
| 40 | 0.75 | uniform | 0.00 | 0.025 | 0.000 | 0.000 | 0.000 (0.000) | 0 |
| 80 | 0.75 | uniform | 0.00 | 0.025 | 0.000 | 0.000 | 0.000 (0.000) | 0 |
| 40 | 0.25 | geographic | 0.25 | 0.175 | 0.025 | 0.000 | 0.025 (0.025) | 0 |
| 80 | 0.25 | geographic | 0.25 | 0.500 | 0.000 | 0.000 | 0.000 (0.000) | 1 |
| 40 | 0.75 | geographic | 0.25 | 0.100 | 0.000 | 0.000 | 0.000 (0.000) | 0 |
| 80 | 0.75 | geographic | 0.25 | 0.625 | 0.000 | 0.000 | 0.000 (0.000) | 0 |
| 40 | 0.25 | uniform | 0.25 | 0.225 | 0.050 | 0.050 | 0.000 (0.000) | 0 |
| 80 | 0.25 | uniform | 0.25 | 0.500 | 0.000 | 0.000 | 0.000 (0.000) | 3 |
| 40 | 0.75 | uniform | 0.25 | 0.125 | 0.000 | 0.000 | 0.000 (0.000) | 0 |
| 80 | 0.75 | uniform | 0.25 | 0.450 | 0.000 | 0.000 | 0.000 (0.000) | 0 |
| 40 | 0.25 | geographic | 0.50 | 0.575 | 0.100 | 0.075 | 0.025 (0.025) | 0 |
| 80 | 0.25 | geographic | 0.50 | 0.925 | 0.000 | 0.000 | 0.000 (0.000) | 2 |
| 40 | 0.75 | geographic | 0.50 | 0.575 | 0.100 | 0.000 | 0.100 (0.048) | 0 |
| 80 | 0.75 | geographic | 0.50 | 0.950 | 0.000 | 0.000 | 0.000 (0.000) | 0 |
| 40 | 0.25 | uniform | 0.50 | 0.800 | 0.200 | 0.200 | 0.000 (0.000) | 0 |
| 80 | 0.25 | uniform | 0.50 | 1.000 | 0.000 | 0.000 | 0.000 (0.000) | 6 |
| 40 | 0.75 | uniform | 0.50 | 0.850 | 0.050 | 0.025 | 0.025 (0.025) | 0 |
| 80 | 0.75 | uniform | 0.50 | 0.975 | 0.000 | 0.000 | 0.000 (0.000) | 0 |

These controlled results do not establish practical value for real linkage
pipelines. Real application requires defensible graph containment and an
error budget supplied by validation, not by access to true identities.
