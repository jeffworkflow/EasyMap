
local map = require 'jf.map'

require 'jf.army.init_army'
require 'jf.army.create_army'
require 'jf.army.way_point'

local self = {}

function self.init()
	--注册路径点
	map.initWayPoint()
	--启动刷兵
	map.createArmy()
end

return self