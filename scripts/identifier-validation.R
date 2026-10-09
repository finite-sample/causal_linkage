source("R/core.R")
source("R/graph.R")
source("R/information.R")
source("R/accuracy.R")

args <- commandArgs(trailingOnly = TRUE)
phase <- if (length(args)) args[1] else "final"
if (!phase %in% c("pilot", "final")) stop("Phase must be pilot or final")
replicates <- if (phase == "pilot") 4L else 40L
out <- file.path("results/identifier-validation", if (phase == "pilot") "pilot" else "")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
alpha <- .05
solver_timeout <- 3L

make_identifiers <- function(n, noise, seed) {
  set.seed(seed)
  groups <- rep(seq_len(10), each = n / 10)
  suffix <- matrix(sample.int(4, n * 2, TRUE), n, 2)
  noisy <- suffix
  corrupted <- which(runif(n) < noise)
  for (i in corrupted) {
    position <- sample.int(2, 1)
    noisy[i, position] <- sample(setdiff(seq_len(4), suffix[i, position]), 1)
  }
  donor_order <- sample.int(n)
  true_map <- match(seq_len(n), donor_order)
  donor_suffix <- suffix[donor_order, , drop = FALSE]
  distance <- outer(noisy[, 1], donor_suffix[, 1], "!=") +
    outer(noisy[, 2], donor_suffix[, 2], "!=")
  graph <- outer(groups, groups[donor_order], "==") & distance <= 1
  stopifnot(all(graph[cbind(seq_len(n), true_map)]))
  edges <- which(graph, arr.ind = TRUE)
  v <- nrow(edges)
  constraints <- matrix(0, 2 * n, v)
  constraints[cbind(edges[, 1], seq_len(v))] <- 1
  constraints[cbind(n + edges[, 2], seq_len(v))] <- 1
  costs <- distance[edges] + runif(v, 0, 1e-6)
  fit <- lpSolve::lp("min", costs, constraints, rep("=", 2 * n), rep(1, 2 * n))
  if (fit$status != 0) stop("Accepted-map assignment failed: ", fit$status)
  chosen <- which(fit$solution > .5)
  accepted <- integer(n)
  accepted[edges[chosen, 1]] <- edges[chosen, 2]
  stopifnot(
    length(chosen) == n, identical(sort(accepted), seq_len(n)),
    all(graph[cbind(seq_len(n), accepted)])
  )
  # The design and outcome draws occur only after identifiers and linkage are fixed.
  z <- sample(rep(0:1, each = n / 2))
  u <- runif(n)
  list(
    seed = seed, groups = groups, suffix = suffix, noisy = noisy,
    donor_order = donor_order, graph = graph, accepted = accepted, true_map = true_map,
    z = z, u = u, error_budget = sum(accepted != true_map),
    corrupted = corrupted, mean_degree = mean(rowSums(graph)),
    max_degree = max(rowSums(graph))
  )
}

binary_p <- function(y, z) {
  n <- length(z)
  m <- sum(z)
  total <- sum(y)
  support <- seq.int(max(0, m - (n - total)), min(m, total))
  statistic <- abs(support / m - (total - support) / (n - m))
  sum(dhyper(support, total, n - total, m)[statistic >= abs(contrast(y, z)) - 1e-12])
}

verify_fit <- function(fit, y, input, require_graph) {
  n <- length(y)
  for (name in c("lower_map", "upper_map", "most_favorable_map", "least_favorable_map")) {
    map <- fit[[name]]
    stopifnot(
      identical(sort(as.integer(map)), seq_len(n)),
      sum(map != input$accepted) <= input$error_budget
    )
    if (require_graph) stopifnot(all(input$graph[cbind(seq_len(n), map)]))
  }
  stopifnot(
    abs(contrast(y[fit$lower_map], input$z) - fit$lower) < 1e-7,
    abs(contrast(y[fit$upper_map], input$z) - fit$upper) < 1e-7,
    abs(binary_p(y[fit$least_favorable_map], input$z) - fit$p_max) < 1e-10,
    abs(binary_p(y[fit$most_favorable_map], input$z) - fit$p_min) < 1e-10
  )
}

wilson <- function(successes, trials) {
  if (!trials) {
    return(c(NA_real_, NA_real_))
  }
  p <- successes / trials
  z <- qnorm(.975)
  center <- (p + z^2 / (2 * trials)) / (1 + z^2 / trials)
  half <- z * sqrt(p * (1 - p) / trials + z^2 / (4 * trials^2)) / (1 + z^2 / trials)
  c(max(0, center - half), min(1, center + half))
}

