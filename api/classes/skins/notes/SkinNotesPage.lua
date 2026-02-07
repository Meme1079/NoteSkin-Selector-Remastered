luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local MAX_NUMBER_CHUNK = global.MAX_NUMBER_CHUNK

local clickObject                   = funkinlua.clickObject
local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

--- Childclass extension, main page component functionality for the noteskin state.
---@class SkinNotesPage
local SkinNotesPage = {}
local SkinNotesGSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

local SCROLLBAR_THUMB_SYNC = false -- * Ignore this btw
--- Page scrollbar functionality, that's it.
---@param snapToPage? boolean Enables the scrollbar snapping to its nearest page index.
---@return nil
function SkinNotesPage:page_scrollbar(snapToPage)
     local snapToPage = snapToPage == nil and true or false

     local pageScrollbarThumb = 'pageScrollbarThumb'
     if clickObject(pageScrollbarThumb, 'camHUD') then
          self.SCROLLBAR_TRACK_THUMB_PRESSED = true
     end

     local MINIMUM_SKIN_LIMIT = 1
     if self.TOTAL_SKIN_LIMIT <= MINIMUM_SKIN_LIMIT then
          playAnim(pageScrollbarThumb, 'unscrollable')
     end
     if self.TOTAL_SKIN_LIMIT > MINIMUM_SKIN_LIMIT and self.SCROLLBAR_TRACK_THUMB_PRESSED == true then
          local DISPLAY_SCROLL_THUMB_HEIGHT   = getProperty(F"{pageScrollbarThumb}.height")
          local DISPLAY_SCROLL_THUMB_OFFSET_Y = getMouseY('camHUD') - (DISPLAY_SCROLL_THUMB_HEIGHT / 2)
          if mousePressed('left') then
               playAnim(pageScrollbarThumb, 'pressed')
               setProperty(F"{pageScrollbarThumb}.y", DISPLAY_SCROLL_THUMB_OFFSET_Y)
          end
          if mouseReleased('left') then
               playAnim(pageScrollbarThumb, 'static')
               self.SCROLLBAR_TRACK_THUMB_PRESSED = false 
          end
     end

     local DISPLAY_SCROLL_THUMB_MIN_POSITION_Y = 127
     local DISPLAY_SCROLL_THUMB_MAX_POSITION_Y = 643
     if getProperty(F"{pageScrollbarThumb}.y") <= DISPLAY_SCROLL_THUMB_MIN_POSITION_Y then
          setProperty(F"{pageScrollbarThumb}.y", DISPLAY_SCROLL_THUMB_MIN_POSITION_Y)
     end
     if getProperty(F"{pageScrollbarThumb}.y") >= DISPLAY_SCROLL_THUMB_MAX_POSITION_Y then
          setProperty(F"{pageScrollbarThumb}.y", DISPLAY_SCROLL_THUMB_MAX_POSITION_Y)
     end

     --- Calculates the page position by using the scroll thumb's position.
     --- By check its range between the major and minor snap positions.
     ---@return number|boolean
     local function calculateScrollCurrentRangePage()
          local displayScrollThumbPositionY = getProperty(F"{pageScrollbarThumb}.y")

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
          self.SCROLLBAR_PAGE_INDEX   = SCROLLBAR_CURRENT_PAGE_INDEX
          self:create(self.SCROLLBAR_PAGE_INDEX)
          self:checkbox_sync()

          if self.SCROLLBAR_PAGE_INDEX == self.TOTAL_SKIN_LIMIT then
               setTextColor('skinStatePreviewPage', 'ff0000')
          else
               setTextColor('skinStatePreviewPage', 'ffffff')
          end

          playSound('ding', 0.5)
          callOnScripts('skinSearchInput_callResetSearch')
          SkinNotesGSave:set('SCROLLBAR_PAGE_INDEX', self.stateClass:upper(), self.SCROLLBAR_PAGE_INDEX)
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
                    setProperty(F"{pageScrollbarThumb}.y", DISPLAY_SCROLL_THUMB_MAX_POSITION_Y)
               elseif SCROLLBAR_CURRENT_PAGE_INDEX >= SCROLLBAR_MID_RANGE_PAGE_INDEX then
                    setProperty(F"{pageScrollbarThumb}.y", scrollbarMajorSnapIndex - SCROLLBAR_MAJOR_SNAP_OFFSET_Y)
               else
                    setProperty(F"{pageScrollbarThumb}.y", scrollbarMajorSnapIndex)
               end
          end 
     end
end

--- Creates a scrollbar snap-marks to each corresponding page, based on its position.
---@return nil
function SkinNotesPage:page_scrollbar_snaps()
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

     local pageScrollbarThumb = 'pageScrollbarThumb'
     local function createSnapMarks(scrollbarTrackSnapObjects, scrollbarTrackSnapIndex, scrollbarTrackMetadata)
          local displayScrollSnapMarkTag = F"displaySliderMark{self.stateClass:upperAtStart()}{scrollbarTrackMetadata.NAME:upperAtStart()}{scrollbarTrackSnapIndex}"
          local displayScrollSnapMarkX   = getProperty(F"{pageScrollbarThumb}.x") + scrollbarTrackMetadata.OFFSETX
          local displayScrollSnapMarkY   = scrollbarTrackSnapObjects[scrollbarTrackSnapIndex]
     
          makeLuaSprite(displayScrollSnapMarkTag, nil, displayScrollSnapMarkX, displayScrollSnapMarkY)
          makeGraphic(displayScrollSnapMarkTag, scrollbarTrackMetadata.WIDTH, 3, scrollbarTrackMetadata.COLOR)
          setObjectOrder(displayScrollSnapMarkTag, getObjectOrder(pageScrollbarThumb))
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

