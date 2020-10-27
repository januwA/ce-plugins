--[[
  在地址上右键Copy CurrentAddress
]]
local al = getAddressList()
local mm = al.Parent.PopupMenu.Items
local nm = createMenuItem(mm)
nm.Caption = "Copy CurrentAddress"
nm.OnClick = function(sender)
  if al.SelectedRecord == nil then
    return
  end

  local curAddr = string.format(targetIs64Bit() and "%016X" or "%08X", al.SelectedRecord.CurrentAddress)
  writeToClipboard(string.upper(curAddr))
end
mm.add(nm)
