platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
--@include shared/normal_distribution.lua
TITLE = "Test: two means"
HINT = "D = hypothesised difference (0 = same). Uses the given two-sample SE"
COLS = 2
FIELDS = {
  {lab="x-bar 1", def=""},
  {lab="x-bar 2", def=""},
  {lab="s1", def=""},
  {lab="s2", def=""},
  {lab="n1", def=""},
  {lab="n2", def=""},
  {lab="D  hyp diff", def="0"},
  {lab="critical", def="1.96"}
}

function compute(v)

  local x1, x2, s1, s2, n1, n2, d, cv = v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8]
  if not (x1 and x2 and s1 and s2 and n1 and n2 and d and cv) then
    return {{"", "enter all eight fields"}} end
  if n1 <= 0 or n2 <= 0 then return {{"n1 / n2", "must be > 0", "w"}} end
  if s1 < 0 or s2 < 0 then return {{"s1 / s2", "cannot be negative", "w"}} end
  local diff = x1 - x2
  local se = sqrt(s1 * s1 / n1 + s2 * s2 / n2)
  if se == 0 then return {{"s1 / s2", "cannot both be 0", "w"}} end
  local t = (diff - d) / se
  local out = {
    {"difference x1-x2", fmt(diff, 4)},
    {"standard error", fmt(se, 5)},
    {"t-stat", fmt(t, 4)},
    {"p-value  2-sided", fmt(2 * normsf(abs(t)), 6)},
    {"decision", abs(t) > cv and "REJECT H0" or "do NOT reject H0"},
    {"CI lower  diff", fmt(diff - cv * se, 4)},
    {"CI upper  diff", fmt(diff + cv * se, 4)},
  }
  if n1 < 30 or n2 < 30 then out[#out+1] = {"small sample", "CLT may not hold", "w"} end
  return out
end

--@include shared/form_columns.lua
