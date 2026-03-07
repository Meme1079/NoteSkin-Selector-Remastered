luaDebugMode = true

local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local hoverObject   = funkinlua.hoverObject
local clickObject   = funkinlua.clickObject
local pressedObject = funkinlua.pressedObject

local MOUSE_IDLE_OFFSET     = {27.9, 27.6}
local MOUSE_HAND_OFFSET     = {40, 27.6}
local MOUSE_DISABLED_OFFSET = {38, 22.6}

local FlavorUI_Mouse = {}

function FlavorUI_Mouse:new(sprite, size, offsets)
     local self = setmetatable({}, {__index = self})
     self.sprite  = sprite
     self.size    = size
     self.offsets = offsets

     return self
end

function FlavorUI_Mouse:create()
     makeAnimatedLuaSprite('FlavorMouseUI', self.sprite, getMouseX('camOther'), getMouseY('camOther'))
     scaleObject('FlavorMouseUI', self.size, self.size)
     addAnimationByPrefix('FlavorMouseUI', 'idle', 'idle0', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'idleClick', 'idleClick', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'hand', 'hand0', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'handClick', 'handClick', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'disabled', 'disabled0', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'disabledClick', 'disabledClick', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'waiting', 'waiting', 5, true)
     addOffset('FlavorMouseUI', 'idle', MOUSE_IDLE_OFFSET[1], MOUSE_IDLE_OFFSET[2])
     addOffset('FlavorMouseUI', 'idleClick', MOUSE_IDLE_OFFSET[1], MOUSE_IDLE_OFFSET[2])
     addOffset('FlavorMouseUI', 'hand', MOUSE_HAND_OFFSET[1], MOUSE_HAND_OFFSET[2])
     addOffset('FlavorMouseUI', 'handClick', MOUSE_HAND_OFFSET[1], MOUSE_HAND_OFFSET[2])
     addOffset('FlavorMouseUI', 'disabled', MOUSE_DISABLED_OFFSET[1], MOUSE_DISABLED_OFFSET[2])
     addOffset('FlavorMouseUI', 'disabledClick', MOUSE_DISABLED_OFFSET[1], MOUSE_DISABLED_OFFSET[2])
     playAnim('FlavorMouseUI', 'idle')
     setObjectCamera('FlavorMouseUI', 'camOther')
     addLuaSprite('FlavorMouseUI', true)

     setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)
end

function FlavorUI_Mouse:update()
     if mouseClicked('left')  then playSound('clicks/clickDown', 0.5) end
     if mouseReleased('left') then playSound('clicks/clickUp', 0.5)   end
     setProperty('FlavorMouseUI.x', getMouseX('camHUD') + self.offsets[1])
     setProperty('FlavorMouseUI.y', getMouseY('camHUD') + self.offsets[2])

     if mouseClicked('left') or mousePressed('left') then 
          playAnim('FlavorMouseUI', 'idleClick')
     else
          playAnim('FlavorMouseUI', 'idle')
     end
end

return FlavorUI_Mouse