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

--- Childclass extension, main page component functionality for the note skin state.
---@class SkinNotesPage
local SkinNotesPage = {}

--- Main page slider functionality for switching throughout multiple pages.
---@param snapToPage? boolean Allows the scrollbar thumb to snap to its nearest page-index.
---@return nil
function SkinNotesPage:page_slider(snapToPage)
     local snapToPage = snapToPage == nil and true or false

     local function sliderTrackThumbAnimations()
          if self.TOTAL_SKIN_LIMIT < 2 then
               return
          end

          if mousePressed('left') then
               playAnim('displaySliderIcon', 'pressed')
               setProperty('displaySliderIcon.y', getMouseY('camHUD') - getProperty('displaySliderIcon.height') / 2)
          end
          if mouseReleased('left') then
               playAnim('displaySliderIcon', 'static')
               self.SCROLLBAR_TRACK_THUMB_PRESSED = false 
          end
     end
     if clickObject('displaySliderIcon', 'camHUD') then
          self.SCROLLBAR_TRACK_THUMB_PRESSED = true
     end
     if self.SCROLLBAR_TRACK_THUMB_PRESSED == true then
          sliderTrackThumbAnimations()
     end
     if self.TOTAL_SKIN_LIMIT < 2 then
          playAnim('displaySliderIcon', 'unscrollable')
     end

     if getProperty('displaySliderIcon.y') <= 127 then
          setProperty('displaySliderIcon.y', 127)
     end
     if getProperty('displaySliderIcon.y') >= 643 then
          setProperty('displaySliderIcon.y', 643)
     end

     local function sliderTrackCurrentPageIndex()
          local displaySliderIconPositionY = getProperty('displaySliderIcon.y')
          for positionIndex = 2, #self.SCROLLBAR_TRACK_MAJOR_SNAP do
               local sliderTrackBehindIntervals     = self.SCROLLBAR_TRACK_MAJOR_SNAP[positionIndex-1]
               local sliderTrackBehindSemiIntervals = self.SCROLLBAR_TRACK_MINOR_SNAP[positionIndex-1]

               local checkSliderTrackIntervalsByPosition     = sliderTrackBehindIntervals > displaySliderIconPositionY
               local checkSliderTrackSemiIntervalsByPosition = displaySliderIconPositionY <= sliderTrackBehindSemiIntervals
               if checkSliderTrackIntervalsByPosition and checkSliderTrackSemiIntervalsByPosition then 
                    return positionIndex-2 
               end
          end
          return false
     end

     local sliderTrackCurrentPageIndex = sliderTrackCurrentPageIndex()
     local function sliderTrackSwitchPage()
          local sliderTrackThumbPressed  = sliderTrackCurrentPageIndex ~= false and self.SCROLLBAR_TRACK_TOGGLE == false
          local sliderTrackThumbReleased = sliderTrackCurrentPageIndex == false and self.SCROLLBAR_TRACK_TOGGLE == true
          if sliderTrackThumbPressed and sliderTrackCurrentPageIndex ~= self.SCROLLBAR_PAGE_INDEX then
               if self.SCROLLBAR_TRACK_THUMB_PRESSED == true then
                    self.SELECT_SKIN_PAGE_INDEX = sliderTrackCurrentPageIndex
                    self.SCROLLBAR_PAGE_INDEX             = sliderTrackCurrentPageIndex
                    self:create(sliderTrackCurrentPageIndex)
                    self:checkbox_sync()

                    if self.SCROLLBAR_PAGE_INDEX == self.TOTAL_SKIN_LIMIT then
                         setTextColor('genInfoStatePage', 'ff0000')
                    else
                         setTextColor('genInfoStatePage', 'ffffff')
                    end

                    playSound('ding', 0.5)
                    callOnScripts('skinSearchInput_callResetSearch')
                    SkinNoteSave:set('SELECT_SKIN_PAGE_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PAGE_INDEX)
               end
               
               self.SCROLLBAR_TRACK_PAGE_INDEX = sliderTrackCurrentPageIndex
               self.SCROLLBAR_TRACK_TOGGLE    = true
          end
          if sliderTrackThumbReleased or sliderTrackCurrentPageIndex == self.SCROLLBAR_TRACK_PAGE_INDEX then
               self.SCROLLBAR_TRACK_TOGGLE = false
          end
     end
     local function sliderTrackSnapPage()
          if snapToPage == false     then return end
          if self.TOTAL_SKIN_LIMIT < 2 then return end -- fixes a weird bug

          if self.SCROLLBAR_TRACK_THUMB_PRESSED == false and mouseReleased('left') then
               if sliderTrackCurrentPageIndex == self.TOTAL_SKIN_LIMIT then
                    setProperty('displaySliderIcon.y', 643)
                    return
               end
               setProperty('displaySliderIcon.y', self.SCROLLBAR_TRACK_MAJOR_SNAP[sliderTrackCurrentPageIndex])
          end
     end

     sliderTrackSwitchPage()
     sliderTrackSnapPage()
end

--- Creates slider-marks to each corresponding page within the slider track, for visual aid purposes.
---@return nil
function SkinNotesPage:page_slider_marks()
     local function sectionSliderMarks(tag, color, width, offsetTrackX, sliderTracks, sliderTrackIndex)
          local sectionSliderMarksTemplate = {state = (self.stateClass):upperAtStart(), tag = tag:upperAtStart(), index = sliderTrackIndex}
          local sectionSliderMarksTag = ('displaySliderMark${state}${tag}${index}'):interpol(sectionSliderMarksTemplate)
          local sectionSliderMarksX   = getProperty('displaySliderTrack.x') - offsetTrackX
          local sectionSliderMarksY   = sliderTracks[sliderTrackIndex]
     
          makeLuaSprite(sectionSliderMarksTag, nil, sectionSliderMarksX, sectionSliderMarksY)
          makeGraphic(sectionSliderMarksTag, width, 3, color)
          setObjectOrder(sectionSliderMarksTag, getObjectOrder('displaySliderIcon') - 0)
          setObjectCamera(sectionSliderMarksTag, 'camHUD')
          setProperty(sectionSliderMarksTag..'.antialiasing', false)
          addLuaSprite(sectionSliderMarksTag)
     end

     for intervalIndex = 1, #self.SCROLLBAR_TRACK_MAJOR_SNAP do
          sectionSliderMarks('interval', '3b8527', 12 * 2, 12 / 2, self.SCROLLBAR_TRACK_MAJOR_SNAP, intervalIndex)
     end
     for semiIntervalIndex = 2, #self.SCROLLBAR_TRACK_MINOR_SNAP do
          sectionSliderMarks('semiInterval', '847500', 12 * 1.5, 12 / 4, self.SCROLLBAR_TRACK_MINOR_SNAP, semiIntervalIndex)
     end
end

--- Main page moving functionality for switching throughout multiple pages.
---@return nil
function SkinNotesPage:page_moved()
     if self.SCROLLBAR_TRACK_THUMB_PRESSED == true then return end
     local conditionPressedDown = keyboardJustConditionPressed('E', getVar('skinSearchInputFocus') == false)
     local conditionPressedUp   = keyboardJustConditionPressed('Q', getVar('skinSearchInputFocus') == false)

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     local curPage = self.SELECT_SKIN_PRE_SELECTION_INDEX - (MAX_NUMBER_CHUNK * (self.SELECT_SKIN_PAGE_INDEX - 1))
     local skinObjectsPerClicked = self.TOTAL_SKIN_OBJECTS_CLICKED[self.SELECT_SKIN_PAGE_INDEX]
     if not (skinObjectsPerClicked[curPage] == nil or skinObjectsPerClicked[curPage] == false) then
          if conditionPressedUp and self.SELECT_SKIN_PAGE_INDEX > 1 then
               setTextColor('genInfoStatePage', 'f0b72f')
               playSound('cancel')
          end
          if conditionPressedDown and self.SELECT_SKIN_PAGE_INDEX < self.TOTAL_SKIN_LIMIT then
               setTextColor('genInfoStatePage', 'f0b72f')
               playSound('cancel')
          end
          return
     end

     if conditionPressedUp and self.SELECT_SKIN_PAGE_INDEX > 1 then
          self.SCROLLBAR_PAGE_INDEX   = self.SCROLLBAR_PAGE_INDEX - 1
          self.SELECT_SKIN_PAGE_INDEX = self.SELECT_SKIN_PAGE_INDEX - 1
          self:create(self.SELECT_SKIN_PAGE_INDEX)
          self:checkbox_sync()

          playSound('ding', 0.5)
          setProperty('displaySliderIcon.y', self.SCROLLBAR_TRACK_MAJOR_SNAP[self.SELECT_SKIN_PAGE_INDEX])
          callOnScripts('skinSearchInput_callResetSearch')
          SkinNoteSave:set('SELECT_SKIN_PAGE_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PAGE_INDEX)
     end
     if conditionPressedDown and self.SELECT_SKIN_PAGE_INDEX < self.TOTAL_SKIN_LIMIT then
          self.SCROLLBAR_PAGE_INDEX   = self.SCROLLBAR_PAGE_INDEX + 1
          self.SELECT_SKIN_PAGE_INDEX = self.SELECT_SKIN_PAGE_INDEX + 1
          self:create(self.SELECT_SKIN_PAGE_INDEX)
          self:checkbox_sync()

          playSound('ding', 0.5)
          setProperty('displaySliderIcon.y', self.SCROLLBAR_TRACK_MAJOR_SNAP[self.SELECT_SKIN_PAGE_INDEX])
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
     local currentPage = ('%.3d'):format(self.SELECT_SKIN_PAGE_INDEX)
     local maximumPage = ('%.3d'):format(self.TOTAL_SKIN_LIMIT)
     setTextString('genInfoStatePage', (' Page ${cur} / ${max}'):interpol({cur = currentPage, max = maximumPage}))
end

return SkinNotesPage