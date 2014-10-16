local _M = { _VERSION = "0.1" }

function  _M.new(self)
    return setmetatable({}, { __index = _M } )
end


-----------------------------------------------------------
--                 Lua APP SERVER CONTROLLER
-----------------------------------------------------------

function _M.exe(controller, action, request)
    local resp = {}
    
    local actionMod = require(controller)
    
    resp = actionMod[action](request)

    return resp
end



return _M
