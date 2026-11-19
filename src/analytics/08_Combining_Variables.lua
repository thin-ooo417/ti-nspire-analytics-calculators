platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
TITLE = "Combining variables / portfolio"
HINT = "corr must be -1 to +1. Weights a,b are proportions (or 1,1 for a sum)"
COLS = 2
FIELDS = {
  {lab="a  weight x", def=""},
  {lab="b  weight y", def=""},
  {lab="mu x", def=""},
  {lab="mu y", def=""},
  {lab="sigma x", def=""},
  {lab="sigma y", def=""},
  {lab="corr(x,y)", def="0"}
}

function compute(v)

  local a, b, mx, my, sx, sy, r = v[1], v[2], v[3], v[4], v[5], v[6], v[7]
  if not (a and b and mx and my and sx and sy and r) then
    return {{"", "enter all seven fields"}} end
  if r < -1 or r > 1 then return {{"corr", "must be -1 to +1", "w"}} end
  if sx < 0 or sy < 0 then return {{"sigma", "cannot be negative", "w"}} end
  local ev = a * mx + b * my
  local vr = a*a*sx*sx + b*b*sy*sy + 2*a*b*sx*sy*r
  local out = {
    {"E[ax+by]", fmt(ev, 6)},
    {"var(ax+by)", fmt(vr, 8)},
  }
  if vr < 0 then
    out[#out+1] = {"variance negative", "check inputs", "w"}
  else
    out[#out+1] = {"st dev", fmt(sqrt(vr), 6)}
  end
  out[#out+1] = {"cov(x,y)", fmt(sx * sy * r, 8)}
  out[#out+1] = {"weighted avg sd", fmt(abs(a)*sx + abs(b)*sy, 6)}
  return out
end

--@include shared/form_columns.lua
