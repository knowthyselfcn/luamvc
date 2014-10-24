local sessionMgr = require("luamvc.session"):new()
local AppConf = require("lib.appconf")
local util = require("luamvc.util")
local template = require ("luamvc.template")

local ctrlMgr = require("luamvc.controllermgr")

local _M = { _VERSION = "0.1" }

function  _M.new(self)
    return setmetatable({}, { __index = _M } )
end

-----------------------------------------------------------
--                 LuaMVC DISPATCHER
-----------------------------------------------------------

function _M.dispatch(self )
    ngx.log(ngx.ERR, "--------> entering dispatch() ") 
	
    local reqURL = ngx.var.uri
    if nil == reqURL then
        error("Illegal URL requested!")
    end

    local urlList = util.split_path(reqURL) 
    if 2 ~= #urlList then
        ngx.print("luaMVC only supports controller/action.lsp style request")
        ngx.exit(200)
    end
    local ctrlName = urlList[1]
    local action_suffix = urlList[#urlList]

    local actionSuffixList = util.split(action_suffix, "[\\.]+")
    if 2 ~= #actionSuffixList then
        ngx.print("action like action.lsp could only be accepted")
        ngx.exit(200)
    end
    local actionName = actionSuffixList[1]
    --local suffix = actionSuffixList[2]  => lsp

    local req = {}
    local response = {}    
    ngx.log(ngx.ERR, "--------> method -is  => ".. ngx.req.get_method() )
    if "POST" == ngx.req.get_method() then
        local h = ngx.req.get_headers()
        local contentTypeFull = h['content-type']
 	local contentLength = h['Content-Length']
        local contentType = util.split(contentTypeFull, "[\\;]")[1]
	ngx.log(ngx.ERR, "--------> content-type is  => ".. contentType  )
	ngx.log(ngx.ERR, "--------> content-length is  => ".. contentLength )
        
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

    local sessionId = ngx.var.cookie_LSESSIONID              
    local now = os.time()

    local tpldir = "" 
    local ctrlObj = nil
    local actionFn =  nil
    if ctrlMgr.privates[ctrlName]  then
        tpldir = "../html/WEB-INF"
	ctrlObj = ctrlMgr.privates[ctrlName]
	if ctrlName == AppConf.loginCtrl and 
		actionName == AppConf.loginAction  then
             -- no session check 
   	else
	    if sessionMgr:checkSessionID(sessionId) then
		-- normal session request
	    else
   		ngx.print("not have an sessionId.You daidan dorobo")	
		ngx.exit(200)
	    end
        end
    elseif ctrlMgr.publics[ctrlName] then
	tpldir = "../html/tpl"
	ctrlObj = ctrlMgr.publics[ctrlName]
    else 
	ngx.log(ngx.ERR, "no such controller")
        ngx.exit(200)
    end
    actionFn = ctrlObj[actionName]
    
    if nil == actionFn then
        --ngx.print("No such action :".. actionName )
        --ngx.exit(200)
    else
        response = actionFn({}, req)
    end

    assert( "table" == type(response), "resp has to be a table")
    local view = tpldir .. reqURL
    template.render(view, { req = req, resp = response} )
end

return _M
