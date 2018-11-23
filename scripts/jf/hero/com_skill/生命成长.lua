local mt = ac.skill['生命成长']

mt{
    --等级
    level = 0,
	max_level = 4,
	
	tip = [[
		|cff11ccff被动：|r
		升级时，生命成长加100%。
	]],
	

}

mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self
	
	hero.upgrade['生命上限'] = 10000
	print(hero.upgrade['生命上限'])
    hero:set_level(1)
    hero:set_level(hero.level)



end

function mt:on_remove()
	--self.event:remove();
end






