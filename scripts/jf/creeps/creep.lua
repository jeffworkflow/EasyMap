
local map = require 'jf.map'
local player = require 'ac.player'
local timerdialog = require 'types.timerdialog'
local rect = require 'types.rect'
local region = require 'types.region'
local fogmodifier = require 'types.fogmodifier'

local creep = {}
setmetatable(creep, creep)

local mt = {}
creep.__index = mt

--类型
mt.type = nil
--当前波数
mt.index = 0
--最大波数数量
mt.max_index = 999999
--野怪刷新状态  开始，下一波，结束
mt.state = nil
--计时器窗口
mt.timerdialog = nil
-- 数量
mt.count =20
-- 当前数量
mt.current_count =0
--刷新区域
mt.region  = nil
--是否随机刷
mt.is_random  = nil
-- 刷新时间 (怪物符合刷新条件后，还需要等待的时间)
mt.cool= nil
--怪物数量 - 刷新条件 达到后进入刷新时间计时 
mt.cool_count = nil

-- true 英雄离开，怪物死亡。false 离开不死亡
-- 格子图 偷懒设计，当怪物与英雄距离超出2000米 （超一屏幕），视为离开挑战区域，怪物死亡。
mt.is_hero_leave_death =false 
-- 说明
mt.tip =nil
mt.creeps_datas = nil
-- 野怪所有者
mt.creep_player = ac.player[13]
-- 单位组
mt.group = {}
-- 触发玩家
mt.trg_player = nil
-- 是否已经开始 防止重复创建
mt.has_started = nil
-- 是否完成
mt.is_finish = false
-- 移除时是否也把单位杀死
mt.is_unit_kill = false
-- 移除时是否移除掉所指区域现在的刷怪。
mt.is_region_replace = false

local function register_creep(self, name, data)
	
    setmetatable(data, data)
    data.__index = creep

    local cep = {}
    setmetatable(cep, cep)
    cep.__index = data
    cep.__call = function(self, data)
        self.data = data
        return self
    end
    cep.name = name
    cep.data = data
    
    self[name] = cep
    creep.all_creep[name] = cep


    return cep
end
--外部new
function creep.new(name)
    -- print(name)
    local data = ac.creep[name or self.name]
    if type(data) == 'function' then
        print('没有被注册')
        return false
    end

	local new = {}
	setmetatable(new, new)
    new.__index = data
	new.id = name
	new.name = name
	new.group = {}
    
    creep.all_creep[name] = new

    return new
end



-- 通过 region 名 找到 creep 刷怪,然后返回
-- region table 的话 无法判断。
-- 有问题 ， 一直没有找到region
function creep:find_creep_by_region(region_str)
    local region_str = region_str 
    if not region_str  then 
        return
    end    
    local name 
    local ceps = {}
    
    for k,v in pairs(creep.all_creep) do
        -- print(k,v.region_str ,region_str)
        if v.region_str == region_str then 
            name = k
            table.insert(ceps,creep.all_creep[name])
        end
    end

    if not name  then 
        print('没有找到region')
        return false
    end

    return ceps
end    

function mt:set_region(rgn)
	--刷怪区域的名字要连续性，不能有空格
    local rect_name = rgn or self.region
    
	--已经转化过了
    if type(rect_name) ~= 'string' then 
        self.region = rect_name 
        return
    end    

    local reg =region.create()
    local _ = 0
    local region_str = ''

    for name in rect_name:gmatch '%S+' do
        -- 只有一个区域时，默认为矩形区域，get_point 取中心点
        _ = _ + 1
        region_str = region_str ..' '.. name
        if _ ==1 then 
            reg = rect.j_rect(name)	
        else
           reg = region.create(rect.j_rect(name)) + reg 
        end   
    end
    
    self.region = reg 
    self.region_str = region_str
end   
function mt:get_region()
    return self.region  
end     
--转化野怪数据
function mt:set_creeps_datas()
	--野怪数据
    local creeps_names =  self.creeps_datas
    if type(creeps_names) ~= 'string' then 
        return 
    end   

    local creeps_datas = {}
    for k,v in creeps_names:gmatch '%[(%S+%s-%S+)%]%*(%d+%s-)' do
        creeps_datas[k]=v
    end
    self.creeps_datas = creeps_datas
end

function creep:remove_by_region_str(region_str)
    -- finde_region
    -- is_region_replace true 停止上个在这个region 刷兵的动作，进行这个刷兵，默认是false
end
function mt:start(player)
    
    if self.has_started  then 
        return 
    end    
    self.has_started = true
    self.is_finish =false
    self.group = {}
    self.creep_timer ={}
    
    --转化字符串 为真正的区域
    self:set_region()
    --转化字符串 为真正的野怪数据
    self:set_creeps_datas()

    -- 刷怪前，是否清除原来的刷怪 动作
    -- print(self.is_region_replace )
    if self.is_region_replace then 
        local ceps = creep:find_creep_by_region(self.region_str)
        if ceps then 
            for i =1, #ceps do
                -- 移除该区域内每个刷怪 动作,如果是自己就不删 跳过。
                if ceps[i].name ~= self.name then 
                    -- print('2 移除:',ceps[i].name)
                    ceps[i]:finish(true)
                end    
            end    
        end    
    end    
    --可能会引起掉线
    local p = player or ac.player.self
    local tip = self.tip or ''
    p:sendMsg('怪物开始刷新:' .. tip, 5)
    self.trg_player = p

    --如果 英雄离开时，区域内怪物死亡。
    -- 英雄在一秒内切换时，可能不会死亡
    self.timer  = ac.loop( 1 * 1000 ,function ()
        -- print('触发英雄',self.trg_player.hero)
        if self.is_hero_leave_death then 
            for _, uu in ipairs(self.group) do

                if uu:is_alive() and (uu:get_point() * self.trg_player.hero:get_point() >=2000) then 
                    self.is_finish =true
                end
            end        
            -- print(self.is_finish)
            if self.is_finish then 
                self:finish(true) 
            end    
        end 
    
    end)
    self.timer:on_timer()
    

    if self.on_start then 
        self:on_start()
    end 

    self:next()   
    
