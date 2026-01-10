luaDebugMode = true

local SkinSaves    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'
local SkinStates   = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinStates'
local SkinNotes    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotes'
local SkinSplashes = require 'mods.NoteSkin Selector Remastered.api.classes.skins.splashes.SkinSplashes'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local ease      = require 'mods.NoteSkin Selector Remastered.api.libraries.ease.ease'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local switch = global.switch
local addCallbackEvents = funkinlua.addCallbackEvents
local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionPress    = funkinlua.keyboardJustConditionPress
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

local SkinStateSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

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

makeLuaSprite('selectorBackground', 'menuDesat', 0, 0)
setObjectCamera('selectorBackground', 'camHUD')
setObjectOrder('selectorBackground', 0)
setProperty('selectorBackground.color', 0x5220bd)
addLuaSprite('selectorBackground')

-- Display Sliders --

makeAnimatedLuaSprite('displaySliderIcon', 'ui/buttons/slider_button', 600, 127) -- min: 127; max: 643
addAnimationByPrefix('displaySliderIcon', 'static', 'slider_button-static')
addAnimationByPrefix('displaySliderIcon', 'pressed', 'slider_button-pressed')
addAnimationByPrefix('displaySliderIcon', 'unscrollable', 'slider_button-unscrollable')
playAnim('displaySliderIcon', 'static')
scaleObject('displaySliderIcon', 0.6, 0.6)
setObjectCamera('displaySliderIcon', 'camHUD')
setProperty('displaySliderIcon.antialiasing', false)
addLuaSprite('displaySliderIcon')

makeLuaSprite('displaySliderTrack', nil, 600 + getProperty('displaySliderIcon.width') / 2.7, 127 + 3)
makeGraphic('displaySliderTrack', 12, 570, '1d1e1f')
setObjectOrder('displaySliderTrack', getObjectOrder('displaySliderIcon'))
setObjectCamera('displaySliderTrack', 'camHUD')
setProperty('displaySliderTrack.antialiasing', false)
addLuaSprite('displaySliderTrack', true)

-- Selection Animation Buttons --

makeLuaText('previewSkinTitleText', 'Preview Animations', 0, 775+12, 470)
setTextFont('previewSkinTitleText', 'FridayNight.ttf')
setTextSize('previewSkinTitleText', 18)
setTextBorder('previewSkinTitleText', 3, '000000')
setObjectCamera('previewSkinTitleText', 'camHUD')
setProperty('previewSkinTitleText.antialiasing', false)
addLuaText('previewSkinTitleText')

makeAnimatedLuaSprite('previewSkinButtonLeft', 'ui/buttons/preview anim/previewAnimIcon_button', 775+12, 500)
addAnimationByPrefix('previewSkinButtonLeft', 'static', 'skinanim-static', 24, false)
addAnimationByPrefix('previewSkinButtonLeft', 'hovered-blocked', 'skinanim-hovered-blocked', 24, false)
addAnimationByPrefix('previewSkinButtonLeft', 'hovered-static', 'skinanim-hovered-static', 24, false)
addAnimationByPrefix('previewSkinButtonLeft', 'hovered-pressed', 'skinanim-hovered-pressed', 24, false)
playAnim('previewSkinButtonLeft', 'static', true)
scaleObject('previewSkinButtonLeft', 0.5, 0.5)
setObjectCamera('previewSkinButtonLeft', 'camHUD')
setProperty('previewSkinButtonLeft.antialiasing', false)
addLuaSprite('previewSkinButtonLeft')

makeAnimatedLuaSprite('previewSkinInfoIconLeft', 'ui/buttons/preview anim/previewAnimInfoDirection_button', 775+12+(60/4.4), 500+(60/4.8))
addAnimationByPrefix('previewSkinInfoIconLeft', 'none', 'icons-none', 24, false)
addAnimationByPrefix('previewSkinInfoIconLeft', 'left', 'icons-left', 24, false)
addAnimationByPrefix('previewSkinInfoIconLeft', 'right', 'icons-right', 24, false)
playAnim('previewSkinInfoIconLeft', 'none', true)
scaleObject('previewSkinInfoIconLeft', 0.5, 0.5)
setObjectCamera('previewSkinInfoIconLeft', 'camHUD')
setProperty('previewSkinInfoIconLeft.antialiasing', false)
addLuaSprite('previewSkinInfoIconLeft')

