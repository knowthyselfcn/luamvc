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
            set_decode_base32 $session $cookie_LSESSIONID; # from the ngx_set_misc module
            set_decrypt_session $raw $session;
            set_decrypt_session $myraw $session;

            if ($raw = '') {
                set $raw 'text to encrypted'; # from the ngx_rewrite module
                set_encrypt_session $lsessionid $raw;
                set_encode_base32 $lsessionid; # from the ngx_set_misc module
                add_header Set-Cookie 'LSESSIONID=$lsessionid';  # from the ngx_headers module
            }

            content_by_lua '
                local dispatcher = require("luamvc.dispatcher"):new()
                dispatcher.dispatch()
            ';
        }