end
  
function mt:next()
    local creeps_datas = self.creeps_datas
    local region = self.region
    local creep_player = self.creep_player

    if self.on_next then 
        self:on_next()
    end 
    if not creeps_datas then 
        print('没有野怪数据')
        return
    end
    local cnt = 0
    local max_cnt =0
    for k,v in pairs(creeps_datas) do 
        max_cnt =max_cnt+1
    end    
    -- creeps_datas[u] = count ，单位，数量
    for k,v in pairs(creeps_datas) do 
        cnt = cnt +1 
        local name = k
        local data = ac.lni.unit[name]
        
        if not data then 
            print('lni 数据 没有被加载')
            return 
        end

        local timer = ac.timer(0.1 * 1000,v,function(t)
            local where 
            if region.type == 'rect' and self.is_random then
                local minx, miny, maxx, maxy = region:get()
                where = ac.point(math.random(minx/32,manx/32)*32,math.random(miny/32,maxy/32)*32)
            else
                --如果是region,不规则区域，只能随机刷
                where = region:get_point()
            end    
            
            local u = creep_player:create_unit(name, where)    
            self.current_count = self.current_count + 1
            -- local u = create_attack_unit(where)

            --设置奖励
            u.reward_gold = data['金钱'] * 2
            u.reward_xp = data['经验'] * 1.5
            
            --不主动攻击 
            u:add_ability 'A00B'
            --将单位添加进单位组
            table.insert(self.group, u)
        
            --监听这个单位挂掉
            self.trg = u:event '单位-死亡' (function()
                self.current_count = self.current_count - 1
                if(self.is_finish) then 
                    return
                end     
                -- 不允许下一波 则返回
                if  not self.allow_next then 
                    return
                end    
                local i = 0
                for _, uu in ipairs(self.group) do
                    if uu:is_alive() then
                        i = i + 1
                        if self.cool_count  then
                            --如果怪物存活数量 > 刷新数量条件 直接返回，不进行下一波的刷新
                            if i > self.cool_count  then 
                                return
                            end    
                        else
                            --如果怪物存活数量 > 0 直接返回，不进行下一波的刷新
                            return	
                        end	
                    end
                end
                

                --当前波数加1,若限定最大波数，则下一波大于最大波数时，跳出
                self.index = self.index +1

                if self.index > self.max_index then 
                    self.allow_next = false
                    self:finish() 
                end    
            
                -- 在当前怪没清完前 不允许下一波
                self.allow_next = false

                --如果有刷新时间配置 则 按照时间等待后刷新，没有的话立即刷新
                if self.cool then 
                    ac.wait(self.cool  * 1000, function()
                        self:next()
                    end)
                else
                    --最小刷新时间
                    --print('等待0.1秒刷新')
                    ac.wait(0.3 * 1000, function()
                        self:next()
                    end)
                end	
                   
            end)
            
        end);
        -- 如果同时杀死100只，每只怪物死亡都循环遍历下表，可能波数会出现问题
        -- 如果 创建出来的兵 要大于刷的条件兵才允许再次刷新，那出来一只，打死一只的情况下，怎么处理
        -- 创建完兵，给标识说可以刷新
        -- 如果 每杀死一只并就判断一次数量 小于 某个值就刷新，这又会导致一瞬间多刷很多只。
        -- print(t.count,v )
        --[[ self.creep_timer = {},table.insert(self.creep_timer,timer)
              timer:on_timerout()

        ]]
        timer.creep_name = k
        self.creep_timer[timer.creep_name] = timer

        local temp_self =self
        function timer:on_timerout()
            temp_self.creep_timer[self.creep_name] = nil
        end  
        if cnt == max_cnt then 
            function timer:on_timerout()
                temp_self.allow_next = true
            end  
        end    

    end


end    
--bug : 移除时，没有kill unit
function mt:finish(is_unit_kill)
    
    self.is_finish = true
    self.has_started = false

    if  self.trg then 
        self.trg:remove()
    end
    if  self.timer then 
        self.timer:remove()
    end
    
    for k,v in pairs(self.creep_timer) do
         --print('移除计时器',k,v)
        if v then 
            v:remove()
        end    
    end	
    
    if self.on_finish then
        self:on_finish()
    end    
 
    local is_unit_kill = is_unit_kill or self.is_unit_kill 
 
    if is_unit_kill then 
        for _, uu in ipairs(self.group) do
            uu:kill()
        end     
     end
 
    --creep.all_creep[self.name] = nil
    
    
end    

local function init()
    creep.all_creep ={}

    ac.creep = setmetatable({}, {__index = function(self, name)
        return function(data)
                return register_creep(self, name, data)
        end
    end})

end
init()

return creep