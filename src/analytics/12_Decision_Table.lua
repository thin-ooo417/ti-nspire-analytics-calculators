platform.apilevel = '1.0'
local abs, floor, sqrt = math.abs, math.floor, math.sqrt

local function fmt(x, dp)
  if x == nil then return "--" end
  if x ~= x then return "n/a" end
  dp = dp or 2
  if abs(x) < 1e-12 then x = 0 end
  local a = abs(x)
  if a ~= 0 and (a < 1e-4 or a >= 1e8) then return string.format("%.4g", x) end
  return string.format("%." .. dp .. "f", x)
end

TITLE = "Decision table: EV, EVPI, maximin"
HINT  = "Blank a whole action row to use fewer than 3. Esc clears all"

local NS, NA = 4, 3                 -- states, actions
local prob = {"", "", "", ""}
local pay  = {}                     -- pay[action][state]
for a = 1, NA do pay[a] = {"", "", "", ""} end

local MAXLEN = 10
local function fit(gc, t, maxw)
  while #t > 1 and gc:getStringWidth(t) > maxw do t = t:sub(2) end
  return t
end

local row, col = 0, 1               -- row 0 = probability row, 1..NA = actions
local edited = {}

local function key(r, c) return r * 10 + c end
local function getS(r, c) if r == 0 then return prob[c] else return pay[r][c] end end
local function setS(r, c, s) if r == 0 then prob[c] = s else pay[r][c] = s end end

local function tonum(s)
  if s == nil or s == "" or s == "-" or s == "." or s == "-." then return nil end
  return tonumber(s)
end

