local cjson = require ("cjson"):new()   -- for debug log
local sessionMgr = require("luamvc.session"):new()
local AppConf = require("lib.appconf")
local util = require("luamvc.util")

local lfs = require"lfs"

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
--                 LuaMVC DISPATCHER
-----------------------------------------------------------

function _M.dispatch(self )
    local template = require ("luamvc.template")

    local reqURL = ngx.var.uri
    if nil == reqURL then
        error("Illegal URL requested!")
    end
    -- ngx.print("reqURL = " .. reqURL)

    local urlList = util.split_path(reqURL) 
    if 2 ~= #urlList then
        ngx.print("luaMVC only supports controller/action.lsp style request")
        ngx.exit(200)
    end
    local controller = urlList[1]
    local action_suffix = urlList[#urlList]

    local actionSuffixList = util.split(action_suffix, "[\\.]+")
    if 2 ~= #actionSuffixList then
        ngx.print("action like action.lsp could only be accepted")
        ngx.exit(200)
    end
    local actionName = actionSuffixList[1]
    local suffix = actionSuffixList[2]

    local req = {}
    if "POST" == ngx.req.get_method() then
        local h = ngx.req.get_headers()
        local contentTypeFull = h['content-type']
        local contentType = util.split(contentTypeFull, "[\\;]")[1]
        
        if "multipart/form-data" == contentType then
            req.files = {}
        else
            ngx.req.read_body()
            req = ngx.req.get_post_args()
        end
    else
        ngx.req.read_body()
        req = ngx.req.get_uri_args()
    end

    local controllerFile =  ""
    local tpldir = "" 
    local goon = false
    -- if there is no such action, try to render the tpl directly
    local sessionId = ngx.var.cookie_LSESSIONID              
    local now = os.time()


    if _M.privates[controller]  then
    ngx.log(ngx.ERR, "controller is private")
        controllerFile = "controller.private." .. controller
        tpldir = "../html/WEB-INF"
        -- ngx.print("    <hr />" .. "    private controller :" )
    elseif  _M.publics[controller] then
    ngx.log(ngx.ERR, "controller is public ")
        controllerFile = "controller.private." .. controller
        controllerFile = "controller.public." .. controller
	tpldir = "../html/tpl"
        --ngx.print("    <hr />" .. "    public controller :" )
    else 
        ngx.print("No such controller :".. controllerFile  )
        ngx.exit(200)
    end

    local status, ctrlClass =  pcall(require, controllerFile )

    local actionObj = nil
    local action =  nil

    if true == status then
        actionObj = ctrlClass:new() 
        action = actionObj[actionName]
    else
        ngx.print("controller load error:" )
 	ngx.exit(200)
    end

    local checkActionFun = true
    if _M.privates[controller]  then
        if controller == AppConf.loginCtrl 
	   and actionName == AppConf.loginAction  then
              
   	else
	    if sessionMgr:checkSessionID(sessionId) then
		ngx.log(ngx.ERR, controller .. "/" .. actionName )
	    else
   		ngx.print("You do not have an sessionId. You daidan dorobo")	
		ngx.exit(200)
	    end
        end 
    else
	if nil == action then
         	checkActionFun = false
    	else
	end
    end
    local response = {}    
    -- check if need action fun, if no need, render tpl directly 
    if checkActionFun then
	response = action({}, req)
        if nil == action then
            ngx.print("No such action :".. actionName )
            ngx.exit(200)
        else
        end
    else
        ngx.log(ngx.ERR, "no need to check actionFun existence")
    end

        --ngx.print("request url :".. tpldir ..reqURL)
    
    local view = tpldir .. reqURL
    assert( "table" == type(response), "resp has to be a table")
    template.render(view, { req = req, resp = response} )
end


return _M
