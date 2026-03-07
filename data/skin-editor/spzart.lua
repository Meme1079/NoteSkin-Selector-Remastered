local FlavorUI_TextField = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_TextField'
local FlavorUI_Mouse     = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_Mouse'
local EditorNotes        = require 'mods.NoteSkin Selector Remastered.api.classes.editor.notes.EditorNotes'

local mouse = FlavorUI_Mouse:new('ui/cursor', 0.4, {-4,0})
mouse:create()

local text = FlavorUI_TextField:new('editorTextFieldStrum', '', 240, 563.44 + 0.56, 140, '')
text.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
text.size = 22
text.max_length = 10
text.placeholder_content = '000.00'
text:create()

local text1 = FlavorUI_TextField:new('editorTextFieldColored', '', 240, (563.44 + 0.56)+(25*-2), 140, '')
text1.font = 'NoteSkin Selector Remastered/fonts/tomo.otf'
text1.size = 22
text1.max_length = 10
text1.placeholder_content = '000.00'
text1:create()

function onUpdate(elapsed)
     text:update()
     text1:update()
     mouse:update()
end