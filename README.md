luamvc
======

a simple web MVC framework written in Lua


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



nginx.conf 

        # lsp pages are dilivered to dispatcher
        location ~\.lsp$ {
            client_max_body_size 500k;
            client_body_buffer_size 500k;
            content_by_lua '
                local dispatcher = require("luamvc.dispatcher"):new()
                dispatcher.dispatch()
            ';
        }

