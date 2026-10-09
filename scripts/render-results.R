args <- commandArgs(trailingOnly = TRUE)
phase <- if (length(args)) args[1] else "final"
d <- read.csv(file.path("results", phase, "summary.csv"))
scenarios <- c(
  "independent_y", "covariate_y", "assignment_y", "independent_t",
  "selection", "identifiers"
)
methods <- c("naive", "attenuation", "audit_difference")
q <- d[d$effect == 1 & d$scenario %in% scenarios & d$method %in% methods, ]
q <- q[order(match(q$scenario, scenarios), match(q$method, methods)), ]
label <- function(s) gsub("_", " ", s, fixed = TRUE)
lines <- c(
  "\\begin{table}[htbp]\\centering\\small",
  paste0(
    "\\caption{Finite-population ATE estimation with uncertain linkage. Each cell uses ",
    "independent simulated populations of 80 units; validation methods audit 40. Bias ",
    "is in outcome units. Coverage is for approximate 95\\% Wald intervals; MCSE is ",
    "Monte Carlo standard error.}"
  ),
  "\\begin{tabular}{llrrr}\\toprule",
  "Scenario & Method & Bias & Coverage & MCSE\\\\\\midrule"
)
for (i in seq_len(nrow(q))) {
  lines <- c(lines, sprintf(
    "%s & %s & %.3f & %.3f & %.3f\\\\",
    label(q$scenario[i]), label(q$method[i]), q$bias[i],
    q$coverage[i], q$coverage_mcse[i]
  ))
}
lines <- c(lines, "\\bottomrule\\end{tabular}", "\\end{table}")
writeLines(lines, "results/simulation-table.tex")
a <- read.csv("application/results/estimates.csv")
a <- a[a$outcome == "total_comp_project" & a$missing_policy == "current_na_rm" &
         a$term == "female_res_2005", ]
b <- read.csv("application/results/coefficient_reconstruction_bounds.csv")
lines <- c(
  "\\begin{table}[htbp]\\centering\\small",
  paste0(
    "\\caption{Rajasthan completed projects, 2011--2014: reproduced 2005 reservation ",
    "coefficient, controlling for 2010 reservation. Standard errors condition on linked",
    " data. Cohort changes differ from linkage reconstruction uncertainty.}"
  ),
  "\\begin{tabular}{llrrr}\\toprule",
  "Link rule & Cohort & GPs & Estimate & OLS SE\\\\\\midrule"
)
for (i in seq_len(nrow(a))) {
  lines <- c(lines, sprintf(
    "%s & %s & %d & %.3f & %.3f\\\\",
    a$method[i], a$cohort[i], a$n[i], a$estimate[i], a$se_ols[i]
  ))
}
lines <- c(
  lines, "\\bottomrule\\end{tabular}", "\\end{table}",
  sprintf(
    paste0(
      "On the fixed %s-GP fuzzy cohort, candidate assignment extrema for the ",
      "2005 coefficient are $[%.2f,%.2f]$, compared with ",
      "$[%.2f,%.2f]$ when donor reuse is allowed. These are ",
      "conditional estimator ranges, not causal confidence intervals."
    ),
    format(b$n_sources[1], big.mark = ","), b$lower[1], b$upper[1],
    b$independent_lower[1], b$independent_upper[1]
  )
)
writeLines(lines, "results/application-table.tex")
# One figure with common axes and direct method labels in each panel.
pdf("results/coverage.pdf", width = 8, height = 6, family = "Helvetica")
par(mfrow = c(2, 3), mar = c(4, 7, 3, 1), mgp = c(2.5, .7, 0))
for (s in scenarios) {
  x <- q[q$scenario == s, ]
  y <- 3:1
  plot(x$coverage, y,
    xlim = c(0, 1), ylim = c(.5, 3.5), yaxt = "n",
    ylab = "", xlab = "Coverage", main = label(s), pch = 19, cex.main = .85
  )
  axis(2, at = y, labels = c("Naive", "Attenuation", "Validation"), las = 1, cex.axis = .8)
  segments(
    pmax(0, x$coverage - 1.96 * x$coverage_mcse), y,
    pmin(1, x$coverage + 1.96 * x$coverage_mcse), y
  )
  abline(v = .95, lty = 2, col = "gray45")
}
dev.off()
text <- c(
  "# Simulation results", "",
  sprintf("Run: %s; %d replications per scenario/effect cell.", phase, unique(d$replicates)),
  "", "The full numerical results are in `summary.csv`. Graph intervals have no point estimate.",
  "Their reported point failures are not applicable; interval failures are counted separately.", ""
)
for (s in scenarios) {
  x <- q[q$scenario == s, ]
  text <- c(text, sprintf("**%s.** %s", label(s), paste(sprintf(
    "%s bias %.3f (MCSE %.3f), coverage %.3f (MCSE %.3f)",
    label(x$method), x$bias, x$bias_mcse, x$coverage, x$coverage_mcse
  ), collapse = "; ")), "")
}
writeLines(head(text, -1L), file.path("results", phase, "report.md"))

