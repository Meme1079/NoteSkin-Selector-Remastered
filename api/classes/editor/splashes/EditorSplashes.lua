local EditorNotes = require 'mods.NoteSkin Selector Remastered.api.classes.editor.notes.EditorNotes'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local math      = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local kbCondJustPressed = funkinlua.kbCondJustPressed
local kbCondPressed     = funkinlua.kbCondPressed
local clickObject       = funkinlua.clickObject

---@enum POSITION
local POSITION = {
     X = 1,
     Y = 2
}

local SKIN_DIRECTIONS = {'left', 'down', 'up', 'right'}
local SKIN_ANIMATIONS = {'note_splash1', 'note_splash2'}
local SKIN_COLORS     = {'purple', 'blue', 'green', 'red'}

---@class EditorSplashes
local EditorSplashes = EditorNotes:new()

function EditorSplashes:new(tag, sprite)
     local self = setmetatable({}, {__index = self})
     self.tag    = tag
     self.sprite = sprite
     self.mouse  = nil

     self._dir  = 1
     self._dirX = 0
     self._dirY = 0
     self._dirA = 1 -- amplifier

     self.__animation_name = 'NOTE_SPLASH1'
     self.__json  = {
          offsets = {
               NOTE_SPLASH1 = {{0,0}, {0,0}, {0,0}, {0,0}},
               NOTE_SPLASH2 = {{0,0}, {0,0}, {0,0}, {0,0}}
          },
          frames = {
               NOTE_SPLASH1 = 24,
               NOTE_SPLASH2 = 24
          },
          size = {
               0.65,
               0.65
          }
     }
     self.__json_offsets_dummy = {
          NOTE_SPLASH1 = {{0,0}, {0,0}, {0,0}, {0,0}},
          NOTE_SPLASH2 = {{0,0}, {0,0}, {0,0}, {0,0}}
     }
     return self
end


function EditorSplashes:create()
     for editorIndex = 1, 4 do
          local editorTag = self.tag..tostring(editorIndex)
          local editorX = 630 + (110*(editorIndex-1))
          local editorY = 150

          local editorDirection = SKIN_DIRECTIONS[editorIndex]
          local editorColors    = SKIN_COLORS[editorIndex]
          makeAnimatedLuaSprite(editorTag, self.sprite, editorX, editorY)
          scaleObject(editorTag, 0.65, 0.65)
          addAnimationByPrefix(editorTag, F"${editorDirection}_splash1", F"note splash ${editorColors} 1", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection}_splash2", F"note splash ${editorColors} 2", 24, true)
          playAnim(editorTag, F"${editorDirection}_splash1")
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
               self.__json.frames[skinAnimations] = getProperty(F"${editorTag}.animation.curAnim.frameRate")

               self.__json_offsets_dummy[skinAnimations][editorIndex][POSITION.X] = math.round(getProperty(F"${editorTag}.offset.x"), 2)
               self.__json_offsets_dummy[skinAnimations][editorIndex][POSITION.Y] = math.round(getProperty(F"${editorTag}.offset.y"), 2)
          end
     end
end

