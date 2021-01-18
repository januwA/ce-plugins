-- 计时器表
local timers = {}
local globalId = 1

--[[
  创建一个循环计时器,timer毫秒为单位
  setInterval(cb:function, timer=20):number
]]
function setInterval(cb, timer)
    local _ID = globalId
    local htimer = createTimer(getMainForm())
    timers[_ID] = htimer

    htimer.Interval = timer or 20
    htimer.OnTimer = cb
    globalId = globalId + 1
    return _ID
end

--[[
  停止Interval计时器
  clearInterval(id:number):void
]]
function clearInterval(id) if (timers[id] ~= nil) then timers[id].destroy() end end

--[[
  只执行一次的计时器,timer毫秒为单位
  setTimeout(cb:function, timer=10):number
]]
function setTimeout(cb, timer)
    local _ID = globalId
    local htimer = createTimer(getMainForm())
    timers[_ID] = htimer

    htimer.Interval = timer or 20
    htimer.OnTimer = function(timer)
        cb(timer)
        clearTimeout(_ID)
    end
    globalId = globalId + 1
    return _ID
end

--[[
  停止Timeout计时器
  clearTimeout(id:number):void
]]
function clearTimeout(id) clearInterval(id) end

