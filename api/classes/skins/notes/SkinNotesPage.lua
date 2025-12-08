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

--- Childclass extension, main page component functionality for the note skin state.
---@class SkinNotesPage
local SkinNotesPage = {}

--- Main page slider functionality for switching throughout multiple pages.
---@param snapToPage? boolean Allows the scrollbar thumb to snap to its nearest page-index.
---@return nil
function SkinNotesPage:page_slider(snapToPage)
     local snapToPage = snapToPage == nil and true or false

     local function sliderTrackThumbAnimations()
          if self.totalSkinLimit < 2 then
               return
          end

          if mousePressed('left') then
               playAnim('displaySliderIcon', 'pressed')
               setProperty('displaySliderIcon.y', getMouseY('camHUD') - getProperty('displaySliderIcon.height') / 2)
          end
          if mouseReleased('left') then
               playAnim('displaySliderIcon', 'static')
               self.sliderTrackThumbPressed = false 
          end
     end
     if clickObject('displaySliderIcon', 'camHUD') then
          self.sliderTrackThumbPressed = true
     end
     if self.sliderTrackThumbPressed == true then
          sliderTrackThumbAnimations()
     end
     if self.totalSkinLimit < 2 then
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
          for positionIndex = 2, #self.sliderTrackIntervals do
               local sliderTrackBehindIntervals     = self.sliderTrackIntervals[positionIndex-1]
               local sliderTrackBehindSemiIntervals = self.sliderTrackSemiIntervals[positionIndex-1]

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
          local sliderTrackThumbPressed  = sliderTrackCurrentPageIndex ~= false and self.sliderTrackToggle == false
          local sliderTrackThumbReleased = sliderTrackCurrentPageIndex == false and self.sliderTrackToggle == true
          if sliderTrackThumbPressed and sliderTrackCurrentPageIndex ~= self.sliderPageIndex then
               if self.sliderTrackThumbPressed == true then
                    self.selectSkinPagePositionIndex = sliderTrackCurrentPageIndex
                    self.sliderPageIndex             = sliderTrackCurrentPageIndex
                    self:create(sliderTrackCurrentPageIndex)

                    if self.sliderPageIndex == self.totalSkinLimit then
                         setTextColor('genInfoStatePage', 'ff0000')
                    else
                         setTextColor('genInfoStatePage', 'ffffff')
                    end

                    playSound('ding', 0.5)
                    callOnScripts('skinSearchInput_callResetSearch')
                    SkinNoteSave:set('selectSkinPagePositionIndex', self.stateClass, self.selectSkinPagePositionIndex)
               end
               
               self.sliderTrackPageIndex = sliderTrackCurrentPageIndex
               self.sliderTrackToggle    = true
          end
          if sliderTrackThumbReleased or sliderTrackCurrentPageIndex == self.sliderTrackPageIndex then
               self.sliderTrackToggle = false
          end
     end
     local function sliderTrackSnapPage()
          if snapToPage == false     then return end
          if self.totalSkinLimit < 2 then return end -- fixes a weird bug

          if self.sliderTrackThumbPressed == false and mouseReleased('left') then
               if sliderTrackCurrentPageIndex == self.totalSkinLimit then
                    setProperty('displaySliderIcon.y', 643)
                    return
               end
               setProperty('displaySliderIcon.y', self.sliderTrackIntervals[sliderTrackCurrentPageIndex])
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

     for intervalIndex = 1, #self.sliderTrackIntervals do
          sectionSliderMarks('interval', '3b8527', 12 * 2, 12 / 2, self.sliderTrackIntervals, intervalIndex)
     end
     for semiIntervalIndex = 2, #self.sliderTrackSemiIntervals do
          sectionSliderMarks('semiInterval', '847500', 12 * 1.5, 12 / 4, self.sliderTrackSemiIntervals, semiIntervalIndex)
     end
end

--- Main page moving functionality for switching throughout multiple pages.
---@return nil
function SkinNotesPage:page_moved()
     if self.sliderTrackThumbPressed == true then return end
     local conditionPressedDown = keyboardJustConditionPressed('E', getVar('skinSearchInputFocus') == false)
     local conditionPressedUp   = keyboardJustConditionPressed('Q', getVar('skinSearchInputFocus') == false)

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     local skinObjectsPerClicked = self.totalSkinObjectClicked[self.selectSkinPagePositionIndex]
     local curPage = self.selectSkinPreSelectedIndex - (16 * (self.selectSkinPagePositionIndex - 1))
     if conditionPressedUp and self.selectSkinPagePositionIndex > 1 then
          self.sliderPageIndex             = self.sliderPageIndex - 1
          self.selectSkinPagePositionIndex = self.selectSkinPagePositionIndex - 1
          self:create(self.selectSkinPagePositionIndex)

          playSound('ding', 0.5)
          setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.selectSkinPagePositionIndex])
          callOnScripts('skinSearchInput_callResetSearch')
          SkinNoteSave:set('selectSkinPagePositionIndex', self.stateClass, self.selectSkinPagePositionIndex)
     end
     if conditionPressedDown and self.selectSkinPagePositionIndex < self.totalSkinLimit then
          self.sliderPageIndex             = self.sliderPageIndex + 1
          self.selectSkinPagePositionIndex = self.selectSkinPagePositionIndex + 1
          self:create(self.selectSkinPagePositionIndex)

          playSound('ding', 0.5)
          setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.selectSkinPagePositionIndex])
          callOnScripts('skinSearchInput_callResetSearch')
          SkinNoteSave:set('selectSkinPagePositionIndex', self.stateClass, self.selectSkinPagePositionIndex)
     end

     if self.selectSkinPagePositionIndex == self.totalSkinLimit then
          setTextColor('genInfoStatePage', 'ff0000')
     else
          setTextColor('genInfoStatePage', 'ffffff')
     end
end

--- Updates the current page text, that is literally it.
---@return nil
function SkinNotesPage:page_text()
     local currentPage = ('%.3d'):format(self.selectSkinPagePositionIndex)
     local maximumPage = ('%.3d'):format(self.totalSkinLimit)
     setTextString('genInfoStatePage', (' Page ${cur} / ${max}'):interpol({cur = currentPage, max = maximumPage}))
end

return SkinNotesPage