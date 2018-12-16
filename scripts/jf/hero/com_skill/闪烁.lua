local mt = ac.skill['闪烁']

mt{
    --等级
    level = 0,
	tip = [[
		闪烁,cd%cool%s.
	]],
	--技能图标
	art = [[ReplaceableTextures\CommandButtons\BTNBlink.blp]],
	cool = 5,

	target_type = ac.skill.TARGET_TYPE_POINT,

	--施法动作
    cast_animation = 'spell throw',
    cast_animation_speed = 1.5,

    --施法前摇后摇
    cast_start_time = 0.15,
    cast_finish_time = 0.15,

	--施法距离
	range = 99999,
	--移动距离
	blink_range = 1000,
	--新目标点
	new_point =nil,

}

--  mt.passive = true
--  mt.level = 1


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	-- hero.weapon['弹道模型'] = [[Abilities\Spells\Other\FrostDamage\FrostDamage.mdl]]
	
end

function mt:on_can_cast()
    local hero = self.owner:get_point()
	local target = self.target:get_point()
	           
	local angle = hero/target  --计算两点之间角度
	-- print(angle)
	
	local distance = target*hero  --计算两点之间的距离
	-- print(distance)
	self.new_point = target
	if distance >= self.blink_range then
		local data = {}
		data[1]=angle
		data[2]=self.blink_range
		self.new_point = hero - data  --计算新点
	end	
	-- print(new_point,target) 
	self.new_point =  self.new_point:findMoveablePoint(300,angle) or self.new_point --附近寻找一个可通行的点。
	if self.new_point:is_block()  then
		return false
	end	
	return true
end

function mt:on_cast_start()
    local hero = self.owner
	local target = self.target
	local new_point = self.new_point
	-- hero:setAlpha(hero:getAlpha() - 50)
	-- local unit = ac.player(1):create_unit('萌物A',target:get_point())
	-- -- unit:set_size(2)
	-- local eff1 = unit:add_effect('overhead',[[AZ_SSCrow_D.mdx]])

	-- local japi = require("jass.japi")
	-- local eff1 = target:get_point():add_effect([[AZ_SSCrow_D.mdx]])

	-- japi.EXSetEffectSize(eff1.handle,10)

	-- local dummy = hero:get_owner():create_dummy('e003', target, 0)
	-- dummy:set_size(12)
	-- dummy:set_high(100)
	-- dummy:set_class '马甲'
	-- dummy:add_restriction '硬直'
	-- dummy:add_restriction '无敌'
	
	-- self.trigger = hero:event '单位-发布指令' (function(_, _, order)
	-- 	-- print(1)
	-- 		self:stop()
	-- 		self:fresh_cool()
	-- 		self:fresh_cool()
	-- 		print(self.name)
	-- 	if order == 'stop' then
	-- 		print('stop')
	-- 	end
	-- end)	
	self.eff = ac.effect(hero:get_point(),[[AZ_SSCrow_D.mdx]],0,1,'overhead'):remove();
	
	-- self.eff = hero:get_point():add_effect([[AZ_SSCrow_D.mdx]]):remove();
	self.eff1 = ac.effect(new_point,[[AZ_SSCrow_D.mdx]],0,1,'overhead'):remove(); 
	-- self.eff1 = ac.effect(new_point,[[AZ_SSCrow_D.mdx]],0,1,'overhead'); 
	-- self.eff1.unit:set_size(5)
	-- self.eff1.unit:add_buff '淡化*改'
	-- {
	-- 	source_alpha = 0,
	-- 	target_alpha = 100,
	-- 	time = 1,
	-- 	remove_when_hit = false,
	-- }


	--self.eff1
	-- local eff2 = ac.point(0,0):add_effect([[AZ_SSCrow_D.mdx]])
	-- eff2:set_size(0.3)
	
	-- hero:get_owner():play_sound([[Sound\Interface\SoulPreservation.wav]])
	



	hero:add_buff '淡化*改'
	{
		source_alpha = 100,
		target_alpha = 0,
		time = self.cast_start_time,
		remove_when_hit = false,
		
	}
end

function mt:on_cast_shot()
    local hero = self.owner
	local target = self.target
	local new_point = self.new_point
	hero:blink(new_point)
	-- print(self.eff) ,false,true
	-- self.eff.unit:remove()
	-- self.eff.unit
	--self.target:play_sound([[response\惠惠\skill\Boom_]] .. math.floor(math.random(7)) .. '.mp3')
   
end
function mt:on_cast_finish()
	local hero = self.owner
	--hero:setAlpha(hero:getAlpha() + 50)
	hero:add_buff '淡化*改'
	{
		source_alpha = 0,
		target_alpha = 100,
		time = self.cast_finish_time,
		remove_when_hit = false,
	}
	self.timer = hero:wait(self.cast_finish_time * 1000 ,function()
		-- self.eff:remove();
	end);	

end	


function mt:on_cast_break()
	local hero = self.owner
	--hero:setAlpha(hero:getAlpha() + 50)
	hero:add_buff '淡化*改'
	{
		source_alpha = 0,
		target_alpha = 100,
		time = self.cast_finish_time,
		remove_when_hit = false,
	}

end	


function mt:on_remove()

	self.timer:remove();
end






