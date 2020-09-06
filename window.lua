-- 和窗口有关的函数



-- 调用DLL中导出的getTargetWindow函数
-- targetWindow
function getTargetWindow()
  return executeCodeEx(0, nil, "getTargetWindow")
end

-- 获取宽字符标题
function getWindowTextW(hwnd)
  local m = createMemoryStream()
  m.Size = 1024
  local text = nil
  if executeCodeLocalEx("GetWindowTextW", hwnd, m.Memory, m.Size) ~= 0 then
    m.Position = 0
    text = readStringLocal(m.Memory, m.Size, true)
  end
  m.destroy()
  m = nil
  return text
end

-- 获取父窗口，如果返回0则是顶级窗口
-- https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getparent
function getParent(hwnd)
  local parent = executeCodeLocalEx("GetParent", hwnd)
  if parent == 0 then
    parent = nil
  end
  return parent
end

-- 获取目标进程窗口RECT
-- https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect
function getTargetWindowRect()
  local w = getTargetWindow()
  if w == nil or w == 0 then
    return nil
  end

  local dword_t = 4
  -- save RECT
  local m = createMemoryStream()
  m.Size = dword_t * 4
  local r = {}

  -- 黑箱
  if executeCodeLocalEx("GetWindowRect", w, m.Memory) then
    m.Position = dword_t * 0
    r["left"] = readIntegerLocal(m.Memory + m.Position, true)

    m.Position = dword_t * 1
    r["top"] = readIntegerLocal(m.Memory + m.Position, true)

    m.Position = dword_t * 2
    r["right"] = readIntegerLocal(m.Memory + m.Position, true)

    m.Position = dword_t * 3
    r["bottom"] = readIntegerLocal(m.Memory + m.Position, true)

    r["width"] = r.right - r.left
    r["height"] = r.bottom - r.top
  else
    r = nil
  end
  m.destroy()
  m = nil
  return r
end

-- 目标进程是否在所有窗口最顶层
function  targetWindowIsTop()
  return getForegroundProcess() == processId
end

--[[
  移动窗口: moveTargetWindow(number x, number y, number? nWidth, number? nHeight, number? bRepaint): bool 如果未指定宽高，则默认为当前宽高
  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-movewindow
]]
function moveTargetWindow(x, y, nWidth, nHeight, bRepaint)
  if type(x) ~= 'number' and type(y) ~= 'number' then return false end
  
  local rect = getTargetWindowRect();
  if rect == nil then return false end
  
  if nWidth == nil then
    nWidth = rect.width
  end

  if nHeight == nil then
    nHeight = rect.height
  end

  if type(nWidth) ~= 'number' and type(nHeight) ~= 'number' then return false end

  if bRepaint == nil then
    bRepaint = true
  end

  return executeCodeEx(0, nil, "moveTargetWindow", x, y, nWidth, nHeight, bRepaint and 1 or 0) ~= 0
end

--[[
  自动点击目标窗口
  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-mouse_event

  downKey  按下时的值 默认 MOUSEEVENTF_LEFTDOWN
  upKey    抬起时的值 默认 MOUSEEVENTF_LEFTUP
  offset 偏移量
  time  执行时间间隔 默认 200毫秒

  ```
    {$lua}
    if syntaxcheck then return end

    [ENABLE]
    closeCb = autoClickTargetWindow()

    [DISABLE]
    closeCb()
    closeCb = nil
  ```
]]
function autoClickTargetWindow(downKey, upKey, offset, time)
  
  -- 获取目标进程窗口属性
  local rect = getTargetWindowRect()
  if rect == nil then
    return
  end

  if downKey == nil then downKey = MOUSEEVENTF_LEFTDOWN end
  if upKey == nil then upKey = MOUSEEVENTF_LEFTUP end
  if offset == nil then offset = 10 end
  if time == nil or type(time) ~= "number" then time = 200 end

  local ptimer = setInterval(function()
    -- 是否选中游戏
    if not targetWindowIsTop() then return end
  
    -- 当前鼠标位置
    local x,y = getMousePos()
  
    -- 在游戏区域内
    if x > rect.left + offset and x < rect.right - offset and
       y > rect.top + offset and y < rect.bottom - offset then
       mouse_event(downKey)
       sleep(20)
       mouse_event(upKey)
    end
  end, time)

  -- 清理函数
  return function ()
    clearInterval(ptimer)
  end
end