local ckey, cres
local function results()
  local k = table.concat(prob, "\30")
  for a = 1, NA do k = k .. "\31" .. table.concat(pay[a], "\30") end
  if k == ckey then return cres end
  ckey = k

  local p, np = {}, 0
  for s = 1, NS do p[s] = tonum(prob[s]); if p[s] then np = np + 1 end end
  if np == 0 then cres = {{"", "enter probabilities"}} return cres end

  local sp, badp = 0, false
  for s = 1, NS do
    if p[s] then
      if p[s] < 0 or p[s] > 1 then badp = true end
      sp = sp + p[s]
    end
  end
  if badp then cres = {{"probabilities", "each 0 to 1", "w"}} return cres end

  -- an action is "live" only if every state with a probability has a payoff
  local live, ev, wrst, bst = {}, {}, {}, {}
  for a = 1, NA do
    local ok, e, lo, hi = true, 0, nil, nil
    for s = 1, NS do
      if p[s] then
        local x = tonum(pay[a][s])
        if x == nil then ok = false break end
        e = e + p[s] * x
        if lo == nil or x < lo then lo = x end
        if hi == nil or x > hi then hi = x end
      end
    end
    live[a] = ok
    if ok then ev[a] = e; wrst[a] = lo; bst[a] = hi end
  end

  local out = {}
  if abs(sp - 1) > 1e-9 then
    out[#out+1] = {"probs sum to " .. fmt(sp, 4), "must be 1", "w"}
  end

  local nlive = 0
  for a = 1, NA do if live[a] then nlive = nlive + 1 end end
  if nlive == 0 then
    out[#out+1] = {"", "fill one action row", "w"}
    cres = out return cres
  end

  for a = 1, NA do
    if live[a] then out[#out+1] = {"EV action " .. a, fmt(ev[a], 3)} end
  end

  if abs(sp - 1) > 1e-9 then cres = out return cres end

  local ba, be = nil, nil
  for a = 1, NA do
    if live[a] and (be == nil or ev[a] > be) then be = ev[a]; ba = a end
  end
  out[#out+1] = {"BEST = action " .. ba, fmt(be, 3)}

  -- perfect information: best action is chosen once each state is known
  local perf = 0
  for s = 1, NS do
    if p[s] then
      local m = nil
      for a = 1, NA do
        if live[a] then
          local x = tonum(pay[a][s])
          if m == nil or x > m then m = x end
        end
      end
      perf = perf + p[s] * m
    end
  end
  out[#out+1] = {"EV perfect info", fmt(perf, 3)}
  out[#out+1] = {"EVPI", fmt(perf - be, 3)}

  local mna, mnv = nil, nil
  for a = 1, NA do
    if live[a] and (mnv == nil or wrst[a] > mnv) then mnv = wrst[a]; mna = a end
  end
  out[#out+1] = {"maximin = action " .. mna, fmt(mnv, 3)}

  local mxa, mxv = nil, nil
  for a = 1, NA do
    if live[a] and (mxv == nil or bst[a] > mxv) then mxv = bst[a]; mxa = a end
  end
  out[#out+1] = {"maximax = action " .. mxa, fmt(mxv, 3)}

  cres = out
  return cres
end

function on.paint(gc)
  local w, h = platform.window:width(), platform.window:height()
  local res = results()

  gc:setColorRGB(255, 255, 255); gc:fillRect(0, 0, w, h)
  gc:setColorRGB(28, 52, 104);   gc:fillRect(0, 0, w, 15)
  gc:setColorRGB(255, 255, 255); gc:setFont("sansserif", "b", 9)
  gc:drawString(TITLE, 4, 1, "top")

  local labW = 28
  local cw   = floor((w - labW - 8) / NS)
  local gy   = 17
  local gh   = 12

  gc:setColorRGB(90, 90, 90); gc:setFont("sansserif", "r", 7)
  for s = 1, NS do
    local lbl = "state " .. s
    gc:drawString(lbl, 4 + labW + (s - 1) * cw + 3, gy - 1, "top")
  end

  for r = 0, NA do
    local y = gy + 11 + r * gh
    gc:setColorRGB(60, 60, 60); gc:setFont("sansserif", "r", 7)
    gc:drawString(r == 0 and "prob" or ("A" .. r), 4, y - 1, "top")
    for s = 1, NS do
      local x = 4 + labW + (s - 1) * cw
      if r == row and s == col then
        gc:setColorRGB(206, 224, 250); gc:fillRect(x, y, cw - 2, gh - 1)
      end
      gc:setColorRGB(140, 140, 140); gc:drawRect(x, y, cw - 2, gh - 1)
      gc:setColorRGB(0, 0, 0); gc:setFont("sansserif", "r", 7)
      local t = fit(gc, getS(r, s), cw - 9)
      gc:drawString(t, x + cw - 5 - gc:getStringWidth(t), y - 1, "top")
      if r == row and s == col then
        gc:setColorRGB(0, 0, 170); gc:fillRect(x + cw - 4, y + 2, 1, gh - 5)
      end
    end
  end

  local ry = gy + 11 + (NA + 1) * gh + 2
  gc:setColorRGB(28, 52, 104); gc:fillRect(4, ry, w - 8, 1)
  ry = ry + 3
  gc:setFont("sansserif", "b", 7)
  gc:drawString("RESULTS", 4, ry - 1, "top")
  ry = ry + 11

  local avail = h - 12 - ry
  local rh = floor(avail / math.max(#res, 1))
  if rh > 12 then rh = 12 end
  if rh < 9 then rh = 9 end

  for i = 1, #res do
    if ry + rh > h - 11 then break end
    gc:setColorRGB(0, 0, 0); gc:setFont("sansserif", "r", 7)
    gc:drawString(tostring(res[i][1]), 6, ry - 1, "top")
    if res[i][3] == "w" then gc:setColorRGB(190, 90, 0)
    else gc:setColorRGB(150, 20, 20) end
    gc:setFont("sansserif", "b", 7)
    local s = tostring(res[i][2])
    gc:drawString(s, w - 6 - gc:getStringWidth(s), ry - 1, "top")
    ry = ry + rh
  end

  gc:setColorRGB(120, 120, 120); gc:setFont("sansserif", "r", 7)
  gc:drawString(HINT, 4, h - 11, "top")
end

function on.arrowKey(k)
  if k == "up" then row = row - 1; if row < 0 then row = NA end
  elseif k == "down" then row = row + 1; if row > NA then row = 0 end
  elseif k == "left" then col = col - 1; if col < 1 then col = NS end
  elseif k == "right" then col = col + 1; if col > NS then col = 1 end end
  platform.window:invalidate()
end

local function advance()
  col = col + 1
  if col > NS then col = 1; row = row + 1; if row > NA then row = 0 end end
  platform.window:invalidate()
end
function on.tabKey() advance() end
function on.enterKey() advance() end
function on.backtabKey()
  col = col - 1
  if col < 1 then col = NS; row = row - 1; if row < 0 then row = NA end end
  platform.window:invalidate()
end

function on.charIn(ch)
  if ch == "\226\136\146" then ch = "-" end
  local cur = getS(row, col)
  if not edited[key(row, col)] then cur = "" end
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
  setS(row, col, cur); edited[key(row, col)] = true
  platform.window:invalidate()
end

function on.backspaceKey()
  setS(row, col, string.sub(getS(row, col), 1, -2))
  edited[key(row, col)] = true
  platform.window:invalidate()
end
function on.deleteKey() on.backspaceKey() end

function on.clearKey()
  setS(row, col, ""); edited[key(row, col)] = true
  platform.window:invalidate()
end

function on.escapeKey()
  for s = 1, NS do prob[s] = "" end
  for a = 1, NA do for s = 1, NS do pay[a][s] = "" end end
  edited = {}; row, col = 0, 1
  platform.window:invalidate()
end
