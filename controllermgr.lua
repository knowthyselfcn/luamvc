local lfs = require "lfs"
local AppConf = require("lib.appconf")
local util = require("luamvc.util")

local _M = {}

local logStr = "\n"
local status = false 
local ctrlClass  = ""
local ctrlFile = ""
local ctrlName = ""

_M.privates = {}
_M.publics = {}
local ctrl_suf = {}
for file in lfs.dir(AppConf.ctrldir .. "/private/") do
    ctrl_suf = util.split(file, "[\\.]+")
    if 2 == #ctrl_suf then
	ctrlName = ctrl_suf[1]
	ctrlFile = "controller.private." .. ctrlName 
        status, ctrlClass =  pcall(require, ctrlFile )
	if true == status then
            _M.privates[ctrlName] = ctrlClass:new() 
	else
	    assert("bad load private class")    
	end
        logStr = logStr ..  "\n private controll : " .. ctrl_suf[1]
    else
    end
end

for file in lfs.dir(AppConf.ctrldir .. "/public/") do
    ctrl_suf = util.split(file, "[\\.]+")
    if 2 == #ctrl_suf then
	ctrlName = ctrl_suf[1]
	ctrlFile = "controller.public." .. ctrlName 
        status, ctrlClass =  pcall(require, ctrlFile )
	if true == status then
            _M.publics[ctrlName] = ctrlClass:new()
	else
	    assert("bad load public class")    
	end
        logStr = logStr ..  "\n public controll : " .. ctrl_suf[1]
    else
    end
end

for k, v in pairs(_M.privates) do
    if _M.publics[k] then
        ngx.log(ngx.ERR, "controll name conflicts : " .. k) 
        return {}
    end
end

ngx.log(ngx.ERR, "--------> " .. logStr ) 

_M.name="contrl mgr"

return _M

