
local slk = require 'jass.slk'
local jass = require 'jass.common'
local dbg = require 'jass.debug'
local skill = require 'ac.skill'
local table = table
local japi = require 'jass.japi'
local runtime = require 'jass.runtime'
local Player = require 'ac.player'
local Unit = require 'types.unit'
local Point = require 'ac.point'
local setmetatable = setmetatable
local xpcall = xpcall
local select = select
local error_handle = runtime.error_handle

local Item = {}
setmetatable(Item, Item)

local mt = {}
Item.__index = mt

mt.id = 0

--类型
mt.type = 'item'

--物品分类
mt.item_type = '无'

--物品等级
mt.level = 1

--价格
mt.gold = 0

--物品所在的格子,1-6
--	-1:无所有者
--	nil:已被移除
mt.slotid = nil

--物品是否唯一
mt.unique = false

--物品创建时间
mt.create_time = nil

--类型
mt.slot_type = '物品'

--当前使用者,指单位
mt.owner = nil

--原始拥有者
mt.player = nil

--最大库存（商店）
mt.maxstock = 1
--当前库存
mt.currentstock =  1

_ITEM_PLACEHOLDER_ID = SYS_ITEM_PLACEHOLDER_ID or 'ches'


--应该被忽略的物品组,该状态时，不应该执行获得、失去、移动物品的逻辑
local _ignore_flag_items = {}

--由于魔兽的机制，导致出售物品后，会触发多一次的单位丢弃物品事件
local _ignore_double_trg_flag_items = {}

--用享元模式来控制占位物品的获取
--占位物品表
local _placeholder_items = {}

local dummy_id = base.string2id(_ITEM_PLACEHOLDER_ID)

--初始化占位物品的状态
local function init_placeholder_item(j_item)
	local item = _placeholder_items[j_item]
	jass.SetItemVisible(j_item, false)
	item._is_leisure = true
end

--增加占位物品
local function add_placeholder_item()
	local j_item = jass.CreateItem(dummy_id, 0, 0)
	dbg.handle_ref(j_item)
	_ignore_flag_items[j_item] = true

	local item = {}
	item.handle = j_item
	item._is_leisure = true
	_placeholder_items[j_item] = item
	init_placeholder_item(j_item)

	return item
end

--获取占位物品
--	@物品的handle
local function get_placeholder_item()
	local item 
	for _, it in pairs(_placeholder_items) do
		if it._is_leisure then
			item = it
			break
		end
	end
	if not item then
		item = add_placeholder_item()
	end
	local j_item = item.handle
	jass.SetItemVisible(j_item, true)
	item._is_leisure = false
	return j_item
end

--重置占位物品的状态
local function reclaim_placeholder_item(j_item)
	init_placeholder_item(j_item)
end



--格子，1-6
function Unit.__index:get_slot_item(slotid)
	if not self._item_list then
		self._item_list = {}
	end
	return self._item_list[slotid]
end

--为单位创建物品
--	物品名字或id
function Unit.__index:add_item(name, data)
	local id = Registry:name_to_id(name)
	local item = Item.create_item(id, self, data)
	return item
end

--单位捡到物品
--	物品
function Unit.__index:pick_item(it)
	it.owner = self
	it._in_slot = true
	local slotid = it:get_slotid(true)
	-- print(it,it.name,slotid)
	if not self._item_list then
		self._item_list = {}
	end
	self._item_list[slotid] = it
	it:on_adding()
end

--单位丢弃物品
--	物品
function Unit.__index:drop_item(it)
	if not it then 
		return
	end	
	it:on_dropping()
	it.owner = nil
	it.last_owner = self
	it._in_slot = false
	if not self._item_list then
		self._item_list = {}
	end
	self._item_list[it.slotid] = nil
	it.slotid = -1
end

--单位拥有物品
--	物品名称
--	@该物品，或者无
function Unit.__index:has_item(name)
	for i = 1, 6 do
		local it = self:get_slot_item(i)
		if it then
			if it:get_name() == name then
				return it
			end
		end
	end
	return false
