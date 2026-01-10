luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local math      = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.newglobal'

local MAX_NUMBER_CHUNK = global.MAX_NUMBER_CHUNK

local keyboardJustConditionPressed = funkinlua.keyboardJustConditionPressed

--- Childclass extension, main saving data component functionality for the note skin state.
---@class SkinNotesSave
local SkinNotesSave = {}
local SkinNotesGSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

--- Saves all the current component attribute values, and other data for the noteskin state.
---@return nil
function SkinNotesSave:save()
     if keyboardJustConditionPressed('ONE',    not getVar('skinSearchInputFocus')) then 
          SkinNotesGSave:flush() end
     if keyboardJustConditionPressed('ESCAPE', not getVar('skinSearchInputFocus')) then 
          SkinNotesGSave:flush() 
     end
end

--- Loads the saved component attribute values, along with the other data.
---@return nil
function SkinNotesSave:save_load()
     self:create(self.SCROLLBAR_PAGE_INDEX)
     self:checkbox_sync()

     local displayScrollThumbTag = 'displaySliderIcon'

     local scrollbarMajorPositionIndex  = self.SCROLLBAR_TRACK_MAJOR_SNAP[self.SCROLLBAR_PAGE_INDEX]
     local scrollbarMajorPositionIsReal = math.isReal(scrollbarMajorPositionIndex)
     local scrollbarMajorPositionFixed  = scrollbarMajorPositionIsReal and scrollbarMajorPositionIndex or 0
     playAnim(displayScrollThumbTag, 'static')
     setProperty(F"{displayScrollThumbTag}.y", scrollbarMajorPositionFixed)
     setTextString('genInfoStateName', F" {self.stateClass:upperAtStart()}")
end

--- Syncs the saved selection highlight corresponding correct position and offset values.
---@protected
---@return nil
function SkinNotesSave:save_selection()
     if self.SELECT_SKIN_PRE_SELECTION_INDEX == 0 then
          return
     end

     local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{self.SELECT_SKIN_PRE_SELECTION_INDEX}"
     if luaSpriteExists(displaySkinIconButtonTag) == true then
          playAnim(displaySkinIconButtonTag, 'selected', true)

          local curIndex = self.SELECT_SKIN_CUR_SELECTION_INDEX - (MAX_NUMBER_CHUNK * (self.SCROLLBAR_PAGE_INDEX - 1))
          self.TOTAL_SKIN_OBJECTS_SELECTED[self.SCROLLBAR_PAGE_INDEX][curIndex] = true
     end
end

return SkinNotesSave