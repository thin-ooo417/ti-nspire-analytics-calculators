platform.apilevel = '1.0'
local abs, floor, sqrt = math.abs, math.floor, math.sqrt

local function fmt(x, dp)
  if x == nil then return "--" end
  if x ~= x then return "n/a" end
  dp = dp or 4
  if abs(x) < 1e-12 then x = 0 end
  local a = abs(x)
  if a ~= 0 and (a < 1e-4 or a >= 1e8) then return string.format("%.4g", x) end
  return string.format("%." .. dp .. "f", x)
end

TITLE = "Descriptive stats + correlation"
HINT  = "Up/Down scroll  Left/Right column  Del clears cell  Esc clears all"

local MAXN, VIS = 40, 5
local dx, dy = {}, {}
for i = 1, MAXN do dx[i] = ""; dy[i] = "" end

local MAXLEN = 10
local function fit(gc, t, maxw)
  while #t > 1 and gc:getStringWidth(t) > maxw do t = t:sub(2) end
  return t
end

local row, col, top = 1, 1, 1
local edited = {}

local function cell(r, c) return (c == 1) and dx[r] or dy[r] end
local function setc(r, c, s) if c == 1 then dx[r] = s else dy[r] = s end end

local function tonum(s)
  if s == nil or s == "" or s == "-" or s == "." or s == "-." then return nil end
  return tonumber(s)
end

local ckey, cres
local function stats()
  local k = table.concat(dx, "\30") .. "\31" .. table.concat(dy, "\30")
  if k == ckey then return cres end
  ckey = k

  local function uni(d)
    local n, s, lo, hi, srt = 0, 0, nil, nil, {}
    for i = 1, MAXN do
      local x = tonum(d[i])
      if x then
        n = n + 1; s = s + x; srt[n] = x
        if lo == nil or x < lo then lo = x end
        if hi == nil or x > hi then hi = x end
      end
    end
    if n == 0 then return nil end
    table.sort(srt)
    local med
    if n % 2 == 1 then med = srt[(n + 1) / 2]
    else med = (srt[n / 2] + srt[n / 2 + 1]) / 2 end
    local m = s / n
    local ss = 0
    for i = 1, MAXN do
      local x = tonum(d[i])
      if x then ss = ss + (x - m) * (x - m) end
    end
    return { n = n, mean = m, med = med,
             sd = (n > 1) and sqrt(ss / (n - 1)) or nil,   -- sample, n-1
             sg = sqrt(ss / n),                            -- population, n
             lo = lo, hi = hi }
  end

  local X, Y = uni(dx), uni(dy)
  if X == nil and Y == nil then
    cres = { rows = {{"", "enter values in X"}}, cov = nil, r = nil, np = 0 }
    return cres
  end

  -- paired statistics over rows where BOTH values are present
  local np, sx, sy = 0, 0, 0
  for i = 1, MAXN do
    local a, b = tonum(dx[i]), tonum(dy[i])
    if a and b then np = np + 1; sx = sx + a; sy = sy + b end
  end
  local cov, r
  if np > 1 then
    local mx, my = sx / np, sy / np
    local sxy, sxx, syy = 0, 0, 0
    for i = 1, MAXN do
      local a, b = tonum(dx[i]), tonum(dy[i])
      if a and b then
        sxy = sxy + (a - mx) * (b - my)
        sxx = sxx + (a - mx) * (a - mx)
        syy = syy + (b - my) * (b - my)
      end
    end
    cov = sxy / np                      -- population covariance (divided by n)
    if sxx > 0 and syy > 0 then r = sxy / sqrt(sxx * syy) end
  end

  cres = { X = X, Y = Y, cov = cov, r = r, np = np }
  return cres
end

