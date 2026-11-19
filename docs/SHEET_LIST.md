# Sheet list

Made by `python scripts/make_sheet_list.py` from the files in `src/`. Do not edit by hand.

"Title on screen" is what the calculator shows at the top of the sheet. "Formula or hint" is the
line printed under it. Inputs are listed in the order they appear on screen.

## Analytics (16 sheets)

Source folder: `src/analytics/`

| File | Title on screen | Formula or hint | Inputs | Form layout |
|---|---|---|---|---|
| `01_Normal_Probability` | Normal: probability from X | Both tails computed exactly - no table lookup needed | x value; mu mean; sigma st dev | `form_columns` |
| `02_Inverse_Normal` | Inverse normal: X from probability | p is the area BELOW x. For an upper tail, enter 1 - tail | p area below x; mu mean; sigma st dev | `form_columns` |
| `03_Confidence_Interval_Z` | CI for the mean (z, large n) | z: 1.96=95% 1.645=90% 2.576=99%. Use 04 if n < 30 | x-bar sample mean; s st dev; n sample size; z critical | `form_columns` |
| `04_Confidence_Interval_T` | CI for the mean (t, small n) | t critical found from n automatically. Needs a normal population | x-bar sample mean; s sample st dev; n sample size; confidence | `form_columns` |
| `05_Sample_Size` | Required sample size | Answer is already rounded UP - quote the whole number | s st dev; E margin wanted; z critical | `form_columns` |
| `06_Test_One_Mean` | Test: one mean | p-value is two-sided. Reject when p < 0.05 | x-bar; s st dev; n; mu0 hypothesis; critical | `form_columns` |
| `07_Test_Two_Means` | Test: two means | D = hypothesised difference (0 = same). Uses the given two-sample SE | x-bar 1; x-bar 2; s1; s2; n1; n2; D hyp diff; critical | `form_columns` |
| `08_Combining_Variables` | Combining variables / portfolio | corr must be -1 to +1. Weights a,b are proportions (or 1,1 for a sum) | a weight x; b weight y; mu x; mu y; sigma x; sigma y; corr(x,y) | `form_columns` |
| `09_Bayes` | Bayes / screening reversal | Enter decimals. P(B\|not A) is the false-positive rate | P(A) prior; P(B\|A); P(B\|not A) | `form_columns` |
| `10_Confusion_Matrix` | Confusion matrix metrics | Rows = actual, columns = predicted. Compare accuracy against baseline | TN act0 pred0; FP act0 pred1; FN act1 pred0; TP act1 pred1 | `form_columns` |
| `11_Expected_Value` | Expected value (up to 6 outcomes) | Leave unused pairs blank. Probabilities must sum to 1 | p1; payoff 1; p2; payoff 2; p3; payoff 3; p4; payoff 4; p5; payoff 5; p6; payoff 6 | `form_columns` |
| `12_Decision_Table` | Decision table: EV, EVPI, maximin | Blank a whole action row to use fewer than 3. Esc clears all | grid: probabilities for up to 4 states, payoffs for up to 3 actions | `its own code` |
| `13_Regression_Coefficient` | Regression: test a coefficient | Excel's printed 95% limits use t, not 1.96 - see README | b coefficient; SE(b); b hypothesised; critical | `form_columns` |
| `14_Regression_Prediction` | Regression: predict + interval | Leave unused b/x pairs at 0. Interval uses SE of the regression | intercept b0; SE of regression; b1; x1; b2; x2; b3; x3; critical | `form_columns` |
| `15_Adjusted_R_Squared` | R-squared and adjusted R-squared | k = number of features (not counting the intercept) | R-squared; n observations; k features | `form_columns` |
| `16_Descriptive_Statistics` | Descriptive stats + correlation | Up/Down scroll Left/Right column Del clears cell Esc clears all | grid: up to 40 rows of X and Y values | `its own code` |

Total: 16 sheets.
