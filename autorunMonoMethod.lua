-- 检查是否启用mono，启动后JIT编译指定的函数
--[[
{$lua}
  if syntaxcheck then return end
  _checkMonoMethod('PlayerAttribute', 'set_currentEnergy')
{$asm}
--]]
function autorunMonoMethod(cName, mName)

  -- 检查参数
  if cName == nil and mName == nil then return end

  -- 检查是否附加进程
  -- showMessage(process)
  if process == nil and readInteger(process) == 0 then
    local msg = 'No process detected.'
    print(msg)
    error(msg)
    return
  end

  -- 激活Mono
  mono_initialize()

  -- Jit编译
  if LaunchMonoDataCollector() ~= 0 then
    local mId = mono_findMethod('Assembly-CSharp', cName, mName)
    mono_compile_method(mId)
  end
end