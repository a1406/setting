local skynet = require "skynet"
require "skynet.manager"

local socket = require "socket"

local sock_fd 
local buffer = nil;
local server_id = nil;

local CMD = { }
local REQUEST = {}
local all_tokens = nil;

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, isArray, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        str = string.gsub(str, "[%c\\\"]", {
            ["\t"] = "\\t",
            ["\r"] = "\\r",
            ["\n"] = "\\n",
            ["\""] = "\\\"",
            ["\\"] = "\\\\",
        })
        return '"' .. str .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    local isArray = function(arr)
        local count = 0 
        for k, v in pairs(arr) do
            count = count + 1 
        end 
        for i = 1, count do
            if arr[i] == nil then
                return false
            end 
        end 
        return true, count
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        local ret, count = isArray(obj)
        if ret then
            for i = 1, count do
                tokens[#tokens + 1] = getIndent(level) .. wrapVal(obj[i], level) .. ","
            end
        else
            for k, v in pairs(obj) do
                tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
            end
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

local function serialize(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{\n"
        for k, v in pairs(obj) do
            lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
            end
        end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end
    return lua
end

--发包封装
local function send_package(info)
    if not sock_fd then
        skynet.error("send_package get sock_fd nil");
        return;
    end

    local package = string.pack(">s2", info)
    local ret = socket.write(sock_fd, package);
    if not ret then
        sock_fd = nil;
    end
end


function CMD.activity_start(c_id, server_id)
    local sql = "select token from device_token where server_id='" .. server_id .. "'";
    all_tokens = skynet.call("db_mysql", "lua", "query", sql);

    skynet.error("to_provider get activity_start", c_id, server_id, sql);
    skynet.error("all_tokens", type(all_tokens), #all_tokens)

    for k, v in pairs(all_tokens) do
        skynet.error("k, v.token", k, v.token)
    end

    if all_tokens and #all_tokens > 0 then
        local item = table.remove(all_tokens, #all_tokens);
        if item then
            local info = item.token .. "|" .. string.format("{\"aps\":{\"alert\":\"activity %s is on!\",\"badge\":1,\"sound\":\"level_success.mp3\"}}", c_id)
            send_package(info)
        end
    end
end

local respones_cmd = {
    ["1"] = "uninstalled",
    ["2"] = "send_success",
}

--uninstalled user, deleted from mysql.
function REQUEST.uninstalled(info)
    local sql = "delete from  device_token where token='" .. info .. "'";

    skynet.send("db_mysql", "lua", "send", sql);

    if all_tokens and #all_tokens > 0 then
        local item = table.remove(all_tokens, #all_tokens);
        if item then
            local info = item.token .. "|" .. string.format("{\"aps\":{\"alert\":\"activity %s is on!\",\"badge\":1,\"sound\":\"level_success.mp3\"}}", c_id)
            send_package(info)
        end
    end
end

function REQUEST.send_success()
    skynet.error("message sended success")
    if all_tokens and #all_tokens > 0 then
        local item = table.remove(all_tokens, #all_tokens);
        if item then
            local info = item.token .. "|" .. string.format("{\"aps\":{\"alert\":\"activity %s is on!\",\"badge\":1,\"sound\":\"level_success.mp3\"}}", c_id)
            send_package(info)
        end
    end
end

local function dispatch(cmd, info)
    if respones_cmd[cmd] and REQUEST[respones_cmd[cmd]] then
        REQUEST[respones_cmd[cmd]](info);
    else
        skynet.error("invalid respones_cmd:", cmd, info)
    end
end


local function unpack_package(buf)
    if not buffer then
        buffer = buf;
        if not buffer then
            skynet.error("buffer is nil");
            return;
        end
    else
        if buf then
            buffer = buffer .. buf;
        end
    end

    while true and buffer do
        local size = #buffer

        if size < 2 then
            return nil
        end

        -- 进行包体操作
        local s = buffer:byte(1) * (255) + buffer:byte(2)

        print("byte1/byte2/byte3 package size, content size", buffer:byte(1), buffer:byte(2), buffer:byte(3), size, s)

        if size < s + 2 then
            skynet.error("unpack_package all size:---")
            return nil
        end

        local result = buffer:sub(3, 2 + s)
        buffer = buffer:sub(3 + s)

        dispatch(result:sub(1, 1), result:sub(2))
    end
end

skynet.start( function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = CMD[cmd]
        if f then
            f(...)
        else
            skynet.error("invalid function called in send_to_provider:", cmd)
        end
        end )
        skynet.register "to_provider"

        sock_fd = socket.open("127.0.0.1", 6002);

        skynet.fork(function()
            while true do
                if sock_fd then
                    local ok, s = socket.read(sock_fd);
                    --print("type ok/s", type(ok), type(s))
                    skynet.error("ok/s", ok, s)
                    unpack_package(ok);

                    if not ok then
                        socket.close(sock_fd);
                        sock_fd = nil;
                        skynet.error("lost connection between provider")
                    end
                else
                    sock_fd = socket.open("127.0.0.1", 6002);
                end
            end
        end)
end )
