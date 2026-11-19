platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
TITLE = "Bayes / screening reversal"
HINT = "Enter decimals. P(B|not A) is the false-positive rate"
COLS = 1
FIELDS = {
  {lab="P(A)  prior", def=""},
  {lab="P(B|A)", def=""},
  {lab="P(B|not A)", def=""}
}

function compute(v)

  local pa, pba, pbna = v[1], v[2], v[3]
  if not (pa and pba and pbna) then return {{"", "enter three probabilities"}} end
  if pa < 0 or pa > 1 then return {{"P(A)", "must be 0 to 1", "w"}} end
  if pba < 0 or pba > 1 then return {{"P(B|A)", "must be 0 to 1", "w"}} end
  if pbna < 0 or pbna > 1 then return {{"P(B|not A)", "must be 0 to 1", "w"}} end
  local joint = pba * pa
  local pb = joint + pbna * (1 - pa)
  local pnb = 1 - pb
  local out = {
    {"P(B)  marginal", fmt(pb, 6)},
    {"P(not B)", fmt(pnb, 6)},
  }
  if pb > 0 then
    out[#out+1] = {"P(A|B)", fmt(joint / pb, 6)}
    out[#out+1] = {"P(not A|B)", fmt(1 - joint / pb, 6)}
  else
    out[#out+1] = {"P(A|B)", "P(B) = 0", "w"}
  end
  if pnb > 0 then
    out[#out+1] = {"P(A|not B)", fmt((1 - pba) * pa / pnb, 6)}
  end
  return out
end

--@include shared/form_columns.lua
