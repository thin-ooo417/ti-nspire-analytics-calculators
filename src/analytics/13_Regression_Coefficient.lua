platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
--@include shared/normal_distribution.lua
TITLE = "Regression: test a coefficient"
HINT = "Excel's printed 95% limits use t, not 1.96 - see README"
COLS = 1
FIELDS = {
  {lab="b  coefficient", def=""},
  {lab="SE(b)", def=""},
  {lab="b hypothesised", def="0"},
  {lab="critical", def="1.96"}
}

function compute(v)

  local b, se, bh, cv = v[1], v[2], v[3], v[4]
  if not (b and se and bh and cv) then return {{"", "enter b and SE(b)"}} end
  if se <= 0 then return {{"SE(b)", "must be > 0", "w"}} end
  local t0 = b / se
  local th = (b - bh) / se
  return {
    {"t-stat vs zero", fmt(t0, 4)},
    {"significant?", abs(t0) > cv and "YES" or "no"},
    {"p-value vs zero", fmt(2 * normsf(abs(t0)), 6)},
    {"t-stat vs hypoth", fmt(th, 4)},
    {"decision vs hypoth", abs(th) > cv and "REJECT" or "do NOT reject"},
    {"CI lower", fmt(b - cv * se, 5)},
    {"CI upper", fmt(b + cv * se, 5)},
  }
end

--@include shared/form_columns.lua
