luaDebugMode = true

local SkinSaves    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'
local SkinStates   = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinStates'
local SkinNotes    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotes'
local SkinSplashes = require 'mods.NoteSkin Selector Remastered.api.classes.skins.splashes.SkinSplashes'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local ease      = require 'mods.NoteSkin Selector Remastered.api.libraries.ease.ease'

-- Prechaching --

precacheImage('menuDesat')
precacheImage('checkboxanim')
precacheImage('ui/buttons/slider_button')
precacheImage('ui/buttons/display_button')
precacheImage('ui/buttons/preview anim/previewAnimIcon_button')
precacheImage('ui/buttons/preview anim/previewAnimInfoDirection_button')
precacheImage('ui/buttons/preview anim/previewAnimSelection_button')
precacheImage('ui/display_selected')
precacheImage('ui/cursor')

-- Background --

makeLuaSprite('skinSelectorBG', 'menuDesat', 0, 0)
setObjectCamera('skinSelectorBG', 'camHUD')
setObjectOrder('skinSelectorBG', 0)
setProperty('skinSelectorBG.color', 0x5220bd)
addLuaSprite('skinSelectorBG')

-- Page Scrollbar --

makeAnimatedLuaSprite('pageScrollbarThumb', 'ui/buttons/slider_button', 600, 127) -- min: 127; max: 643
addAnimationByPrefix('pageScrollbarThumb', 'static', 'slider_button-static')
addAnimationByPrefix('pageScrollbarThumb', 'pressed', 'slider_button-pressed')
addAnimationByPrefix('pageScrollbarThumb', 'unscrollable', 'slider_button-unscrollable')
playAnim('pageScrollbarThumb', 'static')
scaleObject('pageScrollbarThumb', 0.6, 0.6)
setObjectCamera('pageScrollbarThumb', 'camHUD')
setProperty('pageScrollbarThumb.antialiasing', false)
addLuaSprite('pageScrollbarThumb')

local PAGE_SCROLLBAR_THUMB_WIDTH = getProperty('pageScrollbarThumb.width') / 2.7
makeLuaSprite('pageScrollbarTrack', nil, 600 + PAGE_SCROLLBAR_THUMB_WIDTH, 130)
makeGraphic('pageScrollbarTrack', 12, 570, '1d1e1f')
setObjectOrder('pageScrollbarTrack', getObjectOrder('pageScrollbarThumb'))
setObjectCamera('pageScrollbarTrack', 'camHUD')
setProperty('pageScrollbarTrack.antialiasing', false)
addLuaSprite('pageScrollbarTrack', true)

-- Selection Animation Buttons --

local PREVIEW_SKIN_BUTTON_SPRITE    = 'ui/buttons/preview anim/previewAnimIcon_button'
local PREVIEW_SKIN_TOGGLE_SPRITE    = 'ui/buttons/preview anim/previewAnimIcon_toggle'
local PREVIEW_SKIN_ICON_SPRITE      = 'ui/buttons/preview anim/previewAnimInfoDirection_button'
local PREVIEW_SKIN_SELECTION_SPRITE = 'ui/buttons/preview anim/previewAnimSelection_button'

makeLuaText('previewSkinTitle', 'Preview Animations', 0, 787, 470)
setTextFont('previewSkinTitle', 'FridayNight.ttf')
setTextSize('previewSkinTitle', 18)
setTextBorder('previewSkinTitle', 3, '000000')
setObjectCamera('previewSkinTitle', 'camHUD')
setProperty('previewSkinTitle.antialiasing', false)
addLuaText('previewSkinTitle')

makeAnimatedLuaSprite('previewSkinButtonLeft', PREVIEW_SKIN_BUTTON_SPRITE, 787, 500)
addAnimationByPrefix('previewSkinButtonLeft', 'static', 'skinanim-static', 24, false)
addAnimationByPrefix('previewSkinButtonLeft', 'hovered-blocked', 'skinanim-hovered-blocked', 24, false)
addAnimationByPrefix('previewSkinButtonLeft', 'hovered-static', 'skinanim-hovered-static', 24, false)
addAnimationByPrefix('previewSkinButtonLeft', 'hovered-pressed', 'skinanim-hovered-pressed', 24, false)
playAnim('previewSkinButtonLeft', 'static', true)
scaleObject('previewSkinButtonLeft', 0.5, 0.5)
setObjectCamera('previewSkinButtonLeft', 'camHUD')
setProperty('previewSkinButtonLeft.antialiasing', false)
addLuaSprite('previewSkinButtonLeft')

