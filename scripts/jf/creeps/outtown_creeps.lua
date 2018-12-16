
local mt = ac.creep['郊区野怪']{    
    region = 'outtown1 outtown2 outtown3',
    creeps_datas = '[进攻怪物 Lv1]*1  [进攻怪物 Lv2]*1 [进攻怪物 Lv3]*1',
    cool_count = 3,
    tip ="郊区野怪刷新啦，请速速打怪升级，赢取白富美"

}
function mt:on_start()
    print(123)

end
function mt:on_next()
    print(456)

end
function mt:on_finish()
    print(789)

end

ac.creep['郊区野怪']:start()
