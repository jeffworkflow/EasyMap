local mt = ac.skill['霜冻攻击']

mt{
    --等级
    level = 0,
	tip = [[
		|cff11ccff被动：|r
		寒冰攻击，击中目标减缓%move_speed_rate%% 移动速度。
	]],
	


	--减缓移动速度
	move_speed_rate = 40, --90表示百分90%


	--持续时间
	time = 2
}

mt.passive = true
--  mt.passive = true
--  mt.level = 1


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	-- hero.weapon['弹道模型'] = [[Abilities\Spells\Other\FrostDamage\FrostDamage.mdl]]
	
	self.event = hero:event '造成伤害效果' (function(trg, damage)
		--不允许额外技能效果返回（不允许范围伤害，同时又有分裂效果）
		if not damage.allow_other_skill  then
			return
		end	
		--没有绑定技能，绑定了技能，技能不是投射物，直接返回。
		if not damage.skill or not damage.skill.type or damage.skill.type ~= '投射物' then 
		return
		end   

		damage.target:add_buff '减速'
		{
			source = self.source,
			time = self.time,
			move_speed_rate = self.move_speed_rate,
			model = [[Abilities\Spells\Other\FrostDamage\FrostDamage.mdl]]
		}
		
		-- local function f()
		-- 	self:remove()
		-- 	hero:add_buff('不灭之焰-就绪', self.recover_cool)
		-- 	{
		-- 		skill = self.skill,
		-- 	}
		-- 	hero:add_buff '不灭之焰-记录'
		-- 	{
		-- 		skill = self.skill,
		-- 		time = self.skill.stun_time,
		-- 	}
		-- end
		-- self.trg1 = hero:event '单位-获得状态' (function(_, _, buff)
		-- 	if buff.name == '减速' then
		-- 		f()
		-- 	end
		-- end)
	end)	

	
end

function mt:on_remove()

	self.event:remove();
end






