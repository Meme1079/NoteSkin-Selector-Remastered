local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local math = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'

local SKIN_DIRECTIONS = {'left', 'down', 'up', 'right'}
local SKIN_COLORS     = {'purple0', 'blue0', 'green0', 'red0'}

local EditorNotes = {}

function EditorNotes:new(tag, sprite)
     local self = setmetatable({}, {__index = self})
     self.tag    = tag
     self.sprite = sprite

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

local dir = 1

local dx, dy = 0, 0 -- Directional input variables
local di = 1        -- Amplifier
function EditorNotes:update_movement()
     if keyboardPressed('D') then dx = dx + 1 end
     if keyboardPressed('A') then dx = dx - 1 end
     if keyboardPressed('S') then dy = dy + 1 end
     if keyboardPressed('W') then dy = dy - 1 end

     local giX = F"${self.tag}${dir}"

     local length = math.sqrt(dx^2 + dy^2)
     if length > 0 then
          dx = dx / length
          dy = dy / length

          if getProperty(F"${giX}.x") < 420 then
               setProperty(F"${giX}.x", 420)
          end
          if getProperty(F"${giX}.x") > 1174 then
               setProperty(F"${giX}.x", 1174)
          end
          if getProperty(F"${giX}.y") < 1 then
               setProperty(F"${giX}.y", 1)
          end
          if getProperty(F"${giX}.y") > 617 then
               setProperty(F"${giX}.y", 617)
          end

          if keyboardPressed('D') or keyboardPressed('A') and not (keyboardPressed('D') and keyboardPressed('A')) then
               setProperty(F"${giX}.x", getProperty(F"${giX}.x") + dx*di)
          end
          if keyboardPressed('S') or keyboardPressed('W') and not (keyboardPressed('S') and keyboardPressed('W')) then
               setProperty(F"${giX}.y", getProperty(F"${giX}.y") + dy*di)
          end

     


          --setTextString('skinSearchInput', math.round(getProperty(F"${giX}.x"), 2))

          --local do2odoo = math.round(getProperty(F"${giX}.x"), 2)
          --runHaxeCode(F" getVar('skinSearchInput').set_text('${do2odoo}'); ")
          --runHaxeCode(" getVar('skinSearchInput_placeholder').text = ''; ")
     end

     if keyboardJustPressed('LBRACKET') and dir > 1 then
          dir = dir - 1
          --setTextString('animationEditorStrumsInput', math.round(getProperty(F"${giX}.x"), 2))

          --local do2odoo = math.round(getProperty(F"${giX}.x"), 2)
          --runHaxeCode(F" getVar('skinSearchInput').set_text('${do2odoo}'); ")
     end
     if keyboardJustPressed('RBRACKET') and dir < 4 then
          dir = dir + 1
         -- setTextString('animationEditorStrumsInput', math.round(getProperty(F"${giX}.x"), 2))

          --local do2odoo = math.round(getProperty(F"${giX}.x"), 2)
          --runHaxeCode(F" getVar('skinSearchInput').set_text('${do2odoo}'); ")
     end
end

function EditorNotes:update()
end

return EditorNotes