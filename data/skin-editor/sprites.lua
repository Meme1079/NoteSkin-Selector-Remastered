luaDebugMode = true

local F      = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local math   = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'

local SKIN_EDITOR_BG_WIDTH  = getPropertyFromClass('flixel.FlxG', 'width')
local SKIN_EDITOR_BG_HEIGHT = getPropertyFromClass('flixel.FlxG', 'height')

local calcPosX = function(x, offsetX) return x + offsetX          end
local calcPosY = function(y, offsetY) return (y - 5.72) + offsetY end

-- Precaching --

precacheImage('ui/flavorui/cursor')
precacheImage('ui/flavorui/button/button_save')
precacheImage('ui/flavorui/textfield/textfield_number_editor')
precacheImage('ui/flavorui/textfield/textfield_string_editor')

-- Main --

makeLuaSprite('skinEditorBG', '', 0, 0)
makeGraphic('skinEditorBG', SKIN_EDITOR_BG_WIDTH, SKIN_EDITOR_BG_HEIGHT, '242424')
setObjectCamera('skinEditorBG', 'camHUD')
setObjectOrder('skinEditorBG', 0)
addLuaSprite('skinEditorBG')

makeLuaSprite('testSidebar', nil, 0, 0)
makeGraphic('testSidebar', 420, SKIN_EDITOR_BG_HEIGHT, '101010')
setObjectCamera('testSidebar', 'camHUD')
addLuaSprite('testSidebar')

-- Offset --

makeLuaText('editorTitleOffset', ('Offsets'):pad(1, ' '), 0, 5, calcPosY(130.5, -37))
setTextFont('editorTitleOffset', 'tomo.otf')
setTextSize('editorTitleOffset', 20)
setTextBorder('editorTitleOffset', 3, '000000')
setObjectCamera('editorTitleOffset', 'camHUD')
addLuaText('editorTitleOffset')

makeLuaText('editorLabelOffsetX', ('x'):upper():pad(1, ' '), 0, 5, calcPosY(130.5, 8))
setTextFont('editorLabelOffsetX', 'tomo.otf')
setTextColor('editorLabelOffsetX', 'ff746c')
setTextSize('editorLabelOffsetX', 20)
setTextBorder('editorLabelOffsetX', 3, '000000')
setObjectCamera('editorLabelOffsetX', 'camHUD')
addLuaText('editorLabelOffsetX')

makeLuaText('editorLabelOffsetY', ('y'):upper():pad(1, ' '), 0, 207, calcPosY(130.5, 8))
setTextFont('editorLabelOffsetY', 'tomo.otf')
setTextColor('editorLabelOffsetY', '77dd77')
setTextSize('editorLabelOffsetY', 20)
setTextBorder('editorLabelOffsetY', 3, '000000')
setObjectCamera('editorLabelOffsetY', 'camHUD')
addLuaText('editorLabelOffsetY')

makeLuaSprite('editorInputSpriteOffsetX', 'ui/flavorui/textfield/textfield_number_editor', 40, calcPosY(130.5, 0))
scaleObject('editorInputSpriteOffsetX', 0.65, 0.85)
setObjectCamera('editorInputSpriteOffsetX', 'camHUD')
setProperty('editorInputSpriteOffsetX.antialiasing', false)
addLuaSprite('editorInputSpriteOffsetX')

makeLuaSprite('editorInputSpriteOffsetY', 'ui/flavorui/textfield/textfield_number_editor', 240, calcPosY(130.5, 0))
scaleObject('editorInputSpriteOffsetY', 0.65, 0.85)
setObjectCamera('editorInputSpriteOffsetY', 'camHUD')
setProperty('editorInputSpriteOffsetY.antialiasing', false)
addLuaSprite('editorInputSpriteOffsetY')

-- Size --

makeLuaText('editorTitleSize', ('Size'):pad(1, ' '), 0, 5, calcPosY(230.5, -37))
setTextFont('editorTitleSize', 'tomo.otf')
setTextSize('editorTitleSize', 20)
setTextBorder('editorTitleSize', 3, '000000')
setObjectCamera('editorTitleSize', 'camHUD')
addLuaText('editorTitleSize')

makeLuaText('editorLabelSizeX', ('x'):upper():pad(1, ' '), 0, 5, calcPosY(230.5, 8))
setTextFont('editorLabelSizeX', 'tomo.otf')
setTextColor('editorLabelSizeX', 'ff746c')
setTextSize('editorLabelSizeX', 20)
setTextBorder('editorLabelSizeX', 3, '000000')
setObjectCamera('editorLabelSizeX', 'camHUD')
addLuaText('editorLabelSizeX')

makeLuaText('editorLabelSizeY', ('y'):upper():pad(1, ' '), 0, 207, calcPosY(230.5, 8))
setTextFont('editorLabelSizeY', 'tomo.otf')
setTextColor('editorLabelSizeY', '77dd77')
setTextSize('editorLabelSizeY', 20)
setTextBorder('editorLabelSizeY', 3, '000000')
setObjectCamera('editorLabelSizeY', 'camHUD')
addLuaText('editorLabelSizeY')