makeAnimatedLuaSprite('preivewSkinButtonIconLeft', PREVIEW_SKIN_ICON_SPRITE, 787+(150/11), 500+(25/2))
addAnimationByPrefix('preivewSkinButtonIconLeft', 'none', 'icons-none', 24, false)
addAnimationByPrefix('preivewSkinButtonIconLeft', 'left', 'icons-left', 24, false)
addAnimationByPrefix('preivewSkinButtonIconLeft', 'right', 'icons-right', 24, false)
playAnim('preivewSkinButtonIconLeft', 'none', true)
scaleObject('preivewSkinButtonIconLeft', 0.5, 0.5)
setObjectCamera('preivewSkinButtonIconLeft', 'camHUD')
setProperty('preivewSkinButtonIconLeft.antialiasing', false)
addLuaSprite('preivewSkinButtonIconLeft')

makeAnimatedLuaSprite('previewSkinButtonRight', PREVIEW_SKIN_BUTTON_SPRITE, 859, 500)
addAnimationByPrefix('previewSkinButtonRight', 'static', 'skinanim-static', 24, false)
addAnimationByPrefix('previewSkinButtonRight', 'hovered-blocked', 'skinanim-hovered-blocked', 24, false)
addAnimationByPrefix('previewSkinButtonRight', 'hovered-static', 'skinanim-hovered-static', 24, false)
addAnimationByPrefix('previewSkinButtonRight', 'hovered-pressed', 'skinanim-hovered-pressed', 24, false)
playAnim('previewSkinButtonRight', 'static', true)
scaleObject('previewSkinButtonRight', 0.5, 0.5)
setObjectCamera('previewSkinButtonRight', 'camHUD')
setProperty('previewSkinButtonRight.antialiasing', false)
addLuaSprite('previewSkinButtonRight')

makeAnimatedLuaSprite('previewSkinButtonIconRight', PREVIEW_SKIN_ICON_SPRITE, 859+(150/11), 500+(25/2))
addAnimationByPrefix('previewSkinButtonIconRight', 'none', 'icons-none', 24, false)
addAnimationByPrefix('previewSkinButtonIconRight', 'left', 'icons-left', 24, false)
addAnimationByPrefix('previewSkinButtonIconRight', 'right', 'icons-right', 24, false)
playAnim('previewSkinButtonIconRight', 'right', true)
scaleObject('previewSkinButtonIconRight', 0.5, 0.5)
setObjectCamera('previewSkinButtonIconRight', 'camHUD')
setProperty('previewSkinButtonIconRight.antialiasing', false)
addLuaSprite('previewSkinButtonIconRight')

makeAnimatedLuaSprite('previewSkinButtonSelection', PREVIEW_SKIN_SELECTION_SPRITE, 967, 500)
addAnimationByPrefix('previewSkinButtonSelection', 'static', 'selection-static', 24, false)
addAnimationByPrefix('previewSkinButtonSelection', 'pressed', 'selection-pressed', 24, false)
addAnimationByPrefix('previewSkinButtonSelection', 'hovered-static', 'selection-hovered-static', 24, false)
addAnimationByPrefix('previewSkinButtonSelection', 'hovered-pressed', 'selection-hovered-pressed', 24, false)
playAnim('previewSkinButtonSelection', 'static', true)
scaleObject('previewSkinButtonSelection', 0.5, 0.5)
setObjectCamera('previewSkinButtonSelection', 'camHUD')
setProperty('previewSkinButtonSelection.antialiasing', false)
addLuaSprite('previewSkinButtonSelection')

makeLuaText('previewSkinButtonSelectionText', 'Confirm', 0, 982.6, 515)
setTextFont('previewSkinButtonSelectionText', 'sonic.ttf')
setTextSize('previewSkinButtonSelectionText', 25)
setObjectCamera('previewSkinButtonSelectionText', 'camHUD')
setProperty('previewSkinButtonSelectionText.antialiasing', false)
addLuaText('previewSkinButtonSelectionText')

makeAnimatedLuaSprite('previewSkinToggleAnims', PREVIEW_SKIN_TOGGLE_SPRITE, 783, 600)
addAnimationByPrefix('previewSkinToggleAnims', 'active-static', 'active-static', 24, false)
addAnimationByPrefix('previewSkinToggleAnims', 'active-hovered', 'active-hovered', 24, false)
addAnimationByPrefix('previewSkinToggleAnims', 'active-focused', 'active-focused', 24, false)
addAnimationByPrefix('previewSkinToggleAnims', 'inactive-static', 'inactive-static', 24, false)
addAnimationByPrefix('previewSkinToggleAnims', 'inactive-hovered', 'inactive-hovered', 24, false)
addAnimationByPrefix('previewSkinToggleAnims', 'inactive-focused', 'inactive-focused', 24, false)
playAnim('previewSkinToggleAnims', 'inactive-static', true)
scaleObject('previewSkinToggleAnims', 0.51, 0.55)
setObjectCamera('previewSkinToggleAnims', 'camHUD')
setProperty('previewSkinToggleAnims.antialiasing', false)
addLuaSprite('previewSkinToggleAnims')

