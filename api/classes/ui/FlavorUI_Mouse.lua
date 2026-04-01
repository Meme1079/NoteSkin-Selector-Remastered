luaDebugMode = true

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local hoverObject   = funkinlua.hoverObject
local clickObject   = funkinlua.clickObject
local pressedObject = funkinlua.pressedObject

local MOUSE_VARIANT_ERROR = {
     __index    = function() error('Attempted to call an non-existing key') end,
     __newindex = function() error('Attempted to create an non-existing key, pls stop') end
}

local MOUSE_IDLE_OFFSET    = {27.9, 27.6}
local MOUSE_HAND_OFFSET    = {40, 27.6}
local MOUSE_DISABLE_OFFSET = {38, 22.6}

--- Main mouse component class for FlavorUI.
---@class FlavorUI_Mouse
local FlavorUI_Mouse = {}

--- Initializes the main attributes for the mouse.
---@param size number The size of the mouse.
---@param offsets number[] The offset positions of the mouse.
---@return FlavourUI_Mouse
function FlavorUI_Mouse:new(size, offsets)
     local self = setmetatable({}, {__index = self})
     self.size      = size
     self.offsets   = offsets

     local callbackLists = {onHover = function() end, onClick = function() end, onPress = function() end}
     self.elements  = setmetatable({ hand = table.new(0xff,0), disable = table.new(0xff,0)}, MOUSE_VARIANT_ERROR)
     self.callbacks = setmetatable({ hand = callbackLists, disable = callbackLists}, MOUSE_VARIANT_ERROR)
     return self
end

--- Creates the mouse object into the game.
---@return nil
function FlavorUI_Mouse:create()
     makeAnimatedLuaSprite('FlavorMouseUI', 'ui/flavorui/cursor', getMouseX('camOther'), getMouseY('camOther'))
     scaleObject('FlavorMouseUI', self.size, self.size)
     addAnimationByPrefix('FlavorMouseUI', 'idle', 'idle0', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'idleClick', 'idleClick', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'hand', 'hand0', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'handClick', 'handClick', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'disable', 'disabled0', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'disableClick', 'disabledClick', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'waiting', 'waiting', 5, true)
     addOffset('FlavorMouseUI', 'idle', MOUSE_IDLE_OFFSET[1], MOUSE_IDLE_OFFSET[2])
     addOffset('FlavorMouseUI', 'idleClick', MOUSE_IDLE_OFFSET[1], MOUSE_IDLE_OFFSET[2])
     addOffset('FlavorMouseUI', 'hand', MOUSE_HAND_OFFSET[1], MOUSE_HAND_OFFSET[2])
     addOffset('FlavorMouseUI', 'handClick', MOUSE_HAND_OFFSET[1], MOUSE_HAND_OFFSET[2])
     addOffset('FlavorMouseUI', 'disable', MOUSE_DISABLE_OFFSET[1], MOUSE_DISABLE_OFFSET[2])
     addOffset('FlavorMouseUI', 'disableClick', MOUSE_DISABLE_OFFSET[1], MOUSE_DISABLE_OFFSET[2])
     playAnim('FlavorMouseUI', 'idle')
     setObjectCamera('FlavorMouseUI', 'camOther')
     addLuaSprite('FlavorMouseUI', true)

     setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)
end

--- Updates the mouse.
---@return nil
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

     for variants, variant_elements in pairs(self.elements) do
          for _, elements in ipairs(variant_elements) do
               local hoverMouse = hoverObject(elements, 'camHUD')
               local clickMouse = clickObject(elements, 'camHUD')
               local pressMouse = pressedObject(elements, 'camHUD')

               if hoverMouse then
                    playAnim('FlavorMouseUI', variants)
                    self.callbacks[variants]['onHover']()
               end
               if clickMouse then
                    self.callbacks[variants]['onClick']()
               end
               if clickMouse or pressMouse then
                    playAnim('FlavorMouseUI', F"${variants}Click")
                    self.callbacks[variants]['onPress']()
               end
          end
     end
end

--- Adds an object element for the mouse to be interactible.
---@param variant string The specified mouse variant for the object element to interact to.
---@param elements... any The said element(s) to be interactible.
---@return nil
function FlavorUI_Mouse:add_element(variant, ...)
     local added = {...}
     for addIndex = 1, #added do
          table.insert(self.elements[variant], added[addIndex])
     end
end

--- Removes an object element to detach its interactibility.
---@param variant string The specified mouse variant that the object is attach to.
---@param elements... any The said element(s) to be remove.
---@return nil
function FlavorUI_Mouse:remove_element(variant, ...)
     local remove = {...}
     for removeIndex = 1, #remove do
          table.remove(self.elements[variant], table.find(self.elements[variant], remove[removeIndex]))
     end
end

--- Adds a custom callback functionality to the mouse, for extra customizability!!!
---@param variant string The specified mouse variant for the callback to interact to.
---@param callback string The specified callback to utilize with.
---@param code string The said code for the corresponding callback.
---@return nil
function FlavorUI_Mouse:callback_element(variants, callback, code)
     self.callbacks[variants][callback] = code
end

return FlavorUI_Mouse