local funkinlua = {}

local keyboardDoubleIndexes = {pressed = 0, press = 0, released = 0}
function funkinlua.keyboardJustDoublePressed(key)
     if keyboardJustPressed(key:upper()) then
          funkinlua.createTimer('keyboardDoublePressedTimer', 0.2, function() 
               keyboardDoubleIndexes.pressed = 0 
          end)
          keyboardDoubleIndexes.pressed = keyboardDoubleIndexes.pressed + 1
     end

     if keyboardDoubleIndexes.pressed >= 2 then
          keyboardDoubleIndexes.pressed = 0
          return true
     end
end

function funkinlua.keyboardJustDoublePress(key)
     if keyboardJustPress(key:upper()) then
          funkinlua.createTimer('keyboardDoublePressTimer', 0.2, function() 
               keyboardDoubleIndexes.press = 0 
          end)
          keyboardDoubleIndexes.press = keyboardDoubleIndexes.press + 1
     end

     if keyboardDoubleIndexes.press >= 2 then
          keyboardDoubleIndexes.press = 0
          return true
     end
end

function funkinlua.keyboardJustDoubleReleased(key)
     if keyboardJustReleased(key:upper()) then
          funkinlua.createTimer('keyboardDoubleReleasedTimer', 0.2, function() 
               keyboardDoubleIndexes.released = 0 
          end)
          keyboardDoubleIndexes.released = keyboardDoubleIndexes.released + 1
     end

     if keyboardDoubleIndexes.released >= 2 then
          keyboardDoubleIndexes.released = 0
          return true
     end
end

function funkinlua.keyboardJustConditionPressed(key, condition)
     if condition and keyboardJustPressed(key:upper()) then
          return true
     end
end

function funkinlua.keyboardJustConditionPress(key, condition)
     if condition and keyboardJustPress(key:upper()) then
          return true
     end
end

function funkinlua.keyboardJustConditionReleased(key, condition)
     if condition and keyboardReleased(key:upper()) then
          return true
     end
end

local callbackEvents = {}
function funkinlua.addCallbackEvents(callback, codeContent)
     if not _G[callback] then
          _G[callback] = function(...)
               for _,v in pairs(callbackEvents[callback]) do v(...) end
          end
     end

     if not callbackEvents[callback] then
          callbackEvents[callback] = {} 
     end 
     table.insert(callbackEvents[callback], #callbackEvents[callback] + 1, codeContent)
     return #callbackEvents[callback]
end

function funkinlua.removeCallbackEvents(callback, index)
     if not callbackEvents[callback] then
          error(string.format('%s isn\'t a valid event!')) 
     end
     callbackEvents[callback][index] = nil;
end

function funkinlua.hoverObject(object, camera)
     if luaSpriteExists(object) == false then return end
     return callMethodFromClass('flixel.FlxG', 'mouse.overlaps', {instanceArg(object), instanceArg(camera)})
end

function funkinlua.clickObject(object, camera)
     if luaSpriteExists(object) == false then return end
     local overlaps = callMethodFromClass('flixel.FlxG', 'mouse.overlaps', {instanceArg(object), instanceArg(camera)})
     return overlaps and mouseClicked('left')
end

function funkinlua.pressedObject(object, camera)
     if luaSpriteExists(object) == false then return end
     local overlaps = callMethodFromClass('flixel.FlxG', 'mouse.overlaps', {instanceArg(object), instanceArg(camera)})
     return overlaps and mousePressed('left')
end

function funkinlua.releasedObject(object, camera)
     if luaSpriteExists(object) == false then return end
     local overlaps = callMethodFromClass('flixel.FlxG', 'mouse.overlaps', {instanceArg(object), instanceArg(camera)})
     return overlaps and mouseReleased('left')
end

local timers = {}
function funkinlua.createTimer(tag, timer, callback)
     table.insert(timers, {tag, callback})
     runTimer(tag, timer)
end
     
function onTimerCompleted(tag, loops, loopsLeft)
     for _,v in pairs(timers) do
          if v[1] == tag then v[2]() end
     end
end

return funkinlua