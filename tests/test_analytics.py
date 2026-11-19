"""Analytics sheets: distributions, intervals, tests, regression and decisions."""

from __future__ import annotations

import math
import statistics

import pytest

import reference_maths as ref
from conftest import load, names
from form_drivers import ORANGE, Columns, check_dp, result_rows

_SE2 = math.sqrt(4 / 40 + 9 / 50)
_T9 = ref.t_ppf(0.975, 9)

CASES = [
    ("01_Normal_Probability", {1: "110", 2: "100", 3: "5"},
     {"z = (x-mu)/sigma": 2.0, "P(X < x)  lower": ref.norm_cdf(2), "P(X > x)  upper": ref.norm_sf(2),
      "2-tail P(|Z|>|z|)": 2 * ref.norm_sf(2)}),
    ("01_Normal_Probability", {1: "-3.2", 2: "0", 3: "1"},
     {"P(X < x)  lower": ref.norm_cdf(-3.2), "P(X > x)  upper": ref.norm_sf(-3.2)}),
    ("02_Inverse_Normal", {1: "0.975", 2: "0", 3: "1"},
     {"z critical": ref.norm_ppf(0.975), "x = mu + z*sigma": ref.norm_ppf(0.975), "area above x": 0.025}),
    ("02_Inverse_Normal", {1: "0.01", 2: "50", 3: "8"},
     {"z critical": ref.norm_ppf(0.01), "x = mu + z*sigma": 50 + 8 * ref.norm_ppf(0.01)}),
    ("03_Confidence_Interval_Z", {1: "50", 2: "10", 3: "100"},
     {"standard error": 1.0, "margin of error": 1.96, "CI lower": 48.04, "CI upper": 51.96}),
    ("03_Confidence_Interval_Z", {1: "20", 2: "4", 3: "64", 4: "2.576"},
     {"standard error": 0.5, "margin of error": 1.288, "CI lower": 18.712, "CI upper": 21.288}),
    ("04_Confidence_Interval_T", {1: "50", 2: "10", 3: "10"},
     {"degrees of freedom": 9, "t critical": _T9, "standard error": 10 / math.sqrt(10),
      "CI lower": 50 - _T9 * 10 / math.sqrt(10), "CI upper": 50 + _T9 * 10 / math.sqrt(10)}),
    ("04_Confidence_Interval_T", {1: "0", 2: "1", 3: "25", 4: "0.99"}, {"t critical": ref.t_ppf(0.995, 24)}),
    ("05_Sample_Size", {1: "15", 2: "2"},
     {"sqrt(n) needed": 14.7, "n exact": 14.7 ** 2, "n REQUIRED": math.ceil(14.7 ** 2)}),
    ("05_Sample_Size", {1: "10", 2: "1.96"}, {"n exact": 100.0, "n REQUIRED": 100}),
    ("06_Test_One_Mean", {1: "52", 2: "10", 3: "100", 4: "50"},
     {"standard error": 1.0, "t-stat": 2.0, "p-value  2-sided": 2 * ref.norm_sf(2), "CI lower": 50.04, "CI upper": 53.96}),
    ("07_Test_Two_Means", {1: "10", 2: "9", 3: "2", 4: "3", 5: "40", 6: "50"},
     {"difference x1-x2": 1.0, "standard error": _SE2, "t-stat": 1 / _SE2, "p-value  2-sided": 2 * ref.norm_sf(1 / _SE2),
      "CI lower  diff": 1 - 1.96 * _SE2, "CI upper  diff": 1 + 1.96 * _SE2}),
    ("08_Combining_Variables", {1: "0.5", 2: "0.5", 3: "0.12", 4: "0.15", 5: "0.25", 6: "0.4", 7: "0.3"},
     {"E[ax+by]": 0.135, "var(ax+by)": ref.two_asset_variance(0.5, 0.5, 0.25, 0.4, 0.3),
      "st dev": math.sqrt(ref.two_asset_variance(0.5, 0.5, 0.25, 0.4, 0.3)), "cov(x,y)": 0.03,
      "weighted avg sd": 0.325}),
    ("09_Bayes", {1: "0.01", 2: "0.9", 3: "0.05"},
     {"P(B)  marginal": 0.0585, "P(not B)": 0.9415, "P(A|B)": 0.009 / 0.0585, "P(not A|B)": 1 - 0.009 / 0.0585,
      "P(A|not B)": 0.001 / 0.9415}),
    ("10_Confusion_Matrix", {1: "50", 2: "10", 3: "5", 4: "35"},
     {"total": 100, "accuracy": 0.85, "prevalence": 0.40, "baseline all-zero": 0.60, "sensitivity": 35 / 40,
      "specificity": 50 / 60, "pos pred value": 35 / 45}),
    ("11_Expected_Value", {1: "0.2", 2: "10", 3: "0.3", 4: "20", 5: "0.5", 6: "30"},
     {"pairs used": 3, "sum of probs": 1.0, "EXPECTED VALUE": 23.0, "variance": 61.0, "st dev": math.sqrt(61)}),
    ("13_Regression_Coefficient", {1: "2", 2: "0.5"},
     {"t-stat vs zero": 4.0, "p-value vs zero": 2 * ref.norm_sf(4), "t-stat vs hypoth": 4.0, "CI lower": 1.02, "CI upper": 2.98}),
    ("13_Regression_Coefficient", {1: "1.1", 2: "0.2", 3: "1"}, {"t-stat vs zero": 5.5, "t-stat vs hypoth": 0.5}),
    ("14_Regression_Prediction", {1: "10", 2: "2", 3: "3", 4: "4"},
     {"predicted y": 22.0, "margin": 3.92, "interval lower": 18.08, "interval upper": 25.92}),
    ("14_Regression_Prediction", {1: "1.5", 2: "0.8", 3: "2", 4: "3", 5: "-0.5", 6: "4", 7: "0.25", 8: "8", 9: "2"},
     {"terms used": 3, "predicted y": 1.5 + 6 - 2 + 2, "margin": 1.6}),
    ("15_Adjusted_R_Squared", {1: "0.8", 2: "50", 3: "4"},
     {"adjusted R-squared": 1 - 0.2 * 49 / 45, "residual df": 45, "unexplained": 0.2, "penalty applied": 0.8 - (1 - 0.2 * 49 / 45)}),
]


