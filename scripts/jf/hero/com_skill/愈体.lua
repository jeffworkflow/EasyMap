
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
       	静止%stop_move_time%s不动时每秒可获得生命值上限%heal_percent%% 的生命恢复加成，该加成效果会在移动后消失并进入%cool%s的cd
	]],
	--CD
	cool = {5,1,1},
	
	-- 时间s
	stop_move_time = {3,5,5},

	-- 回血 生命上限%
	heal_percent = {1,20,30},

	-- 英雄所在位置%
	point = function (self,hero)
		return hero:get_point()[2]
	end,
	
	-- 当前静止时间
    timer = 0
	--持续时间
	-- time = {10,10,15}
}

-- 被动
mt.passive = true


function mt:on_add()
	
	 local hero = self.owner
 	 local skill = self

	
	-- 判断是否静止
	-- 每0.2秒去检测 玩家位置是否和上一次位置一样，一样就保持静止，不一样就表示动了。
	-- local flag = is_stop_move_duringtime(hero,skill,self.stop_move_time) 
	 self.event_timer = ac.loop(0.2 * 1000,function()

		local point = hero:get_point()[2]
		local last_point = self.point
		-- print(last_point,point)
        --对比 玩家位置是否和上一次位置一样
		if point ~= last_point then 
			self.point = point
			self.timer = 0  --不一样 设置当前静止时间为0
			if self.buff then
			   self.buff:remove()
			end   
		end 
		
		-- 技能在cd内，设置当前静止时间为0
		if self:is_cooling() then
			self.timer = 0
		end
		
		if  self.timer >= self.stop_move_time then 
			
			self.buff = hero:add_buff(filename)
			{
				skill = skill,
				heal_percent = self.heal_percent
			}
			--激活技能c'd
			self:active_cd()
		end
		-- print('当前静止时间：',self.timer)
		self.timer = self.timer + 0.2
		-- print('当前静止时间：',self.timer)
    end) 
    self.event_timer:on_timer()



	-- self.event =  hero:event '单位-发布指令' (function(_, hero, order, target)

	-- 	if self:is_cooling() then
	-- 		return
	-- 	end

	-- 	--判断移动
	-- 	if order == 'smart' and target ~= nil then 
			
	-- 	end
		
	-- end	)

	
end

function mt:on_remove()

	self.event_timer:remove();
end


local mt = ac.buff[filename]


mt.pulse = 1
mt.eff = nil
mt.trg = nil
mt.mover = nil

function mt:on_add()
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