makeLuaSprite('editorInputSpriteSizeX', 'ui/flavorui/textfield/textfield_number_editor', 40, calcPosY(230.5, 0))
scaleObject('editorInputSpriteSizeX', 0.65, 0.85)
setObjectCamera('editorInputSpriteSizeX', 'camHUD')
setProperty('editorInputSpriteSizeX.antialiasing', false)
addLuaSprite('editorInputSpriteSizeX')

makeLuaSprite('editorInputSpriteSizeY', 'ui/flavorui/textfield/textfield_number_editor', 240, calcPosY(230.5, 0))
scaleObject('editorInputSpriteSizeY', 0.65, 0.85)
setObjectCamera('editorInputSpriteSizeY', 'camHUD')
setProperty('editorInputSpriteSizeY.antialiasing', false)
addLuaSprite('editorInputSpriteSizeY')

-- Frames --

makeLuaText('editorTitleFrames', ('Frames'):pad(1, ' '), 0, 5, calcPosY(330.5, -37))
setTextFont('editorTitleFrames', 'tomo.otf')
setTextSize('editorTitleFrames', 20)
setTextBorder('editorTitleFrames', 3, '000000')
setObjectCamera('editorTitleFrames', 'camHUD')
addLuaText('editorTitleFrames')

makeLuaText('editorLabelFrames', ('FPS'):upper():pad(1, ' '), 0, 1, calcPosY(330.5, 10))
setTextFont('editorLabelFrames', 'tomo.otf')
setTextColor('editorLabelFrames', 'c9a0dc')
setTextSize('editorLabelFrames', 15)
setTextBorder('editorLabelFrames', 3, '000000')
setObjectCamera('editorLabelFrames', 'camHUD')
addLuaText('editorLabelFrames')

makeLuaSprite('editorInputSpriteFrames', 'ui/flavorui/textfield/textfield_number_editor', 40, calcPosY(330.5, 0))
scaleObject('editorInputSpriteFrames', 0.65, 0.85)
setObjectCamera('editorInputSpriteFrames', 'camHUD')
setProperty('editorInputSpriteFrames.antialiasing', false)
addLuaSprite('editorInputSpriteFrames')

-- File --

makeLuaText('editorTitleFile', ('SKIN FILE NAME:'):pad(1, ' '), 0, 5, calcPosY((430.5+530.5)/2, -37))
setTextFont('editorTitleFile', 'tomo.otf')
setTextSize('editorTitleFile', 20)
setTextBorder('editorTitleFile', 3, '000000')
setObjectCamera('editorTitleFile', 'camHUD')
addLuaText('editorTitleFile')

makeLuaSprite('editorInputSpriteFile', 'ui/flavorui/textfield/textfield_string_editor', 10, calcPosY((430.5+530.5)/2, 0))
scaleObject('editorInputSpriteFile', 0.65, 0.85)
setObjectCamera('editorInputSpriteFile', 'camHUD')
setProperty('editorInputSpriteFile.antialiasing', false)
addLuaSprite('editorInputSpriteFile')

-- Save --

makeLuaText('editorTitleSaveFile', ('SKIN SAVEFILE PATH:'):pad(1, ' '), 0, 5, calcPosY((530.5+630.5)/2, -37))
setTextFont('editorTitleSaveFile', 'tomo.otf')
setTextSize('editorTitleSaveFile', 20)
setTextBorder('editorTitleSaveFile', 3, '000000')
setObjectCamera('editorTitleSaveFile', 'camHUD')
addLuaText('editorTitleSaveFile')

makeLuaSprite('editorInputSpriteSaveFile', 'ui/flavorui/textfield/textfield_string_editor', 10, calcPosY((530.5+630.5)/2, 0))
scaleObject('editorInputSpriteSaveFile', 0.65, 0.85)
setObjectCamera('editorInputSpriteSaveFile', 'camHUD')
setProperty('editorInputSpriteSaveFile.antialiasing', false)
addLuaSprite('editorInputSpriteSaveFile')

makeLuaText('editorSaveDataText', ('SAVE DATA JSON'):pad(1, ' '), 0, 120, calcPosY((630.5+660.5)/2, 0))
setTextFont('editorSaveDataText', 'tomo.otf')
setTextSize('editorSaveDataText', 20)
setTextColor('editorSaveDataText', 'ffffff')
setTextBorder('editorSaveDataText', 0, '000000')
setObjectCamera('editorSaveDataText', 'camHUD')
addLuaText('editorSaveDataText')

