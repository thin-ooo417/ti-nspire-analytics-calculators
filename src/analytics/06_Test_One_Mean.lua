platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
--@include shared/normal_distribution.lua
TITLE = "Test: one mean"
HINT = "p-value is two-sided. Reject when p < 0.05"
COLS = 1
FIELDS = {
  {lab="x-bar", def=""},
  {lab="s  st dev", def=""},
  {lab="n", def=""},
  {lab="mu0  hypothesis", def=""},
  {lab="critical", def="1.96"}
}

function compute(v)

  local xb, s, n, mu0, cv = v[1], v[2], v[3], v[4], v[5]
  if not (xb and s and n and mu0 and cv) then return {{"", "enter all five"}} end
  if n <= 0 then return {{"n", "must be > 0", "w"}} end
  if s <= 0 then return {{"s", "must be > 0", "w"}} end
  local se = s / sqrt(n)
  local t = (xb - mu0) / se
  local out = {
    {"standard error", fmt(se, 5)},
    {"t-stat", fmt(t, 4)},
    {"p-value  2-sided", fmt(2 * normsf(abs(t)), 6)},
    {"decision", abs(t) > cv and "REJECT H0" or "do NOT reject H0"},
    {"CI lower", fmt(xb - cv * se, 4)},
    {"CI upper", fmt(xb + cv * se, 4)},
  }
  -- the p-value is normal-based; flag it for small samples, as sheet 07 does
  if n < 30 then out[#out+1] = {"small sample", "CLT may not hold", "w"} end
  return out
end

--@include shared/form_columns.lua
