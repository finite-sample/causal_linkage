source("R/core.R")
source("R/graph.R")
source("R/simulation.R")
args <- commandArgs(trailingOnly = TRUE)
reps <- if (length(args)) as.integer(args[1]) else 200L
phase <- if (length(args) > 1) args[2] else "pilot"
if (!phase %in% c("pilot", "final") || is.na(reps) || reps < 2) stop("Invalid run")
seed_base <- if (phase == "pilot") 410000L else 9000000L
cfgs <- scenario_registry()
write.csv(cfgs, "research/scenarios.csv", row.names = FALSE)
dir.create(file.path("results", phase), recursive = TRUE, showWarnings = FALSE)
output <- file.path("results", phase)
all_summaries <- list()
for (s in seq_len(nrow(cfgs))) {
  started <- proc.time()[3]
  results <- lapply(c(0, 1), function(effect) {
    chunks <- lapply(seq_len(reps), function(r) {
      d <- simulate_once(cfgs[s, ], seed_base + s * 100000L + effect * 10000L + r,
        effect = effect
      )
      d$replicate <- r
      d$effect <- effect
      d
    })
    do.call(rbind, chunks)
  })
  d <- do.call(rbind, results)
  d$scenario <- cfgs$scenario[s]
  saveRDS(d, file.path(output, paste0(cfgs$scenario[s], ".rds")))
  groups <- split(d, interaction(d$effect, d$method))
  summary <- do.call(rbind, lapply(groups, function(q) {
    ok <- is.finite(q$error)
    ci <- !is.na(q$covered)
    coverage <- mean(q$covered[ci])
    rejection <- mean(q$rejects_zero[ci])
    data.frame(
      scenario = q$scenario[1], effect = q$effect[1], method = q$method[1],
      replicates = nrow(q), point_failures = sum(!ok),
      interval_failures = sum(!ci), bias = mean(q$error[ok]),
      bias_mcse = sd(q$error[ok]) / sqrt(sum(ok)),
      rmse = sqrt(mean(q$error[ok]^2)), empirical_se = sd(q$error[ok]),
      mean_reported_se = mean(q$se[ok]), coverage = coverage,
      coverage_mcse = sqrt(coverage * (1 - coverage) / sum(ci)),
      rejection = rejection,
      rejection_mcse = sqrt(rejection * (1 - rejection) / sum(ci)),
      width = mean(q$upper[ci] - q$lower[ci]),
      target_shift = mean(q$target_shift), precision = mean(q$precision),
      reconstruction_containment = mean(q$reconstruction_contains_truth),
      candidate_recall = mean(q$candidate_recall),
      true_linkage_containment = mean(q$true_linkage_containment),
      accepted_precision = mean(q$accepted_precision),
      retained_fraction = mean(q$retained),
      oracle_estimator_containment = mean(q$estimator_contains_oracle),
      estimator_width = mean(q$estimator_width)
    )
  }))
  summary$scenario_seconds <- proc.time()[3] - started
  all_summaries[[s]] <- summary
  write.csv(do.call(rbind, all_summaries), file.path(output, "summary.csv"), row.names = FALSE)
  cat(cfgs$scenario[s], sprintf("%.1fs\n", summary$scenario_seconds[1]))
}
session_text <- trimws(capture.output(sessionInfo()), which = "right")
writeLines(session_text, file.path(output, "sessionInfo.txt"))