makeAnimatedLuaSprite('previewSkinButtonRight', 'ui/buttons/preview anim/previewAnimIcon_button', 775+(12*7), 500)
addAnimationByPrefix('previewSkinButtonRight', 'static', 'skinanim-static', 24, false)
addAnimationByPrefix('previewSkinButtonRight', 'hovered-blocked', 'skinanim-hovered-blocked', 24, false)
addAnimationByPrefix('previewSkinButtonRight', 'hovered-static', 'skinanim-hovered-static', 24, false)
addAnimationByPrefix('previewSkinButtonRight', 'hovered-pressed', 'skinanim-hovered-pressed', 24, false)
playAnim('previewSkinButtonRight', 'static', true)
scaleObject('previewSkinButtonRight', 0.5, 0.5)
setObjectCamera('previewSkinButtonRight', 'camHUD')
setProperty('previewSkinButtonRight.antialiasing', false)
addLuaSprite('previewSkinButtonRight')

makeAnimatedLuaSprite('previewSkinInfoIconRight', 'ui/buttons/preview anim/previewAnimInfoDirection_button', 775+(12*7)+(60/4.4), 500+(60/4.8))
addAnimationByPrefix('previewSkinInfoIconRight', 'none', 'icons-none', 24, false)
addAnimationByPrefix('previewSkinInfoIconRight', 'left', 'icons-left', 24, false)
addAnimationByPrefix('previewSkinInfoIconRight', 'right', 'icons-right', 24, false)
playAnim('previewSkinInfoIconRight', 'right', true)
scaleObject('previewSkinInfoIconRight', 0.5, 0.5)
setObjectCamera('previewSkinInfoIconRight', 'camHUD')
setProperty('previewSkinInfoIconRight.antialiasing', false)
addLuaSprite('previewSkinInfoIconRight')

makeAnimatedLuaSprite('previewSkinButtonSelection', 'ui/buttons/preview anim/previewAnimSelection_button', 775+(12*16), 500)
addAnimationByPrefix('previewSkinButtonSelection', 'static', 'selection-static', 24, false)
addAnimationByPrefix('previewSkinButtonSelection', 'pressed', 'selection-pressed', 24, false)
addAnimationByPrefix('previewSkinButtonSelection', 'hovered-static', 'selection-hovered-static', 24, false)
addAnimationByPrefix('previewSkinButtonSelection', 'hovered-pressed', 'selection-hovered-pressed', 24, false)
playAnim('previewSkinButtonSelection', 'static', true)
scaleObject('previewSkinButtonSelection', 0.5, 0.5)
setObjectCamera('previewSkinButtonSelection', 'camHUD')
setProperty('previewSkinButtonSelection.antialiasing', false)
addLuaSprite('previewSkinButtonSelection')

makeLuaText('previewSkinButtonSelectionText', 'Confirm', 0, 775+(12*17.3), 515)
setTextFont('previewSkinButtonSelectionText', 'sonic.ttf')
setTextSize('previewSkinButtonSelectionText', 25)
setObjectCamera('previewSkinButtonSelectionText', 'camHUD')
setProperty('previewSkinButtonSelectionText.antialiasing', false)
addLuaText('previewSkinButtonSelectionText')

--[[ makeLuaSprite('fart', 'ui/buttons/test/fart7', 430, 48)
setObjectCamera('fart', 'camHUD')
setProperty('fart.scale.x', 0.7)
setProperty('fart.scale.y', 0.8)
setProperty('fart.antialiasing', false)
addLuaSprite('fart') ]]

-- General Infos --

makeLuaText('genInfoStateName', ' Notes', 0, 7, 13)
setTextFont('genInfoStateName', 'sonic.ttf')
setTextSize('genInfoStateName', 35)
setTextBorder('genInfoStateName', 3, '000000')
setObjectCamera('genInfoStateName', 'camHUD')
setProperty('genInfoStateName.antialiasing', false)
addLuaText('genInfoStateName')

makeLuaText('genInfoStatePage', ' Page 001 / 100', 0, 7^2.767, 17)
setTextFont('genInfoStatePage', 'sonic.ttf')
setTextSize('genInfoStatePage', 30)
setTextBorder('genInfoStatePage', 3, '000000')
setObjectCamera('genInfoStatePage', 'camHUD')
setProperty('genInfoStatePage.antialiasing', false)
addLuaText('genInfoStatePage')

makeLuaText('genInfoSkinName', 'Funkin', 500, 748, 70)
setTextFont('genInfoSkinName', 'sonic.ttf')
setTextSize('genInfoSkinName', 50)
setTextBorder('genInfoSkinName', 4, '000000')
setTextAlignment('genInfoSkinName', 'center')
setObjectCamera('genInfoSkinName', 'camHUD')
setProperty('genInfoSkinName.antialiasing', false)
addLuaText('genInfoSkinName')

