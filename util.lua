local util = {}

function _split(str, pat)
    if nil == str then
        error("target string should not be nil")
    end
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end
util.split = _split


local function _split_path(str)
    if nil == str then
        error("str should not be nil dfa ")
    end
    return _split(str,'[\\/]+')
end
util.split_path = _split_path


local type = type
local pairs = pairs
local tostring = tostring
local setmetatable = setmetatable

local function print_r(root)
    if ( 0 == table.getn(root)) then
        return "\ntable is empty\n"
    end 
    local function _dump(t, layer)
        local out = "\n"
        for k,v in pairs(t) do
            local indent = ""
            local quoteMark = ""
            if type(k) == "number" then 
                k = tostring(k)
            else 
                quoteMark = "'" 
            end 
            for num=1, layer do
                indent = indent .. "\t"
            end 
            if v == nil then
                out = out ..  indent .. k .. " {" .. cache[v].."}\n"
            elseif type(v) == "table" then
                out = out .. indent .. quoteMark .. k .. quoteMark .."  => (  ".. _dump(v, layer+1) .. "\n" .. indent .. "      )\n"
            else
                out = out .. indent.. quoteMark ..  k .. quoteMark .." [" .. tostring(v).."] \n"
            end 
        end 
        return out 
    end 
    --ngx.log(ngx.ERR, "\n" .. _dump(root, 1)) 
    ngx.say( _dump(root, 1)) 
end
util.dump = print_r


return util
