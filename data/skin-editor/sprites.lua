luaDebugMode = true

local SkinSaves    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'
local SkinToggleUI = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.ui.SkinToggleUI'

local SKIN_EDITOR_BG_WIDTH  = getPropertyFromClass('flixel.FlxG', 'width')
local SKIN_EDITOR_BG_HEIGHT = getPropertyFromClass('flixel.FlxG', 'height')
makeLuaSprite('skinEditorBG', '', 0, 0)
makeGraphic('skinEditorBG', SKIN_EDITOR_BG_WIDTH, SKIN_EDITOR_BG_HEIGHT, '242424')
setObjectCamera('skinEditorBG', 'camHUD')
setObjectOrder('skinEditorBG', 0)
addLuaSprite('skinEditorBG')

-- Shit DooDoo --

makeLuaText('animationEditorPosX', ' Animation', 0, 10, 360)
setTextFont('animationEditorPosX', 'sonic.ttf')
setTextSize('animationEditorPosX', 23)
setTextBorder('animationEditorPosX', 3, '000000')
setObjectCamera('animationEditorPosX', 'camHUD')
setProperty('animationEditorPosX.antialiasing', true)
addLuaText('animationEditorPosX')

makeLuaText('animationEditorConfirmTitle', ' Confirm', 0, 50, 410)
setTextFont('animationEditorConfirmTitle', 'sonic.ttf')
setTextSize('animationEditorConfirmTitle', 23)
setTextBorder('animationEditorConfirmTitle', 3, '000000')
setObjectCamera('animationEditorConfirmTitle', 'camHUD')
setProperty('animationEditorConfirmTitle.antialiasing', false)
addLuaText('animationEditorConfirmTitle')

makeLuaText('animationEditorPressedTitle', ' Pressed', 0, 50, (410-1)*1.12)
setTextFont('animationEditorPressedTitle', 'sonic.ttf')
setTextSize('animationEditorPressedTitle', 23)
setTextBorder('animationEditorPressedTitle', 3, '000000')
setObjectCamera('animationEditorPressedTitle', 'camHUD')
setProperty('animationEditorPressedTitle.antialiasing', false)
addLuaText('animationEditorPressedTitle')

makeLuaText('animationEditorColoredTitle', ' Colored', 0, 50, (410-2)*1.24)
setTextFont('animationEditorColoredTitle', 'sonic.ttf')
setTextSize('animationEditorColoredTitle', 23)
setTextBorder('animationEditorColoredTitle', 3, '000000')
setObjectCamera('animationEditorColoredTitle', 'camHUD')
setProperty('animationEditorColoredTitle.antialiasing', false)
addLuaText('animationEditorColoredTitle')

makeLuaText('animationEditorStrumsTitle', ' Strums', 0, 50, (410-3)*1.36)
setTextFont('animationEditorStrumsTitle', 'sonic.ttf')
setTextSize('animationEditorStrumsTitle', 23)
setTextBorder('animationEditorStrumsTitle', 3, '000000')
setObjectCamera('animationEditorStrumsTitle', 'camHUD')
setProperty('animationEditorStrumsTitle.antialiasing', false)
addLuaText('animationEditorStrumsTitle')

for i = 1, 4 do
     local shit = 'animationEditorLabelX'..i
     makeLuaText(shit, ' X', 0, 185, (410-(i-1)) * (((12*(i-1))/100)+1))
     setTextFont(shit, 'sonic.ttf')
     setTextColor(shit, 'ff746c')
     setTextSize(shit, 23)
     setTextBorder(shit, 3, '000000')
     setObjectCamera(shit, 'camHUD')
     setProperty(shit..'.antialiasing', true)
     addLuaText(shit)
end


-- Input --

local inputTextX = 110 + 130
local bgTextX    = 110 + 120

makeLuaText('animationEditorConfirmInput', '1234567890', 0, inputTextX, 410)
setTextFont('animationEditorConfirmInput', 'sonic.ttf')
setTextSize('animationEditorConfirmInput', 23)
setTextBorder('animationEditorConfirmInput', 0, '000000')
setObjectCamera('animationEditorConfirmInput', 'camHUD')
setProperty('animationEditorConfirmInput.antialiasing', false)
addLuaText('animationEditorConfirmInput')

makeLuaSprite('animationEditorConfirmBackground', 'ui/buttons/value_input2', bgTextX, 410-8)
scaleObject('animationEditorConfirmBackground', 0.7, 0.8)
setObjectCamera('animationEditorConfirmBackground', 'camHUD')
setProperty('animationEditorConfirmBackground.antialiasing', false)
addLuaSprite('animationEditorConfirmBackground')

makeLuaText('animationEditorPressedInput', '1234567890', 0, inputTextX, (410-1)*1.12)
setTextFont('animationEditorPressedInput', 'sonic.ttf')
setTextSize('animationEditorPressedInput', 23)
setTextBorder('animationEditorPressedInput', 0, '000000')
setObjectCamera('animationEditorPressedInput', 'camHUD')
setProperty('animationEditorPressedInput.antialiasing', false)
addLuaText('animationEditorPressedInput')

