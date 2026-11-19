platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
TITLE = "Expected value  (up to 6 outcomes)"
HINT = "Leave unused pairs blank. Probabilities must sum to 1"
COLS = 2
FIELDS = {
  {lab="p1", def=""},
  {lab="payoff 1", def=""},
  {lab="p2", def=""},
  {lab="payoff 2", def=""},
  {lab="p3", def=""},
  {lab="payoff 3", def=""},
  {lab="p4", def=""},
  {lab="payoff 4", def=""},
  {lab="p5", def=""},
  {lab="payoff 5", def=""},
  {lab="p6", def=""},
  {lab="payoff 6", def=""}
}

function compute(v)

  local sp, ev, ex2, k, bad = 0, 0, 0, 0, false
  for i = 1, 11, 2 do
    local p, x = v[i], v[i + 1]
    if p and x then
      if p < 0 or p > 1 then bad = true end
      sp = sp + p; ev = ev + p * x; ex2 = ex2 + p * x * x; k = k + 1
    end
  end
  if k == 0 then return {{"", "enter prob/payoff pairs"}} end
  if bad then return {{"probabilities", "each must be 0 to 1", "w"}} end
  local ok = abs(sp - 1) < 1e-9
  local out = {
    {"pairs used", fmt(k, 0)},
    {"sum of probs", fmt(sp, 6)},
  }
  if not ok then
    out[#out+1] = {"probs do NOT sum to 1", "results invalid", "w"}
    out[#out+1] = {"raw sum p*x", fmt(ev, 4)}
    return out
  end
  local vr = ex2 - ev * ev
  if vr < 0 then vr = 0 end
  out[#out+1] = {"EXPECTED VALUE", fmt(ev, 4)}
  out[#out+1] = {"variance", fmt(vr, 4)}
  out[#out+1] = {"st dev", fmt(sqrt(vr), 4)}
  return out
end

--@include shared/form_columns.lua
