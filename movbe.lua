--[[
  转化选中选项，参考movbe指令

 参考:
 https://forum.cheatengine.org/viewtopic.php?t=578232&sid=ce7b36247dacd61d2271583ae0be4a1c
 https://forum.cheatengine.org/viewtopic.php?p=5745303&sid=5d5fe9fc432c6e7792145b637dadef43
]]

local function _movbe(value)

  -- 将当前value转化为16进制
  local hex = string.format("%x", value)

  -- 补0
  local len = 8 - #hex
  for i = 1, len do
    hex = "0" .. hex
  end

  -- 交换字节
  local be = ''
  for word in string.gmatch(hex, "([0-9a-fA-F][0-9a-fA-F])") do
    be = word..be
  end

  -- 转化为10进制返回
  return ''..tonumber(be, 16)
end

local al = getAddressList()
local mm = al.Parent.PopupMenu.Items

nm = createMenuItem(mm)
nm.Caption = "movbe"
nm.OnClick = function()
  if al.SelCount <= 0 then return end

  local sal_table = al.getSelectedRecords() -- 获取所有选中项
  for key,it in pairs(sal_table)  do it.Value = _movbe(it.Value) end
end
mm.add(nm)