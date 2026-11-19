# TI-Nspire Statistics and Analytics Calculators

16 calculator sheets for normal and t intervals, hypothesis tests, sample size, Bayes, expected value, confusion matrices, regression, decision tables and descriptive statistics. Each sheet opens as a simple form on a TI-Nspire CX or CX CAS: type the numbers you
have and the answer appears underneath.

> **Version 1.0.0.** Every sheet has been tested and verified. Check one sheet first (step 6 below).Check one sheet first (step 6 below).

## Contents

1. [Put the sheets on your calculator](#1-put-the-sheets-on-your-calculator)
2. [Use a sheet](#2-use-a-sheet)
3. [The sheets](#3-the-sheets)
4. [Notes on particular sheets](#4-notes-on-particular-sheets)
5. [If something goes wrong](#5-if-something-goes-wrong)
6. [Known limitations](#6-known-limitations)
7. [For developers](#7-for-developers)
8. [Licence, security and support](#8-licence-security-and-support)

## 1. Put the sheets on your calculator

You need a TI-Nspire CX or CX CAS, its USB cable, and **TI-Nspire Computer Link Software** (free from
education.ti.com) on a Windows or Mac computer.

1. **Download.** Open this repository's **Releases** page, download `ti-nspire-analytics-calculators-1.0.0.zip` and unzip it.
   You get a folder called `analytics` and a `README.txt`.
2. **Connect.** Turn the calculator on and plug it into the computer.
3. **Open Computer Link.** In the Select Handheld window, click your calculator, then **Select**.
4. **Copy.** The top pane shows your computer and the bottom pane shows the calculator. Drag the
   `analytics` folder from the top pane to the bottom pane.
5. **Leave `README.txt` behind.** Computer Link only copies calculator files and cancels the whole
   copy if you include anything else.
6. **Check.** On the calculator press [home], open **My Documents**, then `analytics`, then
   `05_Sample_Size`. Press 15 [enter] 2 (words in square brackets are keys; the rest
   are numbers to type). You should see **n REQUIRED** 217.

The `README.txt` in the zip has the same steps in more detail, with fixes for common problems.
No release yet? Build the zip yourself (section 7).

## 2. Use a sheet

| Sheets | Move | Type | Reset |
|---|---|---|---|
| Sheets 01–11, 13–15 | arrow keys ([left] [right] too on two-column sheets), or [enter] / [tab] | number keys and `.`; `(-)` switches the sign; [backspace] deletes | [esc] puts every field back to its default |
| Sheets 12 and 16 (grids) | arrow keys between cells, or [enter] / [tab] | number keys, `.` and `(-)`; [backspace] deletes | [esc] empties the whole grid |

- Type probabilities and confidence levels as decimals: `0.95`.
- Some fields start with a default, such as a critical value of 1.96. The first key you press in that field replaces it.
- Results appear under the RESULTS line. Orange rows are warnings or input checks.
- If the calculator asks to save changes when you close a sheet, either answer is fine.

**Example.** Confidence interval (`04_Confidence_Interval_T`): mean 50, standard deviation 10, sample size 10, confidence 0.95 (already filled in). Press 50 [enter] 10 [enter] 10:

| Row | Shows |
|---|---|
| t critical | 2.26216 |
| CI lower | 42.8464 |
| CI upper | 57.1536 |

## 3. The sheets

| Sheet | What it works out |
|---|---|
| `01_Normal_Probability` | Probabilities below, above and either side of a value |
| `02_Inverse_Normal` | The value with a given probability below it |
| `03_Confidence_Interval_Z` | Confidence interval for a mean with a z critical value |
| `04_Confidence_Interval_T` | Confidence interval for a mean with the t distribution |
| `05_Sample_Size` | Sample size needed for a given margin of error |
| `06_Test_One_Mean` | Test of one mean against a hypothesised value |
| `07_Test_Two_Means` | Test of the difference between two means |
| `08_Combining_Variables` | Mean and spread of a weighted sum of two variables |
| `09_Bayes` | Bayes' rule for a test or screening result |
| `10_Confusion_Matrix` | Accuracy, sensitivity, specificity and more from a confusion matrix |
| `11_Expected_Value` | Expected value and spread over up to six outcomes |
| `12_Decision_Table` | Best action by expected value, value of perfect information, maximin and maximax |
| `13_Regression_Coefficient` | Test a regression coefficient and its confidence interval |
| `14_Regression_Prediction` | Prediction from a regression with an interval |
| `15_Adjusted_R_Squared` | Adjusted R-squared |
| `16_Descriptive_Statistics` | Mean, median, spread, covariance and correlation of up to 40 pairs |

[docs/SHEET_LIST.md](docs/SHEET_LIST.md) lists every input of every sheet.

## 4. Notes on particular sheets

- **Which critical value.** The interval and test sheets multiply a standard error by the critical value you enter. 1.96 is the two-sided 95% value for the normal distribution (1.645 for 90%, 2.576 for 99%). For a small sample use a t value: `04_Confidence_Interval_T` finds it from n and the confidence level.
- **p-values.** The p-value rows in sheets 06, 07 and 13 always use the normal distribution. With fewer than 30 observations the sheets say so.
- **`13_Regression_Coefficient`.** Excel's regression table prints 95% limits using t with the residual degrees of freedom (n − k − 1), so they are a little wider than b ± 1.96 × SE(b). To match Excel, enter that t value as the critical value; sheet 04 gives it if you enter n as the residual degrees of freedom plus one.
- **`02_Inverse_Normal`.** p is the area **below** x. For an upper tail, enter 1 minus the tail.
- **`05_Sample_Size`.** The answer is already rounded up.
- **`12_Decision_Table`.** Up to 4 states and 3 actions. An action counts only if it has a payoff for every state that has a probability.
- **`16_Descriptive_Statistics`.** Up to 40 rows. Covariance is the population version (divided by n); correlation uses rows where both X and Y are filled.

## 5. If something goes wrong

| Problem | What to do |
|---|---|
| The calculator is not in the Select Handheld list | Turn it on, push the cable in fully at both ends, click Refresh. Try another USB port. |
| Computer Link says a file is not supported and copies nothing | You included `README.txt`. Drag only the `analytics` folder or `.tns` files. |
| A sheet will not open | Copy that file again. If it still fails, open an issue saying which sheet. |
| A percentage looks 100 times too big or small | Type rates as decimals: `0.08`, not `8`. |
| Nothing appears under the fields | The sheet needs more inputs. A dash means that row cannot be worked out yet. |
| A number looks wrong | Open an issue with the sheet name, what you typed and what it showed. |

## 6. Known limitations

- Not yet tried on a calculator in this version. Check one sheet first (step 6 above).
- Made for the TI-Nspire CX and CX CAS. CX II models have not been tried.
- The sheets declare TI-Nspire script API level 1.0, as they were written.

## 7. For developers

### What is in this repository

```
ti-nspire-analytics-calculators/
├── src/
│   ├── analytics/               one .lua file per sheet (16)
│   └── shared/                  code the sheets share
│       ├── form_columns.lua
│       ├── number_format.lua
│       └── normal_distribution.lua
├── scripts/
│   ├── build.py                 builds every sheet into dist/
│   ├── tns_file.py              reads and writes .tns calculator files
│   ├── des_cipher.py            the cipher the .tns format needs
│   └── make_sheet_list.py       rebuilds docs/SHEET_LIST.md
├── tests/                       automated tests
├── docs/
│   ├── LOADING_GUIDE.txt        becomes README.txt in the download
│   ├── SHEET_LIST.md            every sheet and its inputs
│   ├── CHECK_ON_CALCULATOR.md   what to check on a real calculator
│   ├── HOW_IT_WORKS.md          how the build and tests work
│   └── TNS_FILE_FORMAT.md       the calculator file format
├── .github/workflows/           automatic tests and releases
├── CHANGELOG.md  CONTRIBUTING.md  SECURITY.md  THIRD_PARTY_NOTICES.md
└── VERSION  pyproject.toml  requirements-dev.txt
```

### Set up

You need Python 3.10 or later. Nothing else: no compiler and no TI software.

```bash
git clone <GITHUB_REPOSITORY_URL>
cd ti-nspire-analytics-calculators
python -m venv .venv
# Windows: .venv\Scripts\activate     macOS or Linux: source .venv/bin/activate
python -m pip install -r requirements-dev.txt
```

### Build

```bash
python scripts/build.py --zip
```

This writes `dist/analytics/` (the `.tns` files), `dist/README.txt` and `dist/ti-nspire-analytics-calculators-1.0.0.zip`.
Each build checks every sheet compiles as Lua 5.1 (the calculator's version) and that every file
holds exactly its source.

| Option | What it does |
|---|---|
| `--zip` | also make the zip |
| `--check` | change nothing; fail if `dist/` does not match `src/` |
| `--out FOLDER` | write somewhere other than `dist/` |

### Test

```bash
python -m pytest
ruff check .
python scripts/make_sheet_list.py --check
```

The tests check every result against an independent calculation, press random keys on every
sheet, and type the worked checks from the loading guide into the sheets.
[docs/HOW_IT_WORKS.md](docs/HOW_IT_WORKS.md) explains more.

### One file at a time

```bash
python scripts/tns_file.py pack   my_sheet.lua my_sheet.tns
python scripts/tns_file.py unpack my_sheet.tns my_sheet.lua
```

`unpack` cannot read a file the calculator has saved over; rebuild it from `src/` instead.

## 8. Licence, security and support

- **Licence:** none chosen yet, so all rights are reserved. See
  [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for code this project draws on.
- **Security:** the sheets cannot read files or use a network, and the repository holds no
  passwords or personal data. See [SECURITY.md](SECURITY.md).
- **Assessments:** check the rules before taking stored programs into any test or exam.
- **Contributing:** see [CONTRIBUTING.md](CONTRIBUTING.md).
- **Support:** open an issue on this repository.
