"""What the shared column form (form_columns.lua) promises; used by the Analytics sheets."""

from __future__ import annotations

import pytest

from calculator_mock import MINUS_KEY, Sheet
from conftest import SHEETS, fixture_source, names
from form_drivers import Columns, result_rows

COLUMN_SHEETS = [n for n in names() if b"FORM ENGINE" in SHEETS[n]]


def test_this_repository_has_form_columns_sheets():
    assert COLUMN_SHEETS


def test_columns_demo_sheet_results_warnings_and_errors():
    sheet = Sheet(fixture_source("demo_form_columns.lua"))
    for value in ("-2", "5", "3"):
        sheet.type(value)
        sheet.tab()
    rows = result_rows(sheet)
    assert ("a + b", "3.0000", False) in rows and ("c x d", "5.8800", False) in rows
    assert ("a", "is negative", True) in rows
    sheet.lua.execute(b"compute = function() error('boom') end")
    sheet.type("1")                           # an input change forces a recompute
    assert result_rows(sheet) == [("", "check inputs", True)]


# --- two-column engine ----------------------------------------------------------------

@pytest.mark.parametrize("name", COLUMN_SHEETS)
def test_columns_first_paint_asks_for_input(name):
    rows = Columns(name).rows()
    assert len(rows) == 1 and rows[0][0] == "" and rows[0][1].startswith("enter")


def test_columns_first_key_replaces_a_default():
    form = Columns("03_Confidence_Interval_Z")
    form.goto(4)                              # z critical, default 1.96
    form.sheet.type("2")
    field = [line for line in form.sheet.lines() if line[0].text == "z  critical"][0]
    assert field[1].text == "2"


def test_columns_input_rules():
    form = Columns("01_Normal_Probability")
    sheet = form.sheet
    sheet.type("1.5.5")                       # one decimal point
    sheet.char("x")
    field = [line for line in sheet.lines() if line[0].text == "x  value"][0]
    assert field[1].text == "1.55"
    sheet.char(MINUS_KEY)                     # (-) toggles the sign from anywhere
    field = [line for line in sheet.lines() if line[0].text == "x  value"][0]
    assert field[1].text == "-1.55"
    sheet.type("12345678901234")              # capped at 10 characters
    field = [line for line in sheet.lines() if line[0].text == "x  value"][0]
    assert len(field[1].text) <= 11
    sheet.escape()                            # esc restores every default
    field = [line for line in sheet.lines() if line[0].text == "x  value"][0]
    assert field[1].text == ""


def test_columns_leading_decimal_point_gets_a_zero():
    sheet = Columns("01_Normal_Probability").sheet
    sheet.char(".")
    sheet.char("5")
    field = [line for line in sheet.lines() if line[0].text == "x  value"][0]
    assert field[1].text == "0.5"


def test_columns_two_column_navigation():
    form = Columns("07_Test_Two_Means")
    sheet = form.sheet
    sheet.right()
    sheet.type("9")                           # field 2
    sheet.down()
    sheet.type("3")                           # field 4
    sheet.left()
    sheet.type("2")                           # field 3
    sheet.up()
    sheet.type("10")                          # field 1
    texts = {line[0].text: line[1].text for line in sheet.lines() if len(line) == 4}
    flat = {}
    for line in sheet.lines():
        if len(line) == 4:
            flat[line[0].text], flat[line[2].text] = line[1].text, line[3].text
    assert flat["x-bar 1"] == "10" and flat["x-bar 2"] == "9" and flat["s1"] == "2" and flat["s2"] == "3", texts
