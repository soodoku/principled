source("R/data.R")

source("R/analysis.R")

dir.create("tabs", showWarnings = FALSE)

save_table <- function(x, name) {
  write.csv(x, file.path("tabs", paste0(
    name,
    ".csv"
  )), row.names = FALSE, na = "")
}

mt <- read_mturk()

yg <- read_yougov()

m <- mt[mt$assigned & mt$attention & mt$party %in% c("Democrat", "Republican"), ]

y <- yg[yg$party %in% c("Democrat", "Republican"), ]

contrasts_mt <- list(in_response = c(`In decline` = 1, `In stable` = -1), out_response = c(
  `Out decline` = 1,
  `Out stable` = -1
))

contrasts_yg <- list(unbiased = c(Unbiased = 1, Control = -1), biased = c(
  Biased = 1,
  Control = -1
))

add_result <- function(result, study, contrast, sample = "Primary", party = "Pooled") {
  cbind(
    study = study, contrast = contrast, sample = sample, party = party,
    result
  )
}

mt_results <- list()

for (sample in c("Primary", "All assigned", "Loose attention")) {
  z <- mt[mt$assigned & mt$party %in% c("Democrat", "Republican"), ]
  if (sample == "Primary") {
    z <- z[z$attention, ]
  }
  if (sample == "Loose attention") {
    z <- z[z$attention_loose, ]
  }
  for (p in c("Pooled", "Democrat", "Republican")) {
    dz <- if (p == "Pooled") {
      z
    } else {
      z[z$party == p, ]
    }
    for (nm in names(contrasts_mt)) {
      out <- if (nm == "in_response") {
        "in_ft"
      } else {
        "out_ft"
      }
      mt_results[[length(mt_results) + 1]] <- add_result(estimate_contrast(
        dz,
        out, contrasts_mt[[nm]]
      ), "MTurk", nm, sample, p)
    }
  }
}

mt_results <- do.call(rbind, mt_results)

save_table(mt_results, "mturk_direct")

yg_results <- list()

for (weighted in c(FALSE, TRUE)) {
  for (p in c("Pooled", "Democrat", "Republican")) {
    z <- if (p == "Pooled") {
      y
    } else {
      y[y$party == p, ]
    }
    for (nm in names(contrasts_yg)) {
      for (out in c(
        "out_ft", "out_traits", "in_ft", "in_traits", "gap_ft",
        "gap_traits"
      )) {
        yg_results[[length(yg_results) + 1]] <- add_result(estimate_contrast(
          z,
          out, contrasts_yg[[nm]], weighted
        ), "YouGov", nm, if (weighted) {
          "Survey weighted"
        } else {
          "Primary"
        }, p)
      }
    }
  }
}

yg_results <- do.call(rbind, yg_results)

save_table(yg_results, "yougov_effects")

primary_mt <- subset(mt_results, sample == "Primary" & party == "Pooled")

primary_outcome <- with(yg_results, ifelse(
  contrast == "unbiased",
  outcome %in% c("out_ft", "out_traits"),
  outcome %in% c("in_ft", "in_traits")
))
primary_yg <- yg_results[
  yg_results$sample == "Primary" & yg_results$party == "Pooled" & primary_outcome,
]

primary_mt$p_holm <- p.adjust(primary_mt$p, "holm")

primary_yg$p_holm <- p.adjust(primary_yg$p, "holm")

primary <- rbind(primary_mt, primary_yg)

save_table(primary, "primary")

levels <- list()

for (study in c("MTurk", "YouGov")) {
  z <- if (study == "MTurk") {
    m
  } else {
    y
  }
  for (out in c("in_ft", "out_ft", "in_traits", "out_traits")) {
    levels[[length(levels) + 1]] <- cbind(
      study = study, outcome = out,
      cell_statistics(z, out)
    )
  }
}

save_table(do.call(rbind, levels), "cell_means")

save_table(rbind(
  missingness_table(m, c("in_ft", "out_ft", "in_traits", "out_traits")),
  missingness_table(y, c(
    "in_ft", "out_ft", "in_traits", "out_traits", "out_complete",
    "in_complete"
  ))
), "missingness")

flow <- data.frame(
  study = c(rep("MTurk", 7), rep("YouGov", 6)), stage = c(
    "Source records",
    "Known assignment", "Strict attention", "Strict attention and assignment",
    "Partisan main sample", "Democrats in main sample", "Republicans in main sample",
    "Source records", "Partisan main sample", "Out-party thermometer observed",
    "Out-party traits observed", "Out-party six-item complete", "Nonpartisans"
  ),
  n = c(
    nrow(mt), sum(mt$assigned), sum(mt$attention), sum(mt$assigned & mt$attention),
    nrow(m), sum(m$party == "Democrat"), sum(m$party == "Republican"), nrow(yg),
    nrow(y), sum(!is.na(y$out_ft)), sum(!is.na(y$out_traits)), sum(!is.na(y$out_complete)),
    sum(!yg$party %in% c("Democrat", "Republican"))
  )
)

save_table(flow, "sample_flow")

save_table(as.data.frame(with(yg, table(party, arm))), "yougov_assignment")

reported_bias <- list()

