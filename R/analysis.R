party_shares <- function(d, weighted = FALSE) {
  mass <- if (weighted) {
    d$weight
  } else {
    rep(1, nrow(d))
  }
  s <- tapply(mass, d$party, sum)
  s / sum(s)
}

cell_statistics <- function(d, outcome, weighted = FALSE) {
  observed <- !is.na(d[[outcome]]) & !is.na(d$arm) & !is.na(d$party)
  z <- d[observed, ]
  groups <- split(seq_len(nrow(z)), paste(z$party, z$arm, sep = ":"))
  do.call(rbind, lapply(groups, function(i) {
    y <- z[[outcome]][i]
    w <- if (weighted) {
      z$weight[i]
    } else {
      rep(1, length(i))
    }
    n <- length(y)
    if (n < 2) {
      stop("Insufficient observations in an outcome cell")
    }
    m <- sum(w * y) / sum(w)
    h <- w / sum(w)
    variance <- if (weighted) {
      sum((w * (y - m) / (1 - h))^2) / sum(w)^2
    } else {
      var(y) / n
    }
    data.frame(
      party = z$party[i[1]], arm = z$arm[i[1]], n = n, mean = m,
      variance = variance, ess = sum(w)^2 / sum(w^2), min = min(y), max = max(y),
      zero = mean(y == 0), ceiling = mean(y == 100)
    )
  }))
}

estimate_contrast <- function(d, outcome, contrast, weighted = FALSE, shares = NULL) {
  if (is.null(shares)) {
    shares <- party_shares(d, weighted)
  }
  stats <- cell_statistics(d, outcome, weighted)
  stats <- stats[stats$arm %in% names(contrast) & stats$party %in% names(shares), ]
  stopifnot(nrow(stats) == length(contrast) * length(shares))
  a <- unname(shares[stats$party] * contrast[stats$arm])
  v <- a^2 * stats$variance
  se <- sqrt(sum(v))
  df <- if (weighted) {
    sum(stats$n) - nrow(stats)
  } else {
    sum(v)^2 / sum(v^2 / (stats$n - 1))
  }
  est <- sum(a * stats$mean)
  critical <- qt(0.975, df)
  control <- if ("Control" %in% names(contrast)) {
    is_control <- stats$arm == "Control"
    sum(shares[stats$party[is_control]] * stats$mean[is_control])
  } else {
    NA_real_
  }
  data.frame(
    outcome = outcome, estimate = est, se = se, df = df, low = est -
      critical * se, high = est + critical * se, p = 2 * pt(
      -abs(est / se),
      df
    ), n = sum(stats$n), eligible = nrow(d), baseline = control, weighted = weighted,
    inference = if (weighted) {
      "Fixed-weight HC3 t"
    } else {
      "Stratified Welch t"
    }
  )
}

missing_bounds <- function(d, outcome, contrast, lower = NULL, upper = NULL) {
  lo <- if (is.null(lower)) {
    ifelse(is.na(d[[outcome]]), 0, d[[outcome]])
  } else {
    d[[lower]]
  }
  hi <- if (is.null(upper)) {
    ifelse(is.na(d[[outcome]]), 100, d[[outcome]])
  } else {
    d[[upper]]
  }
  shares <- party_shares(d)
  low <- high <- 0
  for (p in names(shares)) {
    for (arm in names(contrast)) {
      idx <- d$party == p & d$arm == arm
      c <- shares[[p]] * contrast[[arm]]
      low <- low + c * mean(if (c >= 0) {
        lo[idx]
      } else {
        hi[idx]
      })
      high <- high + c * mean(if (c >= 0) {
        hi[idx]
      } else {
        lo[idx]
      })
    }
  }
  data.frame(outcome = outcome, low = low, high = high)
}

contrast_influence <- function(d, outcome, contrast, weighted = FALSE) {
  shares <- party_shares(d, weighted)
  original <- estimate_contrast(d, outcome, contrast, weighted, shares)$estimate
  z <- d[d$arm %in% names(contrast) & !is.na(d[[outcome]]), ]
  deleted <- numeric(nrow(z))
  max_h <- 0
  for (p in names(shares)) {
    for (a in names(contrast)) {
      i <- which(z$party == p & z$arm == a)
      y <- z[[outcome]][i]
      w <- if (weighted) {
        z$weight[i]
      } else {
        rep(1, length(i))
      }
      m <- weighted.mean(y, w)
      change <- shares[[p]] * contrast[[a]] * w * (y - m) / (sum(w) - w)
      deleted[i] <- original - change
      max_h <- max(max_h, w / sum(w))
    }
  }
  data.frame(
    outcome = outcome, weighted = weighted, estimate = original,
    deletion_min = min(deleted), deletion_max = max(deleted), max_leverage = max_h
  )
}

permutation_check <- function(d, outcome, contrast, draws = 9999L, seed = 20261004L) {
  shares <- party_shares(d)
  z <- d[d$arm %in% names(contrast) & !is.na(d[[outcome]]), ]
  stopifnot(length(contrast) == 2L, all(sort(contrast) == c(-1, 1)))
  groups <- split(seq_len(nrow(z)), z$party)
  statistic <- function(treatment) {
    sum(vapply(names(groups), function(p) {
      i <- groups[[p]]
      shares[[p]] * (mean(z[[outcome]][i][treatment[i]]) - mean(z[[outcome]][i][!treatment[i]]))
    }, numeric(1)))
  }
  treatment <- z$arm == names(contrast)[contrast == 1]
  observed <- statistic(treatment)
  set.seed(seed)
  exceed <- 0L
  for (b in seq_len(draws)) {
    shuffled <- treatment
    for (i in groups) shuffled[i] <- sample(treatment[i])
    exceed <- exceed + (abs(statistic(shuffled)) >= abs(observed) - 1e-12)
  }
  p <- (exceed + 1) / (draws + 1)
  data.frame(
    outcome = outcome, estimate = observed, draws = draws, seed = seed,
    exceedances = exceed, p = p, mc_se = sqrt(p * (1 - p) / (draws + 1))
  )
}

missingness_table <- function(d, outcomes) {
  do.call(rbind, lapply(outcomes, function(o) {
    do.call(rbind, lapply(
      split(seq_len(nrow(d)), paste(d$party, d$arm)),
      function(i) {
        data.frame(
          study = d$study[1], party = d$party[i[1]], arm = d$arm[i[1]],
          outcome = o, assigned = length(i), observed = sum(!is.na(d[[o]][i])),
          missing = sum(is.na(d[[o]][i]))
        )
      }
    ))
  }))
}