@pytest.mark.parametrize("sheet,typed,expected", CASES, ids=[f"{c[0]}-{i}" for i, c in enumerate(CASES)])
def test_outputs(sheet, typed, expected):
    Columns(sheet).set(typed).expect(expected)


def test_every_form_sheet_is_covered():
    grid_sheets = {"12_Decision_Table", "16_Descriptive_Statistics"}
    assert set(names(folder="analytics")) == {case[0] for case in CASES} | grid_sheets


# --- distribution functions against independent methods and published values -------

def test_reference_methods_agree_with_published_table_values():
    assert abs(ref.norm_ppf(0.975) - 1.959964) < 1e-6
    assert abs(ref.t_ppf(0.975, 9) - 2.262157) < 2e-6
    assert abs(ref.t_ppf(0.975, 24) - 2.063899) < 2e-6
    assert abs(ref.t_ppf(0.995, 4) - 4.604095) < 2e-6


@pytest.mark.parametrize("z", [-6.5, -3.0, -1.0, -0.1, 0.0, 0.5, 1.96, 2.5758, 4.0, 7.5])
def test_normal_probabilities_across_the_range(z):
    shown = Columns("01_Normal_Probability").set({1: str(z), 2: "0", 3: "1"}).results()
    for label, value in (("P(X > x)  upper", ref.norm_sf(z)), ("P(X < x)  lower", ref.norm_cdf(z))):
        if value >= 1e-4:
            check_dp(shown[label], value)                      # six decimals
        elif value >= 1e-12:
            assert abs(float(shown[label]) - value) <= 6e-4 * value   # four significant figures
        else:
            assert float(shown[label]) == 0.0                  # below 1e-12 the sheet shows zero


@pytest.mark.parametrize("p", [0.0005, 0.01, 0.025, 0.1, 0.5, 0.8, 0.95, 0.999])
def test_inverse_normal_across_the_range(p):
    shown = Columns("02_Inverse_Normal").set({1: str(p), 2: "0", 3: "1"}).results()
    check_dp(shown["z critical"], ref.norm_ppf(p))


@pytest.mark.parametrize("n,confidence", [(2, 0.95), (5, 0.9), (12, 0.95), (30, 0.99), (120, 0.95)])
def test_t_critical_values(n, confidence):
    shown = Columns("04_Confidence_Interval_T").set({1: "0", 2: "1", 3: str(n), 4: str(confidence)}).results()
    check_dp(shown["t critical"], ref.t_ppf(1 - (1 - confidence) / 2, n - 1))


# --- decisions, messages and warnings ----------------------------------------------

def test_one_mean_decision():
    assert Columns("06_Test_One_Mean").set({1: "52", 2: "10", 3: "100", 4: "50"}).results()["decision"] == "REJECT H0"
    assert Columns("06_Test_One_Mean").set({1: "51", 2: "10", 3: "100", 4: "50"}).results()["decision"] == "do NOT reject H0"


