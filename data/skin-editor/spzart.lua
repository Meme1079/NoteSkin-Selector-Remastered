local FlavorUI_TextField = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_TextField'
local FlavorUI_Mouse     = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_Mouse'
local EditorNotes        = require 'mods.NoteSkin Selector Remastered.api.classes.editor.notes.EditorNotes'

local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'

local mouse = FlavorUI_Mouse:new('ui/cursor', 0.4, {-4,0})
mouse:create()

local field_X = FlavorUI_TextField:new('field_X', '', 40+8, (163.44 - 5.72)+7, 130, '')
field_X.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
field_X.size = 20
field_X.max_length = 10
field_X.caret_y = 2
field_X.caret_width = 2.5
field_X.caret_height = 20
field_X.placeholder_content = '000.00'
field_X:create()
field_X:set_customFilterPattern("[^0-9.]*", "g")

local field_Y = FlavorUI_TextField:new('field_Y', '', 240+8, (163.44 - 5.72)+7, 130, '')
field_Y.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
field_Y.size = 20
field_Y.max_length = 10
field_Y.caret_y = 2
field_Y.caret_width = 2.5
field_Y.caret_height = 20
field_Y.placeholder_content = '000.00'
field_Y:create()
field_Y:set_customFilterPattern("[^0-9.]*", "g")

function onUpdate(elapsed)
     field_X:update()
     field_Y:update()

     mouse:update()
end



--[[ local editorTextFieldConfirmX = FlavorUI_TextField:new('editorTextFieldConfirmX', '', 240, (563.44 + 0.56)+(25*-6), 140, '')
editorTextFieldConfirmX.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorTextFieldConfirmX.size = 22
editorTextFieldConfirmX.max_length = 10
editorTextFieldConfirmX.placeholder_content = '000.00'
editorTextFieldConfirmX:create()
editorTextFieldConfirmX:set_customFilterPattern("[^0-9.]*", "g")

local editorTextFieldPressedX = FlavorUI_TextField:new('editorTextFieldPressedX', '', 240, (563.44 + 0.56)+(25*-4), 140, '')
editorTextFieldPressedX.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorTextFieldPressedX.size = 22
editorTextFieldPressedX.max_length = 10
editorTextFieldPressedX.placeholder_content = '000.00'
editorTextFieldPressedX:create()
editorTextFieldPressedX:set_customFilterPattern("[^0-9.]*", "g")

local editorTextFieldColoredX = FlavorUI_TextField:new('editorTextFieldColoredX', '', 240, (563.44 + 0.56)+(25*-2), 140, '')
editorTextFieldColoredX.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorTextFieldColoredX.size = 22
editorTextFieldColoredX.max_length = 10
editorTextFieldColoredX.placeholder_content = '000.00'
editorTextFieldColoredX:create()
editorTextFieldColoredX:set_customFilterPattern("[^0-9.]*", "g")

local editorTextFieldStrumX = FlavorUI_TextField:new('editorTextFieldStrumX', '', 240, 563.44 + 0.56, 140, '')
editorTextFieldStrumX.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorTextFieldStrumX.size = 22
editorTextFieldStrumX.max_length = 10
editorTextFieldStrumX.placeholder_content = '000.00'
editorTextFieldStrumX:create()
editorTextFieldStrumX:set_customFilterPattern("[^0-9.]*", "g") -- ("(\\\\d*\\\\.\\\\d{3})?

local editorTextFieldConfirmY = FlavorUI_TextField:new('editorTextFieldConfirmY', '', 250+240, (563.44 + 0.56)+(25*-6), 140, '')
editorTextFieldConfirmY.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorTextFieldConfirmY.size = 22
editorTextFieldConfirmY.max_length = 10
editorTextFieldConfirmY.placeholder_content = '000.00'
editorTextFieldConfirmY:create()
editorTextFieldConfirmY:set_customFilterPattern("[^0-9.]*", "g")

local editorTextFieldPressedY = FlavorUI_TextField:new('editorTextFieldPressedY', '', 250+240, (563.44 + 0.56)+(25*-4), 140, '')
editorTextFieldPressedY.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorTextFieldPressedY.size = 22
editorTextFieldPressedY.max_length = 10
editorTextFieldPressedY.placeholder_content = '000.00'
editorTextFieldPressedY:create()
editorTextFieldPressedY:set_customFilterPattern("[^0-9.]*", "g")

local editorTextFieldColoredY = FlavorUI_TextField:new('editorTextFieldColoredY', '', 250+240, (563.44 + 0.56)+(25*-2), 140, '')
editorTextFieldColoredY.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorTextFieldColoredY.size = 22
editorTextFieldColoredY.max_length = 10
editorTextFieldColoredY.placeholder_content = '000.00'
editorTextFieldColoredY:create()
editorTextFieldColoredY:set_customFilterPattern("[^0-9.]*", "g")

local editorTextFieldStrumY = FlavorUI_TextField:new('editorTextFieldStrumY', '', 250+240, (563.44 + 0.56), 140, '')
editorTextFieldStrumY.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorTextFieldStrumY.size = 22
editorTextFieldStrumY.max_length = 10
editorTextFieldStrumY.placeholder_content = '000.00'
editorTextFieldStrumY:create()
editorTextFieldStrumY:set_customFilterPattern("[^0-9.]*", "g")

function onUpdate(elapsed)
     editorTextFieldConfirmX:update()
     editorTextFieldPressedX:update()
     editorTextFieldColoredX:update()
     editorTextFieldStrumX:update()
     
     editorTextFieldConfirmY:update()
     editorTextFieldPressedY:update()
     editorTextFieldColoredY:update()
     editorTextFieldStrumY:update()

     mouse:update()
end ]]