end

--单位移除找到的物品
--	具体的某物品或根据名字找到的第一个物品
--	@移除成功
function Unit.__index:remove_item( it )
	if not it then
		return false
	end
	if type(it) == 'string' then
		--如果不是物品则是物品的名字
		it = self:has_item(it)
		if not it then
			return false
		end
	end
	jass.RemoveItem(it.handle)
	return true
end

--刷新因为物品带来的速度
--	[不参与计算的物品]
function Unit.__index:fresh_item_move_speed(ignore_item)
	if not self._item_move_speed then
		self._item_move_speed = 0
	end
	unit:add_move_speed(-unit._item_move_speed)
	local max_speed = 0
	local sum_speed = 0
	for i = 1, 6 do
		local it = self:get_slot_item(i)
		if it and item ~= ignore_item then
			if it.is_move_speed_overlay then
				sum_speed = sum_speed + it.move_speed
			else
				if max_speed < it.move_speed then
					max_speed = it.move_speed
				end
			end
		end
	end
	unit._item_move_speed = max_speed + sum_speed
	unit:add_move_speed(unit._item_move_speed)
end

--  为单位 添加出售物品按钮（商店出售），按钮实际 已在售出时创建，所以不需要再一次new。
--	物品名字或id   
function Unit.__index:add_item_button(name, stock)
	local id = Registry:name_to_id(name)
	local item = ac.item[id]
	if type(item) =='function' then
		print(name..'还没注册')
		return false
	end	
	--由于魔兽机制 japi修改的物品string，需要创建完后再添加到商店 才能生效。
	local it = ac.point(0,0):add_item(id)
	if it then 
		it:remove()
	end	
	-- print(item)
    local currentstock = stock or Item.currentstock or 1
	local stockmax = stock or Item.stockmax  or 1
	
    Item.currentstock = currentstock
	Item.stockmax = stockmax
	
    jass.AddItemToStock(self.handle,base.string2id(id), currentstock, stockmax) 

    -- ac.unit_button[name]
	-- return item
end

--  为单位 删除 卖的物品
--	物品名字或id   
function Unit.__index:remove_item_button(name, stock)
	local id = Registry:name_to_id(name)
	local item = ac.item[id]
	if type(item) =='function' then
		print(name..'还没注册')
		return false
	end	
    jass.RemoveItemFromStock(self.handle,base.string2id(id)) 

end

--  删除所有市场的物品
--	物品名字或id   
function Item.remove_item_button_all()
	local id = Registry:name_to_id(name)
    jass.RemoveItemFromAllStock(base.string2id(id)) 
end	

--点创建物品
--	物品名字或id
function Point.__index:add_item(name)
	local id = Registry:name_to_id(name)
	local item = Item.create_item(id, self)
	return item
end

--根据id创建物品
--	war3 id
--	点/单位
--	额外数据表
function Item.create_item(id, who, data)
	local j_id = base.string2id(id)
	
	if who.type == 'point' then
		local x, y = who:get()
		local handle = jass.CreateItem(j_id, x, y)
		dbg.handle_ref(handle)
		local item = Item.new(handle)
		return item
	elseif who.type == 'unit' then
		local unit = who
		local point = unit:get_point()
		local x, y = point:get()
		local handle = jass.CreateItem(j_id, x, y)
		dbg.handle_ref(handle)
		local item = Item.new(handle)
		
		-- 加之前 和 装备唯一 可能要重构下。
		if item  and item.before_add then
			--如果有回调且返回false 或 不填 移除已创建的物品，直接返回
			if not item:before_add(unit)  then
				-- print('create_item 函数内的handle',handle) 
				item:remove()
				return 
			end	
		end	

		--如果装备唯一 直接返回
		
		if item.unique and unit:has_item(Registry:id_to_name(id)) then 
			
	    	-- print('create_item 函数内的handle',handle) 
			item:remove()
			who:get_owner():sendMsg("|cffFCD830"..Registry:id_to_name(id).."|r不允许重复获得")
			return 
		end	

		item:set_player(unit)
		if data and data.slotid then
			local j_its = {}
			for i = 1, data.slotid - 1 do
				--创建占位物品
				if jass.UnitItemInSlot(unit.handle, i - 1) == 0 then
					local j_it = get_placeholder_item()
					jass.UnitAddItem(unit.handle, j_it)
					table.insert(j_its, j_it)
				end
			end
			local res = jass.UnitAddItem(unit.handle, handle)
			--移除占位物品
			for i = 1, #j_its do
				reclaim_placeholder_item(j_its[i])
			end
			-- _ignore_flag_items[handle] = nil
		else
			jass.UnitAddItem(unit.handle, handle)
		end
		
		return item
	end
	
