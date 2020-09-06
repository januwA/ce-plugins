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
  local a = targetIs64Bit() and "x64" or "x86"
  local c = getTargetModuleName() -- 修复中文

  if c == nil or c == "" then
    local Caption = MainForm.ProcessLabel.Caption
    MainForm.ProcessLabel.Caption = a .. "-" .. Caption
  else
    local b = hexPaddingZero(processId)
    MainForm.ProcessLabel.Caption = a .. "-" .. b .. "-" .. c
  end
end

local function onOpenProcessNext()
  initDLL()

  setTimeout(
    function()
      -- 等待dll加载解析后，才开始执行这些函数

      setProcessLabel()

    end,
    500
  )
end

--附加进程会调用这个钩子函数
-- https://wiki.cheatengine.org/index.php?title=Lua:onOpenProcess
processId = 0 -- 进程id
function onOpenProcess(openprocess_id)
  processId = openprocess_id

  setTimeout(onOpenProcessNext, 500)
end

-- 打印table数据
-- 通常你需要将 pl https://github.com/lunarmodules/Penlight/tree/master/lua/pl
-- 下载到你的 <CE-DIR>/lua/pl
function dump(t)
  require "pl.pretty".dump(t)
end

-- 获取目标程序的文件位置
function getTargetFilePath()
  if not getAddressSafe("getTargetFilePath") then return nil end

  local p_wchar = executeCodeEx(0, nil, "getTargetFilePath")
  return readString(p_wchar, 1024, true)
end

-- 获取目标程序的文件目录
function getTargetFileDir()
  if not getAddressSafe("getTargetFileDir") then return nil end

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
  if not getAddressSafe("exitWindowsEx") then return nil end

  if type(val) ~= "number" then
    return false
  end
  return executeCodeEx(0, nil, "exitWindowsEx", val) == 1
end

--[[
  获取目标进程主模块名
]]
function getTargetModuleName()
  
  if not getAddressSafe("getTargetModuleName") then return nil end

  local p_char = executeCodeEx(0, nil, "getTargetModuleName")
  return readString(p_char, 256, true)
end

--[[
  number转hex在补零
  print(hexPaddingZero(10))
]]
function hexPaddingZero(num, len)
  if type(num) ~= "number" then
    return nil
  end

  local hex = string.upper(string.format("%x", num))

  if len == nil then
    len = 8
  end

  while #hex < len do
    hex = "0" .. hex
  end
  return hex
end
