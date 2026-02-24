luaDebugMode = true

local SkinSaves    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F    = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local math = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'

local SKIN_EDITOR_BG_WIDTH  = getPropertyFromClass('flixel.FlxG', 'width')
local SKIN_EDITOR_BG_HEIGHT = getPropertyFromClass('flixel.FlxG', 'height')
makeLuaSprite('skinEditorBG', '', 0, 0)
makeGraphic('skinEditorBG', SKIN_EDITOR_BG_WIDTH, SKIN_EDITOR_BG_HEIGHT, '242424')
setObjectCamera('skinEditorBG', 'camHUD')
setObjectOrder('skinEditorBG', 0)
addLuaSprite('skinEditorBG')

-- Shit DooDoo --

local theUniversalY = 430

makeLuaText('animationEditorConfirmTitle', ' Confirm', 0, 30, theUniversalY)
setTextFont('animationEditorConfirmTitle', 'tomo.otf')
setTextSize('animationEditorConfirmTitle', 23)
setTextBorder('animationEditorConfirmTitle', 3, '000000')
setObjectCamera('animationEditorConfirmTitle', 'camHUD')
addLuaText('animationEditorConfirmTitle')

makeLuaText('animationEditorPressedTitle', ' Pressed', 0, 30, (theUniversalY-1)*1.12)
setTextFont('animationEditorPressedTitle', 'tomo.otf')
setTextSize('animationEditorPressedTitle', 23)
setTextBorder('animationEditorPressedTitle', 3, '000000')
setObjectCamera('animationEditorPressedTitle', 'camHUD')
addLuaText('animationEditorPressedTitle')

makeLuaText('animationEditorColoredTitle', ' Colored', 0, 30, (theUniversalY-2)*1.24)
setTextFont('animationEditorColoredTitle', 'tomo.otf')
setTextSize('animationEditorColoredTitle', 23)
setTextBorder('animationEditorColoredTitle', 3, '000000')
setObjectCamera('animationEditorColoredTitle', 'camHUD')
addLuaText('animationEditorColoredTitle')

makeLuaText('animationEditorStrumsTitle', ' Strums', 0, 30, (theUniversalY-3)*1.36)
setTextFont('animationEditorStrumsTitle', 'tomo.otf')
setTextSize('animationEditorStrumsTitle', 23)
setTextBorder('animationEditorStrumsTitle', 3, '000000')
setObjectCamera('animationEditorStrumsTitle', 'camHUD')
addLuaText('animationEditorStrumsTitle')

for i = 1, 4 do
     local shit = 'animationEditorLabelX'..i
     makeLuaText(shit, ' X', 0, 155, (theUniversalY-(i-1)) * (((12*(i-1))/100)+1))
     setTextFont(shit, 'tomo.otf')
     setTextColor(shit, 'ff746c')
     setTextSize(shit, 23)
     setTextBorder(shit, 3, '000000')
     setObjectCamera(shit, 'camHUD')
     addLuaText(shit)

     local shit = 'animationEditorLabelY'..i
     makeLuaText(shit, ' Y', 0, 395, (theUniversalY-(i-1)) * (((12*(i-1))/100)+1))
     setTextFont(shit, 'tomo.otf')
     setTextColor(shit, '77dd77')
     setTextSize(shit, 23)
     setTextBorder(shit, 3, '000000')
     setObjectCamera(shit, 'camHUD')
     addLuaText(shit)
end


-- Input --

local inputTextX = 90 + 130
local bgTextX    = 90 + 120

makeLuaText('animationEditorConfirmInput', '1234567890', 0, inputTextX, theUniversalY)
setTextFont('animationEditorConfirmInput', 'tomo.otf')
setTextSize('animationEditorConfirmInput', 23)
setTextBorder('animationEditorConfirmInput', 0, '000000')
setObjectCamera('animationEditorConfirmInput', 'camHUD')
addLuaText('animationEditorConfirmInput')

makeLuaSprite('animationEditorConfirmBackground', 'ui/buttons/value_input3', bgTextX, getProperty('animationEditorConfirmInput.y') - 4)
scaleObject('animationEditorConfirmBackground', 0.7, 0.8)
setObjectCamera('animationEditorConfirmBackground', 'camHUD')
addLuaSprite('animationEditorConfirmBackground')

makeLuaText('animationEditorPressedInput', '1234567890', 0, inputTextX, (theUniversalY-1)*1.12)
setTextFont('animationEditorPressedInput', 'tomo.otf')
setTextSize('animationEditorPressedInput', 23)
setTextBorder('animationEditorPressedInput', 0, '000000')
setObjectCamera('animationEditorPressedInput', 'camHUD')
addLuaText('animationEditorPressedInput')