end

--根据handle新建物品
--	handle
function Item.new(handle)
	
	if handle == 0 or not handle then
		return nil
	end
	local war3_id = base.id2string(jass.GetItemTypeId(handle))
	-- print(war3_id)
	local data = ac.item[war3_id] 
	-- print(data)
	if type(data) == 'function' then
		data = Item
	end

	if data.tip  then
		data.tip = data.tip:gsub('%%([%w_]*)%%', function(k)
			local value = data[k]
			local tp = type(value)
			if tp == 'function' then
				return value(data)
			end
			return value
		end)
		Item.set_class_tip(war3_id,data.tip)
	end

	if data.name  then
		Item.set_class_title(war3_id,data.name)
	end

	if data.art  then
		Item.set_class_art(war3_id,data.art)
	end

	local it = {}
	setmetatable(it, it)
	it.__index = data
	it.handle = handle
	it.id = war3_id
	it.war3_id = war3_id
	-- it.name = jass.GetItemName(handle) --modify by jeff 物品初始化时，保存的名字为 新建时的名字非物编名字。old_value: jass.GetItemName(handle)
	it.player = Player[jass.GetItemPlayer(handle)] --modify by jeff 物品新建时 ，无所属玩家。

	--保存到全局物品表中
	Item.all_items[handle] = it
	
	return it
end

--根据句柄获取物品，对外唯一接口
function Item:__call(handle)
	if not handle or handle == 0 then
		return nil
	end
	local it = Item.all_items[handle]
	local old_it = it
	if not it then
		it = Item.new(handle)
	end
	return it
end

--获取物编数据
--	war3 id
--	项目名
--	[默认数据]
function Item.get_slk_by_id(id, name, default)
	local item_data = slk.item[id]
	if not item_data then
		Log.error('物品数据未找到', id)
		return default
	end
	local data = item_data[name]
	if data == nil then
		return default
	end
	if type(default) == 'number' then
		return tonumber(data) or default
	end
	return data
end

--获取物编数据
--	项目名
--	[默认数据]
function mt:get_slk(name, default)
	return Item.get_slk_by_id(self.id, name, default)
end

--获取类别的名称
function mt:get_type_name()
	return jass.GetItemName(self.handle)
end

--获取名称
--	@lua注册时用的名称
function mt:get_name()
	return self.name
end

--获取物品的物编id
function mt:get_id()
	if not self.id then
		self.id = jass.GetItemTypeId(self.handle)
	end
	return self.id
end

--是否已移除
function mt:is_removed()
	return self.removed
end

--上一个位置
mt._last_point = nil

--获取位置
function mt:get_point()

	if self.removed then
		return self._last_point
	else
		return ac.point(jass.GetItemX(self.handle), jass.GetItemY(self.handle))
	end
end

--设置位置
function mt:setPoint(point)
	local x, y = point:get()
	jass.SetItemPosition(self.handle, x, y) --设置物品的位置
	return true
end


