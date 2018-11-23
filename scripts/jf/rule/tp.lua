
local skill = require 'ac.skill'

local mt = ac.skill['回城']
{
	--技能id
	ability_id = 'A01H',

	--图标
	art = [[ReplaceableTextures\CommandButtons\BTNMassTeleport.blp]],

	tip = [[
在5秒的引导后,传送回基地
]],

	cast_animation = 'stand',
	
	--持续施法时间
	cast_channel_time = 5,
	--cast_finish_time = 0.3,
	break_cast_channel = 1,

	cool = 5,

	level = 1,

	max_level = 1,

	ignore_cool_save = true,

	never_reload = true,

	auto_fresh_tip = false,

	simple_tip = true,
}
--

function mt:on_cast_channel()
	local hero = self.owner
	hero:add_effect('origin', [[Abilities\Spells\Human\MassTeleport\MassTeleportCaster.mdl]]):remove()
	self.eff = hero:add_effect('origin', [[Abilities\Spells\Human\MassTeleport\MassTeleportTo.mdl]])
	self.trg = hero:event '受到伤害效果' (function()
		--print('受到伤害')
		self:stop()
	end)
	
	--hero:remove_restriction '硬直'
	self.trigger = hero:event '单位-发布指令' (function(_, _, order)
		if order == 'stop' then
			self:stop()
		end
	end)
end

function mt:on_cast_finish()
	local hero = self.owner

	hero:blink(hero:getBornPoint())
	hero:add_effect('origin', [[Abilities\Spells\Human\MassTeleport\MassTeleportCaster.mdl]]):remove()
	hero:get_owner():setCamera(hero)
end

function mt:on_cast_stop()
	self:set_cd(0)
	self.eff:remove()
	self.trg:remove()
    self.trigger:remove()
end

ac.game:event '玩家-注册英雄' (function(trg, player, hero)
	hero:add_skill('回城', '通用')
end)