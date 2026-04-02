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

--- Initializes the main attributes for the button.
---@param tag string The corresponding tag name given for this button.
---@param variant string The 
---@return FlavorUI_Button
function FlavorUI_Button:new(tag, variant)
     local self = setmetatable({}, {__index = self})
     self.tag     = tag
     self.variant = variant or 'static'

     self.inter_hovered = true
     self.inter_clicked = true
     return self
end

--- Updates the button.
---@return nil
function FlavorUI_Button:update()
     local hoverMouse = hoverObject(self.tag, 'camHUD')
     local clickMouse = clickObject(self.tag, 'camHUD')
     local pressMouse = pressedObject(self.tag, 'camHUD')
     local releaseMouse = releaseObject(self.tag, 'camHUD')

     if self.variant == 'disabled' then
          playAnim(self.tag, 'disabled')

          if clickMouse == true then
               playSound('cancel', 0.4)
          end
          return
     end

     if hoverMouse == true and self.inter_hovered == true then
          playAnim(self.tag, 'hovered')
          self.variant = 'hovered'
          self.inter_hovered = false

          self:onHover()
          return
     end
     if hoverMouse == false and self.inter_hovered == false then
          playAnim(self.tag, 'static')
          self.variant = 'static'
          self.inter_hovered = true
          return
     end

     if (clickMouse or pressMouse) and self.inter_clicked == true then
          playAnim(self.tag, 'pressed')
          self.variant = 'pressed'
          self.inter_clicked = false

          self:onClick()
          return
     end
     if (releaseMouse) and self.inter_clicked == false then
          playAnim(self.tag, 'hovered')
          self.variant = 'hovered'
          self.inter_clicked = true

          self:onRelease()
          return
     end
end

--- Sets the current button variant with a new one.
---@param variant string The new variant to assign.
---@return nil
function FlavorUI_Button:set_variant(variant)
     local hoverMouse = hoverObject(self.tag, 'camHUD')
     local clickMouse = clickObject(self.tag, 'camHUD')
     local pressMouse = pressedObject(self.tag, 'camHUD')
     self.variant = variant

     self.inter_hovered = hoverMouse
     self.inter_clicked = pressMouse == false and true or pressMouse
     self:update()
end

--- Gets the current button variant.
---@return string
function FlavorUI_Button:get_variant()
     return self.variant
end

--- Triggered when hovering a button.
---@return nil
function FlavorUI_Button:onHover()
end

--- Triggered when clicking a button.
---@return nil
function FlavorUI_Button:onClick()
end

---Triggered when the button is released.
---@return nil
function FlavorUI_Button:onRelease()
end

return FlavorUI_Button