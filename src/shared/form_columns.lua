-- ============ FORM ENGINE ============
local vals, edited, sel = {}, {}, 1
for i = 1, #FIELDS do vals[i] = FIELDS[i].def or ""; edited[i] = false end

local MAXLEN = 10  -- longest string a field will accept

local function fit(gc, t, maxw)          -- drop leading chars so the tail stays visible
  while #t > 1 and gc:getStringWidth(t) > maxw do t = t:sub(2) end
  return t
end

local ckey, cres   -- result cache: recompute only when an input actually changes

local function num(i)
  local s = vals[i]
  if s == nil or s == "" or s == "-" or s == "." or s == "-." then return nil end
  return tonumber(s)
end

local function results()
  local k = table.concat(vals, "\30")
  if k ~= ckey then
    local v = {}
    for i = 1, #FIELDS do v[i] = num(i) end
    local ok, r = pcall(compute, v)
    if ok and type(r) == "table" and #r > 0 then cres = r
    else cres = { { "", "check inputs", "w" } } end
    ckey = k
  end
  return cres
end

local function geom(nres)
  local h = platform.window:height()
  local nrows = (COLS == 2) and math.ceil(#FIELDS / 2) or #FIELDS
  local need = nrows + nres + 1
  -- title bar 17, gap above RESULTS 5, footer 12. The old figure (h - 30)
  -- left out the gap, so the last result row could be dropped without notice.
  local avail = h - 17 - 5 - 12
  local lh = math.floor(avail / need)
  if lh > 14 then lh = 14 end
  if lh < 10 then lh = 10 end
  return nrows, lh, (lh >= 13) and 9 or 7
end

function on.paint(gc)
  local w, h = platform.window:width(), platform.window:height()
  local res = results()
  local nrows, lh, fs = geom(#res)

  gc:setColorRGB(255, 255, 255); gc:fillRect(0, 0, w, h)
  gc:setColorRGB(28, 52, 104);   gc:fillRect(0, 0, w, 15)
  gc:setColorRGB(255, 255, 255); gc:setFont("sansserif", "b", 9)
  gc:drawString(TITLE, 4, 1, "top")

  local colW = (COLS == 2) and (w - 6) / 2 or (w - 8)
  local boxW = (COLS == 2) and 62 or 80
  local top  = 17

  for i = 1, #FIELDS do
    local r, c
    if COLS == 2 then r = math.ceil(i / 2); c = (i - 1) % 2 else r = i; c = 0 end
    local y  = top + (r - 1) * lh
    local x0 = 4 + c * colW
    local bx = x0 + colW - boxW - 6

    if i == sel then
      gc:setColorRGB(206, 224, 250); gc:fillRect(x0 - 3, y, colW - 1, lh - 1)
    end
    gc:setColorRGB(0, 0, 0); gc:setFont("sansserif", "r", fs)
    gc:drawString(FIELDS[i].lab, x0, y - 1, "top")

    gc:setColorRGB(140, 140, 140); gc:drawRect(bx, y, boxW, lh - 2)
    gc:setColorRGB(0, 0, 0)
    local txt = fit(gc, vals[i], boxW - 9)
    -- right-aligned at a FIXED x; caret is a separate bar so digits never shift
    gc:drawString(txt, bx + boxW - 5 - gc:getStringWidth(txt), y - 1, "top")
    if i == sel then
      gc:setColorRGB(0, 0, 170); gc:fillRect(bx + boxW - 3, y + 2, 1, lh - 6)
    end
  end

  local ry = top + nrows * lh + 2
  gc:setColorRGB(28, 52, 104); gc:fillRect(4, ry, w - 8, 1)
  ry = ry + 3
  gc:setFont("sansserif", "b", fs)
  gc:drawString("RESULTS", 4, ry - 1, "top")
  ry = ry + lh

  for i = 1, #res do
    if ry + lh > h - 12 then break end
    local warn = (res[i][3] == "w")
    gc:setColorRGB(0, 0, 0)
    gc:setFont("sansserif", "r", fs)
    gc:drawString(tostring(res[i][1]), 6, ry - 1, "top")
    if warn then gc:setColorRGB(190, 90, 0) else gc:setColorRGB(150, 20, 20) end
    gc:setFont("sansserif", "b", fs)
    local s = tostring(res[i][2])
    gc:drawString(s, w - 6 - gc:getStringWidth(s), ry - 1, "top")
    ry = ry + lh
  end

  gc:setColorRGB(120, 120, 120); gc:setFont("sansserif", "r", 7)
  gc:drawString(HINT, 4, h - 12, "top")
end

local function move(d)
  sel = sel + d
  if sel < 1 then sel = #FIELDS end
  if sel > #FIELDS then sel = 1 end
  platform.window:invalidate()
end

function on.arrowKey(key)
  if COLS == 2 then
    if key == "left" then move(-1)
    elseif key == "right" then move(1)
    elseif key == "up" then move(-2)
    elseif key == "down" then move(2) end
  else
    if key == "up" then move(-1) elseif key == "down" then move(1) end
  end
end

function on.tabKey()     move(1) end
function on.backtabKey() move(-1) end
function on.enterKey()   move(1) end

function on.charIn(ch)
  if ch == "\226\136\146" then ch = "-" end       -- Nspire (-) key sends U+2212
  local cur = vals[sel]
  if not edited[sel] then cur = "" end            -- first keystroke replaces a default
  if ch:match("^%d$") then
    if #cur >= MAXLEN then return end             -- cap length so text cannot overrun
    cur = cur .. ch
  elseif ch == "." then
    if cur:find("%.", 1, false) then return end   -- reject a second decimal point
    if #cur >= MAXLEN then return end
    cur = (cur == "" and "0." or cur .. ".")
  elseif ch == "-" then
    if cur:sub(1, 1) == "-" then cur = cur:sub(2) else cur = "-" .. cur end
  else
    return                                        -- ignore everything else
  end
  vals[sel] = cur; edited[sel] = true
  platform.window:invalidate()
end

function on.backspaceKey()
  vals[sel] = string.sub(vals[sel], 1, -2)
  edited[sel] = true
  platform.window:invalidate()
end
function on.deleteKey() on.backspaceKey() end

function on.clearKey()
  vals[sel] = ""; edited[sel] = true
  platform.window:invalidate()
end

function on.escapeKey()
  for i = 1, #FIELDS do vals[i] = FIELDS[i].def or ""; edited[i] = false end
  sel = 1
  platform.window:invalidate()
end
