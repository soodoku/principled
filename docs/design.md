# Research design and analysis

## Questions and comparisons

The experiments ask whether evaluations respond to portrayals of partisans as holding their leaders accountable or reasoning fairly. The units are individual survey respondents. Treatment is assignment to a particular article, not observed reasoning ability.

| Study | Eligible primary sample | Main comparison | Outcome | Interpretation |
| --- | --- | --- | --- | --- |
| MTurk, November 2013 | Assigned Democrats and Republicans, including leaners, passing the pre-treatment attention check | Declining minus sustained approval, within the story about the same leader | Warmth toward the described party's supporters | Effect of the approval-story variant; changes in levels and accompanying narrative remain bundled |
| YouGov, May 2018 | Democrats and Republicans, including leaners, defined by pre-assignment party | Fair-minded opposition minus control | Opposition trait index and party warmth | Effect of the opposition article package |
| YouGov, May 2018 | Same | Biased own party minus control | Own-party trait index and party warmth | Effect of the own-party article package |

YouGov partisans had no fair-minded-own-party or biased-opposition treatment. The design cannot compare identical portrayals of allies and opponents. Independents and “not sure” respondents received Republican articles; their Republican evaluations are separate descriptive experimental comparisons.

The questionnaire describes random assignment, but execution logs are unavailable. Assignment codes and partisan eligibility agree. Neither randomization nor adjustment separates the component effects of article wording, source quotations, dates, portrayed behavior, and party references. Post-treatment manipulation checks are not exclusion criteria or covariates.

## Samples and measurement

MTurk excludes only records without known assignment, nonpartisans, and failures of the pre-treatment instruction to select only blue and yellow. The “loose attention” sensitivity allows extra colors; the no-exclusion sensitivity retains all assigned partisans. Both party thermometers are observed for every known assignment. Multiple outcome blocks represent different question orderings; conflicting duplicate answers cause an error rather than silent replacement.

YouGov uses `pid7pre`, the variable determining eligible articles. Codes 1–3 identify Democrats, 5–7 Republicans, 4 independents, and 8–9 unaligned respondents. Current party variables are retained for reconciliation, but do not redefine eligibility. No demographic, knowledge, response-time, or post-treatment filter is applied. The primary contrasts use observed outcomes within the two relevant arms; the remaining treatment arm contributes only to the fixed eligible party shares.

Thermometers preserve their original 0–100 values. YouGov code 998 is missing. MTurk thermometers name Democrats and Republicans; YouGov names the Democratic Party and Republican Party. The two measures are not pooled across studies.

The YouGov favorable trait index is the mean of available responses to six items. Sincere, open to reason, and patriotic are scored `25 * (response - 1)`; ignorant, smug, and hypocritical are scored `25 * (5 - response)`. Raw responses 1–5 mean very poorly through very well; 8–9 are missing. All-missing indices remain missing. The complete-item alternative requires six observed items. The questionnaire's selfish item is absent from the delivered survey and merged files. The available-item index is a descriptive equal-weight composite, not a validated measure of a single latent trait. Pilot trait levels use all eight observed items with their documented orientation; the primary pilot effects concern warmth.

## Reported bias relative to expectations

After the outcomes, YouGov respondents who read a partisan article reported whether the portrayed party was more, less, or about as biased as previously expected. `tabs/reported_bias.csv` reports unweighted counts and percentages within each article arm, restricted to the main partisan sample. The denominator includes every assigned partisan in that arm, including “don't know” and missing answers. These descriptive percentages do not use the party standardization applied to treatment-effect estimates.

The control arm has no equivalent question. Answers are retrospective and collected after the outcomes; they are neither measured pre-to-post belief changes nor randomized mediators. They help describe how respondents interpreted the articles, but cannot establish that failed updating explains a treatment effect. We neither condition the effect estimates on these answers nor compare the two article arms as if they portrayed the same party.

## Estimation and inference

`R/analysis.R` calculates cell means by pre-treatment party and article. Pooled estimates average within-party arm contrasts using the eligible sample's party shares. The main sample and its shares are defined before outcome deletion. This is an average for that sample composition, not an equal-party average. Party-specific estimates are also reported.

For unweighted estimates, each independent cell contributes squared contrast weight times its sample variance divided by observed count. Intervals use Welch–Satterthwaite degrees of freedom. The weighted alternative uses supplied survey weights for both cell means and eligible party shares, HC3 cell variances, and a t reference with observed comparison count minus compared cells degrees of freedom. Supplied weights and party shares are treated as fixed. Weight-estimation and sample-selection uncertainty are not included. No causal population representativeness follows simply from having calibration weights.

Primary p-values have Holm adjustments within study (two MTurk, four YouGov comparisons). Figure and table intervals are unadjusted 95% intervals. Item-level p-values also have an adjustment across all twelve displayed constituent-item contrasts. Secondary comparisons are exploratory.

The independent unit assumption is at respondent level. No repeated respondent outcomes are stacked and then treated as independent: each contrast uses one outcome per person. When comparing own-party and opposition effects in the pilot, their article arms are disjoint; the combined variance includes all compared cells. A trait-versus-warmth significance comparison is not used as a test that the effects differ.

## Sensitivity

The pipeline produces party-specific estimates, weighting alternatives, attention alternatives, complete-item and leave-one-item-out indices, exact single-case deletion ranges, outcome-response contrasts, and stratified permutation checks. The permutation checks use 9,999 draws and seed 20261004, conditional on the observed-outcome sample and realized within-party arm counts. They require exchangeability in that selected sample and do not cure treatment-dependent missingness.

Worst-case bounds fill missing outcomes with endpoints of their known scale. For the six-item mean, each missing constituent answer is filled separately, retaining the observed answers. These are completion bounds for the realized dataset, not uncertainty intervals for a population effect. They are reported separately from sampling intervals.

No preregistered plan is available in the repository. The analysis is exploratory, with a finite set of stimuli and immediate self-report outcomes. It cannot establish actual reasoning quality, causal mediation, durable affect, or effects for the entire American population.