--删除物品
function mt:remove()
	-- print('remove 函数内的handle',self.handle)
	-- 删除了的 为true. 删除过了就返回不删， modify by jeff 20181119
	if self.removed then
		return
	end
	if self.on_remove then
		self:on_remove()
	end
	
	self._last_point = ac.point(jass.GetItemX(self.handle), jass.GetItemY(self.handle))

	self.removed = true
	self._in_slot = false
	jass.RemoveItem(self.handle)
	dbg.handle_unref(self.handle)
	Item[self.handle] = nil
	Item.all_items[self.handle] = nil --modify by jeff 20181119  删除时，全局表的handle 需要重新赋值为nil。
	self.handle = nil
end

--获取购买金钱
function mt:get_gold()
	return self:get_slk('goldcost')
end

--获取购买木材
function mt:get_lumber()
	return self:get_slk('lumbercost')
end

--获取购买时间间隔  返回秒
function mt:get_stockRegen()
	return self:get_slk('stockRegen')
end

--获取使用次数
function mt:get_stack()
	return jass.GetItemCharges(self.handle)
end

--设置使用次数
function mt:set_stack(count)
	jass.SetItemCharges(self.handle, count)
end

--增加使用次数
function mt:add_stack(count)
	jass.SetItemCharges(self.handle, jass.GetItemCharges(self.handle) + (count or 1))
end

--是否物品可见的
function mt:is_visible()
	return not self.removed and self._in_slot and not self.owner:is_illusion()
end

--刷新物品
function mt:fresh()
	if not self:is_visible() then
		return
	end
	if not self.owner:is_alive() then
		return
	end
	_ignore_flag_items[self.handle] = true
	local u = self.owner
	local slotid = self.slotid
	jass.SetItemPosition(self.handle, 0, 0) --设置物品的位置
	local j_its = {}
	for i = 1, slotid - 1 do
		--创建占位物品
		if jass.UnitItemInSlot(u.handle, i - 1) == 0 then
			local j_it = get_placeholder_item()
			jass.UnitAddItem(u.handle, j_it)
			table.insert(j_its, j_it)
		end
	end
	jass.UnitAddItem(u.handle, self.handle)
	--移除占位物品
	for i = 1, #j_its do
		reclaim_placeholder_item(j_its[i])
	end
	_ignore_flag_items[self.handle] = nil
end

--显示冷却时间
function mt:set_show_cd(cool, max_cool)
	if not self:is_visible() then
		return
	end
	local _max_cool, _cool = self.skill:get_show_cd()
	local cool = cool or _cool
	local max_cool = max_cool or _max_cool
	if self.skill then
		if max_cool then
			japi.EXSetAbilityDataReal(self.skill:get_handle(), 1, 0x69, max_cool)
		end
		japi.EXSetAbilityState(self.skill:get_handle(), 0x01, cool)
		if max_cool then
			japi.EXSetAbilityDataReal(self.skill:get_handle(), 1, 0x69, 0)
		end
	end
end

--获取在单位身上的哪个格子
--	@格子，-1：不在身上
function mt:get_slotid(is_force)
	if self:is_removed() then
		return nil
	end
	if not self.slotid or is_force then
		if not self.owner then
			self.slotid = -1
			return -1
		end
		for i = 0, 5 do
			if jass.UnitItemInSlot(self.owner.handle, i) == self.handle then
				self.slotid = i+1
				break
			end
		end
	end
	return self.slotid
end

--获取持有者
function mt:get_owner()
	return self.owner
end

--获取上一个持有者
function mt:get_last_owner()
	return self.last_owner
end

--获取物品玩家
function mt:get_player()
	if not self.player then
		self.player = jass.GetItemPlayer(self.handle)
	end
	return self.player
end

--设置物品玩家
function mt:set_player(dest)
	local player = dest
	if dest.type == 'unit' then
		player = dest:get_owner()
	end
	jass.SetItemPlayer(self.handle, player.handle)
end

--获取说明
function mt:get_tip()
	return self:get_slk('Ubertip')
end

--获取名称
function mt:get_title()
	return self:get_slk('name')
end

--设置说明
--该函数会修改一类物品的说明
function Item.set_class_tip(id, tip)
	japi.EXSetItemDataString(base.string2id(id), 3, tip)
