local lfs = require "lfs"
local AppConf = require("lib.appconf")
local util = require("luamvc.util")

local _M = { _VERSION = "0.1" }

function  _M.new(self)
    _M.privates = {}
    _M.publics = {}
    local ctrl_suf = {}
    for file in lfs.dir(AppConf.ctrldir .. "/private/") do
	ctrl_suf = util.split(file, "[\\.]+")
	if 2 == #ctrl_suf then
	    _M.privates[ctrl_suf[1]] =  ctrl_suf[1] 	
 	    ngx.log(ngx.ERR, " private controll : " .. ctrl_suf[1]) 
	else
	end
    end

    for file in lfs.dir(AppConf.ctrldir .. "/public/") do
	ctrl_suf = util.split(file, "[\\.]+")
	if 2 == #ctrl_suf then
	    _M.publics[ctrl_suf[1]] =  ctrl_suf[1] 	
 	    ngx.log(ngx.ERR, " public controll : " .. ctrl_suf[1]) 
	else
	end
    end

    for k, v in pairs(_M.privates) do
	if _M.publics[k] then
 	    ngx.log(ngx.ERR, "controll name conflicts : " .. k) 
	    return {}
	end
    end

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
