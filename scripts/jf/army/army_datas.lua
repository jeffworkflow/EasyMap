local army_datas = {}
setmetatable(army_datas, army_datas)

local mt = {}
army_datas.__index = mt

--获得该波次的单位数据
function mt:get_datas_by_index( index )
    return army_datas[index or 1]
end

--获取需要防守的主城
function mt:get_guarded_tower()
    return army_datas['主城']
end


mt['主城'] = {
    name = '主城',
}

mt[1] = {
    name = '进攻怪物 Lv1',
    msg = '正宗阳澄湖大闸蟹来袭，不要争不要抢，人人有份人人有份！',
    count = 80,
    prepare_time = 40,
    clear_time = 100,
    reward_money =30,
    reward_xp=50,
    fall_item ={
        ['初级装备'] = {
            10,
        },
        ['中级装备'] = {
            1,
        },
        ['空瓶'] = {
            10,
        },
        ['不掉落'] = {
            79,
        }
    }
}

mt[2] = {
    name = '进攻怪物 Lv2',
    msg = '',
    count = 90,
    prepare_time = 30,
    clear_time = 90,
    fall_item ={
        ['初级装备'] = {
            88.9,
        },
        ['中级装备'] = {
            1.1,
        },
        ['空瓶'] = {
            10,
        }
    }
}

mt[3] = {
    name = '进攻怪物 Lv3',
    msg = '',
    count = 75,
    prepare_time = 30,
    clear_time = 100,
}

mt[4] = {
    name = '普通进攻怪-第4波',
    msg = '',
    count = 75,
    prepare_time = 30,
    clear_time = 100,
}

mt[5] = {
    name = '普通进攻怪-第5波',
    msg = '',
    count = 90,
    prepare_time = 20,
    clear_time = 100,
}

mt[6] = {
    name = '普通进攻怪-第6波',
    msg = '',
    count = 120,
    prepare_time = 20,
    clear_time = 120,
}

mt[7] = {
    name = '普通进攻怪-第7波',
    msg = '',
    count = 80,
    prepare_time = 40,
    clear_time = 100,
}

mt[8] = {
    name = '普通进攻怪-第8波',
    msg = '',
    count = 80,
    prepare_time = 30,
    clear_time = 100,
}

mt[9] = {
    name = '普通进攻怪-第9波',
    msg = '',
    count = 90,
    prepare_time = 20,
    clear_time = 100,
}

mt[10] = {
    name = '普通进攻怪-第10波',
    msg = '',
    count = 100,
    prepare_time = 20,
    clear_time = 100,
}

mt[11] = {
    name = '普通进攻怪-第11波',
    msg = '',
    count = 100,
    prepare_time = 20,
    clear_time = 100,
}

mt[12] = {
    name = '普通进攻怪-第12波',
    msg = '',
    count = 120,
    prepare_time = 20,
    clear_time = 90,
}

mt[13] = {
    name = '普通进攻怪-第13波',
    msg = '',
    count = 120,
    prepare_time = 25,
    clear_time = 100,
}

mt[14] = {
    name = '普通进攻怪-第14波',
    msg = '',
    count = 120,
    prepare_time = 25,
    clear_time = 90,
}

mt[15] = {
    name = '普通进攻怪-第15波',
    msg = '',
    count = 120,
    prepare_time = 20,
    clear_time = 90,
}

mt[16] = {
    name = '普通进攻怪-第16波',
    msg = '',
    count = 120,
    prepare_time = 20,
    clear_time = 100,
}

mt[17] = {
    name = '普通进攻怪-第17波',
    msg = '',
    count = 130,
    prepare_time = 20,
    clear_time = 100,
}

mt[18] = {
    name = '普通进攻怪-第18波',
    msg = '',
    count = 140,
    prepare_time = 30,
    clear_time = 80,
}

mt[19] = {
    name = '普通进攻怪-第19波',
    msg = '',
    count = 140,
    prepare_time = 15,
    clear_time = 90,
}

mt[20] = {
    name = '普通进攻怪-第20波',
    msg = '',
    count = 120,
    prepare_time = 15,
    clear_time = 90,
}

mt[21] = {
    name = '普通进攻怪-第21波',
    msg = '',
    count = 120,
    prepare_time = 15,
    clear_time = 90,
}

mt[22] = {
    name = '普通进攻怪-第22波',
    msg = '',
    count = 120,
    prepare_time = 15,
    clear_time = 80,
}

mt[23] = {
    name = '普通进攻怪-第23波',
    msg = '',
    count = 130,
    prepare_time = 15,
    clear_time = 80,
}

mt[24] = {
    name = '普通进攻怪-第24波',
    msg = '',
    count = 130,
    prepare_time = 10,
    clear_time = 80,
}

mt[25] = {
    name = '普通进攻怪-第25波',
    msg = '',
    count = 100,
    prepare_time = 15,
    clear_time = 90,
}

mt[26] = {
    name = '普通进攻怪-第26波',
    msg = '',
    count = 100,
    prepare_time = 15,
    clear_time = 100,
}

mt[27] = {
    name = '普通进攻怪-第27波',
    msg = '',
    count = 130,
    prepare_time = 12,
    clear_time = 90,
}

mt[28] = {
    name = '普通进攻怪-第28波',
    msg = '',
    count = 130,
    prepare_time = 12,
    clear_time = 80,
}

mt[29] = {
    name = '普通进攻怪-第29波',
    msg = '',
    count = 130,
    prepare_time = 10,
    clear_time = 80,
}

mt[30] = {
    name = '普通进攻怪-第30波',
    msg = '',
    count = 120,
    prepare_time = 10,
    clear_time = 80,
}

mt[31] = {
    name = '普通进攻怪-第31波',
    msg = '',
    count = 150,
    prepare_time = 10,
    clear_time = 70,
}

mt[32] = {
    name = '普通进攻怪-第32波',
    msg = '',
    count = 150,
    prepare_time = 10,
    clear_time = 60,
}

mt[33] = {
    name = '普通进攻怪-第33波',
    msg = '',
    count = 150,
    prepare_time = 10,
    clear_time = 50,
}

mt[34] = {
    name = '普通进攻怪-第34波',
    msg = '',
    count = 160,
    prepare_time = 10,
    clear_time = 50,
}

mt[35] = {
    name = '普通进攻怪-第35波',
    msg = '',
    count = 170,
    prepare_time = 10,
    clear_time = 50,
}

mt[36] = {
    name = '普通进攻怪-第36波',
    msg = '第36波来袭！真的能活下去吗？',
    count = 180,
    prepare_time = 20,
    clear_time = 60,
}



return army_datas