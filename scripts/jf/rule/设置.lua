--幸运值相关
--[[
    可以抽奖的物品：初级宝箱 中级宝箱 高级宝箱
    可以被抽到的物品类型：角色卡 天赋技能 辅助技能 金币宝箱 宝石宝箱
      
]]

--奖池
ac.luckey_item = {
	['初级装备'] = {'新手剑','新手甲','新手戒指'},
	
    ['中级装备'] = {'灵宝剑'},

}

--播放背景音乐
local jass = require "jass.common"
jass.PlayMusic([[Sound\Music\mp3Music\PH1.mp3]])
jass.SetMusicVolume(100)

-- 技能相关设置

for i = 1, 16 do
	local p = ac.player(i)
	p.ability_list = {}
	if i <= 10 then
		p.ability_list['英雄'] = {size = 7}
		p.ability_list['学习'] = {size = 7}
		p.ability_list['智能施法'] = {size = 7}
		for x = 1, p.ability_list['英雄'].size do
			p.ability_list['英雄'][x] = ('A0%d%d'):format(i - 1, x - 1)
		end
		for x = 1, p.ability_list['学习'].size do
			p.ability_list['学习'][x] = ('AL%d%d'):format(i - 1, x)
		end
		for x = 1, p.ability_list['智能施法'].size do
			p.ability_list['智能施法'][x] = ('AF0%d'):format(x)
		end
	elseif i == 16 then
		p.ability_list['预览'] = {size = 7}
		for x = 1, p.ability_list['预览'].size do
			p.ability_list['预览'][x] = ('A20%d'):format(x - 1)
		end
	end
end