makeAnimatedLuaSprite('editorSaveDataSprite', 'ui/flavorui/button/button_save', 10, calcPosY((630.5+640.5)/2, 0))
addAnimationByPrefix('editorSaveDataSprite', 'static', 'static', 24, false)
addAnimationByPrefix('editorSaveDataSprite', 'hovered', 'hovered', 24, false)
addAnimationByPrefix('editorSaveDataSprite', 'pressed', 'pressed', 24, false)
addAnimationByPrefix('editorSaveDataSprite', 'disabled', 'disabled', 24, false)
scaleObject('editorSaveDataSprite', 0.65, 0.85)
playAnim('editorSaveDataSprite', 'static')
setObjectCamera('editorSaveDataSprite', 'camHUD')
setProperty('editorSaveDataSprite.antialiasing', false)
addLuaSprite('editorSaveDataSprite')

local doodooX = 600
local doodooY = 150

makeAnimatedLuaSprite('doodoo1', 'noteSkins/NOTE_assets', doodooX, doodooY)
scaleObject('doodoo1', 0.65, 0.65)
addAnimationByPrefix('doodoo1', 'left confirm', 'left confirm', 24, false)
addAnimationByPrefix('doodoo1', 'left pressed', 'left pressed', 24, false)
addAnimationByPrefix('doodoo1', 'left colored', 'purple', 24, false)
addAnimationByPrefix('doodoo1', 'left', 'arrowLEFT', 24, false)
playAnim('doodoo1', 'left', false)
setObjectCamera('doodoo1', 'camHUD')
addLuaSprite('doodoo1')

makeAnimatedLuaSprite('doodoo2', 'noteSkins/NOTE_assets', doodooX+(130), doodooY)
scaleObject('doodoo2', 0.65, 0.65)
addAnimationByPrefix('doodoo2', 'down confirm', 'down confirm', 24, false)
addAnimationByPrefix('doodoo2', 'down pressed', 'down pressed', 24, false)
addAnimationByPrefix('doodoo2', 'down colored', 'blue', 24, false)
addAnimationByPrefix('doodoo2', 'down', 'arrowDOWN', 24, false)
playAnim('doodoo2', 'down', false)
setObjectCamera('doodoo2', 'camHUD')
addLuaSprite('doodoo2')

makeAnimatedLuaSprite('doodoo3', 'noteSkins/NOTE_assets', doodooX+(130*2), doodooY)
scaleObject('doodoo3', 0.65, 0.65)
addAnimationByPrefix('doodoo3', 'up confirm', 'up confirm', 24, false)
addAnimationByPrefix('doodoo3', 'up pressed', 'up pressed', 24, false)
addAnimationByPrefix('doodoo3', 'up colored', 'green', 24, false)
addAnimationByPrefix('doodoo3', 'up', 'arrowUP', 24, false)
playAnim('doodoo3', 'up', false)
setObjectCamera('doodoo3', 'camHUD')
addLuaSprite('doodoo3')

makeAnimatedLuaSprite('doodoo4', 'noteSkins/NOTE_assets', doodooX+(130*3), doodooY)
scaleObject('doodoo4', 0.65, 0.65)
addAnimationByPrefix('doodoo4', 'right confirm', 'right confirm', 24, false)
addAnimationByPrefix('doodoo4', 'right pressed', 'right pressed', 24, false)
addAnimationByPrefix('doodoo4', 'right colored', 'red', 24, false)
addAnimationByPrefix('doodoo4', 'right', 'arrowRIGHT', 24, false)
playAnim('doodoo4', 'right', false)
setObjectCamera('doodoo4', 'camHUD')
addLuaSprite('doodoo4')

---

--[[ makeAnimatedLuaSprite('hahaha1', 'ui/flavorui/button/button_display', 500, 300)
addAnimationByPrefix('hahaha1', 'static', 'static')
addAnimationByPrefix('hahaha1', 'selected', 'selected')
addAnimationByPrefix('hahaha1', 'disabled', 'disabled')
addAnimationByPrefix('hahaha1', 'hovered', 'hovered-static')
addAnimationByPrefix('hahaha1', 'pressed', 'hovered-pressed')
playAnim('hahaha1', 'static', true)
scaleObject('hahaha1', 0.8, 0.8)
setObjectCamera('hahaha1', 'camHUD')
setProperty('hahaha1.antialiasing', false)
addLuaSprite('hahaha1')

makeAnimatedLuaSprite('hahaha2', 'ui/flavorui/button/button_display', 650, 300)
addAnimationByPrefix('hahaha2', 'static', 'static')
addAnimationByPrefix('hahaha2', 'selected', 'selected')
addAnimationByPrefix('hahaha2', 'disabled', 'disabled')
addAnimationByPrefix('hahaha2', 'hovered', 'hovered-static')
addAnimationByPrefix('hahaha2', 'pressed', 'hovered-pressed')
playAnim('hahaha2', 'static', true)
scaleObject('hahaha2', 0.8, 0.8)
setObjectCamera('hahaha2', 'camHUD')
setProperty('hahaha2.antialiasing', false)
addLuaSprite('hahaha2') ]]
