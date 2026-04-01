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