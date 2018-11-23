local jass = require 'jass.common'
local japi = require 'jass.japi'
local move = require 'types.move'

local math = math
local string_gsub = string.gsub

local mt = ac.unit.__index

local attribute = {
	['力量']	=	true,--默认基础值  
	['敏捷']	=	true,--默认基础值
	['智力']	=	true,--默认基础值
	['生命']       = true,--默认基础值
	['生命上限']    = true,--默认基础值
	['生命恢复']    = true,--默认基础值
	['生命脱战恢复'] = true,--默认基础值
	['魔法']       = true,--默认基础值
	['魔法上限']    = true,--默认基础值
	['魔法恢复']    = true,--默认基础值
	['魔法脱战恢复'] = true,--默认基础值
	['能量获取率']   = true, --默认%
	['攻击']       = true, --默认基础值
	['护甲']       = true, --默认基础值
	['魔抗']	   =	true, --默认基础值
	['攻击间隔']    = true, --默认基础值
	['攻击速度']    = true, --默认基础值
	['攻击距离']    = true, --默认基础值
	['移动速度']    = true, --默认基础值 
	['减耗']       = true,  --默认基础值 减少扣篮量
	['冷却缩减']    = true, --默认% 
	['吸血']       = true,  --默认%
	['溅射']       = true,  --默认%
	['格挡']       = true,  --默认%
	['格挡伤害']    = true,  --默认%
	['暴击']       = true,   --默认%
	['暴击伤害']    = true,  --默认%
	['破甲']       = true,  --默认表示为基础值  破加伤害计算时，默认0,增加属性时，若用add[破甲%]，将无效。伤害计算时，直接扣掉点数
	['穿透']       = true,  --默认表示为% 穿透，伤害计算时，穿透/100 再扣除
	['护盾']       = true,  --默认表示为基础值 
	['致命几率']		=	true, --默认%
	['致命伤害']		=	true,--默认%
	['会心几率']		=	true,--默认%
	['会心伤害']		=	true,--默认%
	['法爆几率']		=	true,--默认%
	['法爆伤害']		=	true,--默认%
	['技能伤害']		=	true, --默认表示为%
	['技能基础伤害']	 =	true, --默认表示为基础值
	['减伤比']			=	true, --默认表示为%
	['减伤值']		    =	true, --默认表示为基础值
	['金币加成']		=	true,--默认表示为%
	['经验加成']		=	true,--默认表示为%
	['天赋触发几率']	=	true,--默认表示为%
	['额外投射物数量']	=	true,--默认表示为基础值
	['额外范围']		=	true,--默认表示为基础值
	['攻击回血']		=	true,--默认表示为基础值
	['击杀回血']		=	true,--默认表示为基础值
	['对BOSS额外伤害']  =   true,--默认表示为%
}

local set = {}
local get = {}
local on_add = {}
local on_get = {}
local on_set = {}

function mt:add(name, value)
	local v1, v2 = 0, 0
	if name:sub(-1, -1) == '%' then
		v2 = value
		name = name:sub(1, -2)
	else
		v1 = value
	end
	if not attribute[name] then
		error('错误的属性名:' .. tostring(name))
		return
	end
	local key1 = name
	local key2 = name .. '%'
	local attr = self['属性']
	if not attr then
		attr = {}
		self['属性'] = attr
	end
	if not attr[key1] then
		attr[key1] = get[name] and get[name](self) or 0
		attr[key2] = 0
	end
	local f
	
	if on_set[name]  then
		-- local old_value = attr[key1]
		-- if name =='力量' then
		-- 	print('力量老值：',old_value)
		-- end	
		f = on_set[name](self) 
	end
	if on_add[name] then
		v1, v2 =  on_add[name](self, v1, v2)
	end
	if v1 then
		attr[key1] = attr[key1] + v1
	end
	if v2 then
		attr[key2] = attr[key2] + v2
	end
	if set[name] then
		set[name](self, attr[key1] * (1 + attr[key2] / 100))
	end
	if f then
		f()
	end
	-- 增加10%时: 攻击200，攻击加10% ， 200*(1+0.1) = 220 , attr[key1]=200,  attr[key2] = 10%
	-- 减少10%时: 攻击220，攻击 -10% , attr[key1]=200,  attr[key2] = 10% -10% , 攻击220  
	-- 先增加10,再加10%时, 攻击200 ，attr[key1]=200 +10 , attr[key1] =10%， 最终增加 210*1.1 231
	-- 若 先减少10，再减少10%时， attr[key1]=200,  attr[key2] = 10% -10%   最终增加 200
	-- 若 先减少10%，再减少10时，  attr[key2] = 10% -10%，attr[key1]=200  最终增加 200
end