makeLuaSprite('animationEditorPressedBackground', 'ui/buttons/value_input2', bgTextX, (410-8)*1.12)
scaleObject('animationEditorPressedBackground', 0.7, 0.8)
setObjectCamera('animationEditorPressedBackground', 'camHUD')
setProperty('animationEditorPressedBackground.antialiasing', false)
addLuaSprite('animationEditorPressedBackground')

makeLuaText('animationEditorColoredInput', '1234567890', 0, inputTextX, (410-2)*1.24)
setTextFont('animationEditorColoredInput', 'sonic.ttf')
setTextSize('animationEditorColoredInput', 23)
setTextBorder('animationEditorColoredInput', 0, '000000')
setObjectCamera('animationEditorColoredInput', 'camHUD')
setProperty('animationEditorColoredInput.antialiasing', false)
addLuaText('animationEditorColoredInput')

makeLuaSprite('animationEditorColoredBackground', 'ui/buttons/value_input2', bgTextX, (410-8)*1.24)
scaleObject('animationEditorColoredBackground', 0.7, 0.8)
setObjectCamera('animationEditorColoredBackground', 'camHUD')
setProperty('animationEditorColoredBackground.antialiasing', false)
addLuaSprite('animationEditorColoredBackground')

makeLuaText('animationEditorStrumsInput', '1234567890', 0, inputTextX, (410-3)*1.36)
setTextFont('animationEditorStrumsInput', 'sonic.ttf')
setTextSize('animationEditorStrumsInput', 23)
setTextBorder('animationEditorStrumsInput', 0, '000000')
setObjectCamera('animationEditorStrumsInput', 'camHUD')
setProperty('animationEditorStrumsInput.antialiasing', false)
addLuaText('animationEditorStrumsInput')

makeLuaSprite('animationEditorStrumsBackground', 'ui/buttons/value_input2', bgTextX, (410-8)*1.36)
scaleObject('animationEditorStrumsBackground', 0.7, 0.8)
setObjectCamera('animationEditorStrumsBackground', 'camHUD')
setProperty('animationEditorStrumsBackground.antialiasing', false)
addLuaSprite('animationEditorStrumsBackground')

-- Mouse Cursor --

local MOUSE_ANIMATION_OFFSETS = {
     IDLE     = {27.9, 27.6},
     HAND     = {40, 27.6},
     DISABLED = {38, 22.6},
}

makeAnimatedLuaSprite('mouseTexture', 'ui/cursor', getMouseX('camOther'), getMouseY('camOther'))
scaleObject('mouseTexture', 0.4, 0.4)
addAnimationByPrefix('mouseTexture', 'idle', 'idle', 24, false)
addAnimationByPrefix('mouseTexture', 'idleClick', 'idleClick', 24, false)
addAnimationByPrefix('mouseTexture', 'hand', 'hand', 24, false)
addAnimationByPrefix('mouseTexture', 'handClick', 'handClick', 24, false)
addAnimationByPrefix('mouseTexture', 'disabled', 'disabled', 24, false)
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

local SkinEditorGSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')




makeAnimatedLuaSprite('notesTesta', 'noteSkins/NOTE_assets-Arrow Funk', 330, 100)
scaleObject('notesTesta', 0.65, 0.65)
addAnimationByPrefix('notesTesta', 'left_confirm', 'left confirm', 24, false)
addAnimationByPrefix('notesTesta', 'left_pressed', 'left press', 24, false)
addAnimationByPrefix('notesTesta', 'left_colored', 'purple0', 24, false)
addAnimationByPrefix('notesTesta', 'left', 'arrowLEFT', 24, false)
playAnim('notesTesta', 'left', false)
setObjectCamera('notesTesta', 'camHUD')
addLuaSprite('notesTesta')



local dx, dy = 0, 0 -- Directional input variables
local di = 1.15        -- Amplifier
function onUpdatePost(elapsed)
     if keyboardPressed('D') then dx = dx + 1 end
     if keyboardPressed('A') then dx = dx - 1 end
     if keyboardPressed('S') then dy = dy + 1 end
     if keyboardPressed('W') then dy = dy - 1 end

     local length = math.sqrt(dx^2 + dy^2)
     if length > 0 then
          dx = dx / length
          dy = dy / length

          if keyboardPressed('D') or keyboardPressed('A') and not (keyboardPressed('D') and keyboardPressed('A')) then
               setProperty('notesTesta.x', getProperty('notesTesta.x') + dx*di)
          end
          if keyboardPressed('S') or keyboardPressed('W') and not (keyboardPressed('S') and keyboardPressed('W')) then
               setProperty('notesTesta.y', getProperty('notesTesta.y') + dy*di)
          end
     end
end