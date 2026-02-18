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

makeLuaText('animation', ' Animation', 0, 10, 360)
setTextFont('animation', 'sonic.ttf')
setTextSize('animation', 23)
setTextBorder('animation', 3, '000000')
setObjectCamera('animation', 'camHUD')
setProperty('animation.antialiasing', true)
addLuaText('animation')

makeLuaText('confirm', ' Confirm', 0, 50, 410)
setTextFont('confirm', 'sonic.ttf')
setTextSize('confirm', 23)
setTextBorder('confirm', 3, '000000')
setObjectCamera('confirm', 'camHUD')
setProperty('confirm.antialiasing', false)
addLuaText('confirm')

makeLuaSprite('aoef', 'ui/buttons/value_input2', 200, 410-8)
scaleObject('aoef', 0.8, 0.8)
setObjectCamera('aoef', 'camHUD')
setProperty('aoef.antialiasing', false)
addLuaSprite('aoef')

makeLuaText('confirm1', '1234567890', 0, 50 + 160, 410)
setTextFont('confirm1', 'sonic.ttf')
setTextSize('confirm1', 23)
setTextBorder('confirm1', 0, '000000')
setObjectCamera('confirm1', 'camHUD')
setProperty('confirm1.antialiasing', false)
addLuaText('confirm1')

makeLuaText('pressed', ' Pressed', 0, 50, 410*1.08)
setTextFont('pressed', 'sonic.ttf')
setTextSize('pressed', 23)
setTextBorder('pressed', 3, '000000')
setObjectCamera('pressed', 'camHUD')
setProperty('pressed.antialiasing', false)
addLuaText('pressed')

makeLuaText('colored', ' Colored', 0, 50, 410*1.16)
setTextFont('colored', 'sonic.ttf')
setTextSize('colored', 23)
setTextBorder('colored', 3, '000000')
setObjectCamera('colored', 'camHUD')
setProperty('colored.antialiasing', false)
addLuaText('colored')

makeLuaText('strums', ' Strums', 0, 50, 410*1.24)
setTextFont('strums', 'sonic.ttf')
setTextSize('strums', 23)
setTextBorder('strums', 3, '000000')
setObjectCamera('strums', 'camHUD')
setProperty('strums.antialiasing', false)
addLuaText('strums')

-- FF6961

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