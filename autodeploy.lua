-- autodeploy.lua
-- by chu
local cjson = require("cjson")
local shell = require("resty.shell")

-- deploy config
local config = {
    verify_key = "YOUR_VERIFY_KEY_HERE",
    deploy_path = "/TO/DEPLOY/PATH",
    deploy_url = "http://GITLAB_USERNAME:GITLAB_PASSWD@WWW.MYGITLAB.COM/YOUR_REPO.git",
    timeout = 30 * 1000,  -- 30s
}

local function say_json(msg)
    ngx.say(cjson.encode(msg))
end

local function say_error(retval, errmsg, shell_out, shell_err)
    say_json({result = retval, msg = errmsg, shell_out = shell_out, shell_err = shell_err})
end

local function say_ok(shell_out, shell_err)
    say_json({result = 0, msg = "ok", shell_out = shell_out, shell_err = shell_err})
end

ngx.header.content_type = "text/html"

-- only accept POST request
if ngx.var.request_method ~= "POST" then
    say_error(-1, "invalid request type")
else
    local get_args = ngx.req.get_uri_args()
    local verify_key = get_args["key"]

    if verify_key == nil then
        say_error(-1, "invalid operation")
    else
        if verify_key ~= config.verify_key then
            say_error(-1, "key incorrect")
        else
            -- pull operation(non-blocking)
            local shell_cmd = "cd "..config.deploy_path.."; git reset --hard origin/master; git clean -f; git pull "..config.deploy_url
            local status, out, err = shell.execute(shell_cmd, {timeout = config.timeout})

            -- print result
            if status ~= 0 then
                say_error(status, "execute failed", out, err)
            else
                say_ok(out, err)
            end
        end
    end
end
