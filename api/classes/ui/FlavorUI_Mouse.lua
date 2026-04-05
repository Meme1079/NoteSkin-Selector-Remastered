luaDebugMode = true

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local hoverObject    = funkinlua.hoverObject
local clickObject    = funkinlua.clickObject
local pressedObject  = funkinlua.pressedObject
local releasedObject = funkinlua.releasedObject

local MOUSE_CURSOR_OFFSET  = {27.9, 27.6}
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

     self.elements = table.new(0xff, 0)
     return self
end

--- Creates the mouse object into the game.
---@return nil
function FlavorUI_Mouse:create()
     makeAnimatedLuaSprite('FlavorMouseUI', 'ui/flavorui/cursor', getMouseX('camOther'), getMouseY('camOther'))
     scaleObject('FlavorMouseUI', self.size, self.size)
     addAnimationByPrefix('FlavorMouseUI', 'cursor', 'idle0', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'cursorClick', 'idleClick', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'hand', 'hand0', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'handClick', 'handClick', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'disable', 'disabled0', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'disableClick', 'disabledClick', 24, false)
     addAnimationByPrefix('FlavorMouseUI', 'waiting', 'waiting', 5, true)
     addOffset('FlavorMouseUI', 'cursor', MOUSE_CURSOR_OFFSET[1], MOUSE_CURSOR_OFFSET[2])
     addOffset('FlavorMouseUI', 'cursorClick', MOUSE_CURSOR_OFFSET[1], MOUSE_CURSOR_OFFSET[2])
     addOffset('FlavorMouseUI', 'hand', MOUSE_HAND_OFFSET[1], MOUSE_HAND_OFFSET[2])
     addOffset('FlavorMouseUI', 'handClick', MOUSE_HAND_OFFSET[1], MOUSE_HAND_OFFSET[2])
     addOffset('FlavorMouseUI', 'disable', MOUSE_DISABLE_OFFSET[1], MOUSE_DISABLE_OFFSET[2])
     addOffset('FlavorMouseUI', 'disableClick', MOUSE_DISABLE_OFFSET[1], MOUSE_DISABLE_OFFSET[2])
     playAnim('FlavorMouseUI', 'cursor')
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
          playAnim('FlavorMouseUI', 'cursorClick')
     else
          playAnim('FlavorMouseUI', 'cursor')
     end

     for element_names, element_metadata in pairs(self.elements) do
          local mouse_hovered  = hoverObject(element_names, 'camHUD')
          local mouse_clicked  = clickObject(element_names, 'camHUD')
          local mouse_pressed  = pressedObject(element_names, 'camHUD')
          local mouse_released = releasedObject(element_names, 'camHUD')
     
          if mouse_hovered then
               playAnim('FlavorMouseUI', element_metadata.cursor_type)
          end
          if mouse_clicked then

          end
          if mouse_clicked or mouse_pressed then
               playAnim('FlavorMouseUI', F"${element_metadata.cursor_type}Click")
          end
          if mouse_released then
          end
     end

     --[[ for variants, variant_elements in pairs(self.elements) do
          for _, elements in pairs(variant_elements) do
               local mouse_hovered = hoverObject(elements, 'camHUD')
               local mouse_clicked = clickObject(elements, 'camHUD')
               local mouse_pressed = pressedObject(elements, 'camHUD')

               if mouse_hovered then
                    playAnim('FlavorMouseUI', variants)
                    self.callbacks[variants]['onHover']()
               end
               if mouse_clicked then
                    self.callbacks[variants]['onClick']()
               end
               if mouse_clicked or mouse_pressed then
                    playAnim('FlavorMouseUI', F"${variants}Click")
                    self.callbacks[variants]['onPress']()
               end
          end
     end ]]
end

function FlavorUI_Mouse:reactivate()
end

function FlavorUI_Mouse:deactivate()
end


function FlavorUI_Mouse:add_element(element, cursor_type, cursor_active)
     local cursor_type   = cursor_type   == nil and 'hand' or cursor_type
     local cursor_active = cursor_active == nil and true   or cursor_active
     self.elements[element] = {cursor_type = cursor_type, cursor_active = cursor_active}
end

function FlavorUI_Mouse:remove_element(element)
     table.clear(self.elements[element])
end

--function 

return FlavorUI_Mouse