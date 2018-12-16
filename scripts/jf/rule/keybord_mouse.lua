local rect = require "types.rect"

--code,state,message
ac.game:event '玩家-按下按键' (function(trg,code,state,message)
    local keyboard = message.keyboard
    local hero =ac.player.self.hero
	--单击x 移动练功房
    -- if code == keyboard['X'] then
    -- end    


end)

ac.game:event '玩家-双击按键' (function(trg,code,state,message)
    local keyboard = message.keyboard
    local hero =ac.player.self.hero
    local p = ac.player.self
    --双击x 移动练功房
    if code == keyboard['X'] then

        local x,y = rect.j_rect('practice'..p.id):get_point():get()
        local point = ac.point(x,y+200)
        
        hero:blink(point,true,false,true)
        
    end    
    --双击c 回城
    if code == keyboard['C'] then
        hero:blink(rect.j_rect('wq'),true,false,true)
        
    end    

end)

ac.game:event '玩家-聊天' (function(self, player, str)
    local hero = player.hero
    local p = player

    --输入 hg 回城
    if string.lower(str:sub(1, 2)) == 'hg' then
        hero:blink(rect.j_rect('wq'),true,false,true)
    end
    -- '++' 调整镜头大小
    if str == '++' then
        --最大3000
        local distance = p:getCameraField 'CAMERA_FIELD_TARGET_DISTANCE'  +  500
        
        if type(distance) =='number' then  
            p:setCameraField('CAMERA_FIELD_TARGET_DISTANCE', distance)
        end    
    end    
    -- '++' 调整镜头大小
    if str == '--' then
        --最大3000
        local distance = p:getCameraField('CAMERA_FIELD_TARGET_DISTANCE')  -  500
        if type(distance) =='number' then  
            p:setCameraField('CAMERA_FIELD_TARGET_DISTANCE', distance)
        end    
    end   

    if str:sub(1, 1) == '-' then

        local strs = {}
		for s in str:gmatch '%S+' do
			table.insert(strs, s)
        end
        
		local str = string.lower(strs[1]:sub(2))
        strs[1] = str
        --print(str)
        
        -- jt 调整镜头大小
        if str == 'jt' then
            --最大3000
            local distance = math.min(tonumber(strs[2]),3000)
            if type(distance) =='number' then  
                p:setCameraField('CAMERA_FIELD_TARGET_DISTANCE', distance)
            end    
        end    

    end    



end)
