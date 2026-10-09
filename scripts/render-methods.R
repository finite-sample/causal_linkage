source("R/core.R")
source("R/graph.R")
source("R/information.R")
out <- "results/methods"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
example <- read.csv("results/graph-information/same-accuracy-example.csv")
design <- read.csv("results/graph-information/summary.csv")
simulation <- read.csv("results/identifier-validation/summary.csv")
stopifnot(nrow(simulation) == 24L)
labels <- c(
  rate_only = "Accuracy only", near = "Within-arm candidates", far = "Cross-arm candidates"
)
lines <- c(
  "\\begin{table}[htbp]\\centering",
  "\\caption{Same accepted identities and accuracy information, different candidate graphs.",
  "The controlled example fixes eight units, four treated, and an at-most-two identity-error",
  "budget. Both restricted graphs offer two candidates per unit. P-values are exact",
  "two-sided Fisher probabilities.}\\label{tab:example}",
  "\\begin{tabular}{lrrr}\\toprule",
  "Information & Lower contrast & Upper contrast & Maximum p \\\\", "\\midrule",
  sprintf(
    "%s & %.2f & %.2f & %.3f \\\\", labels[example$method],
    example$lower, example$upper, example$p_value
  ),
  "\\bottomrule\\end{tabular}\\end{table}"
)
writeLines(lines, file.path(out, "example.tex"))
part <- design[design$alpha == .05, ]
methods <- c("oracle", "rate_only", "near", "far")
lines <- c(
  "\\begin{table}[htbp]\\centering",
  "\\caption{Exact rejection probabilities in the eight-unit design at the 5\\% level.",
  "All 70 assignments are enumerated, so there is no Monte Carlo error.",
  "The zero-effect row measures sharp-null size; other rows measure power under constant",
  "additive effects. Each method uses the same accepted linkage and error budget.}",
  "\\label{tab:design}",
  "\\begin{tabular}{rrrrr}\\toprule",
  "Effect & Oracle & Accuracy only & First graph & Second graph \\\\", "\\midrule"
)
for (effect in unique(part$effect)) {
  values <- part$rejection_rate[match(paste(effect, methods), paste(part$effect, part$method))]
  lines <- c(lines, paste0(paste(c(effect, sprintf("%.3f", values)), collapse = " & "), " \\\\"))
}
lines <- c(lines, "\\bottomrule\\end{tabular}\\end{table}")
writeLines(lines, file.path(out, "design.tex"))
simulation <- simulation[order(
  simulation$n, simulation$pattern,
  simulation$noise, simulation$effect
), ]
lines <- c(
  "\\begin{center}\\small",
  "\\setlength{\\LTcapwidth}{\\textwidth}",
  "\\begin{longtable}{rrlrrrrr}",
  "\\caption{Identifier-generated candidates: rejection frequencies and paired gains.",
  sprintf("Each row uses %d replications at the 5\\%% level.", unique(simulation$reps)),
  "Corruption changes at most one identifier",
  "character; geographic baseline risks vary by the known identifier group. Each comparison",
  "uses the oracle-known accepted identity-error count. Rejection rates are proportions;",
  "the last column is graph minus accuracy-only rejection, with Monte Carlo standard error.",
  "Unresolved optimizations conservatively do not reject; failures are reported in the text.",
  "The effect column is a probability increment before capping.}\\label{tab:identifier}\\\\",
  "\\toprule",
  "$N$ & Noise & Baseline & Effect & Oracle & Accuracy & Graph & Gain (SE) \\\\",
  "\\midrule\\endfirsthead",
  "\\toprule $N$ & Noise & Baseline & Effect & Oracle & Accuracy & Graph & Gain (SE) \\\\",
  "\\midrule\\endhead",
  sprintf(
    "%d & %.2f & %s & %.2f & %.3f & %.3f & %.3f & %.3f (%.3f) \\\\",
    simulation$n, simulation$noise,
    ifelse(simulation$pattern == "uniform", "Uniform", "Geographic"),
    simulation$effect, simulation$oracle_rejection, simulation$accuracy_rejection,
    simulation$graph_rejection, simulation$graph_accuracy_gain, simulation$gain_mcse
  ),
  "\\bottomrule\\end{longtable}\\end{center}"
)
writeLines(lines, file.path(out, "identifier.tex"))
non_null <- simulation[simulation$effect > 0, ]
raw <- read.csv("results/identifier-validation/per_replication.csv")
large <- raw[raw$effect == max(raw$effect), ]
text <- c(sprintf(
  paste0(
    "At the larger probability increment, the graph procedure rejects in %d of %d ",
    "evaluations, compared with %d for accuracy alone and %d with known identities. ",
    "The gains are modest and substantial power loss remains."
  ),
  sum(large$graph_p <= .05), nrow(large), sum(large$accuracy_p <= .05),
  sum(large$oracle_p <= .05)
), sprintf(
  paste0(
    "Across the positive-increment scenarios, the graph's paired rejection gain ranges",
    " from %.2f to %.2f. Mean candidate counts range from %.1f to %.1f across",
    " scenarios; mean accepted identity accuracy ranges from %.2f to %.2f."
  ),
  min(non_null$graph_accuracy_gain), max(non_null$graph_accuracy_gain),
  min(simulation$mean_degree), max(simulation$mean_degree),
  min(simulation$mean_accuracy), max(simulation$mean_accuracy)
), sprintf(
  paste0(
    "Scenario median graph-test runtimes range from %.3f to %.3f seconds;",
    " the largest scenario 95th-percentile runtime is %.3f seconds.",
    " These timings describe the tested graphs and hardware, not worst-case complexity."
  ),
  min(simulation$graph_runtime_median), max(simulation$graph_runtime_median),
  max(simulation$graph_runtime_p95)
))
text <- c(text, sprintf(
  paste0(
    "Of %d evaluations, %d did not return certified optima under the per-solver ",
    "time limit and received the conservative nonrejection fallback."
  ),
  sum(simulation$reps), sum(simulation$failures)
))
writeLines(text, file.path(out, "identifier-text.tex"))
writeLines(
  sprintf("\\newcommand{\\IdentifierEvaluations}{%d}", sum(simulation$reps)),
  file.path(out, "macros.tex")
)

z <- c(rep(1, 4), rep(0, 4))
accepted <- c(2L, 1L, 3:8)
groups <- list(near = rep(1:4, each = 2), far = c(1, 1, 2, 3, 2, 4, 3, 4))
graphs <- c(
  list(rate_only = matrix(TRUE, 8, 8)),
  lapply(groups, function(group) outer(group, group, "=="))
)
profiles <- list()
breaks <- list()
for (method in names(graphs)) {
  for (budget in 0:8) {
    fit <- graph_information_test(z, z, graphs[[method]], accepted, budget)
    profiles[[length(profiles) + 1L]] <- data.frame(
      method, budget,
      p_min = fit$p_min, p_max = fit$p_max,
      lower = fit$lower, upper = fit$upper
    )
  }
  fit <- graph_breakdown_budget(z, z, graphs[[method]], accepted)
  breaks[[length(breaks) + 1L]] <- data.frame(
    method,
    budget = fit$budget, p_value = fit$p_value, changed = fit$changed,
    witness = paste(fit$linkage, collapse = ",")
  )
}
write.csv(do.call(rbind, profiles), file.path(out, "budget_profiles.csv"), row.names = FALSE)
write.csv(do.call(rbind, breaks), file.path(out, "breakdown.csv"), row.names = FALSE)
writeLines(
  trimws(capture.output(sessionInfo()), which = "right"), file.path(out, "sessionInfo.txt")
)