def test_one_mean_flags_small_samples():
    form = Columns("06_Test_One_Mean").set({1: "52", 2: "10", 3: "20", 4: "50"})
    assert ("small sample", "CLT may not hold") in form.warnings()
    assert Columns("06_Test_One_Mean").set({1: "52", 2: "10", 3: "30", 4: "50"}).warnings() == []


def test_two_means_small_sample_warning_is_drawn():
    """This row used to be computed and then dropped because the screen was mis-measured."""
    form = Columns("07_Test_Two_Means").set({1: "10", 2: "9", 3: "2", 4: "3", 5: "20", 6: "25"})
    assert ("small sample", "CLT may not hold") in form.warnings()
    assert len(form.rows()) == 8


def test_two_means_rejects_zero_spread():
    form = Columns("07_Test_Two_Means").set({1: "10", 2: "9", 3: "0", 4: "0", 5: "40", 6: "50"})
    assert form.rows() == [("s1 / s2", "cannot both be 0", True)]


def test_ci_z_points_to_the_t_sheet_for_small_samples():
    assert ("n < 30", "use t (sheet 04)") in Columns("03_Confidence_Interval_Z").set({1: "50", 2: "10", 3: "20"}).warnings()


def test_regression_coefficient_decisions():
    shown = Columns("13_Regression_Coefficient").set({1: "1.1", 2: "0.2", 3: "1"}).results()
    assert shown["significant?"] == "YES" and shown["decision vs hypoth"] == "do NOT reject"


def test_confusion_matrix_flags_a_model_no_better_than_baseline():
    form = Columns("10_Confusion_Matrix").set({1: "80", 2: "10", 3: "10", 4: "0"})
    assert ("accuracy <= baseline", "model adds nothing") in form.warnings()


def test_expected_value_refuses_probabilities_that_do_not_sum_to_one():
    form = Columns("11_Expected_Value").set({1: "0.2", 2: "10", 3: "0.3", 4: "20"})
    shown = form.results()
    assert ("probs do NOT sum to 1", "results invalid") in form.warnings()
    assert "EXPECTED VALUE" not in shown and float(shown["raw sum p*x"]) == 8.0


@pytest.mark.parametrize("sheet,typed,row", [
    ("01_Normal_Probability", {1: "1", 2: "0", 3: "0"}, ("sigma", "must be > 0")),
    ("02_Inverse_Normal", {1: "1", 2: "0", 3: "1"}, ("p", "must be 0 < p < 1")),
    ("03_Confidence_Interval_Z", {1: "1", 2: "1", 3: "0"}, ("n", "must be > 0")),
    ("04_Confidence_Interval_T", {1: "1", 2: "1", 3: "1"}, ("n", "must be at least 2")),
    ("04_Confidence_Interval_T", {1: "1", 2: "1", 3: "9", 4: "95"}, ("confidence", "0 to 1, eg 0.95")),
    ("05_Sample_Size", {1: "10", 2: "0"}, ("E", "must be > 0")),
    ("06_Test_One_Mean", {1: "1", 2: "0", 3: "10", 4: "0"}, ("s", "must be > 0")),
    ("08_Combining_Variables", {1: "1", 2: "1", 3: "1", 4: "1", 5: "1", 6: "1", 7: "1.5"}, ("corr", "must be -1 to +1")),
    ("09_Bayes", {1: "1.2", 2: "0.5", 3: "0.5"}, ("P(A)", "must be 0 to 1")),
    ("10_Confusion_Matrix", {1: "0", 2: "0", 3: "0", 4: "0"}, ("total", "must be > 0")),
    ("13_Regression_Coefficient", {1: "2", 2: "0"}, ("SE(b)", "must be > 0")),
    ("15_Adjusted_R_Squared", {1: "0.8", 2: "5", 3: "4"}, ("degrees of freedom", "need n > k+1")),
])
def test_input_checks(sheet, typed, row):
    assert Columns(sheet).set(typed).warnings() == [row]


def test_all_result_rows_are_drawn():
    """The engine must never drop a row the calculation returned."""
    for sheet, typed, _ in CASES:
        form = Columns(sheet).set(typed)
        compute = form.sheet.lua.eval(
            b"function(...) local t = {} for i, x in ipairs({...}) do t[i] = tonumber(x) end return #compute(t) end"
        )
        values = [b""] * form.count
        vals = form.sheet.lua.eval(b"function() local t = {} for i, f in ipairs(FIELDS) do t[i] = f.def or '' end return t end")()
        for i in range(form.count):
            values[i] = vals[i + 1]
        for index, text in typed.items():
            values[index - 1] = text.encode()
        assert len(form.rows()) == compute(*values), sheet


# --- 12 decision table ----------------------------------------------------------

def _fill_grid(sheet, rows):
    for row in rows:
        for cell in row:
            sheet.type(cell)
            sheet.tab()


