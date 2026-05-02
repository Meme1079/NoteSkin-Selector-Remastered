local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local math      = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local json = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'

local kbCondJustPressed = funkinlua.kbCondJustPressed
local kbCondPressed     = funkinlua.kbCondPressed

---@enum POSITION
local POSITION = {
     X = 1,
     Y = 2
}

local SKIN_DIRECTIONS = {'left', 'down', 'up', 'right'}
local SKIN_ANIMATIONS = {'pressed', 'confirm', 'colored', 'strums'}
local SKIN_COLORS     = {'purple0', 'blue0', 'green0', 'red0'}

---@class EditorNotes
local EditorNotes = {}

function EditorNotes:new(tag, sprite)
     local self = setmetatable({}, {__index = self})
     self.tag    = tag
     self.sprite = sprite
     self.mouse = nil

     self._dir  = 1
     self._dirX = 0
     self._dirY = 0
     self._dirA = 1 -- amplifier

     self.__animation_name = 'STRUMS'
     self.__json  = {
          offsets = {
               CONFIRM = {{0,0}, {0,0}, {0,0}, {0,0}},
               PRESSED = {{0,0}, {0,0}, {0,0}, {0,0}},
               COLORED = {{0,0}, {0,0}, {0,0}, {0,0}},
               STRUMS  = {{0,0}, {0,0}, {0,0}, {0,0}}
          },
          frames = {
               CONFIRM = 24,
               PRESSED = 24,
               COLORED = 24,
               STRUMS  = 24
          },
          size = {
               0.65,
               0.65
          }
     }
     return self
end

function EditorNotes:create()
     for editorIndex = 1, 4 do
          local editorTag = self.tag..tostring(editorIndex)
          local editorX = 630 + (110*(editorIndex-1))
          local editorY = 150

          local editorDirection = SKIN_DIRECTIONS[editorIndex]
          local editorColors    = SKIN_COLORS[editorIndex]
          makeAnimatedLuaSprite(editorTag, self.sprite, editorX, editorY)
          scaleObject(editorTag, 0.65, 0.65)
          addAnimationByPrefix(editorTag, F"${editorDirection} pressed", F"${editorDirection} press", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection} confirm", F"${editorDirection} confirm", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection} colored", editorColors, 24, true)
          addAnimationByPrefix(editorTag, editorDirection, F"arrow${editorDirection:upper()}", 24, true)
          playAnim(editorTag, editorDirection)
          setObjectCamera(editorTag, 'camHUD')
          addLuaSprite(editorTag, true)
          self.mouse:add_element(editorTag)

          if editorIndex == 1 then
               setProperty('skinEditorHighlight.x', editorX-5)
               setProperty('skinEditorHighlight.y', editorY-5)
          end

          for skinAnimationIndex = 1, #SKIN_ANIMATIONS do
               local skinAnimations = SKIN_ANIMATIONS[skinAnimationIndex]:upper()
               self.__json.offsets[skinAnimations][editorIndex][POSITION.X] = math.round(getProperty(F"${editorTag}.offset.x"), 2)
               self.__json.offsets[skinAnimations][editorIndex][POSITION.Y] = math.round(getProperty(F"${editorTag}.offset.y"), 2)
          end
     end
end

function EditorNotes:update_movement()
     if kbCondPressed('D', self:_get_focused()) or kbCondPressed('RIGHT', self:_get_focused()) then
          self._dirX = self._dirX + 1
     end
     if kbCondPressed('A', self:_get_focused()) or kbCondPressed('LEFT', self:_get_focused()) then
          self._dirX = self._dirX - 1
     end
     if kbCondPressed('S', self:_get_focused()) or kbCondPressed('DOWN', self:_get_focused()) then
          self._dirY = self._dirY + 1
     end
     if kbCondPressed('W', self:_get_focused()) or kbCondPressed('UP', self:_get_focused()) then
          self._dirY = self._dirY - 1
     end

     if kbCondJustPressed('LBRACKET', self:_get_focused()) and self._dir > 1 then
          self._dir = self._dir - 1
          playSound('select')

          local editorX = 630 + (110*(self._dir-1))
          setProperty('skinEditorHighlight.x', editorX-5)
     end
     if kbCondJustPressed('RBRACKET', self:_get_focused()) and self._dir < 4 then
          self._dir = self._dir + 1
          playSound('select')

          local editorX = 630 + (110*(self._dir-1))
          setProperty('skinEditorHighlight.x', editorX-5)
     end

     local dirTag    = self:_get_tag()
     local dirLength = math.sqrt(self._dirX^2 + self._dirY^2)
     if dirLength > 0 then
          self._dirX = self._dirX / dirLength
          self._dirY = self._dirY / dirLength

          if kbCondPressed('A', self:_get_focused()) or kbCondPressed('D', self:_get_focused()) then
               self:set_offset_data_x(math.round(getProperty(F"${dirTag}.offset.x") - self._dirX*self._dirA, 0))
               setProperty(F"${dirTag}.offset.x", self:get_offset_data_x())
          end
          if kbCondPressed('W', self:_get_focused()) or kbCondPressed('S', self:_get_focused()) then
               self:set_offset_data_y(math.round(getProperty(F"${dirTag}.offset.y") - self._dirY*self._dirA, 0))
               setProperty(F"${dirTag}.offset.y", self:get_offset_data_y())
          end

          local stepSize = kbCondPressed('SHIFT', self:_get_focused()) == true and 1000 or 100
          if kbCondPressed('LEFT', self:_get_focused()) or kbCondPressed('RIGHT', self:_get_focused()) then
               self:set_offset_data_x(math.round(getProperty(F"${dirTag}.offset.x") - self._dirX*self._dirA/stepSize, 3))
               setProperty(F"${dirTag}.offset.x", self:get_offset_data_x())
          end
          if kbCondPressed('UP', self:_get_focused()) or kbCondPressed('DOWN', self:_get_focused()) then
               self:set_offset_data_y(math.round(getProperty(F"${dirTag}.offset.y") - self._dirY*self._dirA/stepSize, 3))
               setProperty(F"${dirTag}.offset.y", self:get_offset_data_y())
          end
     end
     setProperty(F"${dirTag}.offset.x", self:get_offset_data_x())
     setProperty(F"${dirTag}.offset.y", self:get_offset_data_y())