makeLuaSprite('animationEditorPressedBackground', 'ui/buttons/value_input3', bgTextX, getProperty('animationEditorPressedInput.y') - 4)
scaleObject('animationEditorPressedBackground', 0.7, 0.8)
setObjectCamera('animationEditorPressedBackground', 'camHUD')
addLuaSprite('animationEditorPressedBackground')

makeLuaText('animationEditorColoredInput', '1234567890', 0, inputTextX, (theUniversalY-2)*1.24)
setTextFont('animationEditorColoredInput', 'tomo.otf')
setTextSize('animationEditorColoredInput', 23)
setTextBorder('animationEditorColoredInput', 0, '000000')
setObjectCamera('animationEditorColoredInput', 'camHUD')
addLuaText('animationEditorColoredInput')

makeLuaSprite('animationEditorColoredBackground', 'ui/buttons/value_input3', bgTextX, getProperty('animationEditorColoredInput.y') - 4)
scaleObject('animationEditorColoredBackground', 0.7, 0.8)
setObjectCamera('animationEditorColoredBackground', 'camHUD')
addLuaSprite('animationEditorColoredBackground')

makeLuaText('animationEditorStrumsInput', '1234567890', 0, inputTextX, (theUniversalY-3)*1.36)
setTextFont('animationEditorStrumsInput', 'tomo.otf')
setTextSize('animationEditorStrumsInput', 23)
setTextBorder('animationEditorStrumsInput', 0, '000000')
setObjectCamera('animationEditorStrumsInput', 'camHUD')
addLuaText('animationEditorStrumsInput')

makeLuaSprite('animationEditorStrumsBackground', 'ui/buttons/value_input3', bgTextX, getProperty('animationEditorStrumsInput.y') - 4)
scaleObject('animationEditorStrumsBackground', 0.7, 0.8)
setObjectCamera('animationEditorStrumsBackground', 'camHUD')
addLuaSprite('animationEditorStrumsBackground')

-- Mouse Cursor --

local MOUSE_ANIMATION_OFFSETS = {
     IDLE     = {27.9, 27.6},
     HAND     = {40, 27.6},
     DISABLED = {38, 22.6},
}

makeAnimatedLuaSprite('mouseTexture', 'ui/cursor', getMouseX('camOther'), getMouseY('camOther'))
scaleObject('mouseTexture', 0.4, 0.4)
addAnimationByPrefix('mouseTexture', 'idle', 'idle0', 24, false)
addAnimationByPrefix('mouseTexture', 'idleClick', 'idleClick', 24, false)
addAnimationByPrefix('mouseTexture', 'hand', 'hand0', 24, false)
addAnimationByPrefix('mouseTexture', 'handClick', 'handClick', 24, false)
addAnimationByPrefix('mouseTexture', 'disabled', 'disabled0', 24, false)
addAnimationByPrefix('mouseTexture', 'disabledClick', 'disabledClick', 24, false)
addAnimationByPrefix('mouseTexture', 'waiting', 'waiting', 5, true)
addOffset('mouseTexture', 'idle', MOUSE_ANIMATION_OFFSETS.IDLE[1], MOUSE_ANIMATION_OFFSETS.IDLE[2])
addOffset('mouseTexture', 'idleClick', MOUSE_ANIMATION_OFFSETS.IDLE[1], MOUSE_ANIMATION_OFFSETS.IDLE[2])
addOffset('mouseTexture', 'hand', MOUSE_ANIMATION_OFFSETS.HAND[1], MOUSE_ANIMATION_OFFSETS.HAND[2])
addOffset('mouseTexture', 'handClick', MOUSE_ANIMATION_OFFSETS.HAND[1], MOUSE_ANIMATION_OFFSETS.HAND[2])
addOffset('mouseTexture', 'disabled', MOUSE_ANIMATION_OFFSETS.DISABLED[1], MOUSE_ANIMATION_OFFSETS.DISABLED[2])
addOffset('mouseTexture', 'disabledClick', MOUSE_ANIMATION_OFFSETS.DISABLED[1], MOUSE_ANIMATION_OFFSETS.DISABLED[2])
playAnim('mouseTexture', 'idle')
setObjectCamera('mouseTexture', 'camOther')
addLuaSprite('mouseTexture', true)
setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)

-- DooDoo Stuff --


local directions = {'left', 'down', 'up', 'right'}
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
end