makeLuaText('genInfoVersion', 'Ver 3.0.0', 0, 1195, 5)
setTextFont('genInfoVersion', 'sonic.ttf')
setTextSize('genInfoVersion', 20)
setTextColor('genInfoVersion', 'fccf03') -- fccf03 03fce7
setTextAlignment('genInfoVersion', 'right')
setObjectCamera('genInfoVersion', 'camHUD')
setProperty('genInfoVersion.antialiasing', false)
addLuaText('genInfoVersion')

for keyID = 1, 4 do
     local previewSkinPositionX = 830 + (105*(keyID-1))
     local previewSkinPositionY = 250

     if keyID == 2 then
          previewSkinPositionX = 830 + (105*(keyID-1)) - 4
     elseif keyID == 3 then
          previewSkinPositionX = 830 + (105*(keyID-1)) - 3
     end

     local genInfoKeybinds = 'genInfoKeybinds-'..keyID
     makeLuaText(genInfoKeybinds, tostring(getKeyBinds(keyID)), nil, previewSkinPositionX, previewSkinPositionY)
     setTextFont(genInfoKeybinds, 'FridayNight.ttf')
     setTextSize(genInfoKeybinds, 35)
     setTextBorder(genInfoKeybinds, 4, '000000')
     setObjectCamera(genInfoKeybinds, 'camHUD')
     addLuaText(genInfoKeybinds)
end

-- Cursor --

makeAnimatedLuaSprite('mouseTexture', 'ui/cursor', getMouseX('camOther'), getMouseY('camOther'))
scaleObject('mouseTexture', 0.4, 0.4)
addAnimationByPrefix('mouseTexture', 'idle', 'idle', 24, false)
addAnimationByPrefix('mouseTexture', 'idleClick', 'idleClick', 24, false)
addAnimationByPrefix('mouseTexture', 'hand', 'hand', 24, false)
addAnimationByPrefix('mouseTexture', 'handClick', 'handClick', 24, false)
addAnimationByPrefix('mouseTexture', 'disabled', 'disabled', 24, false)
addAnimationByPrefix('mouseTexture', 'disabledClick', 'disabledClick', 24, false)
addAnimationByPrefix('mouseTexture', 'waiting', 'waiting', 5, true)
addOffset('mouseTexture', 'idle', 27.9, 27.6)
addOffset('mouseTexture', 'idleClick', 27.9, 27.6)
addOffset('mouseTexture', 'hand', 40, 27.6)
addOffset('mouseTexture', 'handClick', 40, 27.6)
addOffset('mouseTexture', 'disabled', 43, 27.6)
addOffset('mouseTexture', 'disabledClick', 43, 27.6)
playAnim('mouseTexture', 'idle')
setObjectCamera('mouseTexture', 'camOther')
addLuaSprite('mouseTexture', true)
setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)

makeLuaText('skinHighlightName', '', 0, 0, 0)
setTextFont('skinHighlightName', 'sonic.ttf')
setTextSize('skinHighlightName', 25)
setObjectCamera('skinHighlightName', 'camOther')
addLuaText('skinHighlightName', true)

-- HScript Stuff --

addHScript('hscripts/skin-selector/selectorGridBG')     -- Checkerboard & Infinitely BG Stuff
addHScript('hscripts/skin-selector/ui/skinSearchInput') -- Search Input Functionality

-- General Stuff --

