luaDebugMode = true

local F      = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local math   = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'

local SKIN_EDITOR_BG_WIDTH  = getPropertyFromClass('flixel.FlxG', 'width')
local SKIN_EDITOR_BG_HEIGHT = getPropertyFromClass('flixel.FlxG', 'height')
makeLuaSprite('skinEditorBG', '', 0, 0)
makeGraphic('skinEditorBG', SKIN_EDITOR_BG_WIDTH, SKIN_EDITOR_BG_HEIGHT, '242424')
setObjectCamera('skinEditorBG', 'camHUD')
setObjectOrder('skinEditorBG', 0)
addLuaSprite('skinEditorBG')

makeLuaSprite('testSidebar', nil, 0, 0)
makeGraphic('testSidebar', 420, SKIN_EDITOR_BG_HEIGHT, '101010')
setObjectCamera('testSidebar', 'camHUD')
addLuaSprite('testSidebar')

-- @ --

makeLuaText('editorTitleConfirm', ('Offsets'):pad(1, ' '), 0, 10-5, (163.44 - 5.72) + 8 - 45)
setTextFont('editorTitleConfirm', 'tomo.otf')
setTextSize('editorTitleConfirm', 20)
setTextBorder('editorTitleConfirm', 3, '000000')
setObjectCamera('editorTitleConfirm', 'camHUD')
addLuaText('editorTitleConfirm')

makeLuaText('editorLabelX', ('x'):upper():pad(1, ' '), 0, 10-5, (163.44 - 5.72) + 8)
setTextFont('editorLabelX', 'tomo.otf')
setTextColor('editorLabelX', 'ff746c')
setTextSize('editorLabelX', 20)
setTextBorder('editorLabelX', 3, '000000')
setObjectCamera('editorLabelX', 'camHUD')
addLuaText('editorLabelX')

makeLuaText('editorLabelY', ('y'):upper():pad(1, ' '), 0, 240-33, (163.44 - 5.72) + 8)
setTextFont('editorLabelY', 'tomo.otf')
setTextColor('editorLabelY', '77dd77')
setTextSize('editorLabelY', 20)
setTextBorder('editorLabelY', 3, '000000')
setObjectCamera('editorLabelY', 'camHUD')
addLuaText('editorLabelY')

makeLuaSprite('editorInputFieldX', 'ui/buttons/value_input6', 40, (163.44 - 5.72))
scaleObject('editorInputFieldX', 0.65, 0.85)
setObjectCamera('editorInputFieldX', 'camHUD')
setProperty('editorInputFieldX.antialiasing', false)
addLuaSprite('editorInputFieldX')

makeLuaSprite('editorInputFieldY', 'ui/buttons/value_input6', 240, (163.44 - 5.72))
scaleObject('editorInputFieldY', 0.65, 0.85)
setObjectCamera('editorInputFieldY', 'camHUD')
setProperty('editorInputFieldY.antialiasing', false)
addLuaSprite('editorInputFieldY')

-- a --

--[[ makeLuaText('editorTitleConfirmTag', ' Confirm ', 0, 30, 563.44+(25*-6))
setTextFont('editorTitleConfirmTag', 'tomo.otf')
setTextSize('editorTitleConfirmTag', 25)
setTextBorder('editorTitleConfirmTag', 3, '000000')
setObjectCamera('editorTitleConfirmTag', 'camHUD')
addLuaText('editorTitleConfirmTag')

makeLuaText('editorTitlePressedTag', ' Pressed ', 0, 30, 563.44+(25*-4))
setTextFont('editorTitlePressedTag', 'tomo.otf')
setTextSize('editorTitlePressedTag', 25)
setTextBorder('editorTitlePressedTag', 3, '000000')
setObjectCamera('editorTitlePressedTag', 'camHUD')
addLuaText('editorTitlePressedTag')

makeLuaText('editorTitleColoredTag', ' Colored ', 0, 30, 563.44+(25*-2))
setTextFont('editorTitleColoredTag', 'tomo.otf')
setTextSize('editorTitleColoredTag', 25)
setTextBorder('editorTitleColoredTag', 3, '000000')
setObjectCamera('editorTitleColoredTag', 'camHUD')
addLuaText('editorTitleColoredTag')

makeLuaText('editorTitleStrumTag', ' Strums ', 0, 30, 563.44+(25*-0))
setTextFont('editorTitleStrumTag', 'tomo.otf')
setTextSize('editorTitleStrumTag', 25)
setTextBorder('editorTitleStrumTag', 3, '000000')
setObjectCamera('editorTitleStrumTag', 'camHUD')
addLuaText('editorTitleStrumTag')

-- b --

local function doodoo(tag, label, color, x, y, bgX, bgY)
     local editorLabelTag = F"editorLabelTag${tag:upperAtStart()}${label:upper()}"
     local editorBGTag    = F"editorBGTag${tag:upperAtStart()}${label:upper()}"

     makeLuaText(editorLabelTag, label:upper():pad(1, ' '), 0, 180 + x, 563.44 + y)
     setTextFont(editorLabelTag, 'tomo.otf')
     setTextColor(editorLabelTag, color)
     setTextSize(editorLabelTag, 25)
     setTextBorder(editorLabelTag, 3, '000000')
     setObjectCamera(editorLabelTag, 'camHUD')
     addLuaText(editorLabelTag)
     
     makeLuaSprite(editorBGTag, 'ui/buttons/value_input5', 230 + x + bgX, (563.44 - 5.72) + y + bgY)
     scaleObject(editorBGTag, 0.7, 0.8)
     setObjectCamera(editorBGTag, 'camHUD')
     addLuaSprite(editorBGTag)
end

doodoo('strums', 'x', 'ff746c', 0, 0, 0, 0)
doodoo('colored', 'x', 'ff746c', 0, 25*-2, 0, 0)
doodoo('pressed', 'x', 'ff746c', 0, 25*-4, 0, 0)
doodoo('confirm', 'x', 'ff746c', 0, 25*-6, 0, 0)

doodoo('strums', 'y', '77dd77', 250, 0, 0, 0)
doodoo('colored', 'y', '77dd77', 250, 25*-2, 0, 0)
doodoo('pressed', 'y', '77dd77', 250, 25*-4, 0, 0)
doodoo('confirm', 'y', '77dd77', 250, 25*-6, 0, 0)

doodoo('strums', 'fps', '9c77dd', 250*2, 0, 35, 0)
doodoo('colored', 'fps', '9c77dd', 250*2, 25*-2, 35, 0)
doodoo('pressed', 'fps', '9c77dd', 250*2, 25*-4, 35, 0)
doodoo('confirm', 'fps', '9c77dd', 250*2, 25*-6, 35, 0) ]]