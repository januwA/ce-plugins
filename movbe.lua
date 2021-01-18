--[[
  转化选中选项，参考movbe指令

 参考:
 https://forum.cheatengine.org/viewtopic.php?t=578232&sid=ce7b36247dacd61d2271583ae0be4a1c
 https://forum.cheatengine.org/viewtopic.php?p=5745303&sid=5d5fe9fc432c6e7792145b637dadef43
]] -- hex补零
local function zeroPadding(hex)
    local len = 8 - #hex
    for i = 1, len do hex = "0" .. hex end
    return hex
end

-- 提供一个全局的 _movbe 函数
-- 默认返回16进制,toNumber10设置为true可以返回10进制
function _movbe(value, toNumber10)
    if value == nil or value == '' or value == '??' then return '??' end

    -- 将当前value转化为16进制
    local hex = string.format("%x", value)

    -- 补0
    hex = zeroPadding(hex)

    -- 交换字节
    local be = ''
    for word in string.gmatch(hex, "([0-9a-fA-F][0-9a-fA-F])") do
        be = word .. be
    end

    -- 返回10/16进制
    return toNumber10 and '' .. tonumber(be, 16) or string.upper(be)
end

local AjanuwMovbe = {
    form = nil, -- form ui
    lv = nil, -- listview ui
    al = nil, -- getAddressList
    myMenuName = 'movbe' -- 菜单名
}

-- constructor
function AjanuwMovbe:new()
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self:run()
    return o
end

function AjanuwMovbe:run()
    -- form 初始化宽高
    self.formSize = {w = 600, h = 300}

    -- 计时器表
    self.rows = {}

    -- 创建菜单按钮
    self:initMovbeMenuItem()
end

-- 创建右键菜单项
-- Addresslist: https://wiki.cheatengine.org/index.php?title=Lua:Class:Addresslist
function AjanuwMovbe:initMovbeMenuItem()
    self.al = getAddressList()
    local mm = self.al.PopupMenu.Items
    local nm = createMenuItem(mm)
    nm.Caption = self.myMenuName
    nm.OnClick = function() self:MenuItemClickListener() end
    mm.add(nm)
end

-- 点击菜单movbe按钮触发事件
function AjanuwMovbe:MenuItemClickListener()

    -- 未选中任何一项直接返回
    if self.al.SelCount <= 0 then return end

    -- 第一次创建form ui
    if self.form == nil then
        self:initForm()
        self:initListView()
        self:initColumns()
    end

    if self.form.Visible then
        self:clearTimers()
    else
        self.form.show()
    end

    -- 获取所有选中项
    local sal_table = self.al.getSelectedRecords()

    -- 清理上一次的数据
    self.lv.Items.clear()

    -- 显示数据
    self:draw(sal_table)

end

-- 创建主窗体
function AjanuwMovbe:initForm()
    self.form = createForm(false)
    self.form.Caption = 'movbe'
    self.form.BorderStyle = 'bsSizeable'
    self.form.Width = self.formSize.w
    self.form.Height = self.formSize.h
    self.form.Position = poScreenCenter
    self.form.BorderStyle = bsSizeable
    self.form.OnClose = function()

        -- 清理计时器
        self:clearTimers()
        self.form.hide()
    end
end

-- 初始化 listview
function AjanuwMovbe:initListView()
    self.lv = createListView(self.form)
    self.lv.Align = alClient
    self.lv.ViewStyle = vsReport
    self.lv.ReadOnly = true
    self.lv.RowSelect = true
end

-- 初始化 Columns
function AjanuwMovbe:initColumns()
    local c = self.lv.Columns.add()
    c.caption = translate('描述')
    c.width = 100

    c = self.lv.Columns.add()
    c.caption = translate('地址')
    c.width = 100

    c = self.lv.Columns.add()
    c.caption = translate('类型')
    c.width = 50

    c = self.lv.Columns.add()
    c.caption = translate('数值')
    c.width = 80

    c = self.lv.Columns.add()
    c.caption = translate('hex')
    c.width = 80

    c = self.lv.Columns.add()
    c.caption = translate('movbe')
    c.width = 80

    c = self.lv.Columns.add()
    c.caption = translate('movbe hex')
    c.width = 80
end

-- 将数据全部显示在listview中
function AjanuwMovbe:draw(sal_table)
    if sal_table == nil then return end

    -- 判断值是否更改
    for key, it in pairs(sal_table) do self:createRow(key, it) end
end

-- MemoryRecord:https://wiki.cheatengine.org/index.php?title=Lua:Class:MemoryRecord
-- 创建一行row
function AjanuwMovbe:createRow(key, data)
    local row = self.lv.Items.add()
    local val
    local movbeHex

    -- 每隔500毫秒检查一次值是否更新
    self.rows[key] = setInterval(function()
        -- if process == nil and readInteger(process) == 0 then return end
        if data.value == '??' then return end

        if val ~= data.value then
            -- update
            row.SubItems.clear()
            row.caption = data.Description
            row.SubItems.add(data.Address)
            row.SubItems.add(data.Type)

            val = data.value
            movbeHex = _movbe(val)
            row.SubItems.add(val) -- value
            row.SubItems
                .add(string.upper(zeroPadding(string.format("%x", val)))) -- hex value
            row.SubItems.add('' .. tonumber(movbeHex, 16)) -- movbe value 
            row.SubItems.add(movbeHex) -- movbe hex value 
        end
    end, 500)

end

-- 清理计时器
function AjanuwMovbe:clearTimers()
    for k, v in pairs(self.rows) do clearInterval(v) end
    self.rows = {}
end

AjanuwMovbe:new()
