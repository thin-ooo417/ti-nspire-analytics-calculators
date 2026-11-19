# Checking on a real calculator

The automated tests run on a computer and cannot show that a sheet looks right on a TI-Nspire.
Before you rely on a new build, and after any change to `src/shared/`, work through this list.
It takes about ten minutes. `docs/LOADING_GUIDE.txt` explains how to copy the files across.

## 1. One sheet of each layout

Words in square brackets are keys to press; the rest are numbers to type.

| Sheet | Press | You should see |
|---|---|---|
| `05_Sample_Size` | 15 [enter] 2 | n REQUIRED 217 |
| `04_Confidence_Interval_T` | 50 [enter] 10 [enter] 10 | t critical 2.26216 |

For each, also check:

- the title, labels and boxes are all on screen and nothing overlaps;
- a letter key does nothing;
- the `(-)` key types a minus sign in an empty field.

## 2. Changes in version 1.0.0

| Check | How |
|---|---|
| The last result row is shown | `07_Test_Two_Means`: 10, 9, 2, 3, 20, 25 (tab between them). The last row should read "small sample / CLT may not hold" in orange. |
| The grid sheets | `16_Descriptive_Statistics`: 1, tab, 2, tab, 2, tab, 4, tab. Expect n 2 and 2, means 1.5 and 3. |

## If something is wrong

Note the sheet, what you typed and what the screen showed, and open an issue.
