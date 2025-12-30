luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
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
     if keyboardJustConditionPressed('ONE',    not getVar('skinSearchInputFocus')) then 
          SkinNoteSave:flush() end
     if keyboardJustConditionPressed('ESCAPE', not getVar('skinSearchInputFocus')) then 
          SkinNoteSave:flush() 
     end
end

--- Loads the saved attribute properties and other elements for graphical correction.
---@return nil
function SkinNotesSave:save_load()
     self:create(self.SELECT_SKIN_PAGE_INDEX)
     self:checkbox_sync()

     local displayScrollThumbTag = 'displaySliderIcon'
     local scrollbarMajorPositionIndex  = self.SCROLLBAR_TRACK_MAJOR_SNAP[self.SELECT_SKIN_PAGE_INDEX]
     local scrollbarMajorPositionIsReal = math.isReal(scrollbarMajorPositionIndex)
     local scrollbarMajorPosition = scrollbarMajorPositionIsReal and scrollbarMajorPositionIndex or 0
     playAnim(displayScrollThumbTag, 'static')
     setProperty(F"{displayScrollThumbTag}.y", scrollbarMajorPosition)

     setTextString('genInfoStateName', ' '..self.stateClass:upperAtStart())
end

--- Loads and syncs the saved selected highlight. 
---@return nil
function SkinNotesSave:save_selection()
     if self.SELECT_SKIN_PRE_SELECTION_INDEX == 0 then
          return
     end

     local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{self.SELECT_SKIN_PRE_SELECTION_INDEX}"
     if luaSpriteExists(displaySkinIconButtonTag) == true then
          playAnim(displaySkinIconButtonTag, 'selected', true)

          local curIndex = self.SELECT_SKIN_CUR_SELECTION_INDEX - (MAX_NUMBER_CHUNK * (self.SELECT_SKIN_PAGE_INDEX - 1))
          self.TOTAL_SKIN_OBJECTS_SELECTED[self.SELECT_SKIN_PAGE_INDEX][curIndex] = true
     end
end

return SkinNotesSave