
local function init_unit(handle, p)
	if unit.all_units[handle] then
		return unit.all_units[handle]
	end
	if handle == 0 then
		return nil
	end
	local u = setmetatable({}, unit)
	dbg.gchash(u, handle)
	u.gchash = handle
	--保存到全局单位表中
	u.handle = handle
	u.id = base.id2string(jass.GetUnitTypeId(handle))
	u.owner = p or player[1 + jass.GetPlayerId(jass.GetOwningPlayer(handle))]
	u.born_point = u:get_point()
	unit.all_units[handle] = u

	--令物体可以飞行
	u:add_ability 'Arav'
	u:remove_ability 'Arav'

	--忽略警戒点
	jass.RemoveGuardPosition(u.handle)
	jass.SetUnitCreepGuard(u.handle, true)

	--设置高度
	u:set_high(u:get_slk('moveHeight', 0))

	if u:getAbilityLevel 'Aloc' ~= 0 then
		u:set_class '马甲'
	end

	return u
end




function unit.init_unit(handle, p)
	if unit.all_units[handle] then
		return unit.all_units[handle]
    end
    



	local u = init_unit(handle, p)
	if not u then
		return nil
	end
	local data = ac.lni.unit[u:get_name()]
	if data then
		u.unit_type = data.type
		if data.attribute then
			for k, v in pairs(data.attribute) do
				u:set(k, v)
			end
		end
		if data.restriction then
			for _, v in ipairs(data.restriction) do
				u:add_restriction(v)
			end
		end
	end
	if u:getAbilityLevel 'Aloc' == 0 then
		u:event_notify('单位-创建', u)
	end
	if data then
		if data.hero_skill then
			for _, skl in ipairs(data.hero_skill) do
				u:add_skill(skl, '英雄')
			end
		end
		if data.hide_skill then
			for _, skl in ipairs(data.hide_skill) do
				u:add_skill(skl, '隐藏')
			end
		end
	end
	
	return u
end


--创建单位(以玩家为参照)
--	单位id
--	位置
--	[朝向]
function player.__index:create_unit(id, where, face)
	local data = ac.lni.unit[id]
	if data then
		id = data.id
	end
    local j_id = base.string2id('Hapl')
    

	local handle = jass.CreateUnit(self.handle, j_id, x, y, face or 0)

	local u = unit.init_unit(handle, self)

	return u
end