end

function EditorNotes:update_animations()
     for editorIndex = 1, 4 do
          local editorTag = self.tag..tostring(editorIndex)
          local editorX = 630 + (110*(editorIndex-1))
          local editorY = 150

          local editorDirection = SKIN_DIRECTIONS[editorIndex]
          local editorColors    = SKIN_COLORS[editorIndex]
          local function updateEditorNote(offsetName, offsetAnimation)
               self.__animation_name = offsetName:upper()

               playAnim(editorTag, offsetAnimation, true)
               setProperty(F"${editorTag}.offset.x", self.__json.offsets[self.__animation_name][editorIndex][POSITION.X])
               setProperty(F"${editorTag}.offset.y", self.__json.offsets[self.__animation_name][editorIndex][POSITION.Y])
          end
          if kbCondJustPressed('U', self:_get_focused()) then
               updateEditorNote('strums', F"${editorDirection}")
          end
          if kbCondJustPressed('I', self:_get_focused()) then
               updateEditorNote('pressed', F"${editorDirection} pressed")
          end
          if kbCondJustPressed('O', self:_get_focused()) then
               updateEditorNote('confirm', F"${editorDirection} confirm")
          end
          if kbCondJustPressed('P', self:_get_focused()) then
               updateEditorNote('colored', F"${editorDirection} colored")
          end

          if funkinlua.clickObject(editorTag, 'camHUD') == true then
               self._dir = tonumber( editorTag:match('%d$') )

               playSound('exitWindow')
               setProperty('skinEditorHighlight.x', editorX-5)
               setProperty('skinEditorHighlight.y', editorY-5)
          end
     end
end

function EditorNotes:update_scale()
     for editorIndex = 1, 4 do
          local editorTag = self.tag..tostring(editorIndex)
          setProperty(F"${editorTag}.scale.x", self:get_size_data_x())
          setProperty(F"${editorTag}.scale.y", self:get_size_data_y())
     end
end

function EditorNotes:texture(sprite)
     for editorIndex = 1, 4 do
          local editorTag = self.tag..tostring(editorIndex)

          local editorDirection = SKIN_DIRECTIONS[editorIndex]
          local editorColors    = SKIN_COLORS[editorIndex]
          loadFrames(editorTag, sprite)
          addAnimationByPrefix(editorTag, F"${editorDirection} pressed", F"${editorDirection} press", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection} confirm", F"${editorDirection} confirm", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection} colored", editorColors, 24, true)
          addAnimationByPrefix(editorTag, editorDirection, F"arrow${editorDirection:upper()}", 24, true)

          if self.__animation_name == 'STRUMS' then
               playAnim(editorTag, editorDirection, true)
          end
          if self.__animation_name == 'PRESSED' then
               playAnim(editorTag, F"${editorDirection} pressed", true)
          end
          if self.__animation_name == 'CONFIRM' then
               playAnim(editorTag, F"${editorDirection} confirm", true)
          end
          if self.__animation_name == 'COLORED' then
               playAnim(editorTag, F"${editorDirection} colored", true)
          end
     end
end

function EditorNotes:get_offset_data_x()
     return tonumber( self.__json.offsets[self.__animation_name][self._dir][POSITION.X] )
end

function EditorNotes:get_offset_data_y()
     return tonumber( self.__json.offsets[self.__animation_name][self._dir][POSITION.Y] )
end

function EditorNotes:set_offset_data_x(value)
     self.__json.offsets[self.__animation_name][self._dir][POSITION.X] = value
end

function EditorNotes:set_offset_data_y(value)
     self.__json.offsets[self.__animation_name][self._dir][POSITION.Y] = value
end

function EditorNotes:get_size_data_x()
     return tonumber( self.__json.size[POSITION.X] )
end

function EditorNotes:get_size_data_y()
     return tonumber( self.__json.size[POSITION.Y] )
end

function EditorNotes:set_size_data_x(value)
     self.__json.size[POSITION.X] = value
end

function EditorNotes:set_size_data_y(value)
     self.__json.size[POSITION.Y] = value
end

function EditorNotes:_get_tag()
     return F"${self.tag}${self._dir}"
end

function EditorNotes:_get_focused()
     return getPropertyFromClass('backend.ui.PsychUIInputText', 'focusOn') == nil
end

function EditorNotes:fart()
end

return EditorNotes