local hueChangeSwitch = true
local hueChangeCPM    = 0.09
local hueChangeStaticValue = 0   -- start: 0   | end: 30
local hueChangeTweenValue  = 240 -- start: 240 | end: 270
local function hueChangeBG()
     if getModSetting('remove_color_changing_bg', modFolder) ~= false then
          return
     end

     local hueToRGB = function(primary, secondary, tertiary)
          if tertiary < 0 then tertiary = tertiary + 1 end
          if tertiary > 1 then tertiary = tertiary - 1 end
          if tertiary < 1 / 6 then return primary + (secondary - primary) * 6 * tertiary end
          if tertiary < 1 / 2 then return secondary end
          if tertiary < 2 / 3 then return primary + (secondary - primary) * (2 / 3 - tertiary) * 6 end
          return primary;
     end
     local hslToRGB = function(hue, sat, light)
          local hue, sat, light = hue / 360, sat / 100, light / 100
          local red, green, blue = light, light, light; -- achromatic
          if sat ~= 0 then
               local q = light < 0.5 and light * (1 + sat) or light + sat - light * sat;
               local p = 2 * light - q;
               red, green, blue = hueToRGB(p, q, hue + 1 / 3), hueToRGB(p, q, hue), hueToRGB(p, q, hue - 1 / 3);
          end
          return {math.floor(red * 255), math.floor(green * 255), math.floor(blue * 255)}
     end
     local rgbToHex = function(red, green, blue)
          local red   = red   >= 0 and (red   <= 255 and red   or 255) or 0
          local green = green >= 0 and (green <= 255 and green or 255) or 0
          local blue  = blue  >= 0 and (blue  <= 255 and blue  or 255) or 0
          return string.format("%02x%02x%02x", red, green, blue)
     end

     if hueChangeSwitch == true then
          hueChangeStaticValue = hueChangeStaticValue + hueChangeCPM
          hueChangeTweenValue  = ease.inOutExpo(hueChangeStaticValue/30, 0, 30-0, 1)+240

          if math.round(hueChangeStaticValue, 0) >= 30 then 
               hueChangeSwitch = false 
          end
     else
          hueChangeStaticValue = hueChangeStaticValue - hueChangeCPM
          hueChangeTweenValue  = math.abs(ease.inOutExpo(hueChangeStaticValue/30, 30, 0-30, 1)-30)+240

          if math.round(hueChangeStaticValue, 0) <= 0 then 
               hueChangeSwitch = true 
          end
     end

     if not getModSetting('remove_color_changing_bg', modFolder) then
          local rgb = hslToRGB(hueChangeTweenValue, 54, 43)
          local hex = rgbToHex(unpack(rgb))
          setProperty('selectorBackground.color', tonumber('0x'..hex))
     end
end

function onUpdate(elapsed)
     hueChangeBG()
end

local Notes    = SkinNotes:new('notes', 'noteSkins', 'NOTE_assets')
local Splashes = SkinSplashes:new('splashes', 'noteSplashes', 'noteSplashes')

local Skins = SkinStates:new({Notes, Splashes}, SkinStateSave:get('dataStateName', '', 'notes'))
Skins:load()
Skins:create()

function onUpdatePost(elapsed)
     Skins:switch()
     Skins:update()
end

function onDestroy()
     Skins:save()
end


--[[ makeLuaSprite('eefwe', 'ui/buttons/test/daih2', 397.6, 160.8) --397.6, 160.8
scaleObject('eefwe', 0.8, 0.75)
setObjectCamera('eefwe', 'camHUD')
setProperty('eefwe.antialiasing', false)
addLuaSprite('eefwe', true)

makeLuaSprite('efwef', 'ui/buttons/test/wcww3', 397.6, 328.8 - 230) --397.6, 328.8
scaleObject('efwef', 0.8, 0.75)
setObjectCamera('efwef', 'camHUD')
setProperty('efwef.antialiasing', false)
addLuaSprite('efwef', true)

makeLuaText('eowefwe', ' State Selection', nil, 397.6 + 5, getProperty('efwef.y') + 16.2)
setTextFont('eowefwe', 'sonic.ttf')
setTextSize('eowefwe', 33)
setTextBorder('eowefwe', 3, '000000')
setProperty('eowefwe.antialiasing', false)
addLuaSprite('eowefwe', true)


makeAnimatedLuaSprite('wfwfwfwef', 'ui/buttons/slider_button', 397.6 + 430, 328.8 - 160) -- min: 127; max: 643
addAnimationByPrefix('wfwfwfwef', 'static', 'slider_button-static')
addAnimationByPrefix('wfwfwfwef', 'pressed', 'slider_button-pressed')
addAnimationByPrefix('wfwfwfwef', 'unscrollable', 'slider_button-unscrollable')
playAnim('wfwfwfwef', 'static')
scaleObject('wfwfwfwef', 0.5, 0.5)
setObjectCamera('wfwfwfwef', 'camHUD')
setProperty('wfwfwfwef.antialiasing', false)
addLuaSprite('wfwfwfwef', true)

makeLuaSprite('wefveoifwq', nil, 397.6 + 432 + getProperty('wfwfwfwef.width') / 2.7, 328.8 - 160)
makeGraphic('wefveoifwq', 8, 570, '1d1e1f')
setObjectOrder('wefveoifwq', getObjectOrder('wfwfwfwef'))
setObjectCamera('wefveoifwq', 'camHUD')
setProperty('wefveoifwq.antialiasing', false)
addLuaSprite('wefveoifwq', true) ]]
