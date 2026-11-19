platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
--@include shared/normal_distribution.lua
TITLE = "Normal: probability from X"
HINT = "Both tails computed exactly - no table lookup needed"
COLS = 1
FIELDS = {
  {lab="x  value", def=""},
  {lab="mu  mean", def=""},
  {lab="sigma  st dev", def=""}
}

function compute(v)

  local x, mu, sd = v[1], v[2], v[3]
  if not (x and mu and sd) then return {{"", "enter x, mu, sigma"}} end
  if sd <= 0 then return {{"sigma", "must be > 0", "w"}} end
  local z = (x - mu) / sd
  return {
    {"z = (x-mu)/sigma", fmt(z, 4)},
    {"P(X < x)  lower", fmt(normcdf(z), 6)},
    {"P(X > x)  upper", fmt(normsf(z), 6)},
    {"2-tail P(|Z|>|z|)", fmt(2 * normsf(abs(z)), 6)},
  }
end

--@include shared/form_columns.lua
