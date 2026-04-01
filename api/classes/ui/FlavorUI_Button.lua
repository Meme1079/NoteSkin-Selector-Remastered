luaDebugMode = true

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local hoverObject   = funkinlua.hoverObject
local clickObject   = funkinlua.clickObject
local pressedObject = funkinlua.pressedObject

--- Main button component class for FlavorUI.
---@class FlavorUI_Button
local FlavorUI_Button = {}

---
---@param tag
---@param state
---@return FlavorUI_Button
function FlavorUI_Button:new(tag, state)
     local self = setmetatable({}, {__index = self})
     self.tag   = tag
     self.state = state

     self.ddeedede = false
     return self
end

function FlavorUI_Button:update()
     local hoverMouse = hoverObject(self.tag, 'camHUD')
     local clickMouse = clickObject(self.tag, 'camHUD')
     local pressMouse = pressedObject(self.tag, 'camHUD')

     if hoverMouse then
          playAnim(self.tag, 'hovered')
     else
          playAnim(self.tag, 'static')
     end
     if clickMouse or pressMouse then
          playAnim(self.tag, 'pressed')
     end
end

return FlavorUI_Button