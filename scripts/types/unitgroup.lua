local group = {}
local mt={}
setmetatable(group,group)
group.__index = mt
mt.type = 'group'
mt[0] = 0

function mt:GroupIsNil()
    if self == nil then
        return true
    else 
        return false 
    end       
end

function mt:GroupCount()
    return self[0]
end

function mt:UnitInGroup(u)
    if self[u] == nil then
        return false
    else 
        if self[self[u]] == nil then
            return false
        else 
            return true
        end       
    end     
	
end

function mt:CreateGroup()
    return setmetatable({},group)
end

function mt:GroupAddUnit(u)

   --print('add: ',self[self[u]],self[u]) 

   if self:GroupIsNil() then return end
   if self:UnitInGroup(u) then  return end
   
   local i = self[0]+1
   table.insert(self,u)
   self[0]=i
   self[u]=i

   print('单位组添加',self[self[u]],self[u]) 
end

function mt:GroupRemoveUnit(u)
   print('remove: ',self[self[u]],self[u])
   if self:GroupIsNil()  then return end
   if self:UnitInGroup(u) == false then return end

   print('单位组有存在，删除开始',self[u],' 单位组#:',#self,' 单位组[0] ',self[0])
   local i = self[0]-1
   
   table.remove(self,self[u])
   
   -- table remove 中间位置的key 会影响以后的key, 以致于table[u] = key ，table[key] = u ，不一致。
   -- table add {a,b,c,[a] = 1, [b] = 2, [c] = 3}. table remove b 结果：{a,c,[a] = 1, [b] = nil, [c] = 3}, table remove c.出错。 

   for key=self[u],#self do
       self[self[key]] = key
   end	

   self[0]=i
   --self[u]=nil
end



-- function mt:fix_table_key(i,u)
--     if(i)
--     --return u == nil
-- end	
   
function mt:ForGroup(f)
   for i=1,#self do
		f(i,self[i])
	end	
end


function mt:isnil(u)
   return u == nil
end	
--[[
local unit_a = 'a'
local unit_b = 'b'
local unit_c = 'c'

demo_group_unit = CreateGroup()

--local i = '1' +1
demo_group_unit:GroupAddUnit(unit_a)
demo_group_unit:GroupAddUnit(unit_b)
demo_group_unit:GroupAddUnit(unit_c)
demo_group_unit:GroupRemoveUnit(unit_a)

print(demo_group_unit:GroupCount())

--print_r()

function add(u)
 print(u)
end	

--t = add(u)
print(add(1))

demo_group_unit:ForGroup(add)
--]]

return group




