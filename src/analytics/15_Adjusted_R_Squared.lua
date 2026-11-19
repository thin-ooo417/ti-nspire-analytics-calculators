platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
TITLE = "R-squared and adjusted R-squared"
HINT = "k = number of features (not counting the intercept)"
COLS = 1
FIELDS = {
  {lab="R-squared", def=""},
  {lab="n  observations", def=""},
  {lab="k  features", def=""}
}

function compute(v)

  local r2, n, k = v[1], v[2], v[3]
  if not (r2 and n and k) then return {{"", "enter R2, n, k"}} end
  if r2 < 0 or r2 > 1 then return {{"R-squared", "must be 0 to 1", "w"}} end
  if k < 0 then return {{"k", "cannot be negative", "w"}} end
  if n - k - 1 <= 0 then return {{"degrees of freedom", "need n > k+1", "w"}} end
  local adj = 1 - (1 - r2) * (n - 1) / (n - k - 1)
  return {
    {"adjusted R-squared", fmt(adj, 6)},
    {"residual df", fmt(n - k - 1, 0)},
    {"unexplained", fmt(1 - r2, 6)},
    {"penalty applied", fmt(r2 - adj, 6)},
  }
end

--@include shared/form_columns.lua
