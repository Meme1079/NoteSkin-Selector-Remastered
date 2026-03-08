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

local editorInputFieldOffsetX = FlavorUI_TextField:new('editorInputFieldOffsetX', '', OFFSET_FIELD1_X, OFFSET_SECTION_FIELD_Y, 130, '')
editorInputFieldOffsetX.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldOffsetX.size = 20
editorInputFieldOffsetX.max_length = 10
editorInputFieldOffsetX.caret_y = 2
editorInputFieldOffsetX.caret_width = 2.5
editorInputFieldOffsetX.caret_height = 20
editorInputFieldOffsetX.placeholder_content = '000.00'
editorInputFieldOffsetX:create()
editorInputFieldOffsetX:set_customFilterPattern("[^0-9.]*", "g")

local editorInputFieldOffsetY = FlavorUI_TextField:new('editorInputFieldOffsetY', '', OFFSET_FIELD2_X, OFFSET_SECTION_FIELD_Y, 130, '')
editorInputFieldOffsetY.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldOffsetY.size = 20
editorInputFieldOffsetY.max_length = 10
editorInputFieldOffsetY.caret_y = 2
editorInputFieldOffsetY.caret_width = 2.5
editorInputFieldOffsetY.caret_height = 20
editorInputFieldOffsetY.placeholder_content = '000.00'
editorInputFieldOffsetY:create()
editorInputFieldOffsetY:set_customFilterPattern("[^0-9.]*", "g")

-- Size --

local SIZE_SECTION_Y = (263.44 - 5.72)
local SIZE_SECTION_FIELD_Y = SIZE_SECTION_Y + 7

local SIZE_FIELD1_X = 40+8
local SIZE_FIELD2_X = 240+8

local editorInputFieldSizeX = FlavorUI_TextField:new('editorInputFieldSizeX', '', SIZE_FIELD1_X, SIZE_SECTION_FIELD_Y, 130, '')
editorInputFieldSizeX.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldSizeX.size = 20
editorInputFieldSizeX.max_length = 10
editorInputFieldSizeX.caret_y = 2
editorInputFieldSizeX.caret_width = 2.5
editorInputFieldSizeX.caret_height = 20
editorInputFieldSizeX.placeholder_content = '000.00'
editorInputFieldSizeX:create()
editorInputFieldSizeX:set_customFilterPattern("[^0-9.]*", "g")

local editorInputFieldSizeY = FlavorUI_TextField:new('editorInputFieldSizeY', '', SIZE_FIELD2_X, SIZE_SECTION_FIELD_Y, 130, '')
editorInputFieldSizeY.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldSizeY.size = 20
editorInputFieldSizeY.max_length = 10
editorInputFieldSizeY.caret_y = 2
editorInputFieldSizeY.caret_width = 2.5
editorInputFieldSizeY.caret_height = 20
editorInputFieldSizeY.placeholder_content = '000.00'
editorInputFieldSizeY:create()
editorInputFieldSizeY:set_customFilterPattern("[^0-9.]*", "g")

function onUpdate(elapsed)
     editorInputFieldOffsetX:update()
     editorInputFieldOffsetY:update()

     editorInputFieldSizeX:update()
     editorInputFieldSizeY:update()

     mouse:update()
end