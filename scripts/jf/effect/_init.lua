

local str = require 'jf.effect_file'
local fogmodifier = require 'types.fogmodifier'
local rect = require 'types.rect'


ac.alleffects = {}

local minx = -5000
local maxx = 5000
local miny = -5000
local maxy = 5000

local area = 500

local rowx = math.floor((maxx-minx ) / area)
local rowy = math.floor((maxy-miny ) / area)

--创建视野
--rect.create(-1500,1000,-2000,1500)
local function icu()
    local rcts = rect.create(minx,miny,maxx,maxy)
    for i=1,10 do
        fogmodifier.create(ac.player(i), rcts)
    end
end

-- 每个100码创建个特效
local function create_effect()
    local ix,iy = 1,1
    for name in str:gmatch '%S+' do

        if ix > iy * rowx  then 
            iy = iy +1 
        end    
        local x = minx + area * ix
        local y = miny + area* iy
        local where = ac.point(x,y)
        local eff = ac.effect(where, name, 270, 1, 'chest')
        ac.alleffects[name] = eff

        --创建文字
        ac.texttag
        {
            string = name,
            size = 14,
            position = ac.point(x, y-60, 0),
            red = 31,
            green = 165,
            blue = 238,
            permanent = true,
        }
        ix = ix + 1 

    end
end

local function main()
    
    --创建视野
    icu()
    --创建特效
    create_effect()

end 

main()

