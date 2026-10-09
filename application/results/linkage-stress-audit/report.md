# Audit of the 43-link sensitivity result

The coefficients and lottery p-values reproduce independently. The striking shifts
rely on a permissive candidate graph: name distance was measured on concatenated
district, block, and GP names. Shared geography lets weak GP-name alternatives pass.

Every earlier 43-change witness uses candidates worse than the accepted match.
The changed outcomes differ by roughly 195–239 projects on average. Between 14 and
26 accepted exact-name links are replaced, and 6–9 newly selected donors have all
four annual outcomes missing and therefore become zero under the existing policy.

The arithmetic is valid conditional on this graph. It does not establish that
credible near-tie identity uncertainty causes the same instability.

## Restrictions on alternatives, keeping accepted links available

All rows keep the cohort, regression, lottery assumptions, donor uniqueness, and
at-most-43-change budget fixed. Seven diagnostic specifications are shown, not
selected on their outcome. These were investigated after seeing the broad-graph
result; they are not independently calibrated truth-containment sets.

| Year | Additional restriction | Lower coefficient bound | Upper coefficient bound | Edges |
|---:|:---|---:|---:|---:|
| 2005 | Broad cutoff only | -6.9890 | 6.0527 | 15603 |
| 2005 | GP-name distance < 0.1 | 0.0198 | 0.2056 | 4384 |
| 2005 | Full-name distance within 0.01 of accepted | -0.4744 | 0.6020 | 4531 |
| 2005 | Preserve accepted exact-name links | -5.2595 | 3.9975 | 9735 |
| 2005 | Use only already-selected donors | -4.8825 | 5.0585 | 12165 |
| 2005 | New donors have all four observed years | -6.3726 | 5.9324 | 14400 |
| 2005 | GP-name distance < 0.1 and preserve exact links | 0.0359 | 0.0474 | 4363 |
| 2010 | Broad cutoff only | -8.0162 | 4.5545 | 15603 |
| 2010 | GP-name distance < 0.1 | -2.2186 | -1.9213 | 4384 |
| 2010 | Full-name distance within 0.01 of accepted | -2.4229 | -1.5293 | 4531 |
| 2010 | Preserve accepted exact-name links | -6.2751 | 2.6150 | 9735 |
| 2010 | Use only already-selected donors | -6.5354 | 3.1129 | 12165 |
| 2010 | New donors have all four observed years | -7.7043 | 4.3760 | 14400 |
| 2010 | GP-name distance < 0.1 and preserve exact links | -2.0037 | -1.9522 | 4363 |

Bounds optimize the entire declared graph subject to the change budget. An integral
linear-program optimum or a certified integer-program optimum supplies an attaining
witness. When the integer refinement does not finish, the LP relaxation supplies
an outer bound; `attained` in the CSV distinguishes these. The GP-name and near-best
ranges have attaining witnesses. Earlier broad-graph examples searched only a subset
of feasible maps, so the newly optimized broad ranges can be wider.

GP-only distance and near-best margins are illustrative restrictions. Retaining
all accepted links guarantees baseline feasibility, not their correctness. Tighter
graphs may omit true alternatives; independent identity information is needed to
choose defensible restrictions. Exact-name equality is not ground truth either.

## Concrete changes in the earlier 2005 negative witness

| Source GP | Accepted donor | Alternative donor | Accepted projects | Alternative projects |
|:---|:---|:---|---:|---:|
| bonli | Bauli | Chandnoli | 493 | 0 |
| hodu | Hodu | Chadi | 544 | 0 |
| kamthai | Kamathāī | ankhia | 470 | 0 |
| pai | Pai | Bamni | 290 | 0 |
| bichhiwara | Bichhīvāḍā | Chhapi | 351 | 66 |

Full changed identities, distances, candidate ranks, outcome differences, and their
coefficient contributions are saved in [changed_links.csv](changed_links.csv).
[Summary](summary.csv) reports outcome concentration and missingness contributions.

[Restricted bounds](restricted_graph_bounds.csv) and
[attaining assignments](restricted_graph_witnesses.parquet) preserve the tighter-set
calculations. [Endpoint p-values](restricted_endpoint_p.csv) evaluate the attaining
coefficient endpoints with 19,999 draws each and simultaneous 95% Monte Carlo
intervals; they are not claimed global p-value extrema.

[Independent Python refits](independent-review.md) and within-stratum permutations
reproduced the original six accepted/min43/max43 coefficient and p-value results.
Original quota
data remain unchanged. These findings qualify the realistic interpretation of the
earlier result rather than changing its arithmetic.
