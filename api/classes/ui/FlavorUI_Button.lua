luaDebugMode = true

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local hoverObject   = funkinlua.hoverObject
local clickObject   = funkinlua.clickObject
local pressedObject = funkinlua.pressedObject
local releaseObject = funkinlua.releasedObject

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
     self.state = state or 'static'

     self.inter_hovered = true
     self.inter_clicked = true
     return self
end

function FlavorUI_Button:update()
     local hoverMouse = hoverObject(self.tag, 'camHUD')
     local clickMouse = clickObject(self.tag, 'camHUD')
     local pressMouse = pressedObject(self.tag, 'camHUD')
     local releaseMouse = releaseObject(self.tag, 'camHUD')

     if self.state == 'disabled' then
          playAnim(self.tag, 'disabled')
          return
     end

     if hoverMouse == true and self.inter_hovered == true then
          playAnim(self.tag, 'hovered')
          self.state = 'hovered'
          self.inter_hovered = false
          return
     end
     if hoverMouse == false and self.inter_hovered == false then
          playAnim(self.tag, 'static')
          self.state = 'static'
          self.inter_hovered = true
          return
     end

     if (clickMouse or pressMouse) and self.inter_clicked == true then
          playAnim(self.tag, 'pressed')
          self.state = 'pressed'
          self.inter_clicked = false
          return
     end
     if (releaseMouse) and self.inter_clicked == false then
          playAnim(self.tag, 'hovered')
          self.state = 'hovered'
          self.inter_clicked = true
          return
     end
end

function FlavorUI_Button:set_state(value)
     self.state = value

     self.inter_hovered = hoverObject(self.tag, 'camHUD')
     self.inter_clicked = pressedObject(self.tag, 'camHUD')
     self:update()
end

function FlavorUI_Button:get_state()
end

return FlavorUI_Button