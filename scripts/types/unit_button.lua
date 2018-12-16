local jass = require 'jass.common'
local Unit = require 'types.unit'
local player = require 'ac.player'

local Unit_button = {}
setmetatable(Unit_button, Unit_button)


local mt = {}
Unit_button.__index = mt

mt.type = nil

--点击按钮
function mt:click()
    if self.on_click then
        self:on_click()
    end
    if self.clicker then
        -- Sound\Interface\AutoCastButtonClick1.wav --任务提示音
        -- Sound\Interface\BigButtonClick.wav  --按钮点击音
        -- PingMinimap 小地图提示
        self.clicker:event_notify('单位-点击单位按钮', self.clicker, self)
    end
end

--进行标记
--	标记索引
function mt:set(key, value)
    local parent = self.parent or self
    parent[key] = value
    
end

--获取标记
--	标记索引
function mt:get(key)
    local parent = self.parent or self
    return  parent[key] 
end

--新建一个Unit_button
--  名称（要求已经注册）
--  点击的单位
--  出售的商店
function mt:new(name, unit, shop)
    local Button = ac.unit_button[name]
    if type(Button) == 'function' then
        print('按钮没有被注册')
        return false
    end
    local parent = Button[unit]
    if not parent then
        parent = setmetatable({}, {__index = Button})
        Button[unit] = parent
        parent.is_parent = true
        parent.owner = unit
    end
    local new = setmetatable({}, {__index = parent})
    new.parent = parent
    new.clicker = unit
    new.seller = shop

    if not unit._unit_buttons then
        unit._unit_buttons = {}
    end
    if not unit._unit_buttons[name] then
        unit._unit_buttons[name] = parent
    end

    return new
end

--移除
--其实移除方法没什么必要的，要清除的应该是ac.unit_button[name][unit]
function mt:remove()
    if self.is_parent then
        ac.unit_button[self.name][self.owner] = nil
    end
end

--  为单位 添加单位按钮（商店出售），按钮实际 已在售出时创建，所以不需要再一次new。
--	物品名字或id  
function Unit.__index:add_unit_button(name, stock)
	local id = Registry:name_to_id(name)
    local Button = ac.unit_button[name]
    local currentstock = stock or Button:get('currentstock')  or 1
    local stockmax = stock or Button:get('stockmax')  or 1

    jass.AddUnitToStock(self.handle,base.string2id(id), currentstock, stockmax) 

    -- ac.unit_button[name]
	return Button
end

--单位出售单位事件
local j_trg = war3.CreateTrigger(function()
    local handle = jass.GetSoldUnit()
    local shop = ac.unit(jass.GetTriggerUnit())
    local unit = ac.unit(jass.GetBuyingUnit())
    local id = base.id2string(jass.GetUnitTypeId(handle))
    local name = Registry:id_to_name(id)

    local button = Unit_button:new(name, unit, shop)
    if button then
        button:click()
        jass.RemoveUnit(handle)
        -- return
    end
    local sold_unit = ac.unit(handle)
    -- print(shop,button,unit,sold_unit)
    unit:event_notify('单位-购买单位', unit, sold_unit, shop)
    shop:event_notify('单位-出售单位', shop, sold_unit, unit)
end)
for i = 1, 16 do
    jass.TriggerRegisterPlayerUnitEvent(j_trg, player[i].handle, jass.EVENT_PLAYER_UNIT_SELL, nil)
end


local function register_unit_button(self, name, data)
    if not data.war3_id then
        Log.error(('注册%s 按钮单位时，不能没有war3_id'):format(name) )
		return
    end
    
    Registry:register(name, data.war3_id)

    setmetatable(data, data)
    data.__index = Unit_button

    local button = {}
    setmetatable(button, button)
    button.__index = data
    button.__call = function(self, data)
        self.data = data
        return self
    end
    button.name = name
    button.data = data
    
    self[name] = button
    self[data.war3_id] = button

    return button
end

local function init()
    
    --注册单位按钮
    ac.unit_button = setmetatable({}, {__index = function(self, name)
        return function(data)
            return register_unit_button(self, name, data)
        end
    end})

end

init()

return Unit_button