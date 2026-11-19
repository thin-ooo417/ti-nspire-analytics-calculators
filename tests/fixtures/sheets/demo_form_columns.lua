-- Test-only sheet for the engine tests. Never built or shipped.
platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
TITLE = "Engine test sheet"
HINT = "test only"
COLS = 2
FIELDS = {
  {lab="a", def=""},
  {lab="b", def=""},
  {lab="c", def=""},
  {lab="d  default", def="1.96"}
}

function compute(v)

  local a, b, c, d = v[1], v[2], v[3], v[4]
  if not (a and b) then return {{"", "enter a and b"}} end
  local out = {{"a + b", fmt(a + b, 4)}}
  if c then out[#out+1] = {"c x d", fmt(c * (d or 0), 4)} end
  if a < 0 then out[#out+1] = {"a", "is negative", "w"} end
  return out
end

--@include shared/form_columns.lua
