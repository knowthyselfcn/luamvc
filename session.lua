local _M = { _VERSION = "0.1" }

function _M.new(self)
   return setmetatable({}, { __index = _M }) 
end

_M.sessionIds = {}

local function _uuid()
    local uuid = require("uuid")
    local socket = require("socket")
    uuid.randomseed(socket.gettime()*10000)
    local t = uuid()
    return t
end

function _M.generateSessionId(self) 
    local sessionId = _uuid()
    local currentTimeSecond = os.time()
    local expireAt = ngx.cookie_time( currentTimeSecond + 1800 )        -- default expire duration: 30m
    ngx.header['Set-Cookie'] = 'LSESSIONID='.. sessionId ..'; path=/; expires=' .. expireAt 
    _M.sessionIds[sessionId] = {lastvisit = currentTimeSecond, visits = 1} 
    return sessionId
end


function _M.checkSessionID(self, sessionId)
    local res = false
    local currentTimeSecond = os.time()
    local session = _M.sessionIds[sessionId] 
    if nil == session then
        ngx.print("you are faking a sessionid, you daidan dorobo")
    else
        if currentTimeSecond - session.lastvisit > 1800  then  -- session expires in 30m
            _M.sessionIds[sessionId] = nil
            ngx.print("session expired")
        else
            session.lastvisit = currentTimeSecond 
            session.visits = session.visits + 1
            res = true
        end
    end
    return res
end


return _M
