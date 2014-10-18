local cjson = require("cjson"):new()
local logger = require("filelogger")
local dbconf = require("lib.dbconf")
local mysql = require( "resty.mysql")

-----------------------------------------------
local _M = { _VERSION = "0.1" }

function _M.new(self)
    return setmetatable({}, { __index = _M } )
end
-----------------------------------------------

function _M.query(self, sql)
    assert("string" == type(sql), "in db.query(), sql requires string, got " .. type(sql))
    local db, err = mysql:new()
    local res, err, errno, sqlstate = db:connect{ host = dbconf['host'], port=dbconf['port'], database= dbconf['database'], 
    user=dbconf['user'], password=dbconf['password'] }
    if nil ~= err then 
        logger:error(err)
        error(err)
    end  
    local res, err, errno, sqlstate  = db:query(sql)
    local ok, err = db:set_keepalive(10000, 100)
    if not ok then
        logger:error("in db.query() failed to set keepalive: ", err)
    end
    return res, err, errno, sqlstate
end



return _M