makeLuaText('previewSkinToggleAnimDescText', 'Enable Preview Animations', 0, 902.6, 515 + 105)
setTextFont('previewSkinToggleAnimDescText', 'sonic.ttf')
setTextSize('previewSkinToggleAnimDescText', 20)
setObjectCamera('previewSkinToggleAnimDescText', 'camHUD')
setProperty('previewSkinToggleAnimDescText.antialiasing', false)
addLuaText('previewSkinToggleAnimDescText')

-- General Infos --

makeLuaText('skinStatePreviewState', 'Notes', 0, 20, 13)
setTextFont('skinStatePreviewState', 'sonic.ttf')
setTextSize('skinStatePreviewState', 35)
setTextBorder('skinStatePreviewState', 3, '000000')
setObjectCamera('skinStatePreviewState', 'camHUD')
setProperty('skinStatePreviewState.antialiasing', false)
addLuaText('skinStatePreviewState')

makeLuaText('skinStatePreviewPage', ' Page 001 / 100', 0, 217.964756532, 17)
setTextFont('skinStatePreviewPage', 'sonic.ttf')
setTextSize('skinStatePreviewPage', 30)
setTextBorder('skinStatePreviewPage', 3, '000000')
setObjectCamera('skinStatePreviewPage', 'camHUD')
setProperty('skinStatePreviewPage.antialiasing', false)
addLuaText('skinStatePreviewPage')

makeLuaText('skinStatePreviewName', 'Funkin', 500, 748, 70)
setTextFont('skinStatePreviewName', 'sonic.ttf')
setTextSize('skinStatePreviewName', 50)
setTextBorder('skinStatePreviewName', 4, '000000')
setTextAlignment('skinStatePreviewName', 'center')
setObjectCamera('skinStatePreviewName', 'camHUD')
setProperty('skinStatePreviewName.antialiasing', false)
addLuaText('skinStatePreviewName')

makeLuaText('skinStatePreviewVersion', 'Ver 3.0.0', 0, 1195, 5)
setTextFont('skinStatePreviewVersion', 'sonic.ttf')
setTextSize('skinStatePreviewVersion', 20)
setTextColor('skinStatePreviewVersion', 'fccf03') -- fccf03 03fce7
setTextAlignment('skinStatePreviewVersion', 'right')
setObjectCamera('skinStatePreviewVersion', 'camHUD')
setProperty('skinStatePreviewVersion.antialiasing', false)
addLuaText('skinStatePreviewVersion')

local function calculateKeybindOrderPos()
     local results = table.new(4,0)
     local offsets = {0,-4,-3,0}

     local POSITION  = 830
     local INTERVAL  = 105
     for keybindIndex = 1, 4 do
          local INCREMENT = keybindIndex - 1
          table.insert(results, POSITION + (INTERVAL*INCREMENT) + offsets[keybindIndex])
     end
     return results
end

local keybindOrderPos = calculateKeybindOrderPos()
for keybindIndex = 1, #keybindOrderPos do
     local skinStateKeybindsTag = F"skinStateKeybinds-{keybindIndex}"
     local skinStateKeybindsPositionX = keybindOrderPos[keybindIndex]
     local skinStateKeybindsPositionY = 250

     makeLuaText(skinStateKeybindsTag, tostring(getKeyBinds(keybindIndex)), nil, skinStateKeybindsPositionX, skinStateKeybindsPositionY)
     setTextFont(skinStateKeybindsTag, 'FridayNight.ttf')
     setTextSize(skinStateKeybindsTag, 35)
     setTextBorder(skinStateKeybindsTag, 4, '000000')
     setObjectCamera(skinStateKeybindsTag, 'camHUD')
     addLuaText(skinStateKeybindsTag)
end

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

makeLuaText('mouseSkinToolTip', '', 0, 0, 0)
setTextFont('mouseSkinToolTip', 'sonic.ttf')
setTextSize('mouseSkinToolTip', 25)
setObjectCamera('mouseSkinToolTip', 'camOther')
addLuaText('mouseSkinToolTip', true)

