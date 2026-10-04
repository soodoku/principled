# Data and provenance

The public CSVs contain one row per source record. `row_id` is a sequential export identifier, not the survey provider's respondent identifier. Numeric response codes and missing values are preserved until the shared cleaning functions in `R/data.R` recode them.

| Public file | Source file | Records |
| --- | --- | ---: |
| `data/raw/mturk.csv` | `mturk_as/partisanresponse.csv` | 930 |
| `data/raw/yougov.csv` | `yougov_june_2018/VAND0025_OUTPUT.sav` | 1,500 |

Source SHA256 hashes and retained column counts are in [source_manifest.csv](source_manifest.csv). The YouGov field labels and value labels are in [yougov_dictionary.csv](yougov_dictionary.csv). Questionnaires and the vendor codebook are in `data/materials/`; consult them for exact wording. The current article images/PDFs are the experimental stimuli, not verified journalism. The article variants reproduced in those materials supply the interpretation of assignment codes.

## Optional export from original files

The reproduction pipeline needs only the public CSVs. Authors retaining the original study folders can recreate the exports with:

```sh
Rscript scripts/prepare_data.R /path/to/private-data
```

The supplied directory must contain `mturk_as/partisanresponse.csv` and `yougov_june_2018/VAND0025_OUTPUT.sav`. The exporter reads but never edits these originals. It checks source record counts and unique source identifiers, selects an explicit list of numeric fields, and writes the public CSVs, dictionary, and source manifest. The authors retain a byte-verified copy of all original source materials outside the public release. `private-data/` is ignored by Git. Direct identifiers, IP addresses, timestamps, contact details, and free text are omitted from the public export, rather than overwritten in the originals.

## MTurk fields

- `pid`, `pid_d`, `pid_r`, and `pid_i` define party, strength, and independent leaning. Main party codes are 1 Democrat and 2 Republican; codes 3–4 use the leaning branch, whose codes are 3 Democrat, 1 Republican, and 2 neither.
- `attn_check_1` through `attn_check_10` are marked 1 when chosen and blank otherwise. The strict check requires exactly choices 3 and 5.
- `dt`, `dc`, `rt`, `rc`, and `q48` identify the five article branches: Democratic sustained support, Democratic declining support, Republican sustained support, Republican declining support, and Ford control. An observed 1 identifies assignment; all blank means no known assignment. More than one assignment is an error.
- `ft_1`/`q53_1` and `ft_2`/`q53_2` are duplicate order branches for Democratic and Republican thermometers. Values are actual 0–100 scores.
- `dem_traits_1`–`dem_traits_8` and the corresponding `rep` fields have a second branch ending in `.1`. Item order is ignorant, sincere, open to reason, smug, selfish, patriotic, compassionate, hypocritical. Values 1–5 run from very poorly to very well.
- Demographic, political-interest, and knowledge fields are retained as numeric responses with their questionnaire wording. They are not required covariates for the main contrasts.

## YouGov fields

- `article_treat`: 1 control, 2 fair-minded Democrats, 3 biased Democrats, 4 fair-minded Republicans, 5 biased Republicans.
- `pid7pre` supplies treatment-routing party. `pid3pre`, `pid3`, and `pid7` are retained for documentation and reconciliation.
- `ftdems` and `ftreps` are actual 0–100 thermometer responses; 998 is nonresponse.
- `dem_*` and `gop_*` are the six trait responses. Their exact labels and codes are in the exported dictionary. Codes 8–9 are not treated as substantive scale values.
- `weight` is the positive vendor weight. The codebook describes recruitment, matching, and calibration. No new weights are fitted in this repository.
- `aware` and the three `*_check` fields are post-article checks. They are not used to select the main sample. After the affect outcomes, `dem_check` (articles 2–3) and `rep_check` (articles 4–5) ask whether the portrayed party was more biased (1), less biased (2), or about as biased (3) as previously expected; 4 is “don’t know,” and 8–9 are missing. `relative_bias` selects the portrayed party’s response and is missing for control respondents, who received a different check.

The merged survey deliveries contain the same core 2018 observations and a subset of earlier-wave responses; the 2018 source supplies the common cross-sectional experiment. The public release does not depend on an undocumented merge or treat the partially observed earlier wave as a complete baseline.