cells <- expand.grid(
  n = c(40L, 80L), noise = c(.25, .75),
  pattern = c("uniform", "geographic"), stringsAsFactors = FALSE
)
records <- list()
inputs <- list()
witnesses <- list()
seed_offset <- if (phase == "pilot") 10710000L else 10810000L
started <- Sys.time()
for (cell in seq_len(nrow(cells))) {
  design <- cells[cell, ]
  for (replicate_id in seq_len(replicates)) {
    seed <- seed_offset + cell * 1000L + replicate_id
    input <- make_identifiers(design$n, design$noise, seed)
    input_id <- paste(cell, replicate_id, sep = "_")
    inputs[[input_id]] <- input
    p0 <- if (design$pattern == "uniform") {
      rep(.35, design$n)
    } else {
      ifelse(input$groups %% 2, .05, .65)
    }
    for (effect in c(0, .25, .5)) {
      id <- paste(input_id, effect, sep = "_")
      y0 <- as.integer(input$u < p0)
      y1 <- as.integer(input$u < pmin(1, p0 + effect))
      observed <- ifelse(input$z == 1, y1, y0)
      y <- observed[input$donor_order]
      record <- data.frame(
        n = design$n, noise = design$noise, pattern = design$pattern, effect = effect,
        replicate = replicate_id, seed = seed, input_id = input_id,
        error_budget = input$error_budget, accuracy = 1 - input$error_budget / design$n,
        mean_degree = input$mean_degree, max_degree = input$max_degree,
        truth_in_graph = all(input$graph[cbind(seq_len(design$n), input$true_map)]),
        realized_ate = mean(y1 - y0), accepted_estimate = contrast(y[input$accepted], input$z),
        oracle_estimate = contrast(observed, input$z), oracle_p = binary_p(observed, input$z),
        status = "ok", error = "", graph_seconds = NA_real_, accuracy_seconds = NA_real_,
        graph_lower = NA_real_, graph_upper = NA_real_, graph_p = NA_real_,
        accuracy_lower = NA_real_, accuracy_upper = NA_real_, accuracy_p = NA_real_
      )
      accuracy <- NULL
      result <- tryCatch(
        {
          t0 <- proc.time()[["elapsed"]]
          accuracy <- binary_accuracy_test(y, input$z, input$accepted, input$error_budget)
          record$accuracy_seconds <- proc.time()[["elapsed"]] - t0
          t0 <- proc.time()[["elapsed"]]
          graph <- graph_information_test(
            y, input$z, input$graph, input$accepted,
            input$error_budget, solver_timeout = solver_timeout
          )
          record$graph_seconds <- proc.time()[["elapsed"]] - t0
          verify_fit(accuracy, y, input, FALSE)
          verify_fit(graph, y, input, TRUE)
          stopifnot(
            graph$p_max <= accuracy$p_max + 1e-10,
            graph$p_max >= record$oracle_p - 1e-10,
            graph$lower >= accuracy$lower - 1e-7,
            graph$upper <= accuracy$upper + 1e-7
          )
          record$graph_lower <- graph$lower
          record$graph_upper <- graph$upper
          record$graph_p <- graph$p_max
          record$accuracy_lower <- accuracy$lower
          record$accuracy_upper <- accuracy$upper
          record$accuracy_p <- accuracy$p_max
          list(
            graph = graph, accuracy = accuracy, y0 = y0, y1 = y1,
            observed = observed, donor_outcomes = y
          )
        },
        error = function(e) e
      )
      if (inherits(result, "error")) {
        record$status <- "failed"
        record$error <- conditionMessage(result)
        record$graph_p <- 1
        record$graph_seconds <- proc.time()[["elapsed"]] - t0
        if (!is.null(accuracy)) {
          record$accuracy_lower <- accuracy$lower
          record$accuracy_upper <- accuracy$upper
          record$accuracy_p <- accuracy$p_max
        } else {
          record$accuracy_p <- 1
        }
        witnesses[[id]] <- list(error = conditionMessage(result), y0 = y0, y1 = y1)
      } else {
        witnesses[[id]] <- result
      }
      records[[length(records) + 1L]] <- record
    }
    raw <- do.call(rbind, records)
    write.csv(raw, file.path(out, "per_replication.csv"), row.names = FALSE)
    saveRDS(inputs, file.path(out, "inputs.rds"))
    saveRDS(witnesses, file.path(out, "witnesses.rds"))
  }
  cat(
    "Completed cell", cell, "of", nrow(cells), "in",
    round(as.numeric(difftime(Sys.time(), started, units = "secs")), 1), "seconds\n"
  )
}

