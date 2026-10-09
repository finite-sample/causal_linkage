# Binary-confounder illustration with oracle-known propensities for each measured
# covariate. This isolates lost confounding information from propensity fitting.
args <- commandArgs(trailingOnly = TRUE)
reps <- if (length(args)) as.integer(args[1]) else 2000L
set.seed(19000001)
q_grid <- c(0, .25, .5, .75, 1)
results <- lapply(q_grid, function(q) {
  rows <- replicate(reps, {
    n <- 2000L
    x <- rbinom(n, 1, .5)
    z <- rbinom(n, 1, .2 + .6 * x)
    y <- x + z
    w <- ifelse(rbinom(n, 1, q) == 1, x, rbinom(n, 1, .5))
    ew <- .5 + .6 * q * (w - .5)
    ex <- .2 + .6 * x
    c(
      oracle = mean(z * y / ex - (1 - z) * y / (1 - ex)),
      linked = mean(z * y / ew - (1 - z) * y / (1 - ew))
    )
  })
  data.frame(
    copy_probability = q, expected_oracle = 1,
    expected_linked = 1 + .6 * (1 - q^2) / (1 - .36 * q^2),
    observed_oracle = mean(rows[1, ]), observed_linked = mean(rows[2, ]),
    oracle_mcse = sd(rows[1, ]) / sqrt(reps),
    linked_mcse = sd(rows[2, ]) / sqrt(reps), reps = reps
  )
})
write.csv(do.call(rbind, results), "results/observational.csv", row.names = FALSE)
