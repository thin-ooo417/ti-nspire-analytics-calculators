platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
TITLE = "Required sample size"
HINT = "Answer is already rounded UP - quote the whole number"
COLS = 1
FIELDS = {
  {lab="s  st dev", def=""},
  {lab="E  margin wanted", def=""},
  {lab="z  critical", def="1.96"}
}

function compute(v)

  local s, m, z = v[1], v[2], v[3]
  if not (s and m and z) then return {{"", "enter s, E, z"}} end
  if m <= 0 then return {{"E", "must be > 0", "w"}} end
  if s < 0 then return {{"s", "cannot be negative", "w"}} end
  local root = z * s / m
  local ex = root * root
  return {
    {"sqrt(n) needed", fmt(root, 4)},
    {"n exact", fmt(ex, 3)},
    {"n REQUIRED", fmt(math.ceil(ex - 1e-9), 0)},
  }
end

--@include shared/form_columns.lua
