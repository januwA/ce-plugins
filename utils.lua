-- 打印table数据
-- 通常你需要将 pl https://github.com/lunarmodules/Penlight/tree/master/lua/pl
-- 下载到你的 <CE-DIR>/lua/pl
function dump(t)
  require "pl.pretty".dump(t)
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
  local addr = getAddressSafe("isInjectCE_PluginDLL")
  return addr ~= nil and readBytes(addr) == 1
end

--[[
		0关机 1重启 2注销
		失败返回FALSE，否者返回TRUE
    https://www.cnblogs.com/ajanuw/p/13607687.html
    
    :bool
]]
function exitWindowsEx(val)
  if type(val) ~= "number" then
    return false
  end
  return executeCodeEx(0, nil, "exitWindowsEx", val) == 1
end

--[[
  number转hex在补零
  print(hexPaddingZero(10))

  -number  num
  -number? len
  :string
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

--[[

  检查是否启用mono，启动后JIT编译指定的函数

  ```
  {$lua}
    if syntaxcheck then return end
    autorunMonoMethod('PlayerAttribute', 'set_currentEnergy')
  {$asm}
  ```
  -string  className
  -string  methodName
  :void
]]
function autorunMonoMethod(className, methodName)
  -- 检查参数
  if type(className) ~= "string" or type(methodName) ~= "string" then
    return
  end

  -- 检查是否附加进程
  if process == nil or readInteger(process) == 0 then
    return
  end

  -- 激活Mono
  mono_initialize()

  -- Jit编译
  if LaunchMonoDataCollector() ~= 0 then
    local mId = mono_findMethod("Assembly-CSharp", className, methodName)
    mono_compile_method(mId)
  end
end

-- 获取新的跳转字节集
-- local r = getJmpNewBytes(0x008E05AE, 0x01350000, 5, { 0xE9 })
-- writeBytes(0x008E05AE, r)
function getJmpNewBytes(from, to, count, shiftTable)
  -- 跳转偏移字节
  -- 字节集 = 跳转目标地址 - (当前指令地址+当前指令字节长度)
  local offsetByte = to - (from + count)

  -- 初始化跳转指令，默认为jmp
  local newBytes = shiftTable or {0xE9}

  local bt = dwordToByteTable(offsetByte)

  for i, v in ipairs(bt) do
    newBytes[#newBytes + 1] = v
  end
  return newBytes
end
