local FlavorUI_TextField = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_TextField'
local FlavorUI_Button    = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_Button'
local FlavorUI_Mouse     = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_Mouse'

local EditorNotes         = require 'mods.NoteSkin Selector Remastered.api.classes.editor.notes.EditorNotes'
local EditorNotesTemplate = require 'mods.NoteSkin Selector Remastered.api.classes.editor.notes.EditorNotesTemplate'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local math      = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local kbCondJustPressed = funkinlua.kbCondJustPressed

---@enum BORDERS
local BORDERS = {
     LEFT  = 207,
     RIGHT = -545,
     UP    = 177,
     DOWN  = -440
}

local calcPosX = function(x, offsetX) return x + offsetX          end
local calcPosY = function(y, offsetY) return (y - 5.72) + offsetY end

-- Main --

local mouse = FlavorUI_Mouse:new(0.4, {-4,0})
mouse:create()

--- Offset ---

local editorInputFieldOffsetX = FlavorUI_TextField:new('editorInputFieldOffsetX', '', calcPosX(40, 8), calcPosY(130.5, 7), 130)
editorInputFieldOffsetX.font             = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldOffsetX.size             = 20
editorInputFieldOffsetX.maxLength        = 7
editorInputFieldOffsetX.caret_offset_y   = -2
editorInputFieldOffsetX.caret_width      = 2.5
editorInputFieldOffsetX.caret_height     = 20
editorInputFieldOffsetX.placeholder_text = '000.00'
editorInputFieldOffsetX.onChange         = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldOffsetX:add()
editorInputFieldOffsetX:set_customFilterPattern("[^-0-9.]*", "g")
mouse:add_element('editorInputSpriteOffsetX')

local editorInputFieldOffsetY = FlavorUI_TextField:new('editorInputFieldOffsetY', '', calcPosX(240, 8), calcPosY(130.5, 7), 130)
editorInputFieldOffsetY.font             = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldOffsetY.size             = 20
editorInputFieldOffsetY.maxLength        = 6
editorInputFieldOffsetY.caret_offset_y   = -2
editorInputFieldOffsetY.caret_width      = 2.5
editorInputFieldOffsetY.caret_height     = 20
editorInputFieldOffsetY.placeholder_text = '000.00'
editorInputFieldOffsetY.onChange         = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldOffsetY:add()
editorInputFieldOffsetY:set_customFilterPattern("[^-0-9.]*", "g")
mouse:add_element('editorInputSpriteOffsetY')

--- Size ---

local editorInputFieldSizeX = FlavorUI_TextField:new('editorInputFieldSizeX', '', calcPosX(40, 8), calcPosY(230.5, 7), 130)
editorInputFieldSizeX.font             = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldSizeX.size             = 20
editorInputFieldSizeX.maxLength        = 6
editorInputFieldSizeX.caret_offset_y   = -2
editorInputFieldSizeX.caret_width      = 2.5
editorInputFieldSizeX.caret_height     = 20
editorInputFieldSizeX.placeholder_text = '000.00'
editorInputFieldSizeX.onChange         = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldSizeX:add()
editorInputFieldSizeX:set_customFilterPattern("[^0-9.]*", "g")
mouse:add_element('editorInputSpriteSizeX')

local editorInputFieldSizeY = FlavorUI_TextField:new('editorInputFieldSizeY', '', calcPosX(240, 8), calcPosY(230.5, 7), 130)
editorInputFieldSizeY.font             = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldSizeY.size             = 20
editorInputFieldSizeY.maxLength        = 6
editorInputFieldSizeY.caret_offset_y   = -2
editorInputFieldSizeY.caret_width      = 2.5
editorInputFieldSizeY.caret_height     = 20
editorInputFieldSizeY.placeholder_text = '000.00'
editorInputFieldSizeY.onChange         = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldSizeY:add()
editorInputFieldSizeY:set_customFilterPattern("[^0-9.]*", "g")
mouse:add_element('editorInputSpriteSizeY')

--- Frames ---

local editorInputFieldFrames = FlavorUI_TextField:new('editorInputFieldFrames', '', calcPosX(40, 8), calcPosY(330.5, 7), 130)
editorInputFieldFrames.font             = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldFrames.size             = 20
editorInputFieldFrames.maxLength        = 6
editorInputFieldFrames.caret_offset_y   = -2
editorInputFieldFrames.caret_width      = 2.5
editorInputFieldFrames.caret_height     = 20
editorInputFieldFrames.placeholder_text = '00'
editorInputFieldFrames.onChange         = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldFrames:add()
editorInputFieldFrames:set_customFilterPattern("[^0-9]*", "g")
mouse:add_element('editorInputSpriteFrames')

--- File ---

