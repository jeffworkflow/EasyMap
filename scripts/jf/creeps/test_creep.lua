
local mt = ac.creep['test']{    
    region = 'attack',
    creeps_datas = '[进攻怪物 Lv1]*10  [进攻怪物 Lv2]*15 [进攻怪物 Lv3]*15',
    cool_count = 3,
    tip ="郊区野怪刷新啦，请速速打怪升级，赢取白富美"

}
function mt:on_start()
    -- local rect =require 'types.rect'
    -- for i = 1, 80 do
    --     local u = ac.player[13]:create_unit('进攻怪物 Lv1',rect.j_rect 'attack')
	-- 	u:add_buff('定身'){
	-- 		time = 60
	-- 	}
    --     -- u:add_ability 'A00V'
    -- end  

end
function mt:on_next()

end
function mt:on_finish()

end

