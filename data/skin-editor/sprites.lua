luaDebugMode = true

local F      = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local math   = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'

local SKIN_EDITOR_BG_WIDTH  = getPropertyFromClass('flixel.FlxG', 'width')
local SKIN_EDITOR_BG_HEIGHT = getPropertyFromClass('flixel.FlxG', 'height')

-- IDK --

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

local OFFSET_SECTION_Y = (163.44 - 5.72)
local OFFSET_SECTION_TITLE_Y = OFFSET_SECTION_Y - 37
local OFFSET_SECTION_LABEL_Y = OFFSET_SECTION_Y + 8

local OFFSET_LABEL1_X = 10-5
local OFFSET_LABEL2_X = 240-33

local OFFSET_SPRITE1_X = 40
local OFFSET_SPRITE2_X = 240

makeLuaText('editorTitleOffset', ('Offsets'):pad(1, ' '), 0, OFFSET_LABEL1_X, OFFSET_SECTION_TITLE_Y)
setTextFont('editorTitleOffset', 'tomo.otf')
setTextSize('editorTitleOffset', 20)
setTextBorder('editorTitleOffset', 3, '000000')
setObjectCamera('editorTitleOffset', 'camHUD')
addLuaText('editorTitleOffset')

makeLuaText('editorLabelOffsetX', ('x'):upper():pad(1, ' '), 0, OFFSET_LABEL1_X, OFFSET_SECTION_LABEL_Y)
setTextFont('editorLabelOffsetX', 'tomo.otf')
setTextColor('editorLabelOffsetX', 'ff746c')
setTextSize('editorLabelOffsetX', 20)
setTextBorder('editorLabelOffsetX', 3, '000000')
setObjectCamera('editorLabelOffsetX', 'camHUD')
addLuaText('editorLabelOffsetX')

makeLuaText('editorLabelOffsetY', ('y'):upper():pad(1, ' '), 0, OFFSET_LABEL2_X, OFFSET_SECTION_LABEL_Y)
setTextFont('editorLabelOffsetY', 'tomo.otf')
setTextColor('editorLabelOffsetY', '77dd77')
setTextSize('editorLabelOffsetY', 20)
setTextBorder('editorLabelOffsetY', 3, '000000')
setObjectCamera('editorLabelOffsetY', 'camHUD')
addLuaText('editorLabelOffsetY')

makeLuaSprite('editorInputSpriteOffsetX', 'ui/buttons/value_input6', OFFSET_SPRITE1_X, OFFSET_SECTION_Y)
scaleObject('editorInputSpriteOffsetX', 0.65, 0.85)
setObjectCamera('editorInputSpriteOffsetX', 'camHUD')
setProperty('editorInputSpriteOffsetX.antialiasing', false)
addLuaSprite('editorInputSpriteOffsetX')

makeLuaSprite('editorInputSpriteOffsetY', 'ui/buttons/value_input6', OFFSET_SPRITE2_X, OFFSET_SECTION_Y)
scaleObject('editorInputSpriteOffsetY', 0.65, 0.85)
setObjectCamera('editorInputSpriteOffsetY', 'camHUD')
setProperty('editorInputSpriteOffsetY.antialiasing', false)
addLuaSprite('editorInputSpriteOffsetY')

-- Size --

local SIZE_SECTION_Y = (263.44 - 5.72)
local SIZE_SECTION_TITLE_Y = SIZE_SECTION_Y - 37
local SIZE_SECTION_LABEL_Y = SIZE_SECTION_Y + 8

local SIZE_LABEL1_X = 10-5
local SIZE_LABEL2_X = 240-33

local SIZE_SPRITE1_X = 40
local SIZE_SPRITE2_X = 240

makeLuaText('editorTitleSize', ('Size'):pad(1, ' '), 0, SIZE_LABEL1_X, SIZE_SECTION_TITLE_Y)
setTextFont('editorTitleSize', 'tomo.otf')
setTextSize('editorTitleSize', 20)
setTextBorder('editorTitleSize', 3, '000000')
setObjectCamera('editorTitleSize', 'camHUD')
addLuaText('editorTitleSize')

makeLuaText('editorLabelSizeX', ('x'):upper():pad(1, ' '), 0, SIZE_LABEL1_X, SIZE_SECTION_LABEL_Y)
setTextFont('editorLabelSizeX', 'tomo.otf')
setTextColor('editorLabelSizeX', 'ff746c')
setTextSize('editorLabelSizeX', 20)
setTextBorder('editorLabelSizeX', 3, '000000')
setObjectCamera('editorLabelSizeX', 'camHUD')
addLuaText('editorLabelSizeX')

makeLuaText('editorLabelSizeY', ('y'):upper():pad(1, ' '), 0, SIZE_LABEL2_X, SIZE_SECTION_LABEL_Y)
setTextFont('editorLabelSizeY', 'tomo.otf')
setTextColor('editorLabelSizeY', '77dd77')
setTextSize('editorLabelSizeY', 20)
setTextBorder('editorLabelSizeY', 3, '000000')
setObjectCamera('editorLabelSizeY', 'camHUD')
addLuaText('editorLabelSizeY')

makeLuaSprite('editorInputSpriteSizeX', 'ui/buttons/value_input6', SIZE_SPRITE1_X, SIZE_SECTION_Y)
scaleObject('editorInputSpriteSizeX', 0.65, 0.85)
setObjectCamera('editorInputSpriteSizeX', 'camHUD')
setProperty('editorInputSpriteSizeX.antialiasing', false)
addLuaSprite('editorInputSpriteSizeX')

makeLuaSprite('editorInputSpriteSizeY', 'ui/buttons/value_input6', SIZE_SPRITE2_X, SIZE_SECTION_Y)
scaleObject('editorInputSpriteSizeY', 0.65, 0.85)
setObjectCamera('editorInputSpriteSizeY', 'camHUD')
setProperty('editorInputSpriteSizeY.antialiasing', false)
addLuaSprite('editorInputSpriteSizeY')