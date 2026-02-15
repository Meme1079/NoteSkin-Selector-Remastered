luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local hoverObject = funkinlua.hoverObject
local clickObject = funkinlua.clickObject

--- Toggle user-interface class for implementing its functionality.
---@class SkinToggleUI
local SkinToggleUI = {}
local SkinStatesGSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

--- Initializes the main and other attributes for the toggle UI.
---@param toggleTag string The corresponding tag name to implement its functionality.
---@param toggleSaveTag string
---@param toggleStatus? bool The toggle status state being on or off, on being default.
---@return SkinToggleUI
function SkinToggleUI:new(toggleTag, toggleSaveTag, toggleStatus)
     local self = setmetatable({}, {__index = self})
     self.toggleTag     = toggleTag
     self.toggleSaveTag = toggleSaveTag

     self.toggleStates  = {'inactive', 'active'}
     self.toggleHovered = false
     self.toggleClicked = false

     self.toggleCounter  = (toggleStatus == nil or toggleStatus == false) and 0 or 1
     self.toggleIndex    = 1
     self.toggleCurState = self.toggleStates[self.toggleIndex]

     self:__update_state()
     return self
end

function SkinToggleUI:create(x, y)
     makeAnimatedLuaSprite(self.toggleTag, 'ui/buttons/preview anim/previewAnimIcon_toggle', x, y)
     addAnimationByPrefix(self.toggleTag, 'active-static', 'active-static', 24, false)
     addAnimationByPrefix(self.toggleTag, 'active-hovered', 'active-hovered', 24, false)
     addAnimationByPrefix(self.toggleTag, 'active-focused', 'active-focused', 24, false)
     addAnimationByPrefix(self.toggleTag, 'inactive-static', 'inactive-static', 24, false)
     addAnimationByPrefix(self.toggleTag, 'inactive-hovered', 'inactive-hovered', 24, false)
     addAnimationByPrefix(self.toggleTag, 'inactive-focused', 'inactive-focused', 24, false)
     playAnim(self.toggleTag, 'inactive-static', true)
     scaleObject(self.toggleTag, 0.51, 0.562)
     setObjectCamera(self.toggleTag, 'camHUD')
     setProperty(F"{self.toggleTag}.antialiasing", false)
     addLuaSprite(self.toggleTag)
end

--- Update function for the toggle, implements its toggleable ability and other UI related stuff.
--- Additionally adds extra code for specific functions.
---@param extraCode? fun(): nil Adds extra code for extra functionability.
---@return nil
function SkinToggleUI:update(extraCode)
     self:__click()
     self:__hover()
     self:__cursor()

     if extraCode ~= nil then
          extraCode()
     end
end

--- Destroys the toggle functionality, that's it.
---@return nil
function SkinToggleUI:destroy()
     setmetatable(self, nil)
end

--- Sets the status of the toggle.
---@param value bool
---@return nil
function SkinToggleUI:setStatus(value)
     self.toggleCounter = value == true and 1 or 0
end

--- Gets the current status of the toggle.
---@return bool
function SkinToggleUI:getStatus()
     return self.toggleCurState == 'active' and true or false
end

--- Toggle main clicking functionality and animations.
---@private
---@return nil
function SkinToggleUI:__click()
     local previewSkinToggleClicked  = clickObject(self.toggleTag, 'camHUD')
     local previewSkinToggleReleased = mouseReleased('left')

     if previewSkinToggleClicked == true and self.toggleClicked == false then
          self:__update_state()

          playAnim(self.toggleTag, F"{self.toggleCurState}-focused", true)
          self.toggleClicked = true
     end
     if previewSkinToggleReleased == true and self.toggleClicked == true then
          self.toggleCounter = self.toggleCounter + 1
          self:__update_state()
          
          playSound('exitWindow', 0.8)
          playAnim(self.toggleTag, F"{self.toggleCurState}-states", true)
          self.toggleClicked = false
     end
end

--- Toggle main hovering functionality and animations.
---@private
---@return nil
function SkinToggleUI:__hover()
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

--- Toggle main cursor interactive functionality and animations.
---@private
---@return nil
function SkinToggleUI:__cursor()
     if self.toggleClicked == true then
          playAnim('mouseTexture', 'handClick', true)
     elseif self.toggleHovered == true then
          playAnim('mouseTexture', 'hand', true)
     end
end

--- Updates the current state, self-explanatory.
---@private
---@return nil
function SkinToggleUI:__update_state()
     self.toggleIndex    = self.toggleCounter % 2 == 0 and 1 or 2
     self.toggleCurState = self.toggleStates[self.toggleIndex]
     SkinStatesGSave:set(self.toggleSaveTag, 'SAVE', self.toggleCounter % 2 ~= 0)
end

return SkinToggleUI