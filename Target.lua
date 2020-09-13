--[[
  将所有和目标进程有关的函数封装在这个模块中
]]
Target = {
  hwnd = 0,
  pid = 0,
  caption = nil, -- 标题
  exePath = nil, -- game exe path
  exeDir = nil, -- game exe dir
  moduleName = nil -- 主模块名 xxx.exe
}
target = Target

--[[
  获取目标进程主模块名
  :string
]]
function Target.getModuleName()
  local p_char = executeCodeEx(0, nil, "getTargetModuleName")
  Target.moduleName = readString(p_char, 256, true)
  return Target.moduleName
end

--[[
  获取目标进程的exe path

  :string
]]
function Target.getExePath()
  local p_char = executeCodeEx(0, nil, "getTargetExePath")
  Target.exePath = readString(p_char, 1024, true)
  return Target.exePath
end

--[[
  获取目标进程的exe path

  :string
]]
function Target.getExeDir()
  local exePath = Target.getExePath()
  Target.exeDir = string.gsub(exePath, [[[^\]+.exe$]], "")
  return Target.exeDir
end

--[[
  获取标题文本
  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowtextw

  :string or nil
]]
function Target.getWindowTextW()
  local m = createMemoryStream()
  m.Size = 1024
  if executeCodeLocalEx("GetWindowTextW", Target.getWindow(), m.Memory, m.Size) ~= 0 then
    m.Position = 0
    Target.caption = readStringLocal(m.Memory, m.Size, true)
  end
  m.destroy()
  m = nil
  return Target.caption
end

--[[
  返回窗口句柄
  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindow

  :number
]]
function Target.getWindow()
  Target.hwnd = executeCodeEx(0, nil, "getTargetWindow")
  return Target.hwnd
end

--[[
  获取窗口句柄父窗口，如果返回0则是顶级窗口
  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getparent

  -hwnd number
  :number
]]
function Target.getParent(hwnd)
  return executeCodeLocalEx("GetParent", hwnd)
end

--[[
  获取目标进程窗口RECT
  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect

  :RECT or nil
]]
function Target.getWindowRect()
  local w = Target.getWindow()
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

--[[
  目标进程是否在所有窗口最顶层
  :bool
]]
function Target.windowIsTop()
  return getForegroundProcess() == processId
end

--[[
  移动窗口, 如果未指定宽高，则默认为当前宽高
  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-movewindow

  -number x
  -number y
  -number? nWidth
  -number? nHeight
  -number? bRepaint
  :bool
]]
function Target.moveWindow(x, y, nWidth, nHeight, bRepaint)
  if type(x) ~= "number" and type(y) ~= "number" then
    return false
  end

  local rect = Target.getWindowRect()
  if rect == nil then
    return false
  end

  if nWidth == nil then
    nWidth = rect.width
  end

  if nHeight == nil then
    nHeight = rect.height
  end

  if type(nWidth) ~= "number" and type(nHeight) ~= "number" then
    return false
  end

  if bRepaint == nil then
    bRepaint = true
  end
  return executeCodeLocalEx("MoveWindow", Target.getWindow(), x, y, nWidth, nHeight, bRepaint and 1 or 0) ~= 0
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
    closeCb = Target.autoClickWindow()

    [DISABLE]
    closeCb()
    closeCb = nil
  ```

  -number? downKey
  -number? upKey
  -number? offset
  -number? time
  :function
]]
function Target.autoClickWindow(downKey, upKey, offset, time)
  -- 获取目标进程窗口属性
  local rect = Target.getWindowRect()
  if rect == nil then
    return
  end

  if downKey == nil then
    downKey = MOUSEEVENTF_LEFTDOWN
  end
  if upKey == nil then
    upKey = MOUSEEVENTF_LEFTUP
  end
  if offset == nil then
    offset = 10
  end
  if time == nil or type(time) ~= "number" then
    time = 200
  end

  local ptimer =
    setInterval(
    function()
      -- 是否选中游戏
      if not Target.windowIsTop() then
        return
      end

      -- 当前鼠标位置
      local x, y = getMousePos()

      -- 在游戏区域内
      if x > rect.left + offset and x < rect.right - offset and y > rect.top + offset and y < rect.bottom - offset then
        mouse_event(downKey)
        sleep(20)
        mouse_event(upKey)
      end
    end,
    time
  )

  -- 清理函数
  return function()
    clearInterval(ptimer)
  end
end

--[[
  对应 win32Api ShowWindow
  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow

  :void
]]
function Target.showWindow(nCmdShow)
  if type(nCmdShow) ~= "number" then
    return
  end
  return executeCodeLocalEx("ShowWindow", Target.getWindow(), nCmdShow)
end

--[[
  隐藏目标窗口

  :void
]]
function Target.hide()
  return Target.showWindow(0)
end

--[[
  显示目标窗口

  :void
]]
function Target.show()
  return Target.showWindow(1)
end
