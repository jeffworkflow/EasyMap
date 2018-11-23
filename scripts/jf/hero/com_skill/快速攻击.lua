local mt = ac.skill['快速攻击']

mt{
    --等级
    level = 0,
	tip = [[
		|cff11ccff被动：|r
		提升%attack_speed%% 攻速并减少%attack_cool%攻击间隔。
	]],
	


	--增加攻击速度
	attack_speed = 40, --90表示百分90%

	--减少攻击间隔
	attack_cool = 0.2, --90表示百分90%

}

mt.passive = true
--  mt.passive = true
--  mt.level = 1


function mt:on_add()
	
	local hero = self.owner
	local skill = self
	
	
	hero:add('攻击速度',  self.attack_speed)
	hero:add('攻击间隔', - self.attack_cool)
	
end

function mt:on_remove()
	hero.weapon['弹道模型'] = [[fu.mdl]]
	hero:add('攻击速度', - self.attack_speed)
	hero:add('攻击间隔',  self.attack_cool)
	
end






