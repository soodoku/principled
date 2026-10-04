source("R/data.R")

source("R/analysis.R")

p <- read.csv("tabs/primary.csv")

y <- read.csv("tabs/yougov_effects.csv")

m <- read.csv("tabs/mturk_direct.csv")

f <- read.csv("tabs/sample_flow.csv")

complete <- read.csv("tabs/complete_items.csv")

bounds <- read.csv("tabs/missing_outcome_bounds.csv")

macros <- new.env(parent = emptyenv())

fmt <- function(x, digits = 1) formatC(x, digits = digits, format = "f")

count <- function(x) format(x, big.mark = ",", scientific = FALSE, trim = TRUE)

add <- function(name, value) assign(name, as.character(value), envir = macros)

result <- function(name, row) {
  stopifnot(nrow(row) == 1)
  add(paste0(name, "Estimate"), fmt(row$estimate))
  add(paste0(name, "CI"), paste0("[", fmt(row$low), ", ", fmt(row$high), "]"))
  add(paste0(name, "N"), count(row$n))
  add(paste0(name, "P"), fmt(row$p, 3))
}

result("MtIn", subset(p, study == "MTurk" & outcome == "in_ft"))

result("MtOut", subset(p, study == "MTurk" & outcome == "out_ft"))

result("YgOutFt", subset(p, study == "YouGov" & outcome == "out_ft"))

result("YgOutTrait", subset(p, study == "YouGov" & outcome == "out_traits"))

result("YgInFt", subset(p, study == "YouGov" & outcome == "in_ft"))

result("YgInTrait", subset(p, study == "YouGov" & outcome == "in_traits"))

result("YgWeightedTrait", subset(
  y, weighted & party == "Pooled" & contrast == "unbiased" & outcome == "out_traits"
))

result("YgWeightedFt", subset(
  y, weighted & party == "Pooled" & contrast == "unbiased" & outcome == "out_ft"
))

result("YgCompleteTrait", subset(complete, !weighted & contrast == "unbiased"))

result("YgCompleteWeighted", subset(complete, weighted & contrast == "unbiased"))

result("MtAllIn", subset(
  m, sample == "All assigned" & party == "Pooled" & outcome == "in_ft"
))

result("MtAsymmetry", read.csv("tabs/mturk_asymmetry.csv"))

result("MtDemOut", subset(
  m, sample == "Primary" & party == "Democrat" & outcome == "out_ft"
))

result("MtRepOut", subset(
  m, sample == "Primary" & party == "Republican" & outcome == "out_ft"
))

for (o in c("OutFt", "OutTrait", "InFt", "InTrait")) {
  code <- c(OutFt = "out_ft", OutTrait = "out_traits", InFt = "in_ft", InTrait = "in_traits")[[o]]
  r <- subset(p, study == "YouGov" & outcome == code)
  add(paste0("Yg", o, "Control"), fmt(r$baseline))
}

flow_value <- function(study, stage) f$n[f$study == study & f$stage == stage]

add("MtRaw", count(flow_value("MTurk", "Source records")))

add("MtAssigned", count(flow_value("MTurk", "Known assignment")))

add("MtN", count(flow_value("MTurk", "Partisan main sample")))

add("MtAttention", count(flow_value("MTurk", "Strict attention")))

add("MtAttentionDrop", count(flow_value("MTurk", "Source records") - flow_value(
  "MTurk",
  "Strict attention"
)))

add("MtUnassigned", count(flow_value("MTurk", "Source records") - flow_value(
  "MTurk",
  "Known assignment"
)))

add("MtDemN", count(flow_value("MTurk", "Democrats in main sample")))

add("MtRepN", count(flow_value("MTurk", "Republicans in main sample")))

add("YgRaw", count(flow_value("YouGov", "Source records")))

add("YgN", count(flow_value("YouGov", "Partisan main sample")))

add("YgFtMissing", count(flow_value("YouGov", "Partisan main sample") - flow_value(
  "YouGov",
  "Out-party thermometer observed"
)))

add("YgTraitMissing", count(flow_value("YouGov", "Partisan main sample") - flow_value(
  "YouGov",
  "Out-party traits observed"
)))

add("YgCompleteN", count(flow_value("YouGov", "Out-party six-item complete")))

z <- read_yougov()

add("YgDemN", count(sum(z$party == "Democrat")))

add("YgRepN", count(sum(z$party == "Republican")))

add("YgIndependentN", count(sum(z$party == "Independent")))

add("YgUnalignedN", count(sum(z$party == "Unaligned")))

add("YgTraitCategory", fmt(
  subset(p, study == "YouGov" & outcome == "out_traits")$estimate / 25,
  2
))

add("YgFtBound", paste0(
  "[", fmt(bounds$low[bounds$outcome == "out_ft"]), ", ",
  fmt(bounds$high[bounds$outcome == "out_ft"]), "]"
))

x <- subset(bounds, outcome == "out_traits" & assumption == "All missing constituent items")

add("YgTraitBound", paste0("[", fmt(x$low), ", ", fmt(x$high), "]"))

influence <- read.csv("tabs/influence.csv")

i <- subset(influence, study == "YouGov" & outcome == "out_traits")

add("YgTraitInfluence", paste0("[", fmt(i$deletion_min, 2), ", ", fmt(
  i$deletion_max,
  2
), "]"))

permutation <- read.csv("tabs/permutation.csv")

for (j in seq_len(nrow(p))) {
  prefixes <- c("MtIn", "MtOut", "YgOutFt", "YgOutTrait", "YgInFt", "YgInTrait")
  add(paste0(prefixes[j], "PermutationP"), fmt(permutation$p[j], 3))
}

writeLines(vapply(names(macros), function(n) {
  paste0(
    "\\newcommand{\\", n, "}{",
    macros[[n]], "}"
  )
}, character(1)), "tabs/macros.tex")

