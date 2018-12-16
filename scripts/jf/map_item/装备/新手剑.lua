local mt = ac.item['新手剑']{
    war3_id = 'I01T',
    gold = 1000,
    --最大的可用次数
    max_stack = 100,
    unique = 1,
    attack = 1000,
    tip =[[
新手用的武器，攻击 + %attack%
    ]],
    art = [[ReplaceableTextures\CommandButtons\BTNBlink.blp]],

}

-- local tip = mt.tip:gsub('%%([%w_]*)%%', function(k)
--     local value = mt[k]
--     local tp = type(value)
--     if tp == 'function' then
--         return value(mt)
--     end
--     return value
-- end)
-- print(tip)

-- print('新手剑注册',ac.item['新手剑'])