-- 计时器表
local timers = {}
local globalId = 1

-- 创建一个计时器，返回id
function setInterval(cb, timer)
  local _ID = globalId
  local htimer = createTimer(getMainForm())
  timers[_ID] = htimer

  htimer.Interval = timer or 20
  htimer.OnTimer = cb
  globalId = globalId + 1
  return _ID
end

-- 停止计时器
function clearInterval(id)
  if(timers[id] ~= nil) then
    timers[id].destroy()
  end
end

-- 只执行一次的计时器
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

function clearTimeout(id)
  clearInterval(id)
end

