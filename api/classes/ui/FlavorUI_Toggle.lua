luaDebugMode = true

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local hoverObject   = funkinlua.hoverObject
local clickObject   = funkinlua.clickObject
local pressedObject = funkinlua.pressedObject

--- Doodoo fart
---@class FlavorUI_Toggle
local FlavorUI_Toggle = {}

---
---@param tag string
---@param status boolean
---@return FlavorUI_Toggle
function FlavorUI_Toggle:new(tag, status)
     local self = setmetatable({}, {__index = self})
     self.tag    = tag
     self.status = status

     self.cursorTexture = ''
     self.clicked = false
     self.hovered = false
     return self
end

local CREATE_EXECUTE = true
---
---@return nil
function FlavorUI_Toggle:update()
     if CREATE_EXECUTE == true then
          self:onCreate(self)
          CREATE_EXECUTE = false
     end

     self:_click()
     self:_hover()
     self:_cursor()
     self:onUpdate(self)
end

---
---@protected
---@return nil
function FlavorUI_Toggle:_click()
     if clickObject(self.tag, 'camHUD') then
          playAnim(self.tag, F"{self:status_state()}-focused", true)
          self.clicked = true
          self:onClick(self)
     end
     if hoverObject(self.tag, 'camHUD') == true and mouseReleased('left') then
          playAnim(self.tag, F"{self:status_state()}-static", true)
          self.clicked = false
          self.status = not self.status

          self:onPostClick(self)
     end
end

---
---@protected
---@return nil
function FlavorUI_Toggle:_hover()
     if hoverObject(self.tag, 'camHUD') == true and not pressedObject(self.tag, 'camHUD') then
          playAnim(self.tag, F"{self:status_state()}-hovered", true)
          self.hovered = true
          
          self:onHover(self)
     end
     if hoverObject(self.tag, 'camHUD') == false and not pressedObject(self.tag, 'camHUD') then
          playAnim(self.tag, F"{self:status_state()}-static", true)
          self.hovered = false
     end
end

---
---@protected
---@return nil
function FlavorUI_Toggle:_cursor()
     if self.cursorTexture == '' or self.cursorTexture == nil then
          return
     end
     
     if pressedObject(self.tag, 'camHUD') and self.clicked == true then
          playAnim(self.cursorTexture, 'handClick', true)
     end
     if hoverObject(self.tag, 'camHUD') == true  and not pressedObject(self.tag, 'camHUD') then
          playAnim(self.cursorTexture, 'hand', true)
     end
end

---
---@private
---@return string
function FlavorUI_Toggle:status_state()
     return self.status == true and 'active' or 'inactive'
end

---
---@return nil
function FlavorUI_Toggle:destroy()
     setmetatable(self, nil)
end

---
---@param this any
---@return nil
function FlavorUI_Toggle:onCreate(this)
end

---
---@param this any
---@return nil
function FlavorUI_Toggle:onClick(this)
end

---
---@param this any
---@return nil
function FlavorUI_Toggle:onPostClick(this)
end

---
---@param this any
---@return nil
function FlavorUI_Toggle:onHover(this)
end

---
---@param this any
---@return nil
function FlavorUI_Toggle:onUpdate(this)
end

return FlavorUI_Toggle