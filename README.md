# WebAutoDeploy

基于gitlab&amp;nginx&amp;lua的自动化网页部署脚本

## HOW TO USE

### 安装

- 编译[tengine](https://github.com/alibaba/tengine)/[openresty](http://openresty.org/)并安装模块ngx\_lua\_module
- 使用[luarocks](https://luarocks.org/)安装lua-cjson
- 编译安装服务[sockproc](https://github.com/juce/sockproc)
- 安装lua-resty模块[lua-resty-shell](https://github.com/juce/lua-resty-shell)

### 搭建环境

1. 启用sockproc建立到shell的连接

  ```
      ./sockproc /tmp/shell.sock
  ```
  
2. 配置nginx

  ```
      server {
          ...
          
          #lua_code_cache off;  # for development purpose

          location /autodeploy {  # url for AutoDeploy
              content_by_lua_file /data/autodeploy.lua;  # path for autodeploy.lua
          }
      }
  ```

3. 克隆网页并配置autodeploy.lua
4. 重启nginx

  ```
      service nginx reload
  ```

5. 配置gitlab

  在project/settings/webhooks中添加pull动作到网站的hook，如`http://example.com/autodeploy?key=my_verify_key`
  
6. Test Hook
