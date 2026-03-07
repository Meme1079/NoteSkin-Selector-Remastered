local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'

local SKIN_DIRECTIONS = {'left', 'down', 'up', 'right'}
local SKIN_COLORS     = {'purple0', 'blue0', 'green0', 'red0'}

---@class EditorNotes
local EditorNotes = {}

---
---@param tag string
---@param sprite string
---@return SkinNotes
function EditorNotes:new(tag, sprite)
     local self = setmetatable({}, {__index = self})
     self.tag    = tag
     self.sprite = sprite

     return self
end


function EditorNotes:create(strum, x, y, size)
     local ddoodoo = self:set_tag(strum)

     makeAnimatedLuaSprite(ddoodoo, self.sprite, x, y)
     scaleObject(ddoodoo, size[1], size[2])
     addAnimationByPrefix(ddoodoo, F"{SKIN_DIRECTIONS[strum]}_confirm", F"{SKIN_DIRECTIONS[strum]} confirm", 24, false)
     addAnimationByPrefix(ddoodoo, F"{SKIN_DIRECTIONS[strum]}_pressed", F"{SKIN_DIRECTIONS[strum]} pressed", 24, false)
     addAnimationByPrefix(ddoodoo, F"{SKIN_DIRECTIONS[strum]}_colored", SKIN_COLORS[strum], 24, false)
     addAnimationByPrefix(ddoodoo, SKIN_DIRECTIONS[strum], F"arrow{SKIN_DIRECTIONS[strum]:upper()}", 24, false)
     playAnim(ddoodoo, SKIN_DIRECTIONS[strum], false)
     setObjectCamera(ddoodoo, 'camHUD')
     addLuaSprite(ddoodoo)
end

local dir = 1

local dx, dy = 0, 0 -- Directional input variables
local di = 1        -- Amplifier
function EditorNotes:update_movement()
     if keyboardPressed('D') then dx = dx + 1 end
     if keyboardPressed('A') then dx = dx - 1 end
     if keyboardPressed('S') then dy = dy + 1 end
     if keyboardPressed('W') then dy = dy - 1 end

     local giX = F"{self.tag}{dir}"

     local length = math.sqrt(dx^2 + dy^2)
     if length > 0 then
          dx = dx / length
          dy = dy / length

          if keyboardPressed('D') or keyboardPressed('A') and not (keyboardPressed('D') and keyboardPressed('A')) then
               setProperty(F"{giX}.x", getProperty(F"{giX}.x") + dx*di)
          end
          if keyboardPressed('S') or keyboardPressed('W') and not (keyboardPressed('S') and keyboardPressed('W')) then
               setProperty(F"{giX}.y", getProperty(F"{giX}.y") + dy*di)
          end
          setTextString('animationEditorStrumsInput', math.round(getProperty(F"{giX}.x"), 2))
     end

     if keyboardJustPressed('LBRACKET') and dir > 1 then
          dir = dir - 1
          setTextString('animationEditorStrumsInput', math.round(getProperty(F"{giX}.x"), 2))
     end
     if keyboardJustPressed('RBRACKET') and dir < 4 then
          dir = dir + 1
          setTextString('animationEditorStrumsInput', math.round(getProperty(F"{giX}.x"), 2))
     end
end

function EditorNotes:dih(value)
     di = value
end


function EditorNotes:set_sprite(sprite)
end

function EditorNotes:set_tag(strum)
     return self.tag..tostring(strum)
end

-- TODO:
-- inititating the noteskin to adjust the offsets for preview
-- update the noteskin's texture
-- update the noteskin's x and y positions, alongside its framerate
-- saving and converting into JSON
-- change noteskin animation type

return EditorNotes