function mt:set(name, value)
	if not attribute[name] then
		error('错误的属性名:' .. tostring(name))
		return
	end
	local key1 = name
	local key2 = name .. '%'
	local attr = self['属性']
	if not attr then
		attr = {}
		self['属性'] = attr
	end
	if not attr[key1] then
		attr[key1] = get[name] and get[name](self) or 0
		attr[key2] = 0
	end
	local f
	if on_set[name]  then
		-- local old_value = attr[key1]
		-- if name =='力量' then
		-- 	print('力量老值：',old_value)
		-- end	
		f = on_set[name](self) 
	end
	attr[key1] = value
	attr[key2] = 0
	if set[name] then
		set[name](self, attr[key1] * (1 + attr[key2] / 100))
	end
	if f then
		f()
	end
end

function mt:get(name)
	local type = 0
	if name:sub(-1, -1) == '%' then
		name = name:sub(1, -2)
		type = 1
	end
	if not attribute[name] then
		error('错误的属性名:' .. tostring(name))
		return
	end
	local key1 = name
	local key2 = name .. '%'
	local attr = self['属性']
	if not attr then
		attr = {}
		self['属性'] = attr
	end
	if not attr[key1] then
		attr[key1] = get[name] and get[name](self) or 0
		attr[key2] = 0
	end
	if type == 1 then
		return attr[key2]
	end
	if on_get[name] then
		return on_get[name](self, attr[key1] * (1 + attr[key2] / 100))
	end
	return attr[key1] * (1 + attr[key2] / 100)
end

-- 资源相关
-- 能量类型
mt.resource_type = '魔法'

function mt:add_resource(type, value)
	local type, match = string_gsub(type, self.resource_type, '魔法')
	if match == 0 then
		return
	end
	self:add(type, value)
end

function mt:get_resource(type)
	local type, match = string_gsub(type, self.resource_type, '魔法')
	if match == 0 then
		return 0
	end
	return self:get(type)
end

function mt:set_resource(type, value)
	local type, match = string_gsub(type, self.resource_type, '魔法')
	if match == 0 then
		return
	end
	self:set(type, value)
end

-- 每点力量增加1攻击力，每20点增加1%致命伤害，每1点增加10生命值
-- 每25敏捷增加1%会心伤害，每10点增加1护甲，每点增加0.1%攻速
-- 每点智力增加15法力值，每20点增加1%技能伤害，每25点增加1%法爆伤害

--力量
local str_attack = 1
local str_deadly = 0.05  --1点力量增加 0.0005% 致命一击
local str_hp = 10

--敏捷
local agi_speed = 0.1
local agi_heart = 0.04
local agi_defense = 0.1

--智力
local int_mp = 15
local int_skill = 0.05
local int_explosion = 0.04


on_set['力量'] = function(self)
    -- print("新值：",self:get '力量', "老值：",old_value)
	local old_value =  self:get '力量' --老值
	
	return function()
        local value = self:get '力量' - old_value
		self:set('生命上限', self:get '生命上限' + value * str_hp)
		-- 增加致命一击
		self:set('致命伤害', self:get '致命伤害' + value * str_deadly)
		-- 增加攻击
		self:set('攻击', self:get '攻击' + value * str_attack)
	end	
-- end
end


on_set['敏捷'] = function(self,old_value)

	local old_value =  self:get '敏捷' --老值
	return function()
		local value =  self:get '敏捷' - old_value
		-- 增加护甲
		self:set('护甲', self:get '护甲' + value * agi_defense)
		-- 增加会心伤害
		self:set('会心伤害', self:get '会心伤害' + value * agi_heart)
		-- 增加攻击
		self:set('攻击速度', self:get '攻击速度' + value * agi_speed)
	end	
end

on_set['智力'] = function(self,old_value)

	local old_value =  self:get '智力' --老值
	return function()
		local value =  self:get '智力' - old_value
		-- 增加魔法上限
		self:set('魔法上限', self:get '魔法上限' + value * int_mp)
		-- 增加技能伤害
		self:set('技能伤害', self:get '技能伤害' + value * int_skill)
		-- 增加法爆伤害
		self:set('法爆伤害', self:get '法爆伤害' + value * int_explosion)
	end
end


get['生命'] = function(self)
	return jass.GetWidgetLife(self.handle)
end

set['生命'] = function(self, life)
	if life > 1 then
		jass.SetWidgetLife(self.handle, life)
	else
		jass.SetWidgetLife(self.handle, 1)
	end
end

on_get['生命'] = function(self, life)
	if life < 0 then
		return 0
	else
		local max_life = self:get '生命上限'
		if life > max_life then
			return max_life
		end
	end
	return life
end

get['生命上限'] = function(self)
	return jass.GetUnitState(self.handle, jass.UNIT_STATE_MAX_LIFE)
end

set['生命上限'] = function(self, max_life, old_max_life)
	japi.SetUnitState(self.handle, jass.UNIT_STATE_MAX_LIFE, max_life)
	if self.freshDefenceInfo then
		self:freshDefenceInfo()
	end