row <- function(...) paste0(paste(c(...), collapse = " & "), " \\\\")

ci <- function(d) {
  paste0(
    fmt(d$estimate), " [", fmt(d$low), ", ", fmt(d$high),
    "]"
  )
}

write_table <- function(lines, path, align) {
  writeLines(c(
    paste0("\\begin{tabular}{", align, "}"), "\\toprule", lines,
    "\\bottomrule", "\\end{tabular}"
  ), file.path("tabs", paste0(path, ".tex")))
}

lines <- c(
  row("Respondents", "Control", "Fair-minded opposition", "Biased own party"),
  "\\midrule"
)

a <- read.csv("tabs/yougov_assignment.csv")

for (party in c("Democrat", "Republican")) {
  lines <- c(lines, row(
    paste0(party, "s"),
    a$Freq[a$party == party & a$arm == "Control"],
    a$Freq[a$party == party & a$arm == "Unbiased"],
    a$Freq[a$party == party & a$arm == "Biased"]
  ))
}

write_table(lines, "assignment", "lrrr")

lines <- c(row(
  "Article / rated target", "Measure", "Control", "Difference [95\\% CI]",
  "$n$"
), "\\midrule")

for (i in which(p$study == "YouGov")) {
  r <- p[i, ]
  label <- if (r$contrast == "unbiased") {
    "Fair-minded opposition"
  } else {
    "Biased own party"
  }
  lines <- c(lines, row(
    label, if (grepl("traits", r$outcome)) "Traits" else "Warmth",
    fmt(r$baseline), ci(r), r$n
  ))
}

write_table(lines, "yougov_primary", "llrrr")

lines <- c(row("Sample", "Own party", "Opposition"), "\\midrule")

for (sample in c("Primary", "All assigned", "Loose attention")) {
  a <- m[m$sample == sample & m$party == "Pooled", ]
  label <- c(
    Primary = "Strict attention", `All assigned` = "No attention exclusion",
    `Loose attention` = "Loose attention"
  )[[sample]]
  lines <- c(lines, row(
    label, ci(a[a$outcome == "in_ft", ]), ci(a[a$outcome == "out_ft", ])
  ))
}

write_table(lines, "mturk_sensitivity", "lrr")

lines <- c(
  row("Target / measure", "Control $n$", "Fair-minded $n$", "Biased $n$"),
  "\\midrule"
)

miss <- subset(read.csv("tabs/missingness.csv"), study == "YouGov 2018")

for (out in c("out_ft", "out_traits", "out_complete", "in_ft", "in_traits")) {
  label <- c(
    out_ft = "Opposition warmth", out_traits = "Opposition traits",
    out_complete = "Opposition traits: six items", in_ft = "Own-party warmth",
    in_traits = "Own-party traits"
  )[[out]]
  cells <- vapply(c("Control", "Unbiased", "Biased"), function(a) {
    r <- miss[miss$outcome == out & miss$arm == a, ]
    paste0(sum(r$observed), "/", sum(r$assigned))
  }, character(1))
  lines <- c(lines, row(label, cells[1], cells[2], cells[3]))
}

write_table(lines, "response", "lrrr")

lines <- c(row("Article", "Outcome", "Democrats", "Republicans"), "\\midrule")

for (con in c("unbiased", "biased")) {
  for (out in c("out_ft", "out_traits", "in_ft", "in_traits", "gap_ft")) {
    r <- subset(y, !weighted & contrast == con & outcome == out)
    label <- c(
      out_ft = "Opposition warmth", out_traits = "Opposition traits",
      in_ft = "Own-party warmth", in_traits = "Own-party traits", gap_ft = "Warmth gap"
    )[[out]]
    lines <- c(lines, row(
      if (con == "unbiased") "Fair-minded opposition" else "Biased own party",
      label, ci(r[r$party == "Democrat", ]), ci(r[r$party == "Republican", ])
    ))
  }
}

write_table(lines, "yougov_by_party", "llrr")

lines <- c(row("Target", "Decline versus Ford", "Sustained versus Ford"), "\\midrule")

mc <- read.csv("tabs/mturk_control_comparisons.csv")

for (party in c("Democrat", "Republican")) {
  lines <- c(lines, paste0("\\multicolumn{3}{l}{\\textit{", party, " respondents}} \\\\"))
  for (target in c("In", "Out")) {
    out <- if (target == "In") {
      "in_ft"
    } else {
      "out_ft"
    }
    r <- mc[mc$party == party & mc$outcome == out, ]
    lines <- c(lines, row(
      if (target == "In") "Own party" else "Opposition",
      ci(r[r$contrast == paste(target, "decline"), ]),
      ci(r[r$contrast == paste(target, "stable"), ])
    ))
  }
}

write_table(lines, "mturk_control", "lrr")

lines <- c(
  row("Respondents", "Article", "Republican traits", "Republican warmth"),
  "\\midrule"
)

np <- read.csv("tabs/nonpartisans.csv")

for (party in c("Independent", "Unaligned")) {
  for (con in c("unbiased", "biased")) {
    r <- np[np$party == party & np$contrast == con, ]
    lines <- c(lines, row(
      if (party == "Unaligned") "Not sure" else "Independent",
      con, ci(r[r$outcome == "target_traits", ]), ci(r[r$outcome == "target_ft", ])
    ))
  }
}

write_table(lines, "nonpartisans", "llrr")

readme <- readLines("docs/README.md.in")

for (n in names(macros)) {
  readme <- gsub(paste0("@", n, "@"), macros[[n]], readme,
    fixed = TRUE
  )
}

if (any(grepl("@[A-Za-z]+@", readme))) stop("Unresolved README value")

writeLines(readme, "README.md")
