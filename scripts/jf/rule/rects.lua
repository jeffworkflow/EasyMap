
local rect = require 'types.rect'

local map = require 'jf.map'
local region = require 'types.region'
local slk = require 'jass.slk'
local jass = require 'jass.common'
local player = require 'ac.player'
local fogmodifier = require 'types.fogmodifier'

local effect = require 'types.effect'

map.rects = {}

--选人区域
--map.rects['选人区域'] = rect.j_rect 'choose_hero'

map.rects['选人区域'] = rect.j_rect 'choosehero'
map.rects['test'] = rect.create(400,0,1000,1000)
map.rects['test2'] = rect.create(-1500,1000,-2000,1500)

--英雄出生点
map.rects['出生点'] = rect.j_rect 'wq'

--区域
map.rects['郊区'] = rect.j_rect 'outtown'
map.rects['郊区1'] = rect.j_rect 'outtown1'
map.rects['郊区2'] = rect.j_rect 'outtown2'
map.rects['郊区3'] = rect.j_rect 'outtown3'
map.rects['郊区4'] = rect.j_rect 'outtown4'

--全地图
map.rects['全地图'] = rect.create(-8192, -8192, 8192, 8192)
ac.map = map.rects['全地图'] 

--注册不可通行区域
--point.path_region = region.create()

function map.pathRegionInit()
	jass.EnumDestructablesInRect(jass.Rect(-8192, -8192, 8192, 8192), nil, function()
		local dstrct = jass.GetEnumDestructable()
		local id = jass.GetDestructableTypeId(dstrct)
		if tonumber(slk.destructable[id].walkable) == 1 then
			return
		end
		local x0, y0 = jass.GetDestructableX(dstrct), jass.GetDestructableY(dstrct)
		
		--将附近的区域加入不可通行区域
		--local rng = 64
		--point.path_region = point.path_region + rect.create(x - rng, y - rng, x + rng, y + rng)
		local fly = false
		if id == base.string2id 'YTfb' then
			fly = true
		end
		--关闭附近的通行
		for x = x0 - 64, x0 + 64, 32 do
			for y = y0 - 64, y0 + 64, 32 do
				jass.SetTerrainPathable(x, y, 1, false)
				if fly then
					jass.SetTerrainPathable(x, y, 2, false)
				end
			end
		end
		
	end)
end

--禁用边界渲染
jass.EnableWorldFogBoundary(false)
