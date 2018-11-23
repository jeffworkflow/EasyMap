local mt = ac.skill['测试性能']

mt{
    --等级
    level = 0,
    --最大等级
    level = 3,
	tip = [[
		|cff11ccff被动：|r
		击杀单位增加%power%力量，持续%time%s
	]],
	

	-- power
	power = {0.01,0.01,0.01},

	--持续时间
	time = {5,10,15}
}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	-- hero.weapon['弹道模型'] = [[Abilities\Spells\Other\FrostDamage\FrostDamage.mdl]]
    
	
	self.event = hero:event '造成伤害效果' (function(trg, damage)

		hero:add_buff '增加力量'
		{
			skill = skill,
			time =  skill.time,
			power = self.power
		}
	end)


	
end

function mt:on_remove()

	self.event:remove();
end


local mt = ac.buff['增加力量']

mt.cover_type = 1
mt.cover_max = 1000000

mt.effect = nil


function mt:on_add()
	
	self.target:add('攻击', self.power)
end

function mt:on_remove()
	self.target:add('攻击', - self.power)
end

function mt:on_cover(new)
	return new.power + self.power
end







