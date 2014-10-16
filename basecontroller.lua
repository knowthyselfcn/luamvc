local sessionMgr = require("luamvc.session"):new()

local _M = { _VERSION = "0.2" }
_M.name = "base controller"

-----------------------------------------------------------
--                BASE CONTROLLER MODULE 
-----------------------------------------------------------

_M.cjson = require ("cjson"):new()
_M.logger = require("lib.filelogger")

-----------------------------------------------------------
--               FUNCTIONS 
-----------------------------------------------------------

function _M.new(self)
    return setmetatable( { }, { __index = _M }  ) 
end

return _M
