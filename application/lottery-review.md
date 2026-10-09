# Lottery extension verification

The user explicitly requested treating Rajasthan's 2005/2010 reservation assignment
as a lottery. The application implements that as a stated conditional model;
historical verification is not used to block the analysis.

An independent reviewer checked the stratum fixed-effect estimand, conditional
lottery sampling, separate null distributions for changing donor subsets, and
Monte Carlo bounds on p-value extrema. The reviewer independently enumerated 100
random injection-component families and budgets: every computed subset-family
minimum and maximum agreed with exhaustive enumeration. Actual source and donor
IDs each belong to one graph block, validating endpoint-program decomposition.

The review emphasized that observed-data-selected witnesses are sensitivity
examples, that p_min cannot support robust rejection, and that large p_max does
not establish a negligible effect. Those distinctions are incorporated in the
design and generated report. Helper input validation was strengthened after review.

Additional verification reconstructs saved objectives, checks every witness against
the candidate graph and donor uniqueness, compares the accepted-map statistic to
an independent fixed-effect regression, and compares all 38 Monte Carlo null
standard deviations to their analytical finite-population lottery values. Source
hashes are checked unchanged. The unit suite independently enumerates small
lotteries and component-budget programs and tests the exact full-bijection p_min
extension against all feasible linkages in random small graphs.

The 38 witness probability intervals share a 95% simultaneous Monte Carlo guarantee
across both years. Budget-specific bounds use actual changed-link counts; a map
found during a larger-budget search may qualify for a smaller cap. No assumption
about the empirical correctness of the accepted linkage is inferred from this
computation.