--- Page moving functionality, uses keys for switching pages.
---@return nil
function SkinNotesPage:page_moved()
     if SkinNotesGSave:get('PREVIEW_TOGGLE_ANIM_STATUS', 'SAVE', true) == true then
          return
     end
     if self.SCROLLBAR_TRACK_THUMB_PRESSED == true then 
          return 
     end
     local gameControlPressedDown = keyboardJustConditionPressed('E', getVar('skinSearchInputFocus') == false)
     local gameControlPressedUp   = keyboardJustConditionPressed('Q', getVar('skinSearchInputFocus') == false)

     local SEARCH_INPUT_TEXT_CONTENT = getVar('SEARCH_INPUT_TEXT_CONTENT') or ''
     if #SEARCH_INPUT_TEXT_CONTENT > 0 then
          if gameControlPressedUp or gameControlPressedDown then
               setTextColor('skinStatePreviewPage', 'f0b72f')
               playSound('cancel')
          end
          return
     end

     local totalSkinObjectsPagePerIds     = self.TOTAL_SKIN_OBJECTS_IDS[self.SCROLLBAR_PAGE_INDEX]
     local totalSkinObjectsPagePerClicked = self.TOTAL_SKIN_OBJECTS_CLICKED[self.SCROLLBAR_PAGE_INDEX]
     for curIDs = totalSkinObjectsPagePerIds[1], totalSkinObjectsPagePerIds[#totalSkinObjectsPagePerIds] do
          local curSkinIDs = curIDs - (MAX_NUMBER_CHUNK * (self.SCROLLBAR_PAGE_INDEX - 1))
          if totalSkinObjectsPagePerClicked[curSkinIDs] == true then
               if gameControlPressedUp and self.SCROLLBAR_PAGE_INDEX > 1 then
                    setTextColor('skinStatePreviewPage', 'f0b72f')
                    playSound('cancel')
               end
               if gameControlPressedDown and self.SCROLLBAR_PAGE_INDEX < self.TOTAL_SKIN_LIMIT then
                    setTextColor('skinStatePreviewPage', 'f0b72f')
                    playSound('cancel')
               end
               return
          end
     end

     local SCROLLBAR_MIN_RANGE_PAGE_INDEX = 1
     local SCROLLBAR_MAX_RANGE_PAGE_INDEX = self.TOTAL_SKIN_LIMIT

     local pageScrollbarThumb = 'pageScrollbarThumb'
     if gameControlPressedUp and self.SCROLLBAR_PAGE_INDEX > SCROLLBAR_MIN_RANGE_PAGE_INDEX then
          self.SCROLLBAR_PAGE_INDEX = self.SCROLLBAR_PAGE_INDEX - 1
          self:create(self.SCROLLBAR_PAGE_INDEX)
          self:checkbox_sync()

          playSound('ding', 0.5)
          setProperty(F"{pageScrollbarThumb}.y", self.SCROLLBAR_TRACK_MAJOR_SNAP[self.SCROLLBAR_PAGE_INDEX])
          callOnScripts('skinSearchInput_callResetSearch')

          SkinNotesGSave:set('SCROLLBAR_PAGE_INDEX', self.stateClass:upper(), self.SCROLLBAR_PAGE_INDEX)
     end
     if gameControlPressedDown and self.SCROLLBAR_PAGE_INDEX < SCROLLBAR_MAX_RANGE_PAGE_INDEX then
          self.SCROLLBAR_PAGE_INDEX = self.SCROLLBAR_PAGE_INDEX + 1
          self:create(self.SCROLLBAR_PAGE_INDEX)
          self:checkbox_sync()

          playSound('ding', 0.5)
          setProperty(F"{pageScrollbarThumb}.y", self.SCROLLBAR_TRACK_MAJOR_SNAP[self.SCROLLBAR_PAGE_INDEX])
          callOnScripts('skinSearchInput_callResetSearch')
          
          SkinNotesGSave:set('SCROLLBAR_PAGE_INDEX', self.stateClass:upper(), self.SCROLLBAR_PAGE_INDEX)
     end

     local SCROLLBAR_MAJOR_SNAP_OFFSET_Y = 25
     if self.SCROLLBAR_PAGE_INDEX > SCROLLBAR_MIN_RANGE_PAGE_INDEX and self.SCROLLBAR_PAGE_INDEX < SCROLLBAR_MAX_RANGE_PAGE_INDEX then
          setProperty(F"{pageScrollbarThumb}.y", self.SCROLLBAR_TRACK_MAJOR_SNAP[self.SCROLLBAR_PAGE_INDEX] - SCROLLBAR_MAJOR_SNAP_OFFSET_Y)
     end

     if self.SCROLLBAR_PAGE_INDEX == self.TOTAL_SKIN_LIMIT then
          setTextColor('skinStatePreviewPage', 'ff0000')
     else
          setTextColor('skinStatePreviewPage', 'ffffff')
     end
end

--- Updates its current page number text, that's literally it.
---@protected
---@return nil
function SkinNotesPage:page_text()
     local currentPageFormat = ('%.3d'):format(self.SCROLLBAR_PAGE_INDEX)
     local maximumPageFormat = ('%.3d'):format(self.TOTAL_SKIN_LIMIT)
     setTextString('skinStatePreviewPage', F" Page {currentPageFormat} / {maximumPageFormat}")
end

return SkinNotesPage