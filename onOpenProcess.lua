local function initDLL()
  if not isInjectPluginDLL() then
    local dllpath =
      getCheatEngineDir() ..
      (targetIs64Bit() and "autorun\\CE_Plugin\\x64\\Release\\CE_Plugin.dll" or
        "autorun\\CE_Plugin\\Release\\CE_Plugin.dll")
    -- print(dllpath)
    injectDLL(dllpath)
  end
end

-- 加上目标进程是x86还是x64的标识
local function setProcessLabel()
  local a = targetIs64Bit() and "x64" or "x86"
  local c = Target.getModuleName() -- 修复中文

  if c == nil or c == "" then
    local Caption = MainForm.ProcessLabel.Caption
    MainForm.ProcessLabel.Caption = a .. "-" .. Caption
  else
    local b = hexPaddingZero(processId)
    MainForm.ProcessLabel.Caption = a .. "-" .. b .. "-" .. c
  end
end

-- 初始化Target模块中的属性
local function initTarget()
  Target.pid = processId
  Target.getWindow()
  Target.getWindowTextW()
  Target.getExePath()
  Target.getExeDir()
  Target.getModuleName()
end

--附加进程会调用这个钩子函数
-- https://wiki.cheatengine.org/index.php?title=Lua:onOpenProcess
processId = 0 -- 进程id
function onOpenProcess(openprocess_id)
  processId = openprocess_id

  setTimeout(
    function()
      initDLL()
      _____time =
        setInterval(
        function()
          if isInjectPluginDLL() then
            clearInterval(_____time)
            _____time = nil
            -- 等待dll加载解析后，才开始执行这些函数
            setProcessLabel()
            initTarget()
          end
        end,
        200
      )
    end,
    500
  )
end
