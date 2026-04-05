local FlavorUI_TextField = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_TextField'
local FlavorUI_Button    = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_Button'
local FlavorUI_Mouse     = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_Mouse'
local EditorNotes        = require 'mods.NoteSkin Selector Remastered.api.classes.editor.notes.EditorNotes'

local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'

local calcPosX = function(x, offsetX) return x + offsetX          end
local calcPosY = function(y, offsetY) return (y - 5.72) + offsetY end

-- Offset --

local editorInputFieldOffsetX = FlavorUI_TextField:new('editorInputFieldOffsetX', '', calcPosX(40, 8), calcPosY(130.5, 7), 130)
editorInputFieldOffsetX.font             = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldOffsetX.size             = 20
editorInputFieldOffsetX.maxLength        = 10
editorInputFieldOffsetX.caret_offset_y   = -2
editorInputFieldOffsetX.caret_width      = 2.5
editorInputFieldOffsetX.caret_height     = 20
editorInputFieldOffsetX.placeholder_text = '000.00'
editorInputFieldOffsetX.onFieldMax       = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldOffsetX.onChange         = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldOffsetX:add()
editorInputFieldOffsetX:set_customFilterPattern("[^0-9.]*", "g")

local editorInputFieldOffsetY = FlavorUI_TextField:new('editorInputFieldOffsetY', '', calcPosX(240, 8), calcPosY(130.5, 7), 130)
editorInputFieldOffsetY.font             = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldOffsetY.size             = 20
editorInputFieldOffsetY.maxLength        = 10
editorInputFieldOffsetY.caret_offset_y   = -2
editorInputFieldOffsetY.caret_width      = 2.5
editorInputFieldOffsetY.caret_height     = 20
editorInputFieldOffsetY.placeholder_text = '000.00'
editorInputFieldOffsetY.onFieldMax       = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldOffsetY.onChange         = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldOffsetY:add()
editorInputFieldOffsetY:set_customFilterPattern("[^0-9.]*", "g")

-- Size --

local editorInputFieldSizeX = FlavorUI_TextField:new('editorInputFieldSizeX', '', calcPosX(40, 8), calcPosY(230.5, 7), 130)
editorInputFieldSizeX.font             = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldSizeX.size             = 20
editorInputFieldSizeX.maxLength        = 10
editorInputFieldSizeX.caret_offset_y   = -2
editorInputFieldSizeX.caret_width      = 2.5
editorInputFieldSizeX.caret_height     = 20
editorInputFieldSizeX.placeholder_text = '000.00'
editorInputFieldSizeX.onFieldMax       = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldSizeX.onChange         = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldSizeX:add()
editorInputFieldSizeX:set_customFilterPattern("[^0-9.]*", "g")

local editorInputFieldSizeY = FlavorUI_TextField:new('editorInputFieldSizeY', '', calcPosX(240, 8), calcPosY(230.5, 7), 130)
editorInputFieldSizeY.font             = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldSizeY.size             = 20
editorInputFieldSizeY.maxLength        = 10
editorInputFieldSizeY.caret_offset_y   = -2
editorInputFieldSizeY.caret_width      = 2.5
editorInputFieldSizeY.caret_height     = 20
editorInputFieldSizeY.placeholder_text = '000.00'
editorInputFieldSizeY.onFieldMax       = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldSizeY.onChange         = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldSizeY:add()
editorInputFieldSizeY:set_customFilterPattern("[^0-9.]*", "g")

-- Frames --

local editorInputFieldFrames = FlavorUI_TextField:new('editorInputFieldFrames', '', calcPosX(40, 8), calcPosY(330.5, 7), 130)
editorInputFieldFrames.font             = 'NoteSkin Selector Remastered/fonts/tomo.otf'
editorInputFieldFrames.size             = 20
editorInputFieldFrames.maxLength        = 3
editorInputFieldFrames.caret_offset_y   = -2
editorInputFieldFrames.caret_width      = 2.5
editorInputFieldFrames.caret_height     = 20
editorInputFieldFrames.placeholder_text = '00'
editorInputFieldFrames.onFieldMax       = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldFrames.onChange         = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldFrames:add()
editorInputFieldFrames:set_customFilterPattern("[^0-9]*", "g")

