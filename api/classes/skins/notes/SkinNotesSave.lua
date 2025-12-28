luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local math      = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local switch            = global.switch
local createTimer       = funkinlua.createTimer
local hoverObject       = funkinlua.hoverObject
local clickObject       = funkinlua.clickObject
local pressedObject     = funkinlua.pressedObject
local releasedObject    = funkinlua.releasedObject
local addCallbackEvents = funkinlua.addCallbackEvents
local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionPress    = funkinlua.keyboardJustConditionPress
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

local SkinNoteSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

local MAX_NUMBER_CHUNK = 16

--- Childclass extension, main saving data component functionality for the note skin state.
---@class SkinNotesSave
local SkinNotesSave = {}

--- Saves the attributes current properties when exiting the main skin state.
---@return nil
function SkinNotesSave:save()
     if keyboardJustConditionPressed('ONE',    not getVar('skinSearchInputFocus')) then SkinNoteSave:flush() end
     if keyboardJustConditionPressed('ESCAPE', not getVar('skinSearchInputFocus')) then SkinNoteSave:flush() end
end

--- Loads the saved attribute properties and other elements for graphical correction.
---@return nil
function SkinNotesSave:save_load()
     self:create(self.selectSkinPagePositionIndex)
     self:checkbox_sync()

     if math.isReal(self.sliderTrackIntervals[self.selectSkinPagePositionIndex]) == true then
          setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.selectSkinPagePositionIndex])
     else
          setProperty('displaySliderIcon.y', 0)
     end
     playAnim('displaySliderIcon', 'static')
     setTextString('genInfoStateName', ' '..self.stateClass:upperAtStart())
end

--- Loads and syncs the saved selected highlight. 
---@return nil
function SkinNotesSave:save_selection()
     if self.selectSkinPreSelectedIndex == 0 then
          return
     end

     local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = self.selectSkinPreSelectedIndex}
     local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
     if luaSpriteExists(displaySkinIconButton) == true then
          playAnim(displaySkinIconButton, 'selected', true)

          local curIndex = self.selectSkinCurSelectedIndex - (MAX_NUMBER_CHUNK * (self.selectSkinPagePositionIndex - 1))
          self.totalSkinObjectSelected[self.selectSkinPagePositionIndex][curIndex] = true
     end
end

return SkinNotesSave