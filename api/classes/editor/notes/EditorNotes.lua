local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local math = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'

local SKIN_DIRECTIONS = {'left', 'down', 'up', 'right'}
local SKIN_COLORS     = {'purple0', 'blue0', 'green0', 'red0'}

local BORDERS = {minX = 420, maxX = 1174, minY = 1, maxY = 617}

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
          addAnimationByPrefix(editorTag, F"${editorDirection} pressed", F"${editorDirection} pressed", 24, false)
          addAnimationByPrefix(editorTag, F"${editorDirection} confirm", F"${editorDirection} confirm", 24, false)
          addAnimationByPrefix(editorTag, F"${editorDirection} colored", editorColors, 24, false)
          addAnimationByPrefix(editorTag, editorDirection, F"arrow${editorDirection:upper()}", 24, false)
          playAnim(editorTag, editorDirection, false)
          setObjectCamera(editorTag, 'camHUD')
          addLuaSprite(editorTag)
     end
end

function EditorNotes:update_movement()
     if keyboardPressed('D') then self._dirX = self._dirX + 1 end
     if keyboardPressed('A') then self._dirX = self._dirX - 1 end
     if keyboardPressed('S') then self._dirY = self._dirY + 1 end
     if keyboardPressed('W') then self._dirY = self._dirY - 1 end

     local giX = F"${self.tag}${self._dir}"

     local length = math.sqrt(self._dirX^2 + self._dirY^2)
     if length > 0 then
          self._dirX, self._dirY = self._dirX / length, self._dirY / length

          if getProperty(F"${giX}.x") < BORDERS.minX then setProperty(F"${giX}.x", BORDERS.minX) end
          if getProperty(F"${giX}.x") > BORDERS.maxX then setProperty(F"${giX}.x", BORDERS.maxX) end
          if getProperty(F"${giX}.y") < BORDERS.minY then setProperty(F"${giX}.y", BORDERS.minY) end
          if getProperty(F"${giX}.y") > BORDERS.maxY then setProperty(F"${giX}.y", BORDERS.maxY) end

          if keyboardPressed('D') or keyboardPressed('A') and not (keyboardPressed('D') and keyboardPressed('A')) then
               setProperty(F"${giX}.x", getProperty(F"${giX}.x") + self._dirX*self._dirA)
          end
          if keyboardPressed('S') or keyboardPressed('W') and not (keyboardPressed('S') and keyboardPressed('W')) then
               setProperty(F"${giX}.y", getProperty(F"${giX}.y") + self._dirY*self._dirA)
          end
     end

     if keyboardJustPressed('LBRACKET') and self._dir > 1 then
          self._dir = self._dir - 1
     end
     if keyboardJustPressed('RBRACKET') and self._dir < 4 then
          self._dir = self._dir + 1
     end
end

function EditorNotes:update()
end

function EditorNotes:doodoodX()
     local dir = dir
     local giX = F"${self.tag}${dir}"
     return math.round(getProperty(F"${giX}.x"), 2)

end

return EditorNotes