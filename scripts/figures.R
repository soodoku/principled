library(ggplot2)

source("R/style.R")

dir.create("figs", showWarnings = FALSE)

p <- read.csv("tabs/primary.csv")

y <- subset(p, study == "YouGov")

y$measure <- ifelse(grepl("traits", y$outcome), "Favorable trait index", "Feeling thermometer")

y$label <- ifelse(y$contrast == "unbiased", "Fair-minded opposition\nRating the opposition",
  "Biased own party\nRating own party"
)

y$label <- factor(y$label, levels = c(
  "Biased own party\nRating own party",
  "Fair-minded opposition\nRating the opposition"
))

plot <- ggplot(y, aes(x = estimate, y = label)) +
  geom_vline(
    xintercept = 0,
    linetype = "dashed", color = "#888888"
  ) +
  geom_errorbar(aes(
    xmin = low,
    xmax = high
  ), orientation = "y", width = 0.12, linewidth = 0.5) +
  geom_point(
    size = 2.5,
    color = "#176B70"
  ) +
  facet_wrap(~measure, nrow = 1) +
  scale_x_continuous(breaks = seq(
    -4,
    6, 2
  ), limits = c(-4, 6)) +
  labs(x = "Difference from control (0-100 points)") +
  paper_theme()

save_figure(plot, "yougov_effects", height = 3.2)

m <- subset(read.csv("tabs/mturk_direct.csv"), sample == "Primary")

m$party <- factor(m$party, levels = c("Republican", "Democrat", "Pooled"))

m$target <- ifelse(m$contrast == "in_response", "Own party", "Opposition")

plot <- ggplot(m, aes(x = estimate, y = party)) +
  geom_vline(
    xintercept = 0,
    linetype = "dashed", color = "#888888"
  ) +
  geom_errorbar(aes(
    xmin = low,
    xmax = high
  ), orientation = "y", width = 0.15, linewidth = 0.5) +
  geom_point(
    size = 2.5,
    color = "#176B70"
  ) +
  facet_wrap(~target, nrow = 1) +
  scale_x_continuous(breaks = seq(
    -15,
    20, 5
  ), limits = c(-16, 22)) +
  labs(x = "Declining minus sustained approval (thermometer points)") +
  paper_theme()

save_figure(plot, "mturk_effects", height = 3.3)

s <- subset(
  read.csv("tabs/yougov_effects.csv"),
  party == "Pooled" & contrast == "unbiased" & outcome %in% c("out_ft", "out_traits")
)

s$specification <- ifelse(s$weighted, "Survey weighted", "Unweighted")

s$measure <- ifelse(s$outcome == "out_ft", "Feeling thermometer", "Favorable trait index")

c <- subset(read.csv("tabs/complete_items.csv"), contrast == "unbiased")

c$specification <- ifelse(c$weighted, "Six items, weighted", "Six items, unweighted")

c$measure <- "Favorable trait index"

x <- rbind(s[, c("estimate", "low", "high", "specification", "measure")], c[
  ,
  c("estimate", "low", "high", "specification", "measure")
])

x$specification <- factor(x$specification, levels = rev(c(
  "Unweighted", "Survey weighted",
  "Six items, unweighted", "Six items, weighted"
)))

plot <- ggplot(x, aes(x = estimate, y = specification)) +
  geom_vline(
    xintercept = 0,
    linetype = "dashed", color = "#888888"
  ) +
  geom_errorbar(aes(
    xmin = low,
    xmax = high
  ), orientation = "y", width = 0.12, linewidth = 0.5) +
  geom_point(
    size = 2.5,
    color = "#176B70"
  ) +
  facet_wrap(~measure, nrow = 1, scales = "free_y") +
  scale_x_continuous(breaks = seq(-4, 8, 2), limits = c(-4, 8)) +
  labs(x = "Fair-minded opposition minus control (0-100 points)") +
  paper_theme()

save_figure(plot, "sensitivity", height = 3.7)

items <- read.csv("tabs/trait_items.csv")

items$item <- factor(items$item, levels = rev(c(
  "ignorant", "sincere", "open_reason",
  "smug", "patriotic", "hypocritical"
)), labels = rev(c(
  "Less ignorant", "Sincere",
  "Open to reason", "Less smug", "Patriotic", "Less hypocritical"
)))

items$target <- ifelse(items$side == "out", "Fair-minded opposition", "Biased own party")

plot <- ggplot(items, aes(x = estimate, y = item)) +
  geom_vline(
    xintercept = 0,
    linetype = "dashed", color = "#888888"
  ) +
  geom_errorbar(aes(
    xmin = low,
    xmax = high
  ), orientation = "y", width = 0.15, linewidth = 0.5) +
  geom_point(
    size = 2,
    color = "#176B70"
  ) +
  facet_wrap(~target, nrow = 1) +
  labs(x = "Difference from control (0-100 favorable-rating points)") +
  paper_theme()

save_figure(plot, "trait_items", height = 4)
