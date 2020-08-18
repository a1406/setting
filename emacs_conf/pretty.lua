-- 从https://120.24.64.132:8002/oa/LuaTable.php?env=1看到的ssdb里面的数据没有对齐
-- 把数据复制到某个文件A里面，然后lua pretty-print-ssdb-lua-struct.lua A 就可以对齐打印

table.loadstring = function(strData)
    local loadfunc = loadstring
    if not loadfunc then
        loadfunc = load
    end

	local f = loadfunc("do local ret=" .. strData .. " return ret end")
	if f then
	   return f()
	end
end

local function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        -- print(indent.."["..pos.."] => "..tostring(t).." {")
                        print(indent.."["..pos.."] => {")                        
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        -- print(tostring(t).." {")
        print("{")        
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

-- local f = io.open (arg[1], "r")
-- local data = f:read("*a")
-- io.close(f)
local data = io.read('*a')
local b = table.loadstring(data)
print_r(b)

