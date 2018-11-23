
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
		攻击时有%chance%%几率对单位施加[恐吓]buff，使其造成的伤害降低%value%%，不可叠加，持续%time%s,cd%cool%s
	]],

	--CD
	cool = {25,1,1},

	--各种效果值
	value = {10,15,20},

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


	self.event = hero:event '造成伤害效果' (function(trg, damage)
        local u = damage.target
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

			--对目标单位 添加 恐吓buff
			u:add_buff(filename)
			{
				skill = skill,
				time =  skill.time,
				value =  skill.value
			}
				
			--激活技能cd
			self:active_cd()

		end	
	
	end)
	
	--测试
	-- self.event = hero:event '受到伤害效果' (function(trg, damage)
	--     print('受到伤害',damage.damage)
	-- end);
end

function mt:on_remove()
	self.event:remove();
end


local mt = ac.buff[filename]
mt.cover_type = 1
mt.cover_max = 1
mt.debuff = true

function mt:on_add()
	--恐吓buff效果
	local u = self.target
	u:add('攻击%',-self.value)
end
function mt:on_remove()
	local u = self.target
	u:add('攻击%',self.value)
	
end
function mt:on_cover(new)
	return new.value > self.value
end







