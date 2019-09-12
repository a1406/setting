local skynet = require "skynet"
require "skynet.manager"
local mysql = require "mysql"

local db
local command = {} 

local is_paused = false;

--对数据库进行操作
function command.QUERY(sql)  
    --print("sql:"..sql)
 	local  r =mysql.query(db,sql)

 	if r.errno then
		skynet.error("ERROR sql:", sql);
	 	for k,v in pairs(r) do
	 	 	skynet.error("k/v", k, v);
	 	end
 	end

	skynet.ret(skynet.pack(r))

	r = nil;

	return true
end

function command.SEND(sql)  
    --print("sql:"..sql)
    while true == is_paused do
    end

 	local  r = mysql.query(db,sql)
 	
 	if r.errno then
		skynet.error("ERROR sql sended:", sql);
	 	for k,v in pairs(r) do
	 	 	skynet.error("k/v", k, v);
	 	end
 	end

 	r = nil;

	return true
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		if not f then
			print("skynet.call的目标是一个不存在的函数")
		end
		f(...)
	end)
	skynet.register "db_mysql"

	db = mysql.connect {
		database="sanguo",
		user="root",
		password="123465", 
        host = "127.0.0.1",
        port = 3306,
    }
end)
