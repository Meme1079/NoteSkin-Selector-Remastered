local FlavorUI_TextField = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_TextField'
local FlavorUI_Mouse     = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_Mouse'
local EditorNotes        = require 'mods.NoteSkin Selector Remastered.api.classes.editor.notes.EditorNotes'

local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'

local mouse = FlavorUI_Mouse:new('ui/cursor', 0.4, {-4,0})
mouse:create()

-- Offset --

local OFFSET_SECTION_Y = (163.44 - 5.72)
local OFFSET_SECTION_FIELD_Y = OFFSET_SECTION_Y + 7

local OFFSET_FIELD1_X = 40+8
local OFFSET_FIELD2_X = 240+8

local editorInputFieldOffsetX = FlavorUI_TextField:new('editorInputFieldOffsetX', '', OFFSET_FIELD1_X, OFFSET_SECTION_FIELD_Y, 130)
editorInputFieldOffsetX.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldOffsetX.size = 20
editorInputFieldOffsetX.max_length = 10
editorInputFieldOffsetX.caret_y = 2
editorInputFieldOffsetX.caret_width = 2.5
editorInputFieldOffsetX.caret_height = 20
editorInputFieldOffsetX.placeholder_content = '000.00'
editorInputFieldOffsetX.onFieldMax = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldOffsetX:create()
editorInputFieldOffsetX:set_customFilterPattern("[^0-9.]*", "g")

local editorInputFieldOffsetY = FlavorUI_TextField:new('editorInputFieldOffsetY', '', OFFSET_FIELD2_X, OFFSET_SECTION_FIELD_Y, 130)
editorInputFieldOffsetY.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldOffsetY.size = 20
editorInputFieldOffsetY.max_length = 10
editorInputFieldOffsetY.caret_y = 2
editorInputFieldOffsetY.caret_width = 2.5
editorInputFieldOffsetY.caret_height = 20
editorInputFieldOffsetY.placeholder_content = '000.00'
editorInputFieldOffsetY.onFieldMax = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldOffsetY:create()
editorInputFieldOffsetY:set_customFilterPattern("[^0-9.]*", "g")

-- Size --

local SIZE_SECTION_Y = (263.44 - 5.72)
local SIZE_SECTION_FIELD_Y = SIZE_SECTION_Y + 7

local SIZE_FIELD1_X = 40+8
local SIZE_FIELD2_X = 240+8

local editorInputFieldSizeX = FlavorUI_TextField:new('editorInputFieldSizeX', '', SIZE_FIELD1_X, SIZE_SECTION_FIELD_Y, 130)
editorInputFieldSizeX.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldSizeX.size = 20
editorInputFieldSizeX.max_length = 10
editorInputFieldSizeX.caret_y = 2
editorInputFieldSizeX.caret_width = 2.5
editorInputFieldSizeX.caret_height = 20
editorInputFieldSizeX.placeholder_content = '000.00'
editorInputFieldSizeX.onFieldMax = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldSizeX:create()
editorInputFieldSizeX:set_customFilterPattern("[^0-9.]*", "g")

local editorInputFieldSizeY = FlavorUI_TextField:new('editorInputFieldSizeY', '', SIZE_FIELD2_X, SIZE_SECTION_FIELD_Y, 130)
editorInputFieldSizeY.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldSizeY.size = 20
editorInputFieldSizeY.max_length = 10
editorInputFieldSizeY.caret_y = 2
editorInputFieldSizeY.caret_width = 2.5
editorInputFieldSizeY.caret_height = 20
editorInputFieldSizeY.placeholder_content = '000.00'
editorInputFieldSizeY.onFieldMax = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldSizeY:create()
editorInputFieldSizeY:set_customFilterPattern("[^0-9.]*", "g")

-- Frame --

local FRAMES_SECTION_Y = (363.44 - 5.72)
local FRAMES_SECTION_FIELD_Y = FRAMES_SECTION_Y + 7

local FRAMES_FIELD_X = 40+8

local editorInputFieldFrames = FlavorUI_TextField:new('editorInputFieldFrames', '', FRAMES_FIELD_X, FRAMES_SECTION_FIELD_Y, 130)
editorInputFieldFrames.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldFrames.size = 20
editorInputFieldFrames.max_length = 3
editorInputFieldFrames.caret_y = 2
editorInputFieldFrames.caret_width = 2.5
editorInputFieldFrames.caret_height = 20
editorInputFieldFrames.placeholder_content = '00'
editorInputFieldFrames.onFieldMax = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldFrames:create()
editorInputFieldFrames:set_customFilterPattern("[^0-9]*", "g")

-- File --

local FILES_SECTION_Y = (((463.44+563.44)/2) - 5.72)
local FILES_SECTION_FIELD_Y = FILES_SECTION_Y + 9

local FILES_FIELD_X = 10+8

local editorInputFieldFiles = FlavorUI_TextField:new('editorInputFieldFiles', 'NOTE_assets-', FILES_FIELD_X, FILES_SECTION_FIELD_Y, 360)
editorInputFieldFiles.font = 'NoteSkin Selector Remastered/fonts/sonic.ttf'
editorInputFieldFiles.size = 20
editorInputFieldFiles.max_length = 11+50
editorInputFieldFiles.field_offset_y = -3
editorInputFieldFiles.caret_width = 2.5
editorInputFieldFiles.caret_height = 20
editorInputFieldFiles.placeholder_content = 'NOTE_assets-'
editorInputFieldFiles.placeholder_offset_y = -3
editorInputFieldFiles.onFieldMax = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldFiles.onChange = [[
     FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1);

     if (StringTools.startsWith(curText, "NOTE_assets-") == false) {
          this.set_text("NOTE_assets-");
          this.set_caretIndex(12);
     }
]]
editorInputFieldFiles:create()

function onUpdate(elapsed)
     editorInputFieldOffsetX:update()
     editorInputFieldOffsetY:update()
     editorInputFieldSizeX:update()
     editorInputFieldSizeY:update()
     editorInputFieldFrames:update()
     editorInputFieldFiles:update()

     mouse:update()
end