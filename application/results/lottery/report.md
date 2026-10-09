# Rajasthan under an assumed reservation lottery

The [candidate-set audit](../linkage-stress-audit/report.md) finds that this broad
graph admits weak GP-name alternatives because its distance includes shared
district and block names. Tighter name rules sharply reduce coefficient sensitivity.
The dramatic small-budget shifts below require that broad candidate-set assumption.

Assignment is assumed uniform within district, Samiti, current-cycle caste
category, and other-cycle reservation status, fixing each stratum's treated count.
This assumption includes exchangeability within the retained cohort.

Outcome: recorded completed projects summed over 2011–2014, with the existing
missing-as-zero convention. The statistic is the stratum fixed-effect slope,
not the earlier additive OLS coefficient. Pure-treatment strata carry zero weight.

Each row is a feasible linkage evaluated against its own lottery distribution.
The endpoint maps optimize the statistic; they do not necessarily optimize p.
The near-zero map mixes whole alternating components of the endpoint maps.

| Year | Maximum changed identities | Upper bound on minimum p | Lower bound on maximum p |
|---:|---:|---:|---:|
| 2005 | 0 | 0.984182 | 0.977965 |
| 2005 | 4 | 0.597410 | 0.999634 |
| 2005 | 21 | 0.056032 | 0.999634 |
| 2005 | 43 | 0.002210 | 0.999634 |
| 2005 | 217 | 0.000366 | 0.999634 |
| 2005 | 435 | 0.000366 | 0.999634 |
| 2010 | 0 | 0.220560 | 0.201970 |
| 2010 | 4 | 0.071151 | 0.425255 |
| 2010 | 21 | 0.002210 | 0.997594 |
| 2010 | 43 | 0.000366 | 0.999634 |
| 2010 | 217 | 0.000366 | 0.999634 |
| 2010 | 435 | 0.000366 | 0.999634 |

All evaluated witnesses satisfying a cap contribute, including a map discovered
in a larger-budget search that ultimately changes fewer identities.

