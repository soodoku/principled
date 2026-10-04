# Verification

The unit tests exercise behavior rather than README content: unexpected response codes and conflicting branches fail; wholly missing indices remain missing; thermometers retain their original values; eligible samples and assignment cells agree with the delivered data. Tests compare unweighted intervals with `t.test`, weighted HC3 variances with a separately fitted saturated regression, and case-deletion calculations with direct refits. A seeded simulation checks coverage for a known average effect with unequal party-specific effects and variances.

## Analysis checks

| Area | Check and interpretation |
| --- | --- |
| Unit and denominator | One source row per respondent; original source identifiers unique; no joins required. Each reported comparison count uses only observed outcomes in its compared arms. Party shares use the full eligible sample. |
| Assignment | Exactly one known MTurk article or no known assignment; YouGov assignments agree with pre-party eligibility. Unknown assignment is never coded as control. Execution logs are unavailable. |
| Timing | Pilot attention and party identification precede treatment. YouGov routing uses pre-assignment party. Post-article awareness and manipulation checks are not controls or exclusions. |
| Measurement | Original thermometer codes are preserved. Negative traits reverse direction before averaging. All-missing indices remain missing. Pilot gaps are always own-party minus opposition. |
| Levels | `cell_means.csv` reports each cell's mean, range, floor/ceiling shares, and sample size. Favorable opposition ratings are low at baseline; this does not imply every respondent is at the floor or unable to move downward. |
| Inference | Cell variances match independent calculations. Main unweighted intervals allow unequal variances. Weighted alternatives condition on supplied weights and target different party shares. No claim compares subgroup significance as if it tested an interaction. |
| Multiplicity | Main p-values adjusted within study; constituent-item p-values adjusted together. Unadjusted intervals are labeled. Secondary estimates remain exploratory. |
| Missing outcomes | Reported by party and arm; outcome-response contrasts and endpoint-completion bounds are generated. The warmth contrast has substantial missingness. Bounds and confidence intervals answer different questions. |
| Influence and specifications | Exact respondent deletion, leave-one-item-out indices, complete-item means, survey weighting, party-specific estimates, and pilot attention alternatives are generated. No single-case deletion reverses the positive YouGov trait point estimate. |
| Randomization check | Seeded assignment permutations preserve within-party arm counts among observed respondents. This conditional exercise does not resolve selective outcome observation. |
| Generalization | Neither convenience recruitment nor vendor matching is a probability sample. Fixed news articles are not a random sample of possible portrayals. Immediate ratings do not establish lasting change. |
| Identification | Missing YouGov target-by-portrayal cells prevent a factorial double-standard test. Article components are bundled. No mediation effect is estimated. |
| Manuscript provenance | All computed prose estimates and table bodies are generated. Literal dates, scale endpoints, response codes, and vendor interview counts are design facts. Reference metadata was checked against publisher records. |

Panel estimators, instrumental variables, discontinuities, spillover estimators, and mediation inference are inapplicable to the reported analysis. The partially observed earlier-wave data are not required for the cross-sectional randomized contrasts.

## Reproduction gates

`make check` runs the full analysis, generated figures and tables, manuscript compilation, linting, and tests. A release also requires independent review, inspection of every rendered manuscript page, and CI on the publication commit. See the GitHub release for the checks on a particular version.