for (arm in c("Unbiased", "Biased")) {
  z <- y[y$arm == arm, ]
  response <- factor(ifelse(is.na(z$relative_bias), 5, z$relative_bias),
    levels = 1:5,
    labels = c("More biased", "Less biased", "About as biased", "Don't know", "Missing")
  )
  counts <- as.data.frame(table(response))
  reported_bias[[arm]] <- data.frame(
    arm = arm, response = counts$response, n = counts$Freq,
    assigned = nrow(z), percent = 100 * counts$Freq / nrow(z)
  )
}

save_table(do.call(rbind, reported_bias), "reported_bias")

save_table(as.data.frame(with(mt, table(party, article, attention))), "mturk_assignment")

save_table(as.data.frame(with(yg, table(party, current_party))), "party_reconciliation")

complete <- list()

for (side in c("out", "in")) {
  nm <- if (side == "out") {
    "unbiased"
  } else {
    "biased"
  }
  for (weighted in c(FALSE, TRUE)) {
    complete[[length(complete) + 1]] <- add_result(
      estimate_contrast(
        y,
        paste0(side, "_complete"), contrasts_yg[[nm]], weighted
      ), "YouGov",
      nm, "Six-item complete"
    )
  }
}

save_table(do.call(rbind, complete), "complete_items")

items <- c("ignorant", "sincere", "open_reason", "smug", "patriotic", "hypocritical")

item_results <- list()

omit_results <- list()

for (side in c("out", "in")) {
  nm <- if (side == "out") {
    "unbiased"
  } else {
    "biased"
  }
  for (item in items) {
    item_results[[length(item_results) + 1]] <- cbind(
      side = side, item = item,
      estimate_contrast(y, paste0(side, "_score_", item), contrasts_yg[[nm]])
    )
    z <- y
    z$reduced <- available_mean(z[, paste0(side, "_score_", setdiff(
      items,
      item
    ))])
    omit_results[[length(omit_results) + 1]] <- cbind(
      side = side, omitted = item,
      estimate_contrast(z, "reduced", contrasts_yg[[nm]])
    )
  }
}

item_results <- do.call(rbind, item_results)

item_results$p_holm <- p.adjust(item_results$p, "holm")

save_table(item_results, "trait_items")

save_table(do.call(rbind, omit_results), "leave_one_item_out")

bounds <- list()

influence <- list()

permutation <- list()

response <- list()

for (i in seq_len(nrow(primary))) {
  row <- primary[i, ]
  z <- if (row$study == "MTurk") {
    m
  } else {
    y
  }
  con <- if (row$study == "MTurk") {
    contrasts_mt[[row$contrast]]
  } else {
    contrasts_yg[[row$contrast]]
  }
  influence[[i]] <- cbind(study = row$study, contrast = row$contrast, contrast_influence(
    z,
    row$outcome, con
  ))
  permutation[[i]] <- cbind(study = row$study, contrast = row$contrast, permutation_check(
    z,
    row$outcome, con
  ))
  if (row$study == "YouGov") {
    bounds[[length(bounds) + 1]] <- cbind(
      contrast = row$contrast, assumption = "Wholly missing outcome",
      missing_bounds(z, row$outcome, con)
    )
    if (grepl("traits", row$outcome)) {
      side <- sub("_traits", "", row$outcome)
      bounds[[length(bounds) + 1]] <- cbind(
        contrast = row$contrast, assumption = "All missing constituent items",
        missing_bounds(
          z, row$outcome, con, paste0(side, "_lower"),
          paste0(side, "_upper")
        )
      )
    }
    z$observed <- 100 * !is.na(z[[row$outcome]])
    response[[length(response) + 1]] <- cbind(
      outcome_original = row$outcome,
      contrast = row$contrast, estimate_contrast(z, "observed", con)
    )
  }
}

save_table(do.call(rbind, bounds), "missing_outcome_bounds")

save_table(do.call(rbind, influence), "influence")

save_table(do.call(rbind, permutation), "permutation")

save_table(do.call(rbind, response), "response_differences")

mt_control <- list()

for (p in c("Democrat", "Republican")) {
  z <- m[m$party == p, ]
  for (arm in c("Out decline", "Out stable", "In decline", "In stable")) {
    for (out in c("out_ft", "in_ft")) {
      con <- setNames(c(1, -1), c(arm, "Control"))
      mt_control[[length(mt_control) + 1]] <- cbind(
        party = p, contrast = arm,
        estimate_contrast(z, out, con)
      )
    }
  }
}

save_table(do.call(rbind, mt_control), "mturk_control_comparisons")

z <- m

z$target_ft <- ifelse(grepl("^In", z$arm), z$in_ft, z$out_ft)

con <- c(`Out decline` = 1, `Out stable` = -1, `In decline` = -1, `In stable` = 1)

save_table(estimate_contrast(z, "target_ft", con), "mturk_asymmetry")

nonpartisan <- list()

for (p in c("Independent", "Unaligned")) {
  z <- yg[yg$party == p, ]
  for (out in c("target_ft", "target_traits")) {
    for (nm in names(contrasts_yg)) {
      nonpartisan[[length(nonpartisan) + 1]] <- cbind(
        party = p, contrast = nm,
        estimate_contrast(z, out, contrasts_yg[[nm]])
      )
    }
  }
}

save_table(do.call(rbind, nonpartisan), "nonpartisans")

writeLines(capture.output(sessionInfo()), "tabs/session_info.txt")

print(primary[, c(
  "study", "contrast", "outcome", "estimate", "low", "high",
  "n", "eligible", "p_holm"
)], row.names = FALSE)