function EditorSplashes:texture(sprite)
     for editorIndex = 1, 4 do
          local editorTag = self.tag..tostring(editorIndex)
          local editorX = 630 + (110*(editorIndex-1))
          local editorY = 150

          local editorDirection = SKIN_DIRECTIONS[editorIndex]
          local editorColors    = SKIN_COLORS[editorIndex]
          makeAnimatedLuaSprite(editorTag, sprite, editorX, editorY)
          scaleObject(editorTag, 0.65, 0.65)
          addAnimationByPrefix(editorTag, F"${editorDirection}_splash1", F"note splash ${editorColors} 1", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection}_splash2", F"note splash ${editorColors} 2", 24, true)
          playAnim(editorTag, F"${editorDirection}_splash1")
          setObjectCamera(editorTag, 'camHUD')
          addLuaSprite(editorTag, true)
          self.mouse:add_element(editorTag)

          if self.__animation_name == 'NOTE_SPLASH1' then
               playAnim(editorTag, F"${editorDirection}_splash1", true)
          end
          if self.__animation_name == 'NOTE_SPLASH2' then
               playAnim(editorTag, F"${editorDirection}_splash2", true)
          end

          for skinAnimationIndex = 1, #SKIN_ANIMATIONS do
               local skinAnimations = SKIN_ANIMATIONS[skinAnimationIndex]:upper()
               self.__json.offsets[skinAnimations][editorIndex][POSITION.X] = math.round(getProperty(F"${editorTag}.offset.x"), 2)
               self.__json.offsets[skinAnimations][editorIndex][POSITION.Y] = math.round(getProperty(F"${editorTag}.offset.y"), 2)
               self.__json.frames[skinAnimations] = getProperty(F"${editorTag}.animation.curAnim.frameRate")

               self.__json_offsets_dummy[skinAnimations][editorIndex][POSITION.X] = math.round(getProperty(F"${editorTag}.offset.x"), 2)
               self.__json_offsets_dummy[skinAnimations][editorIndex][POSITION.Y] = math.round(getProperty(F"${editorTag}.offset.y"), 2)
          end
     end
end

function EditorSplashes:update_animations()
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
               setProperty(F"${editorTag}.animation.curAnim.frameRate", self.__json.frames[self.__animation_name])
          end
          if kbCondJustPressed('U', self:_get_focused()) then
               playAnim(editorTag, F"${editorDirection}_splash1", true)
          end
          if kbCondJustPressed('I', self:_get_focused()) then
               playAnim(editorTag, F"${editorDirection}_splash2", true)
          end

          if clickObject(editorTag, 'camHUD') == true then
               self._dir = tonumber( editorTag:match('%d$') )

               playSound('exitWindow')
               setProperty('skinEditorHighlight.x', editorX-5)
               setProperty('skinEditorHighlight.y', editorY-5)
          end
     end
end

function EditorSplashes:save() 
     local jsonDataOffsetsDummy = self.__json_offsets_dummy
     local jsonDataOffsets      = self.__json.offsets
     local jsonDataFrames       = self.__json.frames
     local jsonDataSize         = self.__json.size

     local offsets = {}
     for skinAnimationIndex = 1, #SKIN_ANIMATIONS do
          local skinAnimation = SKIN_ANIMATIONS[skinAnimationIndex]
          offsets[skinAnimation] = {}
          
          for strumIndex = 1, 4 do
               local offsetsDummy = jsonDataOffsetsDummy[skinAnimation:upper()][strumIndex]
               local offsetsData  = jsonDataOffsets[skinAnimation:upper()][strumIndex]

               local strumOffsetX = math.round(offsetsDummy[POSITION.X] - offsetsData[POSITION.X],  2)
               local strumOffsetY = math.round(offsetsData[POSITION.Y]  - offsetsDummy[POSITION.Y], 2)
               offsets[skinAnimation][strumIndex] = {strumOffsetX, strumOffsetY}
          end
     end

     local jsonNotesConst = getTextFromFile('json/editor/constant/splashes.json')
     local jsonNotesParse = json.parse(jsonNotesConst)
     local jsonNotesIndex = 0
     for names, values in pairs(jsonNotesParse.animations) do
          for _, anims in pairs(values) do
               jsonNotesIndex = jsonNotesIndex + 1
               anims.offsets = offsets[names][jsonNotesIndex]
          end
          jsonNotesIndex = 0
     end
     for names in pairs(jsonNotesParse.frames) do
          jsonNotesParse.frames[names] = jsonDataFrames[names:upper()]
     end
     jsonNotesParse.size = jsonDataSize

     return jsonNotesParse
end

return EditorSplashes
--[[ 

local editorColors    = SKIN_COLORS[editorIndex]
addAnimationByPrefix(editorTag, F"note splash ${editorColors} 1", F"note splash ${editorColors} 1", 24, true)
addAnimationByPrefix(editorTag, F"note splash ${editorColors} 2", F"note splash ${editorColors} 2", 24, true)

]]