function on.paint(gc)
  local w, h = platform.window:width(), platform.window:height()
  local S = stats()

  gc:setColorRGB(255, 255, 255); gc:fillRect(0, 0, w, h)
  gc:setColorRGB(28, 52, 104);   gc:fillRect(0, 0, w, 15)
  gc:setColorRGB(255, 255, 255); gc:setFont("sansserif", "b", 9)
  gc:drawString(TITLE, 4, 1, "top")

  local numW, cw = 24, 88
  local gy, gh = 17, 12

  gc:setColorRGB(90, 90, 90); gc:setFont("sansserif", "r", 7)
  gc:drawString("X", 4 + numW + cw / 2, gy - 1, "top")
  gc:drawString("Y", 4 + numW + cw + cw / 2, gy - 1, "top")

  for k = 0, VIS - 1 do
    local i = top + k
    local y = gy + 11 + k * gh
    gc:setColorRGB(140, 140, 140); gc:setFont("sansserif", "r", 7)
    gc:drawString(tostring(i), 4, y - 1, "top")
    for c = 1, 2 do
      local x = 4 + numW + (c - 1) * cw
      if i == row and c == col then
        gc:setColorRGB(206, 224, 250); gc:fillRect(x, y, cw - 3, gh - 1)
      end
      gc:setColorRGB(140, 140, 140); gc:drawRect(x, y, cw - 3, gh - 1)
      gc:setColorRGB(0, 0, 0); gc:setFont("sansserif", "r", 7)
      local t = fit(gc, cell(i, c), cw - 12)
      gc:drawString(t, x + cw - 7 - gc:getStringWidth(t), y - 1, "top")
      if i == row and c == col then
        gc:setColorRGB(0, 0, 170); gc:fillRect(x + cw - 5, y + 2, 1, gh - 5)
      end
    end
  end

  -- scroll position
  gc:setColorRGB(150, 150, 150); gc:setFont("sansserif", "r", 7)
  local sp = string.format("%d-%d of %d", top, top + VIS - 1, MAXN)
  gc:drawString(sp, w - 6 - gc:getStringWidth(sp), gy - 1, "top")

  local ry = gy + 11 + VIS * gh + 2
  gc:setColorRGB(28, 52, 104); gc:fillRect(4, ry, w - 8, 1)
  ry = ry + 3

  local X, Y = S.X, S.Y
  if X == nil and Y == nil then
    gc:setColorRGB(150, 20, 20); gc:setFont("sansserif", "b", 9)
    gc:drawString("enter values in column X", 6, ry, "top")
    gc:setColorRGB(120, 120, 120); gc:setFont("sansserif", "r", 7)
    gc:drawString(HINT, 4, h - 11, "top")
    return
  end

  local xR, yR = 4 + numW + cw - 6, 4 + numW + 2 * cw - 6
  local rh = 10

  gc:setColorRGB(90, 90, 90); gc:setFont("sansserif", "b", 7)
  gc:drawString("X", xR - gc:getStringWidth("X"), ry - 1, "top")
  gc:drawString("Y", yR - gc:getStringWidth("Y"), ry - 1, "top")
  ry = ry + rh

  local function line(lab, fx, fy)
    gc:setColorRGB(0, 0, 0); gc:setFont("sansserif", "r", 7)
    gc:drawString(lab, 6, ry - 1, "top")
    gc:setColorRGB(150, 20, 20); gc:setFont("sansserif", "b", 7)
    if fx then gc:drawString(fx, xR - gc:getStringWidth(fx), ry - 1, "top") end
    if fy then gc:drawString(fy, yR - gc:getStringWidth(fy), ry - 1, "top") end
    ry = ry + rh
  end

  local function g(t, f, dp) if t == nil then return nil end
    if t[f] == nil then return "--" end return fmt(t[f], dp) end

  line("n",            g(X, "n", 0),  g(Y, "n", 0))
  line("mean",         g(X, "mean"),  g(Y, "mean"))
  line("median",       g(X, "med"),   g(Y, "med"))
  line("s  sample sd", g(X, "sd"),    g(Y, "sd"))
  line("sigma pop sd", g(X, "sg"),    g(Y, "sg"))
  line("min",          g(X, "lo"),    g(Y, "lo"))
  line("max",          g(X, "hi"),    g(Y, "hi"))

  gc:setColorRGB(0, 0, 0); gc:setFont("sansserif", "r", 7)
  if S.np > 1 then
    gc:drawString("cov (pop, /n)", 6, ry - 1, "top")
    gc:setColorRGB(150, 20, 20); gc:setFont("sansserif", "b", 7)
    local s = fmt(S.cov, 5)
    gc:drawString(s, yR - gc:getStringWidth(s), ry - 1, "top")
    ry = ry + rh
    gc:setColorRGB(0, 0, 0); gc:setFont("sansserif", "r", 7)
    gc:drawString("correlation  (" .. S.np .. " pairs)", 6, ry - 1, "top")
    gc:setColorRGB(150, 20, 20); gc:setFont("sansserif", "b", 7)
    s = fmt(S.r, 6)
    gc:drawString(s, yR - gc:getStringWidth(s), ry - 1, "top")
  else
    gc:setColorRGB(150, 150, 150)
    gc:drawString("fill both columns for cov / correlation", 6, ry - 1, "top")
  end

  gc:setColorRGB(120, 120, 120); gc:setFont("sansserif", "r", 7)
  gc:drawString(HINT, 4, h - 11, "top")
end

local function fix()
  if row < 1 then row = 1 end
  if row > MAXN then row = MAXN end
  if row < top then top = row end
  if row > top + VIS - 1 then top = row - VIS + 1 end
  if top < 1 then top = 1 end
  platform.window:invalidate()
end

function on.arrowKey(k)
  if k == "up" then row = row - 1
  elseif k == "down" then row = row + 1
  elseif k == "left" then col = 1
  elseif k == "right" then col = 2 end
  fix()
end

function on.enterKey() row = row + 1; fix() end
function on.tabKey()
  if col == 1 then col = 2 else col = 1; row = row + 1 end
  fix()
end
function on.backtabKey()
  if col == 2 then col = 1 else col = 2; row = row - 1 end
  fix()
end

function on.charIn(ch)
  if ch == "\226\136\146" then ch = "-" end
  local cur = cell(row, col)
  if not edited[row * 10 + col] then cur = "" end
  if ch:match("^%d$") then
    if #cur >= MAXLEN then return end
    cur = cur .. ch
  elseif ch == "." then
    if cur:find("%.", 1, false) then return end
    if #cur >= MAXLEN then return end
    cur = (cur == "" and "0." or cur .. ".")
  elseif ch == "-" then
    if cur:sub(1, 1) == "-" then cur = cur:sub(2) else cur = "-" .. cur end
  else
    return
  end
  setc(row, col, cur); edited[row * 10 + col] = true
  platform.window:invalidate()
end

function on.backspaceKey()
  setc(row, col, string.sub(cell(row, col), 1, -2))
  edited[row * 10 + col] = true
  platform.window:invalidate()
end
function on.deleteKey()
  setc(row, col, ""); edited[row * 10 + col] = true
  platform.window:invalidate()
end
function on.clearKey() on.deleteKey() end

function on.escapeKey()
  for i = 1, MAXN do dx[i] = ""; dy[i] = "" end
  edited = {}; row, col, top = 1, 1, 1
  platform.window:invalidate()
end