end

--设置标题
--该函数会修改一类物品的标题
function Item.set_class_title(id, title)
	japi.EXSetItemDataString(base.string2id(id), 4, title)
	japi.EXSetItemDataString(base.string2id(id), 2, '购买|cffFCD830'..title..'|r')
end

--设置物品图标
--该函数会修改一类物品的图标
function Item.set_class_art(id, art)
	japi.EXSetItemDataString(base.string2id(id), 1, art)
	--Item:fresh()
end

--设置可丢弃性
function mt:set_dropable(drop)
	if drop == nil then
		drop = true
	end
	self._is_dropable = drop
	jass.SetItemDroppable(self.handle, drop)
end

--获取可丢弃新
function mt:get_dropable()
	return self._is_dropable and true
end

--单位是否被持有
function mt:is_owned()
	return jass.IsItemOwned(self.handle)
end

--获取物品，增加通用属性
--生命、魔法、攻击、攻速、防御、移速、三维属性、技能
function mt:on_add_attribute()
	local unit = self.owner

	if self.life then
		unit:add('生命上限',self.life)
	end

	if self.mana then
		unit:add('魔法上限',self.mana)
	end

	if self.attack then
		unit:add('攻击',self.attack)
	end

	if self.attack_speed then
		unit:add('攻击速度',self.attack_speed)
	end

	if self.defence then
		unit:add('护甲',self.defence)
	end

	if self.move_speed then
		unit:add('移动速度',self.move_speed)
	end

	if unit:is_type_hero() then
		if self.str then
			unit:add_add_str(self.str)
		end
		
		if self.agi then
			unit:add_add_agi(self.agi)
		end
		
		if self.int then
			unit:add_add_int(self.int)
		end
	end
		
	if self.skills then
		if type(self.skills) == 'string' then
			for name in self.skills:gmatch('%S+') do
				local skl = ac.skill[name]
				if skl then
					unit:add_skill(skl, '物品'){}
				else
					Log.error(('物品%s的skills字段存在没初始化的技能%s(被添加的)，请检查！！'):format(self:get_title(), name))
				end
			end
		else
			Log.error(('物品%s的skills字段不为字符串，请检查！！'):format(self:get_title()))
		end
	end

end

--丢弃物品，增加通用属性
function mt:on_remove_attribute()
	local unit = self.owner
	if self.life then
		unit:add('生命上限',-self.life)
	end

	if self.mana then
		unit:add('魔法上限',-self.mana)
	end

	if self.attack then
		unit:add('攻击',-self.attack)
	end

	if self.attack_speed then
		unit:add('攻击速度',-self.attack_speed)
	end

	if self.defence then
		unit:add('护甲',-self.defence)
	end

	if self.move_speed then
		unit:add('移动速度',-self.move_speed)
	end

	if unit:is_type_hero() then
		if self.str then
			unit:add_add_str(-self.str)
		end

		if self.agi then
			unit:add_add_agi(-self.agi)
		end

		if self.int then
			unit:add_add_int(-self.int)
		end
	end

	if self.skills then
		if type(self.skills) == 'string' then
			for name in self.skills:gmatch('%S+') do
				local skl = ac.skill[name]
				if skl then
					unit:remove_skill(skl)
				else
					Log.error(('物品%s的skills字段存在没初始化的技能%s(被移除的)，请检查！！'):format(self:get_title(), name))
				end
			end
		else
			Log.error(('物品%s的skills字段不为字符串，请检查！！'):format(self:get_title()))
		end
	end

end


--获得物品,加成属性
function mt:on_adding()
	local unit = self.owner

	if unit.is_backpack_container then
		return
	end

	if self.on_add_before then
		self:on_add_before()
	end

	self:on_add_attribute()

	if self.on_add then
		self:on_add()
	end
end

