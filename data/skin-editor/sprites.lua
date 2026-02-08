local SKIN_EDITOR_BG_WIDTH  = getPropertyFromClass('flixel.FlxG', 'width')
local SKIN_EDITOR_BG_HEIGHT = getPropertyFromClass('flixel.FlxG', 'height')
makeLuaSprite('skinEditorBG', '', 0, 0)
makeGraphic('skinEditorBG', SKIN_EDITOR_BG_WIDTH, SKIN_EDITOR_BG_HEIGHT, '242424')
setObjectCamera('skinEditorBG', 'camHUD')
setObjectOrder('skinEditorBG', 0)
addLuaSprite('skinEditorBG')

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