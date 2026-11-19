platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
TITLE = "CI for the mean  (z, large n)"
HINT = "z: 1.96=95%  1.645=90%  2.576=99%.  Use 04 if n < 30"
COLS = 1
FIELDS = {
  {lab="x-bar  sample mean", def=""},
  {lab="s  st dev", def=""},
  {lab="n  sample size", def=""},
  {lab="z  critical", def="1.96"}
}

function compute(v)

  local xb, s, n, z = v[1], v[2], v[3], v[4]
  if not (xb and s and n and z) then return {{"", "enter x-bar, s, n"}} end
  if n <= 0 then return {{"n", "must be > 0", "w"}} end
  if s < 0 then return {{"s", "cannot be negative", "w"}} end
  local se = s / sqrt(n)
  local m = z * se
  local out = {
    {"standard error", fmt(se, 5)},
    {"margin of error", fmt(m, 5)},
    {"CI lower", fmt(xb - m, 4)},
    {"CI upper", fmt(xb + m, 4)},
  }
  if n < 30 then out[#out+1] = {"n < 30", "use t (sheet 04)", "w"} end
  return out
end

--@include shared/form_columns.lua