--失去物品,减少属性
function mt:on_dropping()
	local unit = self.owner
	if not unit then
		return
	end	 
	if unit.is_backpack_container then
		return
	end

	if self.on_drop then
		self:on_drop()
	end

	self:on_remove_attribute()

	if self.on_drop_after then
		self:on_drop_after()
	end
end

--使用物品
function mt:on_using()
	if self.on_use then
		self:on_use()
	end
end

ac.game:event '单位-购买物品前' (function(trg, unit, it, shop)
	if it.removed then
		return
	end
	if it.unique and unit:has_item(it.name) then
		it:remove()
	    unit:get_owner():sendMsg(it.name.."不允许重复获得")
		return
	end
	return true
end)

ac.game:event '单位-购买物品' (function(trg, unit, it, shop)
	-- print('购买物品，物品价格',it.gold)
	if it.removed then
		return
	end
	if it.gold then
		unit:get_owner():addGold( - it.gold,unit)
	end	

	-- 如果已存在，物品将进入购买cd中。
	
end)

ac.game:event '单位-抵押物品' (function(trg,unit, it, shop)
	if it.removed then
		return
	end
	if it.gold then
		unit:get_owner():addGold(it.gold/2,unit)
	end	

end)

ac.game:event '单位-失去物品' (function(trg, unit, it)
	if it:is_removed() then
		return
	end
	unit:drop_item(it)
end)


ac.game:event '单位-获得物品' (function(trg, unit, it)
	-- print(it.name,it.removed,it.unique,unit:has_item(it.name))
	if not it then
		return
	end

	if it.removed  then
		return
	end
    --如果 物品唯一，丢弃在原来的位置。
	if it.unique and unit:has_item(it.name) then
		it:setPoint(it:get_point()) 
		unit:get_owner():sendMsg(it.name.."不允许重复获得")
		return 
	end	

	unit:pick_item(it)
	-- print(it.owner)
end)

ac.game:event '单位-使用物品' (function(trg, unit, it)
	if it.removed then
		return
	end
	it.owner = unit
	it:on_using()
end)

--监听在物品栏中移动物品
ac.game:event '单位-发布指令' (function(trg, hero, order, target,_,order_id)
	-- print(order,order_id)
	local slotid = order_id - 852001
	if slotid >= 1 and slotid <= 6 then
		local j_it = jass.GetOrderTargetItem()
		if _ignore_flag_items[j_it] then
			return
		end

		local it = Item(j_it)
		--原地移动物品(右键双击)
		if it.slotid == slotid then
			hero:event_notify('单位-右键双击物品', hero, it)
			return
		end
		local last_slotid = it.slotid
		it.slotid = slotid
		local dest = jass.UnitItemInSlot(hero.handle, last_slotid)

		hero:event_notify('单位-移动物品', hero, it)
		if dest then
			hero:event_notify('单位-移动物品', hero, dest)
		end

	end
end)

