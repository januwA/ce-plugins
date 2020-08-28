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


-- 打印table数据
-- 通常你需要将 pl https://github.com/lunarmodules/Penlight/tree/master/lua/pl
-- 下载到你的 <CE-DIR>/lua/pl
function dump(t)
  require "pl.pretty".dump(t)
end
