platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
--@include shared/normal_distribution.lua
-- Acklam's rational start + Halley steps against the exact CDF above.
local function invnorm(p)
  if p == nil or p ~= p or p <= 0 or p >= 1 then return nil end
  local a = {-3.969683028665376e+01, 2.209460984245205e+02, -2.759285104469687e+02,
             1.383577518672690e+02, -3.066479806614716e+01, 2.506628277459239e+00}
  local b = {-5.447609879822406e+01, 1.615858368580409e+02, -1.556989798598866e+02,
             6.680131188771972e+01, -1.328068155288572e+01}
  local c = {-7.784894002430293e-03, -3.223964580411365e-01, -2.400758277161838e+00,
             -2.549732539343734e+00, 4.374664141464968e+00, 2.938163982698783e+00}
  local d = {7.784695709041462e-03, 3.224671290700398e-01, 2.445134137142996e+00,
             3.754408661907416e+00}
  local q, r, x
  if p < 0.02425 then
    q = sqrt(-2 * log(p))
    x = (((((c[1]*q+c[2])*q+c[3])*q+c[4])*q+c[5])*q+c[6]) /
        ((((d[1]*q+d[2])*q+d[3])*q+d[4])*q+1)
  elseif p <= 0.97575 then
    q = p - 0.5; r = q * q
    x = (((((a[1]*r+a[2])*r+a[3])*r+a[4])*r+a[5])*r+a[6])*q /
        (((((b[1]*r+b[2])*r+b[3])*r+b[4])*r+b[5])*r+1)
  else
    q = sqrt(-2 * log(1 - p))
    x = -(((((c[1]*q+c[2])*q+c[3])*q+c[4])*q+c[5])*q+c[6]) /
         ((((d[1]*q+d[2])*q+d[3])*q+d[4])*q+1)
  end
  -- Halley refinement; evaluate whichever tail avoids cancellation
  for _ = 1, 2 do
    local e
    if p > 0.5 then e = p - normcdf(x) else e = normsf(x) - (1 - p) end
    local u = e * 2.5066282746310002 * exp(x * x / 2)
    x = x + u / (1 + x * u / 2)
  end
  return x
end
TITLE = "Inverse normal: X from probability"
HINT = "p is the area BELOW x. For an upper tail, enter 1 - tail"
COLS = 1
FIELDS = {
  {lab="p  area below x", def=""},
  {lab="mu  mean", def=""},
  {lab="sigma  st dev", def=""}
}

function compute(v)

  local p, mu, sd = v[1], v[2], v[3]
  if not (p and mu and sd) then return {{"", "enter p, mu, sigma"}} end
  if sd <= 0 then return {{"sigma", "must be > 0", "w"}} end
  if p <= 0 or p >= 1 then return {{"p", "must be 0 < p < 1", "w"}} end
  local z = invnorm(p)
  return {
    {"z critical", fmt(z, 6)},
    {"x = mu + z*sigma", fmt(mu + z * sd, 4)},
    {"area above x", fmt(1 - p, 6)},
  }
end

--@include shared/form_columns.lua
