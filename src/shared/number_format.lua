local function fmt(x, dp)
  if x == nil then return "--" end
  if x ~= x then return "n/a" end
  if x == math.huge then return "inf" end
  if x == -math.huge then return "-inf" end
  dp = dp or 4
  if abs(x) < 1e-12 then x = 0 end
  local a = abs(x)
  if a ~= 0 and (a < 1e-4 or a >= 1e8) then return string.format("%.4g", x) end
  return string.format("%." .. dp .. "f", x)
end