-- Color Gradient Background --

local MAX_RGB_VALUE   = 255
local MAX_HSL_VALUE   = 360
local MAX_SAT_VALUE   = 100
local MAX_LIGHT_VALUE = 100
local function HUE_RGBConv(primary, secondary, tertiary)
     if tertiary < 0 then tertiary = tertiary + 1 end
     if tertiary > 1 then tertiary = tertiary - 1 end
     if tertiary < 1 / 6 then return primary + (secondary - primary) * 6 * tertiary end
     if tertiary < 1 / 2 then return secondary end
     if tertiary < 2 / 3 then return primary + (secondary - primary) * (2 / 3 - tertiary) * 6 end
     return primary;
end
local function HSL_RGBConv(hue, sat, light)
     local hue, sat, light = hue / MAX_HSL_VALUE, sat / MAX_SAT_VALUE, light / MAX_LIGHT_VALUE
     local red, green, blue = light, light, light; -- achromatic
     if sat ~= 0 then
          local q = light < 0.5 and light * (1 + sat) or light + sat - light * sat;
          local p = 2 * light - q;
          red, green, blue = HUE_RGBConv(p, q, hue + 1 / 3), HUE_RGBConv(p, q, hue), HUE_RGBConv(p, q, hue - 1 / 3);
     end
     return {math.floor(red * MAX_RGB_VALUE), math.floor(green * MAX_RGB_VALUE), math.floor(blue * MAX_RGB_VALUE)}
end
local function RGB_HEXConv(red, green, blue)
     local red   = red   >= 0 and (red   <= MAX_RGB_VALUE and red   or MAX_RGB_VALUE) or 0
     local green = green >= 0 and (green <= MAX_RGB_VALUE and green or MAX_RGB_VALUE) or 0
     local blue  = blue  >= 0 and (blue  <= MAX_RGB_VALUE and blue  or MAX_RGB_VALUE) or 0
     return string.format("%02x%02x%02x", red, green, blue)
end

local COLOR_ITERATION = 0.09
local COLOR_HUE_START = 240

local COLOR_TWEEN_TIME_START = 30
local COLOR_TWEEN_TIME_END   = 0

local colorSwitchEnable   = true
local colorTweenTimeValue = 0   -- start: 0   | end: 30
local colorTweenHueValue  = 240 -- start: 240 | end: 270
local function colorSelectorTransitions()
     if getModSetting('remove_color_changing_bg', modFolder) == true then
          return
     end

     local function colorTweenStartTransition()
          colorTweenTimeValue = colorTweenTimeValue + COLOR_ITERATION
          colorTweenHueValue  = ease.inOutExpo(colorTweenTimeValue/30, 0, 30, 1) + COLOR_HUE_START

          if math.round(colorTweenTimeValue, 0) >= COLOR_TWEEN_TIME_START then 
               colorSwitchEnable = false 
          end
     end
     local function colorTweenEndTransition()
          colorTweenTimeValue = colorTweenTimeValue - COLOR_ITERATION
          colorTweenHueValue  = math.abs(ease.inOutExpo(colorTweenTimeValue/30, 30, -30, 1)-30) + COLOR_HUE_START

          if math.round(colorTweenTimeValue, 0) <= COLOR_TWEEN_TIME_END then 
               colorSwitchEnable = true 
          end
     end
     if colorSwitchEnable == true then
          colorTweenStartTransition()
     else
          colorTweenEndTransition()
     end

     local COLOR_RGB = HSL_RGBConv(colorTweenHueValue, 54, 43)
     local COLOR_HEX = RGB_HEXConv(unpack(COLOR_RGB))
     setProperty('skinSelectorBG.color', tonumber(F"0x{COLOR_HEX}"))
end

-- SkinState Stuff --

local SkinStatesGSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

local Notes    = SkinNotes:new('notes', 'noteSkins', 'NOTE_assets')
local Splashes = SkinSplashes:new('splashes', 'noteSplashes', 'noteSplashes')
local Skins    = SkinStates:new({Notes, Splashes}, SkinStatesGSave:get('dataStateName', '', 'notes'))
Skins:load()
Skins:create()

-- HScript Stuff --

addHScript('hscripts/skin-selector/selectorGridBG')     -- Checkerboard & Infinitely BG Stuff
addHScript('hscripts/skin-selector/ui/skinSearchInput') -- Search Input Functionality

-- General Stuff --

function onUpdate(elapsed)
     colorSelectorTransitions()
end

function onUpdatePost(elapsed)
     Skins:switch()
     Skins:update()
end

function onDestroy()
     Skins:save()
end