platform.apilevel = '1.0'
local abs, floor, sqrt, exp, log = math.abs, math.floor, math.sqrt, math.exp, math.log
--@include shared/number_format.lua
TITLE = "Confusion matrix metrics"
HINT = "Rows = actual, columns = predicted. Compare accuracy against baseline"
COLS = 2
FIELDS = {
  {lab="TN act0 pred0", def=""},
  {lab="FP act0 pred1", def=""},
  {lab="FN act1 pred0", def=""},
  {lab="TP act1 pred1", def=""}
}

function compute(v)

  local tn, fp, fn, tp = v[1], v[2], v[3], v[4]
  if not (tn and fp and fn and tp) then return {{"", "enter TN, FP, FN, TP"}} end
  if tn < 0 or fp < 0 or fn < 0 or tp < 0 then
    return {{"counts", "cannot be negative", "w"}} end
  local tot = tn + fp + fn + tp
  if tot <= 0 then return {{"total", "must be > 0", "w"}} end
  local acc  = (tp + tn) / tot
  local base = (tn + fp) / tot
  local out = {
    {"total", fmt(tot, 0)},
    {"accuracy", fmt(acc, 5)},
    {"prevalence", fmt((fn + tp) / tot, 5)},
    {"baseline all-zero", fmt(base, 5)},
  }
  if fn + tp > 0 then out[#out+1] = {"sensitivity", fmt(tp / (fn + tp), 5)} end
  if tn + fp > 0 then out[#out+1] = {"specificity", fmt(tn / (tn + fp), 5)} end
  if fp + tp > 0 then out[#out+1] = {"pos pred value", fmt(tp / (fp + tp), 5)} end
  if acc <= base then
    out[#out+1] = {"accuracy <= baseline", "model adds nothing", "w"}
  end
  return out
end

--@include shared/form_columns.lua
