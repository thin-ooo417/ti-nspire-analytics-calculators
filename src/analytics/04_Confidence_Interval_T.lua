platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
local function gammln(xx)
  local cof = {76.18009172947146, -86.50532032941677, 24.01409824083091,
               -1.231739572450155, 0.1208650973866179e-2, -0.5395239384953e-5}
  local x, y = xx, xx
  local tmp = x + 5.5
  tmp = tmp - (x + 0.5) * log(tmp)
  local ser = 1.000000000190015
  for j = 1, 6 do y = y + 1; ser = ser + cof[j] / y end
  return -tmp + log(2.5066282746310005 * ser / x)
end

local function betacf(a, b, x)
  local EPS, FPMIN = 3e-14, 1e-300
  local qab, qap, qam = a + b, a + 1, a - 1
  local c, d = 1, 1 - qab * x / qap
  if abs(d) < FPMIN then d = FPMIN end
  d = 1 / d
  local h = d
  for m = 1, 200 do
    local m2 = 2 * m
    local aa = m * (b - m) * x / ((qam + m2) * (a + m2))
    d = 1 + aa * d; if abs(d) < FPMIN then d = FPMIN end
    c = 1 + aa / c; if abs(c) < FPMIN then c = FPMIN end
    d = 1 / d; h = h * d * c
    aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2))
    d = 1 + aa * d; if abs(d) < FPMIN then d = FPMIN end
    c = 1 + aa / c; if abs(c) < FPMIN then c = FPMIN end
    d = 1 / d
    local del = d * c
    h = h * del
    if abs(del - 1) < EPS then break end
  end
  return h
end

local function betai(a, b, x)
  if x <= 0 then return 0 end
  if x >= 1 then return 1 end
  local bt = exp(gammln(a + b) - gammln(a) - gammln(b) + a * log(x) + b * log(1 - x))
  if x < (a + 1) / (a + b + 2) then
    return bt * betacf(a, b, x) / a
  else
    return 1 - bt * betacf(b, a, 1 - x) / b
  end
end

local function tcdf(t, df)
  if df == nil or df <= 0 or t ~= t then return nil end
  local tail = 0.5 * betai(df / 2, 0.5, df / (df + t * t))
  if t >= 0 then return 1 - tail else return tail end
end

-- inverse t. Symmetry halves the search: solve the upper half, then mirror.
-- 50 steps over [0,1e5] gives ~9e-11, far beyond the 5 dp displayed.
local function invt(p, df)
  if p == nil or df == nil or p <= 0 or p >= 1 or df <= 0 then return nil end
  if p == 0.5 then return 0 end
  local q, flip = p, false
  if p < 0.5 then q = 1 - p; flip = true end
  local lo, hi = 0, 1e5
  for _ = 1, 50 do
    local mid = (lo + hi) / 2
    if tcdf(mid, df) < q then lo = mid else hi = mid end
  end
  local x = (lo + hi) / 2
  if flip then return -x end
  return x
end
TITLE = "CI for the mean  (t, small n)"
HINT = "t critical found from n automatically. Needs a normal population"
COLS = 1
FIELDS = {
  {lab="x-bar  sample mean", def=""},
  {lab="s  sample st dev", def=""},
  {lab="n  sample size", def=""},
  {lab="confidence", def="0.95"}
}

function compute(v)

  local xb, s, n, cf = v[1], v[2], v[3], v[4]
  if not (xb and s and n and cf) then return {{"", "enter x-bar, s, n"}} end
  if n < 2 then return {{"n", "must be at least 2", "w"}} end
  if cf <= 0 or cf >= 1 then return {{"confidence", "0 to 1, eg 0.95", "w"}} end
  local df = n - 1
  local t = invt(1 - (1 - cf) / 2, df)
  local se = s / sqrt(n)
  local m = t * se
  return {
    {"degrees of freedom", fmt(df, 0)},
    {"t critical", fmt(t, 5)},
    {"standard error", fmt(se, 5)},
    {"CI lower", fmt(xb - m, 4)},
    {"CI upper", fmt(xb + m, 4)},
  }
end

--@include shared/form_columns.lua
