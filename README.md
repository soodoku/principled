# Principled Partisan Affect?

**Evidence from Two Survey Experiments**

Douglas J. Ahler, Carolyn E. Roush, and Gaurav Sood

[Read the paper](ms/main.pdf) · [Research design and measurement](docs/design.md) · [Data and reproduction](docs/data.md)

## TL;DR

Do people reward fellow partisans for holding their leaders accountable, or prefer them to remain loyal? Do they warm to opponents who appear fair-minded? Two survey experiments offer limited evidence on these questions.

### 2013: Do people reward their own side for withdrawing support?

MTurk respondents read news stories saying that Democrats' support for Obama or Republicans' support for Cruz either **declined or remained high after a controversy**. They then rated how warmly they felt toward Democrats and Republicans. The outcome was their view of those partisan groups.

- When the story concerned **their own party**, respondents who read about declining support rated their fellow partisans **less warmly** than those who read about sustained support: a **-4.3-point difference** on a 0–100 scale (95% CI [-8.9, 0.2]).
- When the story concerned **the opposing party**, declining support produced slightly **warmer ratings of that party's members**: a **1.2-point difference** ([-4.1, 6.5]).

The first estimate points in the opposite direction from rewarding one's own side for holding its leader accountable. It could reflect a preference for loyalty. **But both confidence intervals include zero, and the stories differed in more than the approval trend.** These results do not establish a preference for loyalty, a reward for accountability, or different standards for allies and opponents.

### 2018: Do fair-minded opponents become more appealing?

YouGov respondents read a control article, an article portraying the opposing party as fair-minded, or one portraying their own party as biased. They then rated the parties' traits and how warmly they felt toward them.

The article portraying opponents as fair-minded raised favorable trait ratings by **2.5 points** on a 0–100 scale (95% CI [-0.3, 5.4]), but changed warmth by only **0.5 points** ([-2.8, 3.9]). The article portraying respondents' own party as biased produced no clear penalty. The trait improvement is suggestive; its precision depends on survey weighting and whether the index requires answers to every item.

YouGov did not show partisans stories about **fair-minded allies or biased opponents**. It therefore cannot test whether people judge the same behavior differently depending on which party displays it. Both studies measure immediate reactions to particular news stories, whose wording and commentary changed along with the depicted behavior. Neither establishes actual reasoning quality or lasting attitude change.

## Reproduce

Use R 4.6.0, GNU Make, and a TeX installation with XeLaTeX and `latexmk`. R dependencies are pinned in `renv.lock`.

```sh
make restore
make check
```

`make check` rebuilds the analysis, figures, tables, README, and PDF; runs R linting; and tests recodes, estimators, and sample accounting. `make analysis` rebuilds the CSV results alone. `make paper` produces `ms/main.pdf`. No private files are needed.

The main analyses use 724 MTurk partisans passing a pre-treatment attention check and 1,133 YouGov partisans identified by the party measure used to route treatment. Leaners count as partisans. Estimates standardize within-party comparisons to each study's eligible partisan composition. YouGov survey-weighted estimates, complete-item analyses, response rates, missing-outcome bounds, item decomposition, and party-specific results accompany the primary unweighted estimates.

## Repository

| Path | Contents |
| --- | --- |
| `data/raw/` | Public respondent-level exports, with original numeric response codes |
| `data/materials/` | Questionnaires, codebook, and the stimuli used to interpret assignment |
| `R/` | Shared cleaning, estimation, and figure style |
| `scripts/` | Reproduction and optional export from privately retained source data |
| `tabs/`, `figs/` | Generated estimates, diagnostics, tables, and figures |
| `ms/` | Manuscript source, references, and compiled paper |
| `docs/` | Design, data provenance, and a claim-to-output ledger |
| `tests/` | Data integrity and estimator verification |

The public exports omit respondent identifiers, IP addresses, emails, and free text. The authors retain the original files separately; the optional export step does not alter them. See [data documentation](docs/data.md).

## Citation

Ahler, Douglas J., Carolyn E. Roush, and Gaurav Sood. *Principled Partisan Affect? Evidence from Two Survey Experiments*. Research note. See [CITATION.cff](CITATION.cff) for machine-readable metadata.

The README is generated from `docs/README.md.in` and the analysis results. Edit the template to keep quoted estimates synchronized with the paper.
