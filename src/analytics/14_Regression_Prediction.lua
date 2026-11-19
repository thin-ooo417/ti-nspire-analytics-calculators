platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
TITLE = "Regression: predict + interval"
HINT = "Leave unused b/x pairs at 0. Interval uses SE of the regression"
COLS = 2
FIELDS = {
  {lab="intercept b0", def=""},
  {lab="SE of regression", def=""},
  {lab="b1", def=""},
  {lab="x1", def=""},
  {lab="b2", def="0"},
  {lab="x2", def="0"},
  {lab="b3", def="0"},
  {lab="x3", def="0"},
  {lab="critical", def="1.96"}
}

function compute(v)

  local b0, sr, cv = v[1], v[2], v[9]
  local b1, x1, b2, x2, b3, x3 = v[3], v[4], v[5], v[6], v[7], v[8]
  if not (b0 and sr and cv) then return {{"", "enter b0, SE, critical"}} end
  if sr < 0 then return {{"SE of regression", "cannot be negative", "w"}} end
  local yh, terms = b0, 0
  if b1 and x1 then yh = yh + b1 * x1; terms = terms + 1 end
  if b2 and x2 then yh = yh + b2 * x2; terms = terms + 1 end
  if b3 and x3 then yh = yh + b3 * x3; terms = terms + 1 end
  local m = cv * sr
  return {
    {"terms used", fmt(terms, 0)},
    {"predicted y", fmt(yh, 4)},
    {"margin", fmt(m, 4)},
    {"interval lower", fmt(yh - m, 4)},
    {"interval upper", fmt(yh + m, 4)},
  }
end

--@include shared/form_columns.lua
