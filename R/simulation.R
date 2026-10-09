scenario_registry <- function() {
  data.frame(
    scenario = c(
      "independent_y", "covariate_y", "assignment_y", "outcome_y",
      "independent_t", "outcome_t", "covariate_x", "joint_xy",
      "joint_ty", "selection", "missing_edges", "duplicate_reuse",
      "unequal_arms", "high_error", "homogeneous", "identifiers"
    ),
    layout = c(
      "y", "y", "y", "y", "t", "t", "x", "xy", "ty", "y",
      "y", "y", "y", "y", "y", "y"
    ),
    mechanism = c(
      "independent", "covariate", "assignment", "outcome",
      "independent", "outcome", "covariate", "covariate",
      "independent", "selection", "missing", "duplicate",
      "independent", "independent", "independent", "identifier"
    ),
    error_fraction = c(rep(.3, 13), .6, .3, .3),
    treated_fraction = c(rep(.5, 12), .25, .5, .5, .5),
    heterogeneity = c(rep(.8, 14), 0, .8),
    stringsAsFactors = FALSE
  )
}
rotate <- function(x) c(x[-1], x[1])
lin_fit <- function(y, z, x) {
  if (min(sum(z), sum(1 - z)) < 3 || length(unique(x)) < 2) {
    return(c(estimate = NA, se = NA, lower = NA, upper = NA))
  }
  xc <- x - mean(x)
  fit <- lm(y ~ z * xc, data = data.frame(y = y, z = z, xc = xc))
  variance <- sandwich::vcovHC(fit, type = "HC2")["z", "z"]
  estimate <- unname(coef(fit)["z"])
  se <- sqrt(variance)
  c(
    estimate = estimate, se = se, lower = estimate - 1.96 * se,
    upper = estimate + 1.96 * se
  )
}
simulate_once <- function(cfg, seed, effect = 1, n = 80L) {
  set.seed(seed)
  x <- runif(n, -1, 1)
  y0 <- 2 + 1.5 * x + runif(n, -.3, .3)
  tau <- effect * (1 + cfg$heterogeneity * x)
  y1 <- y0 + tau
  m <- as.integer(n * cfg$treated_fraction)
  z <- numeric(n)
  z[sample.int(n, m)] <- 1
  y <- ifelse(z == 1, y1, y0)
  k <- max(2L, as.integer(n * cfg$error_fraction))
  ranker <- switch(cfg$mechanism,
    covariate = x,
    assignment = z + runif(n) / 10,
    outcome = y,
    runif(n)
  )
  changed <- order(ranker, decreasing = TRUE)[seq_len(k)]
  map <- seq_len(n)
  map[changed] <- rotate(changed)
  g <- diag(n) == 1
  g[cbind(seq_len(n), map)] <- TRUE
  # Extra candidates create ambiguity without changing the accepted permutation.
  extra <- sample.int(n)
  g[cbind(seq_len(n), extra)] <- TRUE
  confidence <- ifelse(map == seq_len(n), rbeta(n, 8, 2), rbeta(n, 3, 4))
  outside <- rep(FALSE, n)
  if (cfg$mechanism == "identifier") {
    families <- vapply(seq_len(n / 8), function(i) paste(sample(letters, 6), collapse = ""), "")
    names_a <- paste0(rep(families, each = 8), vapply(seq_len(n), function(i) {
      paste(sample(letters, 2), collapse = "")
    }, ""))
    names_b <- names_a
    names_b[changed] <- vapply(names_b[changed], function(s) {
      paste0(substr(s, 1, 6), sample(letters, 1), substr(s, 8, 8))
    }, "")
    distance <- stringdist::stringdistmatrix(names_a, names_b,
      method = "jw", p = 0,
      nthread = 1
    )
    g <- distance < .12
    map <- max.col(-distance, ties.method = "first")
    chosen_distance <- distance[cbind(seq_len(n), map)]
    confidence <- 1 - chosen_distance
    outside[] <- TRUE
  }
  yl <- y
  zl <- z
  xl <- x
  if (cfg$layout %in% c("y", "xy", "ty")) yl <- y[map]
  if (cfg$layout %in% c("t", "ty")) zl <- z[map]
  if (cfg$layout %in% c("x", "xy")) xl <- x[map]
  if (cfg$mechanism == "duplicate") {
    map[changed] <- which.max(y)
    yl <- y[map]
  }
  keep <- confidence > .8
  if (cfg$mechanism == "selection") {
    keep <- x < .3
    outside[!keep] <- TRUE
    g[!keep, ] <- FALSE
    yl[!keep] <- 0
  }
  if (cfg$mechanism == "missing") {
    g[cbind(changed, changed)] <- FALSE
  }
  fit <- function(yv, zv) {
    if (min(sum(zv), sum(1 - zv)) < 2) {
      return(c(estimate = NA, se = NA, lower = NA, upper = NA))
    }
    neyman(yv, zv)
  }
  audit <- sample.int(n, n / 2)
  naive <- fit(yl, zl)
  exact <- map == seq_len(n) & keep
  # Controlled experiments give an idealized perfect-precision subset, explicitly
  # distinct from operational exact-name linkage in the application.
  if (cfg$mechanism == "identifier") exact <- confidence == 1
  fits <- list(
    oracle = fit(y, z), naive = naive,
    high_confidence = fit(yl[keep], zl[keep]),
    exact_subset = fit(yl[exact], zl[exact]),
    adjusted = lin_fit(yl[keep], zl[keep], xl[keep]),
    audit_difference = audit_correct(yl, zl, audit, y[audit], z[audit], m),
    validation_only = audit_correct(rep(0, n), z, audit, y[audit], z[audit], m),
    attenuation = attenuation_correct(
      naive["estimate"], naive["se"],
      as.numeric(map[audit] == audit), n
    )
  )
  # Correct layout: reverse treatment-file edges to use assignment-file anchors.
  bg <- if (cfg$layout == "t") t(g) else g
  if (cfg$layout %in% c("x", "ty")) bg <- diag(n) == 1
  bounds <- causal_bounds(z, y, bg, c(0, 6), outside = outside)
  fits$graph <- c(
    estimate = NA, se = NA, lower = bounds["lower"],
    upper = bounds["upper"]
  )
  names(fits$graph) <- c("estimate", "se", "lower", "upper")
  rows <- lapply(names(fits), function(method) {
    f <- fits[[method]]
    # Strip names introduced by combining previously named scalars.
    est <- as.numeric(f[1])
    se <- as.numeric(f[2])
    lo <- as.numeric(f[3])
    hi <- as.numeric(f[4])
    data.frame(
      method = method, estimate = est, se = se, lower = lo, upper = hi,
      truth = mean(tau), error = est - mean(tau),
      covered = lo <= mean(tau) & hi >= mean(tau),
      rejects_zero = lo > 0 | hi < 0,
      target_shift = if (method == "exact_subset") {
        mean(tau[exact]) - mean(tau)
      } else if (method %in% c("high_confidence", "adjusted")) {
        mean(tau[keep]) - mean(tau)
      } else {
        0
      },
      precision = mean(map == seq_len(n)), retained = mean(keep),
      reconstruction_contains_truth = all(diag(bg) | outside),
      candidate_recall = mean(diag(g)),
      true_linkage_containment = all(diag(g)),
      accepted_precision = if (method == "exact_subset") mean(map[exact] == which(exact))
      else if (method %in% c("high_confidence", "adjusted")) mean(map[keep] == which(keep))
      else mean(map == seq_len(n)),
      estimator_contains_oracle = bounds["estimator_lower"] <= contrast(y, z) + 1e-9 &
        bounds["estimator_upper"] >= contrast(y, z) - 1e-9,
      estimator_width = bounds["estimator_upper"] - bounds["estimator_lower"]
    )
  })
  do.call(rbind, rows)
}
