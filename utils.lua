-- 打印table数据
-- 通常你需要将 pl https://github.com/lunarmodules/Penlight/tree/master/lua/pl
-- 下载到你的 <CE-DIR>/lua/pl
function dump(t)
  require "pl.pretty".dump(t)
end

-- 获取父窗口，如果返回0则是顶级窗口
-- https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getparent
function GetParent(hwnd)
 local parent = executeCodeLocalEx("GetParent", hwnd)
 if parent == 0 then return nil end
 return parent
end

-- 获取目标进程窗口句柄,只会返回顶级窗口句柄
function getTargetWindow()
  local w = getWindow(getForegroundWindow(), GW_HWNDFIRST)
  local pid = getOpenedProcessID()
  while w and (w~=0) do
    if getWindowProcessID(w) == pid and not GetParent(w) then
      return w
    end
    w = getWindow(w,GW_HWNDNEXT)
  end
  return nil
end

-- 获取目标进程窗口RECT
-- https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect
function getTargetWindowRect()
  local w = getTargetWindow()
  if w == nil then return nil end
  
  local dword_t = 4;
  -- save RECT
  local m = createMemoryStream()
  m.Size = dword_t * 4
  local r = {}
  
  -- 黑箱
  if executeCodeLocalEx("GetWindowRect", w, m.Memory) then
    m.Position = dword_t * 0;
    r['left'] = readIntegerLocal(m.Memory + m.Position, true)

    m.Position = dword_t * 1;
    r['top'] = readIntegerLocal(m.Memory + m.Position, true)

    m.Position = dword_t * 2;
    r['right'] = readIntegerLocal(m.Memory + m.Position, true)

    m.Position = dword_t * 3;
    r['bottom'] = readIntegerLocal(m.Memory + m.Position, true)

    r['width'] = r.right - r.left
    r['height'] = r.bottom - r.top
  end
  m.destroy()
  m=nil
  return r

end