end

on_set['生命上限'] = function(self)
	local rate = self:get '生命' / self:get '生命上限'
	return function()
		self:set('生命', self:get '生命上限' * rate)
	end
end

get['魔法'] = function(self)
	return jass.GetUnitState(self.handle, jass.UNIT_STATE_MANA)
end

set['魔法'] = function(self, mana)
	jass.SetUnitState(self.handle, jass.UNIT_STATE_MANA, math.ceil(mana))
end

on_add['魔法'] = function(self, v1, v2)
	v1 = v1 + v1 * self:get '能量获取率' / 100
	return v1, v2
end

on_get['魔法'] = function(self, mana)
	if mana < 0 then
		return 0
	else
		local max_mana = self:get '魔法上限'
		if mana > max_mana then
			return max_mana
		end
	end
	return mana
end

get['魔法上限'] = function(self)
	return jass.GetUnitState(self.handle, jass.UNIT_STATE_MAX_MANA)
end

set['魔法上限'] = function(self, max_mana)
	japi.SetUnitState(self.handle, jass.UNIT_STATE_MAX_MANA, max_mana)
end

on_set['魔法上限'] = function(self)

	local rate =0
	if self:get '魔法上限' > 0 then 
		 rate = self:get '魔法' / self:get '魔法上限'
	end
	
	return function()
		self:set('魔法', self:get '魔法上限' * rate)
	end
end

get['攻击'] = function(self)
	japi.SetUnitState(self.handle, 0x10, 1)
	japi.SetUnitState(self.handle, 0x11, 1)
	return japi.GetUnitState(self.handle, 0x12) + 1
end

set['攻击'] = function(self, attack)
	japi.SetUnitState(self.handle, 0x12, attack - 1)
	if self.freshDamageInfo then
		self:freshDamageInfo()
	end
end

get['护甲'] = function(self)
	return japi.GetUnitState(self.handle, 0x20)
end

set['护甲'] = function(self, defence)
	japi.SetUnitState(self.handle, 0x20, defence)
	if self.freshDefenceInfo then
		self:freshDefenceInfo()
	end
end

get['攻击间隔'] = function(self)
	return japi.GetUnitState(self.handle, 0x25)
end

set['攻击间隔'] = function(self, attack_cool)
	japi.SetUnitState(self.handle, 0x25, attack_cool)
end

set['攻击速度'] = function(self, attack_speed)
	if attack_speed >= 0 then
		japi.SetUnitState(self.handle, 0x51, 1 + attack_speed / 100)
	else
		--当攻击速度小于0的时候,每点相当于攻击间隔增加1%
		japi.SetUnitState(self.handle, 0x51, 1 + attack_speed / (100 - attack_speed))
	end
end

on_set['攻击速度'] = function(self)
	return self:fresh_cool()
end

get['攻击距离'] = function(self)
	return japi.GetUnitState(self.handle, 0x16)
end

set['攻击距离'] = function(self, attack_range)
	japi.SetUnitState(self.handle, 0x16, attack_range)
end

get['移动速度'] = function(self)
	return jass.GetUnitDefaultMoveSpeed(self.handle)
end

set['移动速度'] = function(self, move_speed)
	if not self:has_restriction '定身' then
		jass.SetUnitMoveSpeed(self.handle, move_speed)
	end
	move.update_speed(self, on_get['移动速度'](self, move_speed))
	--英雄属性面板
	if self.freshMoveSpeedInfo then
		self:freshMoveSpeedInfo()
	end
end

on_get['移动速度'] = function(self, move_speed)
	if move_speed < 0 then
		return 0
	elseif move_speed > 1000 then
		return 1000
	end
	return move_speed
end

on_set['减耗'] = function(self)
	return self:fresh_cost()
end

on_get['冷却缩减'] = function(self, cool_reduce)
	if cool_reduce > 80 then
		return 80
	end
	return cool_reduce
end

on_set['冷却缩减'] = function(self)
	return self:fresh_cool()
end

on_get['吸血'] = function(self, value)
	if value > 150 then
		return 150
	end
	return value
end

on_get['溅射'] = function(self, splash)
	if splash > 100 then
		return 100
	end
	return splash
end

set['格挡'] = function(self)
	if self.freshDefenceInfo then
		self:freshDefenceInfo()
	end
end

get['格挡伤害'] = function()
	return 60
end

set['格挡伤害'] = function()
	if self.freshDefenceInfo then
		self:freshDefenceInfo()
	end
end

set['暴击'] = function(self)
	if self.freshDamageInfo then
		self:freshDamageInfo()
	end
end

get['暴击伤害'] = function()
	return 150
end

set['暴击伤害'] = function(self)
	if self.freshDamageInfo then
		self:freshDamageInfo()
	end
end

on_get['穿透'] = function(self, pene_rate)
	if pene_rate > 40 then
		return 40
	end
	return pene_rate
end
