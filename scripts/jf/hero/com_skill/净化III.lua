
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
		攻击时有%chance%%几率为周围所有友军清除所有负面buff，并且施加一个免疫效果，使其不受到负面buff影响，持续%time%s,cd%cool%s
        
	]],
	--CD
	cool = {25,1,1},
	--范围
	area = {350,500,1000},
	--护盾
	shield = {1500,2500,3500},
	
	-- 几率
	chance = {100,20,30},

	--持续时间
	time = {10,10,15}
}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	-- hero.weapon['弹道模型'] = [[Abilities\Spells\Other\FrostDamage\FrostDamage.mdl]]


	self.event = hero:event '造成伤害效果' (function(trg, damage)

		-- ac.effect(hero:get_point(),[[Abilities\Spells\Human\ManaShield\ManaShieldCaster.mdl]],0,1,'overhead'):remove();

		if self:is_cooling() then
			return
		end
		
		--普攻触发
		if damage:is_common_attack()   then
            --几率触发
			if math.random(1,100) > self.chance then
				return
			end

			for i,u in ac.selector()
				: is_ally(hero)
				: of_not_building()
				: ipairs()
     		do
				--添加免疫负面buff
				u:add_buff(filename)
				{
					skill = skill,
					time =  skill.time
				}
				--清除所有负面buff
				for buff in u:each_buff() do
					if buff.debuff then
						buff:remove()
					end
				end
			end
			--激活技能cd
			self:active_cd()

		end	
	
	end)
	
end

function mt:on_remove()
	self.event:remove();
end


local mt = ac.buff[filename]
mt.cover_type = 1

function mt:on_add()
	--免疫负面状态
	local hero = self.target
	self.trg = hero:event '单位-即将获得状态' (function(_, _, buff)
		if buff.debuff then
			return true
		end
	end);
end
function mt:on_remove()
	self.trg:remove();
end
function mt:on_cover(new)
	if new.time > self:get_remaining() then
		self:set_remaining(new.time)
	end
	return false
end