compare <- d[d$effect == 1 & d$scenario %in% c("independent_y", "selection", "identifiers") &
               d$method %in% c("naive", "audit_difference", "graph"), ]
compare <- compare[order(compare$scenario, compare$method), ]
lines <- c(
  "\\begin{table}[htbp]\\centering\\small",
  paste0(
    "\\caption{Point intervals and graph confidence sets, with ", unique(d$replicates),
    " replications per cell. Width is in outcome units. Null rejection uses sharp-zero ",
    "effect runs; power uses positive-effect runs. Coverage refers to the ",
    "finite-population ATE. Graph sets use known potential-outcome support [0,6].}"
  ),
  "\\begin{tabular}{llrrrr}\\toprule",
  "Scenario & Method & Coverage & Width & Null rejection & Power\\\\\\midrule"
)
for (i in seq_len(nrow(compare))) {
  row <- compare[i, ]
  null <- d[d$effect == 0 & d$scenario == row$scenario & d$method == row$method, ]
  lines <- c(lines, sprintf(
    "%s & %s & %.3f & %.2f & %.3f & %.3f\\\\",
    label(row$scenario), label(row$method), row$coverage,
    row$width, null$rejection, row$rejection
  ))
}
lines <- c(lines, "\\bottomrule\\end{tabular}\\end{table}")
writeLines(lines, "results/remedies-table.tex")
ind <- d[d$effect == 1 & d$scenario == "independent_y", ]
sel <- d[d$effect == 1 & d$scenario == "selection", ]
value <- function(frame, method, field) frame[frame$method == method, field]
interpretation <- c(
  sprintf(
    paste0(
      "Under independent outcome linkage, the naive estimator has bias %.3f; ",
      "the validation difference estimator has bias %.3f (MCSE %.3f). ",
      "Under selection, their biases are %.3f and %.3f. ",
      "Validation restores the fixed-population target under its sampling assumptions; ",
      "the normal approximation still needs separate assessment."
    ),
    value(ind, "naive", "bias"), value(ind, "audit_difference", "bias"),
    value(ind, "audit_difference", "bias_mcse"), value(sel, "naive", "bias"),
    value(sel, "audit_difference", "bias")
  ),
  "",
  sprintf(
    paste0(
      "The graph causal sets are protective but weak in these designs. ",
      "For independent outcome linkage their mean width is %.2f and ",
      "power is %.3f; validation intervals have width %.2f and power %.3f. ",
      "The identifier design permits every source an outside option, so its ",
      "graph sets can be logically uninformative. The separate estimator ranges ",
      "still measure how much one-to-one coupling constrains reconstruction. ",
      "This experiment does not establish a competitive general-purpose graph interval."
    ),
    value(ind, "graph", "width"), value(ind, "graph", "rejection"),
    value(ind, "audit_difference", "width"), value(ind, "audit_difference", "rejection")
  )
)
writeLines(interpretation, "results/simulation-interpretation.tex")
