--main.lua

-- cclog
function cclog(...)
    print(string.format(...))
end

function edit_DrawNode() end

function vLuaReloadLocal()
    for i,name in ipairs(_vload) do
        package.loaded[name] = nil
    end
    gRes:ReleaseAllFile();
    local lst = _vload;
    _vload = {};
    for i,name in ipairs(lst) do
        require(name);
    end
    if not noLoadGlobal then
        vLuaReloadGlobal()
    end
end

function vLuaLoadFinish( name )
    _vload = _vload or {};
    table.insert(_vload, name);
end

function vLuaFlush(noLoadGlobal)
    for i,name in ipairs(_vload) do
        package.loaded[name] = nil
    end
    local lst = _vload;
    _vload = {};
    for i,name in ipairs(lst) do
        require(name);
    end
    if not noLoadGlobal then
        vLuaReloadGlobal()
    end
end

function vLuaReloadGlobal()
    gAudio = VAudioManager:new();
    gSys = VSystem:new();
    gData = VDataManager:new();
    gData:initInfo();
    local apkFileName = gUpdate.apkFileName;
    local versionList = gUpdate.versionList;
    gUpdate = VUpdate:new();
    gUpdate.apkFileName = apkFileName;
    gUpdate.versionList = versionList;
    gZipUpdate = VZipUpdate:new();
    gReq = VRequest:new();
    gRsp = VResponse:new();
    gEvent = VEventMaganer:new();
    gPush = function(node) return gWindow:Push(node) end
    gPop = function(node) return gWindow:Pop(node) end
    gView = function(idx) return idx and gWindow:view()(idx) or gWindow:view() end
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    require "run"
    
    -- 屏蔽cocos2dx原生的多分辨率解决方案。
    local frameSize = gDtr:getOpenGLView():getFrameSize();
    gDtr:getOpenGLView():setDesignResolutionSize(frameSize.width, frameSize.height, 0)

    gAudio = VAudioManager:new();               --声音管理
    gSys = VSystem:new();                       --系统相关功能
    gData = VDataManager:new();                 --数据管理
    gData:initInfo();
    gWindow = VWindow();                        --全局窗口
    gUpdate = VUpdate:new();                    --升级相关
    gZipUpdate = VZipUpdate:new();              --apk包下载
    gReq = VRequest:new();                      --协议发送
    gRsp = VResponse:new();                     --协议返回
    gEvent = VEventMaganer:new();               --时间处理
    gArmatureList = {};                                    -- 骨骼文件列表
    run();
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