def test_decision_table():
    sheet = load("12_Decision_Table")
    probs = [0.3, 0.5, 0.2]
    payoffs = [[100, 50, -20], [60, 60, 60], [150, 20, -80]]
    _fill_grid(sheet, [[str(p) for p in probs] + [""]] + [[str(v) for v in row] + [""] for row in payoffs])
    shown = {label: value for label, value, _ in result_rows(sheet)}
    ev = [sum(p * x for p, x in zip(probs, row, strict=True)) for row in payoffs]
    for action, value in enumerate(ev, start=1):
        check_dp(shown[f"EV action {action}"], value)
    best = max(range(3), key=lambda a: ev[a])
    check_dp(shown[f"BEST = action {best + 1}"], ev[best])
    perfect = sum(p * max(row[s] for row in payoffs) for s, p in enumerate(probs))
    check_dp(shown["EV perfect info"], perfect)
    check_dp(shown["EVPI"], perfect - ev[best])
    worst = [min(row) for row in payoffs]
    check_dp(shown[f"maximin = action {worst.index(max(worst)) + 1}"], max(worst))
    top = [max(row) for row in payoffs]
    check_dp(shown[f"maximax = action {top.index(max(top)) + 1}"], max(top))


def test_decision_table_ignores_an_incomplete_action():
    sheet = load("12_Decision_Table")
    _fill_grid(sheet, [["0.5", "0.5", "", ""], ["10", "20", "", ""], ["30", "", "", ""]])
    shown = {label: value for label, value, _ in result_rows(sheet)}
    assert "EV action 1" in shown and "EV action 2" not in shown
    check_dp(shown["BEST = action 1"], 15.0)


def test_decision_table_checks_probabilities():
    sheet = load("12_Decision_Table")
    _fill_grid(sheet, [["0.5", "0.3", "", ""], ["10", "20", "", ""]])
    rows = result_rows(sheet)
    assert rows[0][1] == "must be 1" and rows[0][2]
    assert not any(label.startswith("BEST") for label, _, _ in rows)


# --- 16 descriptive statistics ----------------------------------------------------

def _stats_lines(sheet):
    drawn = sheet.paint()
    rows = {}
    for t in drawn:
        rows.setdefault(t.y, []).append(t)
    out = {}
    for y in sorted(rows):
        line = sorted(rows[y], key=lambda t: t.x)
        if line[0].x == 6:
            out[line[0].text] = [t.text for t in line[1:]]
    return out


def test_descriptive_statistics_and_correlation():
    xs, ys = [1, 2, 3, 4, 5], [2, 4, 5, 4, 5]
    sheet = load("16_Descriptive_Statistics")
    for x, y in zip(xs, ys, strict=True):
        sheet.type(str(x))
        sheet.tab()
        sheet.type(str(y))
        sheet.tab()
    lines = _stats_lines(sheet)
    for label, fx in (("n", len), ("mean", statistics.mean), ("median", statistics.median),
                      ("s  sample sd", statistics.stdev), ("sigma pop sd", statistics.pstdev),
                      ("min", min), ("max", max)):
        check_dp(lines[label][0], fx(xs))
        check_dp(lines[label][1], fx(ys))
    mx, my = statistics.mean(xs), statistics.mean(ys)
    cov = sum((x - mx) * (y - my) for x, y in zip(xs, ys, strict=True)) / len(xs)
    check_dp(lines["cov (pop, /n)"][0], cov)
    check_dp(lines["correlation  (5 pairs)"][0], cov / (statistics.pstdev(xs) * statistics.pstdev(ys)))


def test_descriptive_statistics_with_one_column_only():
    sheet = load("16_Descriptive_Statistics")
    for x in ("4", "8", "15", "16", "23", "42"):
        sheet.type(x)
        sheet.enter()
    lines = _stats_lines(sheet)
    check_dp(lines["mean"][0], 18.0)
    check_dp(lines["median"][0], 15.5)
    assert "fill both columns for cov / correlation" in sheet.texts()


def test_descriptive_statistics_scrolls_to_forty_rows():
    sheet = load("16_Descriptive_Statistics")
    for i in range(1, 41):
        sheet.type(str(i))
        sheet.enter()
    lines = _stats_lines(sheet)
    check_dp(lines["n"][0], 40)
    check_dp(lines["mean"][0], 20.5)
    assert "36-40 of 40" in sheet.texts()


def test_warning_rows_are_orange():
    sheet = Columns("03_Confidence_Interval_Z").set({1: "50", 2: "10", 3: "20"}).sheet
    assert any(t.text == "use t (sheet 04)" and t.rgb == ORANGE for t in sheet.paint())
