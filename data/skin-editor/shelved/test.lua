local FlavorUI_TextField = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_TextField'
local FlavorUI_Mouse     = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_Mouse'
local EditorNotes        = require 'mods.NoteSkin Selector Remastered.api.classes.editor.notes.EditorNotes'

local F    = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local math = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'


local fart = EditorNotes:new('fartdoodoo', 'noteSkins/NOTE_assets-DSides')
for strums = 1,4 do
     fart:create(strums, 410 + (105*(strums - 1)), 100, {0.65, 0.65})
end

local text = FlavorUI_TextField:new('hi', '', 90 + 130, ((430-3)*1.36)+3, 140, '')
text.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
text.size = 22
text.max_length = 10
text.placeholder_content = '000.00'

text:create()

local mouse = FlavorUI_Mouse:new('ui/cursor', 0.4, {-4,0})
mouse:create()


function onUpdatePost(elapsed)
     text:update()

     mouse:update()
end


--[[ local directions = {'left', 'down', 'up', 'right'}
local colors = {'purple0', 'blue0', 'green0', 'red0'}
for strumIndex = 1, 4 do
     local awesomeTag = F"notesTesta{strumIndex}"
     makeAnimatedLuaSprite(awesomeTag, 'noteSkins/NOTE_assets-DSides', 410 + (105*(strumIndex - 1)), 100)
     scaleObject(awesomeTag, 0.65, 0.65)
     addAnimationByPrefix(awesomeTag, F"{directions[strumIndex]}_confirm", F"{directions[strumIndex]} confirm", 24, false)
     addAnimationByPrefix(awesomeTag, F"{directions[strumIndex]}_pressed", F"{directions[strumIndex]} pressed", 24, false)
     addAnimationByPrefix(awesomeTag, F"{directions[strumIndex]}_colored", colors[stumIndex], 24, false)
     addAnimationByPrefix(awesomeTag, directions[strumIndex], F"arrow{directions[strumIndex]:upper()}", 24, false)
     playAnim(awesomeTag, directions[strumIndex], false)
     setObjectCamera(awesomeTag, 'camHUD')
     addLuaSprite(awesomeTag)
end

local dir = 1

local dx, dy = 0, 0 -- Directional input variables
local di = 1        -- Amplifier
function onUpdatePost(elapsed)
     if keyboardPressed('D') then dx = dx + 1 end
     if keyboardPressed('A') then dx = dx - 1 end
     if keyboardPressed('S') then dy = dy + 1 end
     if keyboardPressed('W') then dy = dy - 1 end

     local giX = F"notesTesta{dir}"

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
end ]]



--[[ local FlavorUI_Toggle = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_Toggle'
local SkinSaves       = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local hoverObject   = funkinlua.hoverObject
local clickObject   = funkinlua.clickObject
local pressedObject = funkinlua.pressedObject

local NoteSkinSelector = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

makeAnimatedLuaSprite('test', 'ui/buttons/preview anim/previewAnimIcon_toggle', 100, 100)
addAnimationByPrefix('test', 'active-static', 'active-static', 24, false)
addAnimationByPrefix('test', 'active-hovered', 'active-hovered', 24, false)
addAnimationByPrefix('test', 'active-focused', 'active-focused', 24, false)
addAnimationByPrefix('test', 'inactive-static', 'inactive-static', 24, false)
addAnimationByPrefix('test', 'inactive-hovered', 'inactive-hovered', 24, false)
addAnimationByPrefix('test', 'inactive-focused', 'inactive-focused', 24, false)
playAnim('test', 'inactive-static', true)
scaleObject('test', 0.51, 0.562)
setObjectCamera('test', 'camHUD')
setProperty(F"test.antialiasing", false)
addLuaSprite('test')

local doodoo = FlavorUI_Toggle:new('test', NoteSkinSelector:get('DOODOO', 'SAVE', false))
doodoo.cursorTexture = 'mouseTexture'
doodoo.onPostClick = function(this)
     playSound('exitWindow', 0.8)
     NoteSkinSelector:set('DOODOO', 'SAVE', this.status)
end

function onUpdatePost(elapsed)
     doodoo:update()
end
 ]]