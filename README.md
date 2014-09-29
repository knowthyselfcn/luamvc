luamvc
======


A simple MVC framework written in Lua for Openresty

It is a full MVC framework with ORM. 

Depends on :
  resty-template
  luasocket
  uuid

  
How to use:
  1, I suggest that an independant dir in openresty home like scriptlua, clone it there.



an example directory

scriptdir:
          -- controller
          -- lib
          -- luamvc
          -- svc      
htmlroot:
          -- tpl        lua template files
          -- css
          -- js
          -- *.html
         
Just clone luamvc into the scriptdir.



example nginx.conf 

        # lsp pages are dilivered to dispatcher
        location ~\.lsp$ {
            client_max_body_size 500k;
            client_body_buffer_size 500k;
            content_by_lua '
                local dispatcher = require("luamvc.dispatcher"):new()
                dispatcher.dispatch()
            ';
        }


lua script in WEB-INF cannot be accessed directly. It needs mapping. In LuaMVC, the mapping strategy is rather simple. 
Becuase LuaMVC is not designed for large and complex applications, we use "convention over configuration". The lua script
is WEB-INF must be like controllname/actionName.lsp and it can only be accessed by controllerName/actionName.lsp. The 
request is processed by a  function named "actionName" in script/controller/controllerName.lua.




This project is just for study, not production ready. 