local editorInputFieldFiles = FlavorUI_TextField:new('editorInputFieldFiles', '', calcPosY(15, 8), calcPosY((430.5+530.5)/2, 6), 360)
editorInputFieldFiles.font                 = 'NoteSkin Selector Remastered/fonts/cooper-hewitt heavy.ttf'
editorInputFieldFiles.size                 = 17
editorInputFieldFiles.maxLength            = 11+50
editorInputFieldFiles.offset_y             = -9
editorInputFieldFiles.selection_offset_y   = -13
editorInputFieldFiles.caret_offset_y       = -3
editorInputFieldFiles.caret_width          = 2.5
editorInputFieldFiles.caret_height         = 20
editorInputFieldFiles.antialiasing         = false
editorInputFieldFiles.placeholder_text     = 'folder/skin'
editorInputFieldFiles.placeholder_offset_x = -1
editorInputFieldFiles.placeholder_offset_y = -9
editorInputFieldFiles.onChange             = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldFiles:add()
mouse:add_element('editorInputSpriteFile')

--- Save ---

local editorInputFieldSaveFile = FlavorUI_TextField:new('editorInputFieldSaveFile', '', calcPosY(15, 8), calcPosY((530.5+630.5)/2, 6), 360)
editorInputFieldSaveFile.font                 = 'NoteSkin Selector Remastered/fonts/cooper-hewitt heavy.ttf'
editorInputFieldSaveFile.size                 = 17
editorInputFieldSaveFile.maxLength            = 11+50
editorInputFieldSaveFile.offset_y             = -9
editorInputFieldSaveFile.selection_offset_y   = -13
editorInputFieldSaveFile.caret_offset_y       = -3
editorInputFieldSaveFile.caret_width          = 2.5
editorInputFieldSaveFile.caret_height         = 20
editorInputFieldSaveFile.antialiasing         = false
editorInputFieldSaveFile.placeholder_text     = '/folder...'
editorInputFieldSaveFile.placeholder_offset_x = -1
editorInputFieldSaveFile.placeholder_offset_y = -9
editorInputFieldSaveFile.onChange             = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldSaveFile:add()
mouse:add_element('editorInputSpriteSaveFile')

local editorSaveDataSprite = FlavorUI_Button:new('editorSaveDataSprite')
mouse:add_element('editorSaveDataSprite')

-- Updates --

local b = EditorNotesTemplate:new('noteSkins/NOTE_assets')
b:create()

local a = EditorNotes:new('editorNotes', 'noteSkins/NOTE_assets-DSides')
a.mouse = mouse
a:create()

local pp = 0
function onUpdate(elapsed)
     editorInputFieldOffsetX:update()
     editorInputFieldOffsetY:update()
     editorInputFieldSizeX:update()
     editorInputFieldSizeY:update()
     editorInputFieldFrames:update()
     editorInputFieldFiles:update()
     editorInputFieldSaveFile:update()
     editorSaveDataSprite:update()
     mouse:update()

     -- Main Stuff --

     local FlavorUI_TextField_Focus = getPropertyFromClass('backend.ui.PsychUIInputText', 'focusOn') == nil
     a:update_animations()
     a:update_movement()
     
     if FlavorUI_TextField_Focus then
          editorInputFieldOffsetX:set_field( math.round(a:get_offset_data_x(), 2) )
          editorInputFieldOffsetY:set_field( math.round(a:get_offset_data_y(), 2) )
     end

     if kbCondJustPressed('ENTER', editorInputFieldOffsetX:focused()) then
          a:set_offset_data_x(editorInputFieldOffsetX:get_field())

          local status, result = pcall(math.round, editorInputFieldOffsetX:get_field():gsub('%-%-+', '-'), 2)
          editorInputFieldOffsetX:set_field(status == true and result or a:get_offset_data_x())
          editorInputFieldOffsetX:set_caret_index(#editorInputFieldOffsetX:get_field())
     end
     if kbCondJustPressed('ENTER', editorInputFieldOffsetY:focused()) then
          a:set_offset_data_y(editorInputFieldOffsetY:get_field())

          local status, result = pcall(math.round, editorInputFieldOffsetY:get_field():gsub('%-%-+', '-'), 2)
          editorInputFieldOffsetY:set_field(status == true and result or a:get_offset_data_y())
          editorInputFieldOffsetY:set_caret_index(#editorInputFieldOffsetY:get_field())
     end

     if kbCondJustPressed('ENTER', editorInputFieldFiles:focused())  then
          if checkFileExists(F"images/noteSkins/${editorInputFieldFiles:entered()}.png") == false then
               editorInputFieldFiles:invalid_field('0xffff0000', 'Skin Doesn\\\'t Exist!')
               return
          end
          a:texture('noteskins/'..editorInputFieldFiles:entered())
     end
     if kbCondJustPressed('Z', FlavorUI_TextField_Focus) then
          b:set_order(100)
     end
     if kbCondJustPressed('X', FlavorUI_TextField_Focus) then
          b:set_order(3)
     end
end