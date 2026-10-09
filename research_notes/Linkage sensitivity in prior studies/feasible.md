# Sensitivity over feasible record linkages: direct methodological precedents

## Have researchers optimized downstream estimates over sets of record matchings?

### Takeaway
Yes. Hall and Fienberg (2012) explicitly formulate regression-coefficient extrema over a confidence set of bipartite matchings. This is a direct precedent, not merely a paper about changing linkage thresholds.

### Cited Findings
- Section 5 defines the minimum and maximum of the least-squares statistic over a matching confidence set. It explicitly distinguishes uncertainty about the statistic under the unknown true matching from uncertainty about a population regression parameter; the latter needs additional sampling uncertainty. The paper constructs confidence sets through linear constraints on bipartite matchings. [Hall and Fienberg, author manuscript, pp. 9–11](https://www.cs.cmu.edu/~rjhall/linkage.pdf)
- Their variable-cohort regression implementation approximates the matched-subset Gram matrix by scaling the full-data inverse Gram matrix. Their proposed greedy algorithm does not guarantee exact extrema. Their empirical illustration bounds matching size in two waves of an older-adult survey, rather than presenting a causal coefficient reversal. Thus the general optimization idea is established; the paper is not an exact duplicate of a fixed-cohort causal application. [Hall and Fienberg, Sections 5–6](https://www.cs.cmu.edu/~rjhall/linkage.pdf)

### Inferences
- Fixed-design OLS coefficient bounds in our application are a straightforward specialization of that established objective: each coefficient is a linear function of linked outcomes. Exact constrained optimization and careful causal interpretation may be useful implementation work, but are not sufficient to claim an unprecedented inferential principle.

### Gaps
- This search did not establish how often applied causal papers implement this optimization. Existence and routine adoption are different questions.

## Have researchers shown that candidate-set quality changes sensitivity bounds?

### Takeaway
Yes, strikingly close to our audit: Turkcapar and Krishnan (2023) calculate aggregate bounds over feasible graph matchings, vary similarity measures and candidate restrictions, and show how bad candidate sets widen intervals or cause them to miss truth.

### Cited Findings
- The paper bounds aggregate queries over two-table integration using constrained bipartite graph matching, with extensions to one-to-many relationships. Real-data comparisons include Jaccard, blocking plus Jaccard, edit distance, and weighted Jaccard. Weighted Jaccard produces the narrowest intervals in their examples; edit distance, inappropriate for their title comparisons, produces the widest. [Turkcapar and Krishnan, Section 5.3](https://arxiv.org/html/2309.05178v1)
- Simulations separately vary false positives and false negatives in candidate sets. Lower candidate precision widens intervals; poor recall creates failures to contain the true answer. The paper also finds that candidate-degree skew matters and matching cardinality constraints reduce its impact. These are aggregate-query results, not causal treatment-effect or randomization-p-value results. [Turkcapar and Krishnan, Sections 5.4–5.5](https://arxiv.org/html/2309.05178v1)
- Earlier work likewise returned lower and upper OLAP aggregate answers while leaving entity resolution unresolved, without requiring probabilities for alternative resolutions. [Sismanis et al., ICDE 2009, author institution record](https://research.ibm.com/publications/resolution-aware-query-answering-for-business-intelligence)

### Inferences
- The finding that permissive candidate rules manufacture dramatic sensitivity and better identity information narrows it is already a studied methodological phenomenon. Tightening a graph may also falsely reassure if it removes true links; narrowness by itself is not validation.

### Gaps
- These sources do not give the exact Rajasthan combination of a fixed cohort, alternative donor injections, a cap on changed accepted links, and stratified-lottery inference. That unlocated combination cannot establish novelty by itself.

## Do causal researchers quantify how few record errors can reverse a test conclusion?

### Takeaway
Yes for closely related outcome misclassification; this is distinct from identity linkage but directly precedes the minimal-changes-to-reverse-significance logic.

### Cited Findings
- Heng and Shaw (2025; first preprint 2022) define warning accuracy and minimal alteration number: the fewest binary outcome corrections required to reverse a randomization-test decision. They formulate integer optimization and discuss sharp and weak causal nulls. Their framework permits both directions of reversal. [Heng and Shaw, Sections 3–4](https://arxiv.org/html/2201.03111v3)
- They explicitly warn that worst-case sensitivity does not tell us how many errors actually exist. They recommend comparing the influential error types with substantive knowledge and validation data. This is an excellent precedent for interpreting, rather than overselling, our extreme-linkage witnesses. Their unknowns are binary outcome labels, not candidate-constrained, one-to-one record identities. [Heng and Shaw, Section 3.2 and Appendix E](https://arxiv.org/html/2201.03111v3)
- Applied linkage quantitative-bias analysis also exists: Doidge et al. find apparently increasing Down's syndrome prevalence in individual data sources but a stable linked-data trend after accounting for error. This is prevalence estimation, not a causal regression or exact feasible-matching bound. [Doidge et al. 2020, original paper](https://ijpds.org/article/download/1157/3052/4627)

### Inferences
- A useful response to the user is: yes, both practical sensitivity checks and formal worst-case methods exist; our result is an application within that tradition. The contribution would need to rest on a consequential, well-validated application or a specific inference advance, not the discovery that a few strategically located linkage mistakes can matter.

### Gaps
- I did not identify a primary paper in this short targeted search reporting exact global minimum and maximum randomization p-values over our precise class of candidate-constrained injections with a fixed cohort and a changed-link budget. This is a bounded search statement, not evidence that no such work exists.
