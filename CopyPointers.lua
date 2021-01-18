--[[
  在地址上右键Copy Pointers
]] local al = getAddressList()
local mm = al.Parent.PopupMenu.Items
local nm = createMenuItem(mm)
nm.Caption = "Copy Pointers"
nm.OnClick = function(sender)
    local it = al.SelectedRecord
    if it == nil then return end

    if it.OffsetCount ~= 0 then
        local addr = it.Address
        for i = it.OffsetCount - 1, 0, -1 do
            local next = string.format("%x", it.Offset[i])
            addr = "[" .. addr .. "]+" .. next
        end
        writeToClipboard(string.upper(addr))
    end
end
mm.add(nm)