| Year | Linkage | Statistic | MC p | Simultaneous MC interval | Changed links |
|---:|:---|---:|---:|:---|---:|
| 2005 | accepted | 0.0359 | 0.981250 | [0.977965, 0.984182] | 0 |
| 2005 | minimum | -33.0302 | 0.000050 | [0.000000, 0.000366] | 1703 |
| 2005 | maximum | 33.3403 | 0.000050 | [0.000000, 0.000366] | 1734 |
| 2005 | near_zero | 0.0000 | 1.000000 | [0.999634, 1.000000] | 1730 |
| 2005 | budget_4_minimum | -0.9128 | 0.586250 | [0.574987, 0.597410] | 4 |
| 2005 | budget_4_maximum | 0.7965 | 0.636850 | [0.625834, 0.647730] | 4 |
| 2005 | budget_4_near_zero | 0.0359 | 0.981250 | [0.977965, 0.984182] | 0 |
| 2005 | budget_21_minimum | -3.2683 | 0.050900 | [0.045999, 0.056032] | 21 |
| 2005 | budget_21_maximum | 3.0820 | 0.066100 | [0.060543, 0.071878] | 21 |
| 2005 | budget_21_near_zero | 0.0359 | 0.981250 | [0.977965, 0.984182] | 0 |
| 2005 | budget_43_minimum | -5.4491 | 0.001250 | [0.000565, 0.002210] | 43 |
| 2005 | budget_43_maximum | 5.0378 | 0.002250 | [0.001288, 0.003483] | 43 |
| 2005 | budget_43_near_zero | 0.0359 | 0.981250 | [0.977965, 0.984182] | 0 |
| 2005 | budget_217_minimum | -15.8434 | 0.000050 | [0.000000, 0.000366] | 217 |
| 2005 | budget_217_maximum | 15.0009 | 0.000050 | [0.000000, 0.000366] | 217 |
| 2005 | budget_217_near_zero | -0.0040 | 0.997500 | [0.996148, 0.998482] | 1 |
| 2005 | budget_435_minimum | -22.7470 | 0.000050 | [0.000000, 0.000366] | 435 |
| 2005 | budget_435_maximum | 21.8800 | 0.000050 | [0.000000, 0.000366] | 435 |
| 2005 | budget_435_near_zero | -0.0000 | 1.000000 | [0.999634, 1.000000] | 1 |
| 2010 | accepted | -1.9522 | 0.211200 | [0.201970, 0.220560] | 0 |
| 2010 | minimum | -34.0225 | 0.000050 | [0.000000, 0.000366] | 1678 |
| 2010 | maximum | 32.6737 | 0.000050 | [0.000000, 0.000366] | 1740 |
| 2010 | near_zero | 0.0000 | 1.000000 | [0.999634, 1.000000] | 1685 |
| 2010 | budget_4_minimum | -2.8724 | 0.065400 | [0.059871, 0.071151] | 4 |
| 2010 | budget_4_maximum | -1.2178 | 0.436550 | [0.425255, 0.447835] | 4 |
| 2010 | budget_4_near_zero | -1.2178 | 0.436550 | [0.425255, 0.447835] | 4 |
| 2010 | budget_21_minimum | -5.1375 | 0.001250 | [0.000565, 0.002210] | 21 |
| 2010 | budget_21_maximum | 1.3650 | 0.387400 | [0.376320, 0.398500] | 21 |
| 2010 | budget_21_near_zero | -0.0066 | 0.996550 | [0.995003, 0.997730] | 13 |
| 2010 | budget_43_minimum | -7.0954 | 0.000050 | [0.000000, 0.000366] | 43 |
| 2010 | budget_43_maximum | 3.9832 | 0.011250 | [0.008961, 0.013798] | 43 |
| 2010 | budget_43_near_zero | 0.0031 | 0.998650 | [0.997594, 0.999333] | 13 |
| 2010 | budget_217_minimum | -16.6097 | 0.000050 | [0.000000, 0.000366] | 217 |
| 2010 | budget_217_maximum | 14.2769 | 0.000050 | [0.000000, 0.000366] | 217 |
| 2010 | budget_217_near_zero | -0.0001 | 1.000000 | [0.999634, 1.000000] | 34 |
| 2010 | budget_435_minimum | -23.1425 | 0.000050 | [0.000000, 0.000366] | 435 |
| 2010 | budget_435_maximum | 20.9455 | 0.000050 | [0.000000, 0.000366] | 435 |
| 2010 | budget_435_near_zero | 0.0004 | 1.000000 | [0.999634, 1.000000] | 23 |

Each year uses 19999 independent lottery draws. Intervals have at least 95% joint
Monte Carlo coverage across all 38 witness probabilities (Bonferroni-adjusted
Clopper–Pearson). The plus-one MC p-value is not an exact enumeration probability.

| Year | Bounds on minimum p | Bounds on maximum p |
|---:|:---|:---|
| 2005 | [0.000000, 0.000366] | [0.999634, 1.000000] |
| 2010 | [0.000000, 0.000366] | [0.999634, 1.000000] |

These bound the global extrema with the same Monte Carlo confidence; they are
not a computed exact p-value range. A small feasible p shows linkage sensitivity,
not robust rejection. A large feasible p rules out uniform rejection across the
candidate set, subject to the reported Monte Carlo uncertainty. It does not prove
a small or zero treatment effect. Witnesses chosen using observed data are not
individually valid post-selection causal tests.

All selected anchors must match one eligible donor, with no donor reuse. Candidate
distance is below 0.1. Budget rows additionally cap changed accepted identities;
they optimize a switchable-component subset of the graph. Unbudgeted endpoint
rows allow all feasible graph links. Accepted links
and prior election-history linkage remain assumptions, not independently validated
truth. These results quantify sensitivity conditional on that reconstruction set.

See [design and interpretation](../../lottery-design.md) and
[budget-specific p extrema bounds](budget_p_extrema_bounds.csv).