-- File --

local editorInputFieldFiles = FlavorUI_TextField:new('editorInputFieldFiles', 'NOTE_assets-', calcPosY(15, 8), calcPosY((430.5+530.5)/2, 6), 360)
editorInputFieldFiles.font                 = 'NoteSkin Selector Remastered/fonts/TOMO Sponge Regular.otf'
editorInputFieldFiles.size                 = 20
editorInputFieldFiles.maxLength            = 11+50
editorInputFieldFiles.caret_offset_y       = -3
editorInputFieldFiles.caret_width          = 2.5
editorInputFieldFiles.caret_height         = 20
editorInputFieldFiles.antialiasing         = false
editorInputFieldFiles.placeholder_text     = 'NOTE_assets-'
editorInputFieldFiles.placeholder_offset_x = -1
editorInputFieldFiles.onFieldMax           = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldFiles.onChange             = [[ 
     FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1);

     if (StringTools.startsWith(curText, "NOTE_assets-") == false) {
          this.set_text("NOTE_assets-");
          this.set_caretIndex(12);
     }
]]
editorInputFieldFiles:add()

-- Save --

local editorInputFieldSaveFile = FlavorUI_TextField:new('editorInputFieldSaveFile', '', calcPosY(15, 8), calcPosY((530.5+630.5)/2, 6), 360)
editorInputFieldSaveFile.font                 = 'NoteSkin Selector Remastered/fonts/TOMO Sponge Regular.otf'
editorInputFieldSaveFile.size                 = 20
editorInputFieldSaveFile.maxLength            = 11+50
editorInputFieldSaveFile.caret_offset_y       = -3
editorInputFieldSaveFile.caret_width          = 2.5
editorInputFieldSaveFile.caret_height         = 20
editorInputFieldSaveFile.antialiasing         = false
editorInputFieldSaveFile.placeholder_text     = '/folder...'
editorInputFieldSaveFile.placeholder_offset_x = -1
editorInputFieldSaveFile.onFieldMax           = [[ FlxG.sound.play(Paths.sound('cancel'), 0.5); ]]
editorInputFieldSaveFile.onChange             = [[ FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1); ]]
editorInputFieldSaveFile:add()

local editorSaveDataSprite = FlavorUI_Button:new('editorSaveDataSprite')

-- Mouse --

local mouse = FlavorUI_Mouse:new(0.4, {-4,0})
mouse:create()

mouse:add_element('editorInputSpriteOffsetX')
--

--[[ mouse:add_element('hand', editorInputSpriteOffsetX, editorInputSpriteOffsetY)
mouse:add_element('hand', editorInputSpriteSizeX, editorInputSpriteSizeY)
mouse:add_element('hand', editorInputSpriteFrames, editorInputSpriteFile, editorInputSpriteSaveFile)
mouse:add_element('hand', editorSaveDataSprite)
mouse:create() ]]

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

     if keyboardJustPressed('T') then
          mouse:remove_element('editorInputSpriteOffsetX')
     end
     if keyboardJustPressed('F') then
          mouse:add_element('editorInputSpriteOffsetX')
     end

     --[[ if keyboardJustPressed('R') then
          editorSaveDataSprite:set_variant('disabled')
          mouse:switch_variant('hand', 'disable', editorSaveDataSprite)
     end
     if keyboardJustPressed('D') then
          editorSaveDataSprite:set_variant('static')
          mouse:switch_variant('disable', 'hand', editorSaveDataSprite)
     end

     if keyboardJustPressed('T') then
          editorSaveDataSprite:deactivation()
          mouse:remove_elementAll(editorSaveDataSprite)
     end
     if keyboardJustPressed('F') then
          editorSaveDataSprite:reactivation()
          mouse:add_element(editorSaveDataSprite.mouseVariant, editorSaveDataSprite)
     end
     mouse:update() ]]
end