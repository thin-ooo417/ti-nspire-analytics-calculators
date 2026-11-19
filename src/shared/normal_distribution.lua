-- Hart (1968) rational approximation. Double precision, |err| < 1e-15.
-- normsf returns the UPPER tail directly so no precision is lost to 1-p.
local function normsf(z)
  if z ~= z then return nil end
  local y = abs(z)
  local p
  if y > 37 then
    p = 0
  else
    local e = exp(-y * y / 2)
    if y < 7.07106781186547 then
      local b = 3.52624965998911e-02 * y + 0.700383064443688
      b = b * y + 6.37396220353165
      b = b * y + 33.912866078383
      b = b * y + 112.079291497871
      b = b * y + 221.213596169931
      b = b * y + 220.206867912376
      local c = 8.83883476483184e-02 * y + 1.75566716318264
      c = c * y + 16.064177579207
      c = c * y + 86.7807322029461
      c = c * y + 296.564248779674
      c = c * y + 637.333633378831
      c = c * y + 793.826512519948
      c = c * y + 440.413735824752
      p = e * b / c
    else
      local b = y + 0.65
      b = y + 4 / b
      b = y + 3 / b
      b = y + 2 / b
      b = y + 1 / b
      p = e / (b * 2.506628274631)
    end
  end
  if z < 0 then return 1 - p else return p end
end

local function normcdf(z) return normsf(-z) end
