luaDebugMode = true

local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'

local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local hoverObject = funkinlua.hoverObject
local clickObject = funkinlua.clickObject

---@class SkinToggleUI
local SkinToggleUI = {}

function SkinToggleUI:new(toggleTag)
     local self = setmetatable({}, {__index = self})
     self.toggleTag = toggleTag

     self.toggleStates  = {'inactive', 'active'}
     self.toggleHovered = false
     self.toggleClicked = false

     self.toggleCounter  = 1
     self.toggleIndex    = 1
     self.toggleCurState = self.toggleStates[self.toggleIndex]
     return self
end

function SkinToggleUI:update()
     self:__click()
     self:__hover()
     self:__cursor()
end

function SkinToggleUI:status()
     return self.toggleCurState == 'active' and true or false
end

function SkinToggleUI:destroy()
     self = nil
     return self
end

function SkinToggleUI:__update_state()
     self.toggleIndex    = self.toggleCounter % 2 == 0 and 1 or 2
     self.toggleCurState = self.toggleStates[self.toggleIndex]
end

function SkinToggleUI:__click()
     local previewSkinToggleClicked  = clickObject(self.toggleTag, 'camHUD')
     local previewSkinToggleReleased = mouseReleased('left')

     if previewSkinToggleClicked == true and self.toggleClicked == false then
          playAnim(self.toggleTag, F"{self.toggleCurState}-focused", true)
          self.toggleClicked = true
     end
     if previewSkinToggleReleased == true and self.toggleClicked == true then
          self.toggleCounter = self.toggleCounter + 1
          self:__update_state()

          playAnim(self.toggleTag, F"{self.toggleCurState}-states", true)
          self.toggleClicked = false
     end
end

function SkinToggleUI:__hover()
     self:__update_state()
     if self.toggleClicked == true then
          return
     end

     if hoverObject(self.toggleTag, 'camHUD') == true then
          self.toggleHovered = true
     end
     if hoverObject(self.toggleTag, 'camHUD') == false then
          self.toggleHovered = false
     end

     if self.toggleHovered == true then
          playAnim(self.toggleTag, F"{self.toggleCurState}-hovered", true)
     end
     if self.toggleHovered == false then
          playAnim(self.toggleTag, F"{self.toggleCurState}-static", true)
     end
end

function SkinToggleUI:__cursor()
     if self.toggleClicked == true then
          playAnim('mouseTexture', 'handClick', true)
     elseif self.toggleHovered == true then
          playAnim('mouseTexture', 'hand', true)
     end
end

return SkinToggleUI