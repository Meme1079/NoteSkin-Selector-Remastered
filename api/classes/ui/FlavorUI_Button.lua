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

     self.deactivate = false

     self.__inter_hovered = true
     self.__inter_clicked = true
     return self
end

--- Updates the button.
---@return nil
function FlavorUI_Button:update()
     local hoverMouse   = hoverObject(self.tag, 'camHUD')
     local clickMouse   = clickObject(self.tag, 'camHUD')
     local pressMouse   = pressedObject(self.tag, 'camHUD')
     local releaseMouse = releaseObject(self.tag, 'camHUD')

     if self.deactivate == true then
          return
     end

     if self.variant == 'disabled' then
          playAnim(self.tag, 'disabled')
          self:onDisable(self)

          if clickMouse == true then
               playSound('cancel', 0.4)
               self:onClick(self)
          end
          return
     end

     if hoverMouse == true and self.__inter_hovered == true then
          playAnim(self.tag, 'hovered')
          self.variant = 'hovered'
          self.__inter_hovered = false

          self:onHover(self)
          return
     end
     if hoverMouse == false and self.__inter_hovered == false then
          playAnim(self.tag, 'static')
          self.variant = 'static'
          self.__inter_hovered = true
          return
     end

     if (clickMouse or pressMouse) and self.__inter_clicked == true then
          playAnim(self.tag, 'pressed')
          self.variant = 'pressed'
          self.__inter_clicked = false

          self:onClick(self)
          return
     end
     if (releaseMouse) and self.__inter_clicked == false then
          playAnim(self.tag, 'hovered')
          self.variant = 'hovered'
          self.__inter_clicked = true

          self:onRelease(self)
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

     self.__inter_hovered = hoverMouse
     self.__inter_clicked = pressMouse == false and true or pressMouse
     self:update()
end

--- Gets the current button variant.
---@return string
function FlavorUI_Button:get_variant()
     return self.variant
end

--- Deactivates the button's functionality completely.
---@return nil
function FlavorUI_Button:deactivation()
     self.deactivate = true

     playAnim(self.tag, 'static')
end

--- Reactivates the button's functionality.
---@return nil
function FlavorUI_Button:reactivation()
     local hoverMouse = hoverObject(self.tag, 'camHUD')
     local clickMouse = clickObject(self.tag, 'camHUD')
     local pressMouse = pressedObject(self.tag, 'camHUD')
     self.deactivate = false
    
     self.__inter_hovered = hoverMouse
     self.__inter_clicked = pressMouse == false and true or pressMouse
     self:update()
end

--- Triggered when hovering a button.
---@param this FlavorUI_Button Returns The whole class itself.
---@return nil
function FlavorUI_Button:onHover(this)
end

--- Triggered when clicking a button.
---@param this FlavorUI_Button Returns The whole class itself.
---@return nil
function FlavorUI_Button:onClick(this)
end

--- Triggered when the button is released.
---@param this FlavorUI_Button Returns The whole class itself.
---@return nil
function FlavorUI_Button:onRelease(this)
end

--- Triggered when the button is disabled.
---@param this FlavorUI_Button Returns The whole class itself.
---@return nil
function FlavorUI_Button:onDisable(this)
end

return FlavorUI_Button