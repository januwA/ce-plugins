-- 获取新的跳转字节集
 -- local r = getJmpNewBytes(0x008E05AE, 0x01350000, 5, { 0xE9 })
-- writeBytes(0x008E05AE, r)
function getJmpNewBytes(from, to, count, shiftTable)

  -- 跳转偏移字节
  -- 字节集 = 跳转目标地址 - (当前指令地址+当前指令字节长度)
  local offsetByte = to - (from+count)

  -- 初始化跳转指令，默认为jmp
  local newBytes =  shiftTable or { 0xE9 }

  local bt = dwordToByteTable(offsetByte)

  for i, v in ipairs(bt) do
     newBytes[#newBytes+1] = v
  end
  return newBytes
end
