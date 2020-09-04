local function initDLL()
  if not isInjectPluginDLL() then
    local dllpath =
      getCheatEngineDir() ..
      (targetIs64Bit() and "autorun\\CE_Plugin\\x64\\Release\\CE_Plugin.dll" or
        "autorun\\CE_Plugin\\Release\\CE_Plugin.dll")
    -- print(dllpath)
    injectDLL(dllpath)
    writeBytes(getAddressSafe("isInjectCE_PluginDLL"), 1)
  end
end

-- 加上目标进程是x86还是x64的标识
local function setProcessLabel()
  local Caption = MainForm.ProcessLabel.Caption
  local str = targetIs64Bit() and "x64" or "x86"
  MainForm.ProcessLabel.Caption = str .. "-" .. Caption
end

local function onOpenProcessNext()
  initDLL()
  setProcessLabel()
end

--附加进程会调用这个钩子函数
-- https://wiki.cheatengine.org/index.php?title=Lua:onOpenProcess
processId = 0 -- 进程id
function onOpenProcess(openprocess_id)
  processId = openprocess_id

  setTimeout(onOpenProcessNext, 1000)
end

-- 打印table数据
-- 通常你需要将 pl https://github.com/lunarmodules/Penlight/tree/master/lua/pl
-- 下载到你的 <CE-DIR>/lua/pl
function dump(t)
  require "pl.pretty".dump(t)
end

-- 获取目标程序的文件位置
function getTargetFilePath()
  local p_wchar = executeCodeEx(0, nil, "getTargetFilePath")
  return readString(p_wchar, 1024, true)
end

-- 获取目标程序的文件目录
function getTargetFileDir()
  local p_wchar = executeCodeEx(0, nil, "getTargetFileDir")
  return readString(p_wchar, 1024, true)
end

-- 打印一个对象的属性列表
-- dumpProps(MainForm)
function dumpProps(obj)
  local r = getPropertyList(obj)
  for i = 0, r.Count - 1, 1 do
    print(r[i])
  end
end

-- 打印子组件列表名
-- dumpComps(MainForm)
function dumpComps(obj)
  for i = 0, obj.getComponentCount() - 1 do
    local it = obj.getComponent(i)
    print(it.Name)
  end
end

-- 如果已经注入返回true
function isInjectPluginDLL()
  return getAddressSafe("isInjectCE_PluginDLL") ~= nil
end

--[[
		0关机 1重启 2注销
		返回FALSE则失败，否者返回TRUE
		https://www.cnblogs.com/ajanuw/p/13607687.html
]]
function exitWindowsEx(val)
  if type(val) ~= 'number' then return false end
  return executeCodeEx(0, nil, "exitWindowsEx", val) == 1
end