condition_id <- interaction(raw$n, raw$noise, raw$pattern, raw$effect)
summaries <- lapply(split(raw, condition_id), function(d) {
  ok <- d$status == "ok"
  result <- d[1, c("n", "noise", "pattern", "effect")]
  result$reps <- nrow(d)
  result$failures <- sum(!ok)
  result$exact_completion <- mean(ok)
  # Solver failures receive the prespecified conservative p=1 fallback.
  for (method in c("oracle", "graph", "accuracy")) {
    rejects <- d[[paste0(method, "_p")]] <= alpha
    rate <- mean(rejects)
    interval <- wilson(sum(rejects), nrow(d))
    result[[paste0(method, "_rejection")]] <- rate
    result[[paste0(method, "_lo")]] <- interval[1]
    result[[paste0(method, "_hi")]] <- interval[2]
  }
  gain <- as.integer(d$graph_p <= alpha) - as.integer(d$accuracy_p <= alpha)
  result$graph_accuracy_gain <- mean(gain)
  result$gain_mcse <- sd(gain) / sqrt(nrow(d))
  result$graph_width <- if (any(ok)) mean(d$graph_upper[ok] - d$graph_lower[ok]) else NA_real_
  result$accuracy_width <- mean(d$accuracy_upper - d$accuracy_lower)
  result$mean_realized_ate <- mean(d$realized_ate)
  result$mean_error_budget <- mean(d$error_budget)
  result$mean_accuracy <- mean(d$accuracy)
  result$mean_degree <- mean(d$mean_degree)
  result$graph_runtime_median <- median(d$graph_seconds)
  result$graph_runtime_p95 <- unname(quantile(d$graph_seconds, .95))
  result
})
summary <- do.call(rbind, summaries)
rownames(summary) <- NULL
write.csv(summary, file.path(out, "summary.csv"), row.names = FALSE)
saveRDS(
  list(
    phase = phase, replicates = replicates, cells = cells, alpha = alpha,
    seed_offset = seed_offset, solver_timeout = solver_timeout,
    started = started, finished = Sys.time()
  ),
  file.path(out, "configuration.rds")
)
writeLines(
  trimws(capture.output(sessionInfo()), which = "right"), file.path(out, "session-info.txt")
)
code <- c(
  "R/core.R", "R/graph.R", "R/information.R", "R/accuracy.R",
  "scripts/identifier-validation.R"
)
write.csv(data.frame(path = code, md5 = unname(tools::md5sum(code))),
  file.path(out, "input-manifest.csv"),
  row.names = FALSE
)
report <- c(
  "# Outcome-blind identifier validation", "",
  paste("Phase:", phase, ";", nrow(raw), "evaluations;", sum(raw$status != "ok"), "failures."),
  "",
  "Identifiers and accepted assignments precede treatment and outcome generation.",
  "True-graph containment follows the bounded corruption mechanism. Both robust",
  "methods receive the same oracle-known identity-error budget: a privileged input,",
  "not an estimated real-data accuracy guarantee. All donor outcomes are conserved.",
  "",
  "Completed solves are exact; a solver failure receives conservative p=1. Graph p-values are",
  "maximized over candidate-compatible bijections; accuracy-only p-values use the",
  "closed-form binary success-count support. Every saved endpoint witness is checked.",
  "",
  "summary.csv reports rejection rates with Wilson 95% intervals and paired power",
  "differences with Monte Carlo standard errors. Zero estimated MCSE when every",
  "paired difference is zero does not prove a zero population difference. Null",
  "rejection frequencies are noisy diagnostics, not a proof of test size. No",
  "failed run is excluded from rejection rates. Graph widths summarize completed solves only.",
  "The three ILP calls each have a three-second time limit; exact_completion reports",
  "the successful fraction. Computational fallback can reverse the theoretical power ordering.",
  "",
  "| n | Noise | Baseline | Effect | Oracle | Graph | Accuracy | Gain (MCSE) | Failures |",
  "|---:|---:|:---|---:|---:|---:|---:|:---|---:|"
)
for (i in seq_len(nrow(summary))) {
  x <- summary[i, ]
  report <- c(report, sprintf(
    "| %d | %.2f | %s | %.2f | %.3f | %.3f | %.3f | %.3f (%.3f) | %d |",
    x$n, x$noise, x$pattern, x$effect, x$oracle_rejection,
    x$graph_rejection, x$accuracy_rejection,
    x$graph_accuracy_gain, x$gain_mcse, x$failures
  ))
}
report <- c(
  report, "", "These controlled results do not establish practical value for real linkage",
  "pipelines. Real application requires defensible graph containment and an",
  "error budget supplied by validation, not by access to true identities."
)
writeLines(report, file.path(out, "report.md"))
print(summary)
if (any(raw$status != "ok")) {
  message("Failures retained with conservative p=1 fallback: ", sum(raw$status != "ok"))
}
