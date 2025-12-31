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

--- Childclass extension, main page component functionality for the note skin state.
---@class SkinNotesPage
local SkinNotesPage = {}

local SCROLLBAR_THUMB_SYNC = false -- * Ignore this btw
--- Main page slider functionality for switching throughout multiple pages.
---@param snapToPage? boolean Allows the scrollbar thumb to snap to its nearest page-index.
---@return nil
function SkinNotesPage:page_slider(snapToPage)
     local snapToPage = snapToPage == nil and true or false

     local displayScrollThumbTag = 'displaySliderIcon'
     if clickObject(displayScrollThumbTag, 'camHUD') then
          self.SCROLLBAR_TRACK_THUMB_PRESSED = true
     end

     local MINIMUM_SKIN_LIMIT = 1
     if self.TOTAL_SKIN_LIMIT <= MINIMUM_SKIN_LIMIT then
          playAnim(displayScrollThumbTag, 'unscrollable')
     end
     if self.TOTAL_SKIN_LIMIT > MINIMUM_SKIN_LIMIT and self.SCROLLBAR_TRACK_THUMB_PRESSED == true then
          local DISPLAY_SCROLL_THUMB_HEIGHT   = getProperty('displaySliderIcon.height')
          local DISPLAY_SCROLL_THUMB_OFFSET_Y = getMouseY('camHUD') - (DISPLAY_SCROLL_THUMB_HEIGHT / 2)
          if mousePressed('left') then
               playAnim(displayScrollThumbTag, 'pressed')
               setProperty(F"{displayScrollThumbTag}.y", DISPLAY_SCROLL_THUMB_OFFSET_Y)
          end
          if mouseReleased('left') then
               playAnim(displayScrollThumbTag, 'static')
               self.SCROLLBAR_TRACK_THUMB_PRESSED = false 
          end
     end

     local DISPLAY_SCROLL_THUMB_MIN_POSITION_Y = 127
     local DISPLAY_SCROLL_THUMB_MAX_POSITION_Y = 643
     if getProperty(F"{displayScrollThumbTag}.y") <= DISPLAY_SCROLL_THUMB_MIN_POSITION_Y then
          setProperty(F"{displayScrollThumbTag}.y", DISPLAY_SCROLL_THUMB_MIN_POSITION_Y)
     end
     if getProperty(F"{displayScrollThumbTag}.y") >= DISPLAY_SCROLL_THUMB_MAX_POSITION_Y then
          setProperty(F"{displayScrollThumbTag}.y", DISPLAY_SCROLL_THUMB_MAX_POSITION_Y)
     end

     --- Calculates the page position by using the scroll thumb's position.
     --- By check its range between the major and minor snap positions.
     ---@return number|boolean
     local function calculateScrollCurrentRangePage()
          local displayScrollThumbPositionY = getProperty(F"{displayScrollThumbTag}.y")

          local STARTING_SNAP_POSITION = 2
          for snapIndex = STARTING_SNAP_POSITION, #self.SCROLLBAR_TRACK_MAJOR_SNAP do
               local scrollbarMajorSnapIndexBehind = self.SCROLLBAR_TRACK_MAJOR_SNAP[snapIndex-1]
               local scrollbarMinorSnapIndexBehind = self.SCROLLBAR_TRACK_MINOR_SNAP[snapIndex-1]

               local SCROLLBAR_MAXIMUM_RANGE = scrollbarMajorSnapIndexBehind > displayScrollThumbPositionY
               local SCROLLBAR_MINIMUM_RANGE = displayScrollThumbPositionY  <= scrollbarMinorSnapIndexBehind
               if SCROLLBAR_MINIMUM_RANGE and SCROLLBAR_MAXIMUM_RANGE then 
                    return snapIndex - STARTING_SNAP_POSITION 
               end
          end
          return false
     end
     local SCROLLBAR_CURRENT_PAGE_INDEX = calculateScrollCurrentRangePage()

     local SCROLLBAR_CURRENT_PAGE_IS_NUMBER     = SCROLLBAR_CURRENT_PAGE_INDEX ~= false
     local SCROLLBAR_CURRENT_PAGE_IS_SAME_INDEX = SCROLLBAR_CURRENT_PAGE_INDEX ~= self.SCROLLBAR_PAGE_INDEX
     if SCROLLBAR_CURRENT_PAGE_IS_NUMBER and SCROLLBAR_CURRENT_PAGE_IS_SAME_INDEX and self.SCROLLBAR_TRACK_THUMB_PRESSED == true then
          self.SELECT_SKIN_PAGE_INDEX = SCROLLBAR_CURRENT_PAGE_INDEX
          self.SCROLLBAR_PAGE_INDEX   = SCROLLBAR_CURRENT_PAGE_INDEX
          self:create(SCROLLBAR_CURRENT_PAGE_INDEX)
          self:checkbox_sync()

          if self.SCROLLBAR_PAGE_INDEX == self.TOTAL_SKIN_LIMIT then
               setTextColor('genInfoStatePage', 'ff0000')
          else
               setTextColor('genInfoStatePage', 'ffffff')
          end

          playSound('ding', 0.5)
          callOnScripts('skinSearchInput_callResetSearch')
          SkinNoteSave:set('SCROLLBAR_PAGE_INDEX',   self.stateClass:upper(), self.SCROLLBAR_PAGE_INDEX)
          SkinNoteSave:set('SELECT_SKIN_PAGE_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PAGE_INDEX)
     end

     if self.TOTAL_SKIN_LIMIT > MINIMUM_SKIN_LIMIT and self.SCROLLBAR_TRACK_THUMB_PRESSED == false then
          if not mouseReleased('left') and SCROLLBAR_THUMB_SYNC == true then
               return
          end
          SCROLLBAR_THUMB_SYNC = true

          local scrollbarMajorSnapIndex = self.SCROLLBAR_TRACK_MAJOR_SNAP[SCROLLBAR_CURRENT_PAGE_INDEX]
          local scrollbarIsPageMaxLimit = SCROLLBAR_CURRENT_PAGE_INDEX == self.TOTAL_SKIN_LIMIT
          if snapToPage == true then
               local SCROLLBAR_MID_RANGE_PAGE_INDEX = 2
               local SCROLLBAR_MAJOR_SNAP_OFFSET_Y  = 25

               if SCROLLBAR_CURRENT_PAGE_INDEX == self.TOTAL_SKIN_LIMIT then
                    setProperty(F"{displayScrollThumbTag}.y", DISPLAY_SCROLL_THUMB_MAX_POSITION_Y)
               elseif SCROLLBAR_CURRENT_PAGE_INDEX >= SCROLLBAR_MID_RANGE_PAGE_INDEX then
                    setProperty(F"{displayScrollThumbTag}.y", scrollbarMajorSnapIndex - SCROLLBAR_MAJOR_SNAP_OFFSET_Y)
               else
                    setProperty(F"{displayScrollThumbTag}.y", scrollbarMajorSnapIndex)
               end
          end 
     end
end

--- Creates slider-marks to each corresponding page within the slider track, for visual aid purposes.
---@return nil
function SkinNotesPage:page_slider_marks()
     local SCROLLBAR_METADATA_MAJOR = {
          NAME    = 'major',
          COLOR   = '3b8527',
          WIDTH   = 12 * 2,
          OFFSETX = 12 / 1
     }
     local SCROLLBAR_METADATA_MINOR = {
          NAME    = 'minor',
          COLOR   = '847500',
          WIDTH   = 12 * 1.5,
          OFFSETX = 12 / 0.8
     }

     local displayScrollThumbTag = 'displaySliderIcon'
     local function createSnapMarks(scrollbarTrackSnapObjects, scrollbarTrackSnapIndex, scrollbarTrackMetadata)
          local displayScrollSnapMarkTag = F"displaySliderMark{self.stateClass:upperAtStart()}{scrollbarTrackMetadata.NAME:upperAtStart()}{scrollbarTrackSnapIndex}"
          local displayScrollSnapMarkX   = getProperty(F"{displayScrollThumbTag}.x") + scrollbarTrackMetadata.OFFSETX
          local displayScrollSnapMarkY   = scrollbarTrackSnapObjects[scrollbarTrackSnapIndex]
     
          makeLuaSprite(displayScrollSnapMarkTag, nil, displayScrollSnapMarkX, displayScrollSnapMarkY)
          makeGraphic(displayScrollSnapMarkTag, scrollbarTrackMetadata.WIDTH, 3, scrollbarTrackMetadata.COLOR)
          setObjectOrder(displayScrollSnapMarkTag, getObjectOrder(displayScrollThumbTag))
          setObjectCamera(displayScrollSnapMarkTag, 'camHUD')
          setProperty(F"{displayScrollSnapMarkTag}.antialiasing", false)
          addLuaSprite(displayScrollSnapMarkTag)
     end

     for majorSnapIndex = 1, #self.SCROLLBAR_TRACK_MAJOR_SNAP do
          createSnapMarks(self.SCROLLBAR_TRACK_MAJOR_SNAP, majorSnapIndex, SCROLLBAR_METADATA_MAJOR)
     end
     for minorSnapIndex = 2, #self.SCROLLBAR_TRACK_MINOR_SNAP do -- 2-index start, prevent an extra snap mark sprite
          createSnapMarks(self.SCROLLBAR_TRACK_MINOR_SNAP, minorSnapIndex, SCROLLBAR_METADATA_MINOR)
     end
end

--- Main page moving functionality for switching throughout multiple pages.
---@return nil
function SkinNotesPage:page_moved()
     if self.SCROLLBAR_TRACK_THUMB_PRESSED == true then return end
     local gameControlPressedDown = keyboardJustConditionPressed('E', getVar('skinSearchInputFocus') == false)
     local gameControlPressedUp   = keyboardJustConditionPressed('Q', getVar('skinSearchInputFocus') == false)

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          if gameControlPressedUp or gameControlPressedDown then
               setTextColor('genInfoStatePage', 'f0b72f')
               playSound('cancel')
          end
          return
     end

     local totalSkinObjectsPagePerIds     = self.TOTAL_SKIN_OBJECTS_ID[self.SELECT_SKIN_PAGE_INDEX]
     local totalSkinObjectsPagePerClicked = self.TOTAL_SKIN_OBJECTS_CLICKED[self.SELECT_SKIN_PAGE_INDEX]
     for curIDs = totalSkinObjectsPagePerIds[1], totalSkinObjectsPagePerIds[#totalSkinObjectsPagePerIds] do
          local curSkinIDs = curIDs - (MAX_NUMBER_CHUNK * (self.SELECT_SKIN_PAGE_INDEX - 1))
          if totalSkinObjectsPagePerClicked[curSkinIDs] == true then
               if gameControlPressedUp and self.SELECT_SKIN_PAGE_INDEX > 1 then
                    setTextColor('genInfoStatePage', 'f0b72f')
                    playSound('cancel')
               end
               if gameControlPressedDown and self.SELECT_SKIN_PAGE_INDEX < self.TOTAL_SKIN_LIMIT then
                    setTextColor('genInfoStatePage', 'f0b72f')
                    playSound('cancel')
               end
               return
          end
     end

     local displayScrollThumbTag = 'displaySliderIcon'
     if gameControlPressedUp and self.SELECT_SKIN_PAGE_INDEX > 1 then
          self.SCROLLBAR_PAGE_INDEX   = self.SCROLLBAR_PAGE_INDEX   - 1
          self.SELECT_SKIN_PAGE_INDEX = self.SELECT_SKIN_PAGE_INDEX - 1
          self:create(self.SELECT_SKIN_PAGE_INDEX)
          self:checkbox_sync()

          playSound('ding', 0.5)
          setProperty(F"{displayScrollThumbTag}.y", self.SCROLLBAR_TRACK_MAJOR_SNAP[self.SELECT_SKIN_PAGE_INDEX])
          callOnScripts('skinSearchInput_callResetSearch')
          SkinNoteSave:set('SELECT_SKIN_PAGE_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PAGE_INDEX)
     end
     if gameControlPressedDown and self.SELECT_SKIN_PAGE_INDEX < self.TOTAL_SKIN_LIMIT then
          self.SCROLLBAR_PAGE_INDEX   = self.SCROLLBAR_PAGE_INDEX   + 1
          self.SELECT_SKIN_PAGE_INDEX = self.SELECT_SKIN_PAGE_INDEX + 1
          self:create(self.SELECT_SKIN_PAGE_INDEX)
          self:checkbox_sync()

          playSound('ding', 0.5)
          setProperty(F"{displayScrollThumbTag}.y", self.SCROLLBAR_TRACK_MAJOR_SNAP[self.SELECT_SKIN_PAGE_INDEX])
          callOnScripts('skinSearchInput_callResetSearch')
          SkinNoteSave:set('SELECT_SKIN_PAGE_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PAGE_INDEX)
     end

     if self.SELECT_SKIN_PAGE_INDEX == self.TOTAL_SKIN_LIMIT then
          setTextColor('genInfoStatePage', 'ff0000')
     else
          setTextColor('genInfoStatePage', 'ffffff')
     end
end

--- Updates the current page text, that is literally it.
---@return nil
function SkinNotesPage:page_text()
     local currentPageFormat = ('%.3d'):format(self.SELECT_SKIN_PAGE_INDEX)
     local maximumPageFormat = ('%.3d'):format(self.TOTAL_SKIN_LIMIT)
     setTextString('genInfoStatePage', F" Page {currentPageFormat} / {maximumPageFormat}")
end

return SkinNotesPage