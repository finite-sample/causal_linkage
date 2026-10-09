library(testthat)
source("../../R/core.R")
source("../../R/graph.R")

test_that("finite permutation expectation holds with heterogeneous effects", {
  n <- 6L
  y0 <- c(2, 8, 1, 4, 9, 0)
  y1 <- y0 + c(-2, 4, 0, 1, 8, 2)
  maps <- list(1:6, c(2, 1, 3, 4, 6, 5), c(6, 1:5))
  for (m in 1:5) {
    for (map in maps) {
      values <- apply(assignments(n, m), 1, function(z) {
        y <- y0 + z * (y1 - y0)
        contrast(y[map], z)
      })
      expect_equal(mean(values), permutation_expectation(y0, y1, map))
    }
  }
})

test_that("within-arm and joint-field permutations preserve contrasts", {
  y <- c(0, 2, 4, 3, 5, 6)
  z <- c(1, 1, 1, 0, 0, 0)
  map <- c(3, 1, 2, 6, 4, 5)
  expect_equal(contrast(y[map], z), contrast(y, z))
  map <- c(6, 1:5)
  expect_equal(contrast(y[map], z[map]), contrast(y, z))
  d <- data.frame(y = y, z = z)
  out <- reconstruct(d, d, map, c("y", "z"))
  expected <- d[map, ]
  rownames(expected) <- NULL
  expect_equal(out, expected)
  expect_error(reconstruct(d, d, rep(1, 6), "y"), "injective")
})

test_that("audit correction is unbiased with estimated conservative variance", {
  n <- 6L
  k <- 4L
  y0 <- c(0, 1, 4, 2, 6, 3)
  tau <- c(1, 2, 0, 3, 1, 2)
  audit_sets <- combn(n, k)
  estimates <- variances <- numeric()
  oracle <- numeric()
  for (z in split(assignments(n, 3), row(assignments(n, 3)))) {
    y <- y0 + z * tau
    # Deliberately outcome-dependent incorrect treatment and outcome pairing.
    yl <- sort(y, decreasing = TRUE)
    zl <- rev(z)
    oracle <- c(oracle, contrast(y, z))
    local <- vapply(seq_len(ncol(audit_sets)), function(a) {
      s <- audit_sets[, a]
      fit <- audit_correct(yl, zl, s, y[s], z[s], sum(z))
      c(fit["estimate"], fit["se"]^2)
    }, numeric(2))
    expect_equal(mean(local[1, ]), contrast(y, z))
    estimates <- c(estimates, local[1, ])
    variances <- c(variances, local[2, ])
  }
  expect_equal(mean(estimates), mean(tau))
  # Population variance, since every assignment and audit subset is enumerated.
  exact_var <- mean((estimates - mean(estimates))^2)
  expect_equal(mean(variances) - exact_var, var(tau) / n, tolerance = 1e-9)
  full <- audit_correct(y0, rep(c(1, 0), 3), 1:6, y0, rep(c(1, 0), 3), 3)
  expect_equal(unname(full["se"]), unname(neyman(y0, rep(c(1, 0), 3))["se"]))
})

test_that("variance decomposition retains covariance and need not inflate", {
  a <- assignments(6, 3)
  y <- c(0, 1, 3, 4, 6, 8)
  o <- apply(a, 1, function(z) contrast(y, z))
  l <- rep(0, length(o))
  d <- l - o
  expect_equal(var(l), var(o) + var(d) + 2 * cov(o, d))
  expect_lt(var(l), var(o))
})

test_that("selection can bias a perfectly linked experiment", {
  y0 <- rep(0, 8)
  tau <- c(rep(0, 4), rep(4, 4))
  a <- assignments(8, 4)
  values <- apply(a, 1, function(z) {
    s <- 1:4
    if (length(unique(z[s])) < 2) {
      return(NA_real_)
    }
    contrast((y0 + tau * z)[s], z[s])
  })
  expect_equal(mean(values, na.rm = TRUE), 0)
  expect_equal(mean(tau), 2)
})

test_that("covariate-error confounding formula agrees with probability enumeration", {
  for (q in seq(0, 1, .1)) {
    expectation <- 0
    for (x in 0:1) {
      for (z in 0:1) {
        for (w in 0:1) {
          pz <- .2 + .6 * x
          probability <- .5 * (if (z == 1) pz else 1 - pz) *
            (q * (w == x) + (1 - q) / 2)
          ew <- .5 + .6 * q * (w - .5)
          expectation <- expectation + probability *
            (z * (x + z) / ew - (1 - z) * (x + z) / (1 - ew))
        }
      }
    }
    expect_equal(expectation, 1 + .6 * (1 - q^2) / (1 - .36 * q^2))
  }
})

test_that("uninformative identity gives equal observable laws and opposite effects", {
  a <- assignments(2, 1)
  observed_p <- t(apply(a, 1, function(z) sort(z)))
  observed_q <- t(apply(a, 1, function(z) sort(1 - z)))
  expect_equal(observed_p, observed_q)
  expect_equal(mean(rep(1, 2) - rep(0, 2)), 1)
  expect_equal(mean(rep(0, 2) - rep(1, 2)), -1)
})