local function register_jass_triggers()

	--获得物品、捡起物品
	local j_trg = war3.CreateTrigger(function()
		local j_it = jass.GetManipulatedItem()
		
		if _ignore_flag_items[j_it] then
			return
		end
		local unit = Unit(jass.GetTriggerUnit())
		local it = Item(j_it)
		-- print(j_it,it.handle,it.name,it.removed,it.unique,unit:has_item(it.name))

		unit:event_notify('单位-获得物品', unit, it)
		unit:event_notify('单位-获得物品后', unit, it)
	end)
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(j_trg, Player[i].handle, jass.EVENT_PLAYER_UNIT_PICKUP_ITEM, nil)
	end

	--失去物品、丢弃物品
	local j_trg = war3.CreateTrigger(function()
		local j_it = jass.GetManipulatedItem()
		if _ignore_flag_items[j_it] then
			return
		end
		--由于魔兽的机制，多一次触发丢弃事件，故需要排除
		if _ignore_double_trg_flag_items[j_it] then
			_ignore_double_trg_flag_items[j_it] = nil
			return
		end
		local unit = Unit(jass.GetTriggerUnit())
		local it = Item(j_it)
		unit:event_notify('单位-失去物品', unit, it)
	end)
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(j_trg, Player[i].handle, jass.EVENT_PLAYER_UNIT_DROP_ITEM, nil)
	end

	--失去物品
	local j_trg = war3.CreateTrigger(function()
		local j_it = jass.GetSoldItem()
		if _ignore_flag_items[j_it] then
			return
		end
		local unit = Unit(jass.GetTriggerUnit())
		local it = Item(j_it)
		local shop = Unit(jass.GetBuyingUnit())
		unit:event_notify('单位-抵押物品', unit, it, shop)
		shop:event_notify('单位-收购物品', shop, it, unit)
		unit:event_notify('单位-失去物品', unit, it)
		it:remove()
		_ignore_double_trg_flag_items[j_it] = true
	end)
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(j_trg, Player[i].handle, jass.EVENT_PLAYER_UNIT_PAWN_ITEM, nil)
	end

	--购买物品    商店卖出物品流程： 创建物品，将物品给 触发单位。而物品给触发单位这动作是 pick item 。因此获得物品的回调在捡起时合适。
	--           无法阻止单位-获得物品事件。
	local j_trg = war3.CreateTrigger(function()
		local j_it = jass.GetSoldItem()
		if _ignore_flag_items[j_it] then
			return
		end
		local unit = Unit(jass.GetBuyingUnit())
		local shop = Unit(jass.GetSellingUnit())
		local it = Item(j_it)
        
		if not unit:event_dispatch('单位-购买物品前', unit, it, shop) then
		    return 
		end
		it:set_player(unit)
		-- unit:event_notify('单位-获得物品', unit, it)
		unit:event_notify('单位-购买物品', unit, it, shop)
		shop:event_notify('单位-出售物品', shop, it, unit)
	end)
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(j_trg, Player[i].handle, jass.EVENT_PLAYER_UNIT_SELL_ITEM, nil)
	end

	--使用物品
	local j_trg = war3.CreateTrigger(function()
		local unit = Unit(jass.GetTriggerUnit())
		local it = Item(jass.GetManipulatedItem())
		unit:event_notify('单位-使用物品', unit, it)
	end)
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(j_trg, Player[i].handle, jass.EVENT_PLAYER_UNIT_USE_ITEM, nil)
	end

end

--注册物品
local function register_item(self, name, data)
	local war3_id = data.war3_id
	if not war3_id or war3_id == '' then
		Log.error(('注册%s物品时，不能没有war3_id'):format(name) )
		return
	end
	Registry:register(name, war3_id)

	setmetatable(data, data)
	data.__index = Item
	data.name = name

	local item = {}
	setmetatable(item, item)
	item.__index = data
	item.__call = function(self, data) 
		self.data = data
		return self 
	end
	item.name = name
	item.data = data

	-- 图标，名字，说明 需要在物品刚注册时就更变。不是被创建出来时更变。
	-- 预设商店的物品里，图标 无法修改。
	if data.tip  then
		
		data.tip = data.tip:gsub('%%([%w_]*)%%', function(k)
			local value = data[k]
			local tp = type(value)
			if tp == 'function' then
				return value(data)
			end
			return value
		end)

		Item.set_class_tip(war3_id,data.tip)
	end

	if data.name  then
		Item.set_class_title(war3_id,data.name)
	end

	if data.art  then
		Item.set_class_art(war3_id,data.art)
	end
	-- print(data.tip,data.name,data.art)

	self[name] = item
	self[war3_id] = item
	return item
end

local function init()

	Item.all_items = {}

	--注册常用的jass事件
	register_jass_triggers()

	ac.item = setmetatable({}, {__index = function(self, name)
		return function(data)
			return register_item(self, name, data)
		end
	end})

end
-- 英萌的选择器只针对单位。暂时不对物品做处理
local function save_default_item()
	ignore_flag = true
	local group = ac.selector():allow_god():get()
	ignore_flag = false
	--print_r(group)
	for _, u in ipairs(group) do
	
	end
end

init()

return Item