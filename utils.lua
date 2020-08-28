local function initDLL()
  local dllpath =
    getCheatEngineDir() ..
    (targetIs64Bit() and "autorun\\CE_Plugin\\x64\\Release\\CE_Plugin.dll" or
      "autorun\\CE_Plugin\\Release\\CE_Plugin.dll")
  -- print(dllpath)
  injectDLL(dllpath)
end

--附加进程会调用这个钩子函数
-- https://wiki.cheatengine.org/index.php?title=Lua:onOpenProcess
processId = 0 -- 进程id
function onOpenProcess(openprocess_id)
  processId = openprocess_id

  -- 延迟1s 注入DLL插件
  setTimeout(initDLL, 1000)
end

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

-- 打印table数据
-- 通常你需要将 pl https://github.com/lunarmodules/Penlight/tree/master/lua/pl
-- 下载到你的 <CE-DIR>/lua/pl
function dump(t)
  require "pl.pretty".dump(t)
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
  end
  m.destroy()
  m = nil
  return r
end
