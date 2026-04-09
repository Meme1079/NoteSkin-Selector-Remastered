local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local math      = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local kbCondJustPressed = funkinlua.kbCondJustPressed
local kbCondPressed     = funkinlua.kbCondPressed

local SKIN_DIRECTIONS = {'left', 'down', 'up', 'right'}
local SKIN_COLORS     = {'purple0', 'blue0', 'green0', 'red0'}
local BORDERS         = {minX = 420, maxX = 1174, minY = 1, maxY = 617}

local EditorNotes = {}

function EditorNotes:new(tag, sprite)
     local self = setmetatable({}, {__index = self})
     self.tag    = tag
     self.sprite = sprite

     self._dir  = 1
     self._dirX = 0
     self._dirY = 0
     self._dirA = 1

     return self
end

function EditorNotes:create()
     for editorIndex = 1, 4 do
          local editorTag = self.tag..tostring(editorIndex)
          local editorX = 600 + (130*(editorIndex-1))
          local editorY = 150

          local editorDirection = SKIN_DIRECTIONS[editorIndex]
          local editorColors    = SKIN_COLORS[editorIndex]
          makeAnimatedLuaSprite(editorTag, self.sprite, editorX, editorY)
          scaleObject(editorTag, 0.65, 0.65)
          addAnimationByPrefix(editorTag, F"${editorDirection} pressed", F"${editorDirection} pressed", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection} confirm", F"${editorDirection} confirm", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection} colored", editorColors, 24, true)
          addAnimationByPrefix(editorTag, editorDirection, F"arrow${editorDirection:upper()}", 24, true)
          playAnim(editorTag, editorDirection)
          setObjectCamera(editorTag, 'camHUD')
          addLuaSprite(editorTag)
     end
end

function EditorNotes:update_movement()
     if kbCondPressed('D', self:_get_focused()) or kbCondPressed('RIGHT', self:_get_focused()) then self._dirX = self._dirX + 1 end
     if kbCondPressed('A', self:_get_focused()) or kbCondPressed('LEFT', self:_get_focused())  then self._dirX = self._dirX - 1 end
     if kbCondPressed('S', self:_get_focused()) or kbCondPressed('DOWN', self:_get_focused())  then self._dirY = self._dirY + 1 end
     if kbCondPressed('W', self:_get_focused()) or kbCondPressed('UP', self:_get_focused())    then self._dirY = self._dirY - 1 end

     local dirTag    = self:_get_tag()
     local dirLength = math.sqrt(self._dirX^2 + self._dirY^2)
     if dirLength > 0 then
          self._dirX, self._dirY = self._dirX / dirLength, self._dirY / dirLength

          if getProperty(F"${dirTag}.x") < BORDERS.minX then setProperty(F"${dirTag}.x", BORDERS.minX) end
          if getProperty(F"${dirTag}.x") > BORDERS.maxX then setProperty(F"${dirTag}.x", BORDERS.maxX) end
          if getProperty(F"${dirTag}.y") < BORDERS.minY then setProperty(F"${dirTag}.y", BORDERS.minY) end
          if getProperty(F"${dirTag}.y") > BORDERS.maxY then setProperty(F"${dirTag}.y", BORDERS.maxY) end

          local function directionMovement(mainKey, altKey)
               local mainKeyPressed = kbCondPressed(mainKey, self:_get_focused())
               local altkeyPressed  = kbCondPressed(altKey, self:_get_focused())
               return mainKeyPressed or altkeyPressed and not (mainKeyPressed and altkeyPressed)
          end
          if directionMovement('D', 'A') then
               setProperty(F"${dirTag}.x", math.round(getProperty(F"${dirTag}.x") + self._dirX*self._dirA, 2))
          end
          if directionMovement('S', 'W') then
               setProperty(F"${dirTag}.y", math.round(getProperty(F"${dirTag}.y") + self._dirY*self._dirA, 2))
          end
          if directionMovement('RIGHT', 'LEFT') then
               setProperty(F"${dirTag}.x", math.round(getProperty(F"${dirTag}.x") + self._dirX*self._dirA/6, 2))
          end
          if directionMovement('DOWN', 'UP') then
               setProperty(F"${dirTag}.y", math.round(getProperty(F"${dirTag}.y") + self._dirY*self._dirA/6, 2))
          end
     end

     if kbCondJustPressed('LBRACKET', self:_get_focused()) and self._dir > 1 then
          self._dir = self._dir - 1
     end
     if kbCondJustPressed('RBRACKET', self:_get_focused()) and self._dir < 4 then
          self._dir = self._dir + 1
     end
end

function EditorNotes:texture(sprite)
     for editorIndex = 1, 4 do
          local editorTag = self.tag..tostring(editorIndex)

          local editorDirection = SKIN_DIRECTIONS[editorIndex]
          local editorColors    = SKIN_COLORS[editorIndex]
          loadFrames(editorTag, sprite)
          addAnimationByPrefix(editorTag, F"${editorDirection} pressed", F"${editorDirection} pressed", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection} confirm", F"${editorDirection} confirm", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection} colored", editorColors, 24, true)
          addAnimationByPrefix(editorTag, editorDirection, F"arrow${editorDirection:upper()}", 24, true)
          playAnim(editorTag, editorDirection)
          setObjectCamera(editorTag, 'camHUD')
          addLuaSprite(editorTag)
     end
end

function EditorNotes:get_x()
     return getProperty(F"${self:_get_tag()}.x")
end

function EditorNotes:get_y()
     return getProperty(F"${self:_get_tag()}.y")
end

function EditorNotes:set_x(value)
     return setProperty(F"${self:_get_tag()}.x", value)
end

function EditorNotes:set_y(value)
     return setProperty(F"${self:_get_tag()}.y", value)
end

function EditorNotes:_get_tag()
     return F"${self.tag}${self._dir}"
end

function EditorNotes:_get_focused()
     return getPropertyFromClass('backend.ui.PsychUIInputText', 'focusOn') == nil
end

return EditorNotes