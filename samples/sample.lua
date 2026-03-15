-- Lua script example
local http = require("socket.http")
local json = require("dkjson")

local UserService = {}
UserService.__index = UserService

function UserService.new()
    return setmetatable({ cache = {} }, UserService)
end

function UserService:get_user(id)
    if self.cache[id] then return self.cache[id] end

    local body, code = http.request("https://api.example.com/users/" .. id)
    if code ~= 200 then return nil, "HTTP " .. code end

    local user, err = json.decode(body)
    if not user then return nil, err end

    self.cache[id] = user
    return user
end

local svc = UserService.new()
local user, err = svc:get_user(1)
if user then
    print(string.format("Hello, %s!", user.name))
else
    print("Error: " .. (err or "unknown"))
end
