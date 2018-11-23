
local file = debug.getinfo(1, "S").source -- 第二个参数 "S" 表示仅返回 source,short_src等字段， 其他还可以 "n", "f", "I", "L"等 返回不同的字段信息
local filename = string.sub(file, 2, -1) -- 去掉开头的"@"
-- filename = string.match(path, "^.*/") -- 捕获最后一个 "/" 之前的部分 就是我们最终要的目录部分
filename = stripextension(strippath(filename))


local mt = ac.skill[filename]

mt{
    --等级
    level = 0,
    --最大等级
    max_level = 3,
	tip = [[
		|cff11ccff被动：|r
        生命值低于%below_life%%时获得一个回春buff，每秒恢复%heal_percent%%最大生命值，持续%time%s，cd%cool%s  

	]],
	--CD
	cool = {5,1,1},
	
	-- 低于生命%
	below_life = {50,50,50},

	-- 回血 生命上限%
	heal_percent = {1,20,30},

	-- power
	power = {100,2,3},

	--持续时间
	time = {10,10,15}
}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	-- hero.weapon['弹道模型'] = [[Abilities\Spells\Other\FrostDamage\FrostDamage.mdl]]
	
	self.event =  hero:event '受到伤害效果' (function(trg, damage)
		if self:is_cooling() then
			return
		end
		
		local life = hero:get '生命'
		local max_life = hero:get '生命上限'
		local target_life = max_life * self.below_life / 100

		if life < target_life then
			
			hero:add_buff(filename)
			{
				skill = skill,
				time =  skill.time,
				heal_percent = self.heal_percent
			}
			
			--激活技能冷却
		   self:active_cd()
		end
		-- print('力量2 当前层数:',self:get_stack())
	end)


	
end

function mt:on_remove()

	self.event:remove();
end


local mt = ac.buff[filename]


mt.pulse = 1
mt.eff = nil
mt.trg = nil
mt.mover = nil

function mt:on_add()
	-- print(1)
	local hero = self.target
	hero:add_effect('origin', [[Abilities\Spells\Undead\ReplenishMana\SpiritTouchTarget.mdl]]):remove()
end

function mt:on_remove()
	
	--self.mover:remove()
end

function mt:on_pulse()
	local hero = self.target

	local life = hero:get '生命'
	local max_life = hero:get '生命上限'

	hero:heal
	{
		source = hero,
		skill = self.skill,
		heal = max_life * self.heal_percent / 100,
	}
end

function mt:on_cover()
	return true
end







