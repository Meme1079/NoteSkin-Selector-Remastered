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

--- Childclass extension, main searching component functionality for the note skin state.
---@class SkinNotesSearch
local SkinNotesSearch = {}

--- Collection group of search methods.
---@return nil
function SkinNotesSearch:search()
     self:search_create()
     self:search_skins()
     self:search_selection()
     self:search_checkbox_sync()
end

--- Calculates and searches the nearest skin from the given input to be loaded.
---@return nil
function SkinNotesSearch:search_skins()
     local SEARCH_INPUT_CONTENT = getVar('skinSearchInput_textContent') or ''
     local FIRST_JUST_RELEASED  = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})
     if FIRST_JUST_RELEASED == -1 or getVar('skinSearchInputFocus') == false then -- optimization purposes
          return
     end

     local skinInputContent   = SEARCH_INPUT_CONTENT
     local skinInputContentID = states.calculateSearch(self.stateClass, self.statePrefix, 'ids', false) -- to clear previous search results
     local skinSearchIndex = 0
     for searchPage = 1, #self.totalSkinObjectID do
          local totalSkinObjectIDs     = self.totalSkinObjectID[searchPage]
          local totalSkinObjectMerge   = table.merge(totalSkinObjectIDs, skinInputContentID)
          local totalSkinObjectPresent = table.singularity(totalSkinObjectMerge, true)

          for curPresentIndex = 1, #totalSkinObjectPresent do
               skinSearchIndex = skinSearchIndex + 1
               self.searchSkinObjectIndex[skinSearchIndex] = totalSkinObjectPresent[curPresentIndex]
               self.searchSkinObjectPage[skinSearchIndex]  = searchPage
          end
     end
end

--- Creates a chunk gallery of available display skins to select from when searching.
---@return nil
function SkinNotesSearch:search_create()
     local SEARCH_INPUT_CONTENT = getVar('skinSearchInput_textContent') or ''
     local SEARCH_INPUT_FOCUS   = getVar('skinSearchInputFocus') or false
     local FIRST_JUST_RELEASED  = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})
     if FIRST_JUST_RELEASED  == -1 or  SEARCH_INPUT_FOCUS == false then -- optimization purposes
          return
     end
     if SEARCH_INPUT_CONTENT == '' and SEARCH_INPUT_FOCUS == true  then -- optimization purposes
          self:create(self.selectSkinPagePositionIndex)
          self:page_text()
          self:save_selection()
          return
     end
     
     for skinPages = 1, self.totalSkinLimit do
          for skinDisplays = 1, #self.totalSkinObjects[skinPages] do
               if skinPages == skinIndex then
                    goto SKIP_SKIN_PAGE
               end

               local skinObjectID = self.totalSkinObjectID[skinPages][skinDisplays]
               local displaySkinIconTagButton = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{skinObjectID}"
               local displaySkinIconTagSkin   = F"displaySkinIconSkin{self.stateClass:upperAtStart()}-{skinObjectID}"
               if luaSpriteExists(displaySkinIconTagButton) == true and luaSpriteExists(displaySkinIconTagSkin) == true then
                    removeLuaSprite(displaySkinIconTagButton, true)
                    removeLuaSprite(displaySkinIconTagSkin, true)
               end
               ::SKIP_SKIN_PAGE::
          end
     end

     --- Calculates the positions of each display skins to be shown within the chunk gallery.
     ---@return table[number]
     local function displaySkinIconPositions()
          local displaySkinIconPositions = {}
          local displaySkinIconPosX = 0
          local displaySkinIconPosY = 0

          local SKIN_ROW_MAX_LENGTH    = 4
          local SKIN_SEARCH_MAX_LENGTH = states.calculateSearch(self.stateClass, self.statePrefix, 'names', true)
          for skinDisplays = 1, #SKIN_SEARCH_MAX_LENGTH do
               if (skinDisplays - 1) % SKIN_ROW_MAX_LENGTH == 0 then
                    displaySkinIconPosY = displaySkinIconPosY + 1
                    displaySkinIconPosX = 0
               else
                    displaySkinIconPosX = displaySkinIconPosX + 1
               end

               local DISPLAY_SKIN_OFFSET_X =  20
               local DISPLAY_SKIN_OFFSET_Y = -20
               local DISPLAY_SKIN_DISTRIBUTION_OFFSET_X = 145
               local DISPLAY_SKIN_DISTRIBUTION_OFFSET_Y = 150

               local DISPLAY_SKIN_POSITION_X = DISPLAY_SKIN_OFFSET_X + (DISPLAY_SKIN_DISTRIBUTION_OFFSET_X * displaySkinIconPosX)
               local DISPLAY_SKIN_POSITION_Y = DISPLAY_SKIN_OFFSET_Y + (DISPLAY_SKIN_DISTRIBUTION_OFFSET_Y * displaySkinIconPosY)
               displaySkinIconPositions[#displaySkinIconPositions+1] = {DISPLAY_SKIN_POSITION_X, DISPLAY_SKIN_POSITION_Y}
          end
          return displaySkinIconPositions
     end

     local filterSearchByID   = states.calculateSearch(self.stateClass, self.statePrefix, 'ids', false)
     local filterSearchByName = states.calculateSearch(self.stateClass, self.statePrefix, 'names', false)
     local filterSearchBySkin = states.calculateSearch(self.stateClass, self.statePrefix, 'names', true)

     local currenMinPageRange = (self.selectSkinPagePositionIndex - 1) * MAX_NUMBER_CHUNK
     local currenMaxPageRange = self.selectSkinPagePositionIndex       * MAX_NUMBER_CHUNK
     currenMinPageRange = (currenMinPageRange == 0) and 1 or currenMinPageRange -- adjust for 1-based index

     local searchFilterSkinPageRange = table.tally(currenMinPageRange, currenMaxPageRange)
     local searchFilterSkinPresent   = table.singularity(table.merge(filterSearchByID, searchFilterSkinPageRange), false)
     local searchFilterSkinRange     = table.sub(searchFilterSkinPresent, 1, #filterSearchByName) -- adjust for present skins only
     for skinSearchIndex, skinSearchIDs in pairs(searchFilterSkinRange) do
          local displaySkinIconTagButton = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{skinSearchIDs}"
          local displaySkinIconTagSkin   = F"displaySkinIconSkin{self.stateClass:upperAtStart()}-{skinSearchIDs}"
          local displaySkinIconPosX = displaySkinIconPositions()[skinSearchIndex][1]
          local displaySkinIconPosY = displaySkinIconPositions()[skinSearchIndex][2]
          makeAnimatedLuaSprite(displaySkinIconTagButton, 'ui/buttons/display_button', displaySkinIconPosX, displaySkinIconPosY)
          addAnimationByPrefix(displaySkinIconTagButton, 'static', 'static')
          addAnimationByPrefix(displaySkinIconTagButton, 'selected', 'selected')
          addAnimationByPrefix(displaySkinIconTagButton, 'blocked', 'blocked')
          addAnimationByPrefix(displaySkinIconTagButton, 'hover', 'hovered-static')
          addAnimationByPrefix(displaySkinIconTagButton, 'pressed', 'hovered-pressed')
          playAnim(displaySkinIconTagButton, 'static', true)
          scaleObject(displaySkinIconTagButton, 0.8, 0.8)
          setObjectCamera(displaySkinIconTagButton, 'camHUD')
          setProperty(F"{displaySkinIconTagButton}.antialiasing", false)
          addLuaSprite(displaySkinIconTagButton)

          --- Gets the skins' display metadata value, acts as a helper function.
          --- Checks for any missing values and replaces it with its default value.
          ---@param metadata string The metadata element to get its value.
          ---@param constant any The constant default value, if the metadata element is missing.
          ---@return any
          local function displaySkinMetadata(metadata, constant)
               local metaObjectsDisplay = self.totalMetadataOrderedDisplay[tonumber(skinSearchIDs)]
               if metaObjectsDisplay           == '@void' then return constant end
               if metaObjectsDisplay[metadata] == nil     then return constant end
               return metaObjectsDisplay[metadata]
          end
          local displaySkinMetadataFrames   = displaySkinMetadata('frames',   24)
          local displaySkinMetadataPrefixes = displaySkinMetadata('prefixes', 'arrowUP')
          local displaySkinMetadataSize     = displaySkinMetadata('size',     {0.55, 0.55})
          local displaySkinMetadataOffsets  = displaySkinMetadata('offsets',  {0, 0})

          local DISPLAY_SKIN_POSITION_OFFSET_X = 16.5
          local DISPLAY_SKIN_POSITION_OFFSET_Y = 12
          local displaySkinIconPosOffsetX = displaySkinIconPosX + DISPLAY_SKIN_POSITION_OFFSET_X
          local displaySkinIconPosOffsetY = displaySkinIconPosY + DISPLAY_SKIN_POSITION_OFFSET_Y

          local displaySkinIconSkinSprite = F"{self.statePaths}/{filterSearchBySkin[skinSearchIndex]}"
          makeAnimatedLuaSprite(displaySkinIconTagSkin, displaySkinIconSkinSprite, displaySkinIconPosOffsetX, displaySkinIconPosOffsetY)
          scaleObject(displaySkinIconTagSkin, displaySkinMetadataSize[1], displaySkinMetadataSize[2])
          addAnimationByPrefix(displaySkinIconTagSkin, 'static', displaySkinMetadataPrefixes, displaySkinMetadataFrames, true)

          local DISPLAY_SKIN_OFFSET_X = getProperty(F"{displaySkinIconTagSkin}.offset.x")
          local DISPLAY_SKIN_OFFSET_Y = getProperty(F"{displaySkinIconTagSkin}.offset.y")
          local displaySkinIconOffsetX = DISPLAY_SKIN_OFFSET_X - displaySkinMetadataOffsets[1]
          local displaySkinIconOffsetY = DISPLAY_SKIN_OFFSET_Y + displaySkinMetadataOffsets[2]
          addOffset(displaySkinIconTagSkin, 'static', displaySkinIconOffsetX, displaySkinIconOffsetY)
          playAnim(displaySkinIconTagSkin, 'static')
          setObjectCamera(displaySkinIconTagSkin, 'camHUD')
          addLuaSprite(displaySkinIconTagSkin)

          if skinSearchIndex > #filterSearchBySkin then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    removeLuaSprite(displaySkinIconButton, true)
                    removeLuaSprite(displaySkinIconSkin, true)
               end
          end
          self:save_selection()
     end
end

--- Creates the preview strums' graphic sprites and its text when searching.
---@return nil
function SkinNotesSearch:search_preview()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     --- Gets the skin's object data from the currently selected skin.
     ---@param skinObjects table The object to retreive its data.
     ---@return any
     local function currentPreviewSkinData(skinObjects)
          if self.selectSkinCurSelectedIndex == 0 or self.totalSkins[self.selectSkinCurSelectedIndex] == nil then
               return skinObjects[1][1] -- default value
          end

          for skinPages = 1, self.totalSkinLimit do -- checks if each page has an existing skin object
               local selectedSkinPage  = self.totalSkinObjectIndexes[skinPages]
               local selectedSkinIndex = table.find(selectedSkinPage, self.selectSkinCurSelectedIndex)
               if selectedSkinIndex ~= nil then
                    return skinObjects[skinPages][selectedSkinIndex]
               end
          end
     end

     local currentPreviewDataSkins    = currentPreviewSkinData(self.totalSkinObjects)
     local currentPreviewDataNames    = currentPreviewSkinData(self.totalSkinObjectNames)
     local currentPreviewMetadataPrev = currentPreviewSkinData(self.totalMetadataObjectPreview)

     --- Gets the skin's preview metadata object from its JSON.
     ---@param metadataName string The name of the metadata to be fetch.
     ---@return table
     local function previewMetadataObject(metadataName)
          local metadataSkinPrevObj         = currentPreviewMetadataPrev
          local metadataSkinPrevObjElements = currentPreviewMetadataPrev[metadataName]
          if metadataSkinPrevObj == '@void' or metadataSkinPrevObjElements == nil then
               return self.previewStaticDataPreview[metadataName]
          end
          return metadataSkinPrevObjElements
     end

     --- Same as the previous function above, helper function; this retreives mainly its animation from its JSON.
     ---@param animationName string The name of the animation metadata to be fetch.
     ---@param strumIndex number The strum index number to cycle each value.
     ---@param ?byAnimationGroup boolean Whether it will retreive by group or not.
     ---@return table
     local function previewMetadataObjectAnims(animationName, strumIndex, byAnimationGroup)
          local metadataSkinPrevObj     = currentPreviewMetadataPrev
          local metadataSkinPrevObjAnim = currentPreviewMetadataPrev.animations

          local constantSkinPrevObjAnimNames = self.previewConstDataPreviewAnims['names'][animationName]
          local constantSkinPrevObjAnim      = self.previewStaticDataPreview.animation
          if byAnimationGroup == true then
               if metadataSkinPrevObj == '@void' or metadataSkinPrevObjAnim == nil then
                    return constantSkinPrevObjAnim[animationName]
               end
               if metadataSkinPrevObjAnim == nil then
                    metadataSkinPrevObj['animations'] = constantSkinPrevObjAnim
                    return constantSkinPrevObjAnim
               end
               if metadataSkinPrevObjAnim[animationName] == nil then
                    metadataSkinPrevObj['animations'][animationName] = constantSkinPrevObjAnim[animationName]
                    return constantSkinPrevObjAnim[animationName]
               end
               return metadataSkinPrevObjAnim[animationName]
          end

          local skinPrevAnimElements = constantSkinPrevObjAnimNames[strumIndex]
          if metadataSkinPrevObj == '@void' or metadataSkinPrevObjAnim == nil then
               return constantSkinPrevObjAnim[animationName][skinPrevAnimElements]
          end
          if metadataSkinPrevObjAnim == nil then
               previewMetadataObject['animations'] = constantSkinPrevObjAnim
               return constantSkinPrevObjAnim
          end
          if metadataSkinPrevObjAnim[animationName] == nil then
               previewMetadataObject['animations'][animationName] = constantSkinPrevObjAnim[skinAnim]
               return constantSkinPrevObjAnim[animationName][skinPrevAnimElements]
          end
          return metadataSkinPrevObjAnim[animationName][skinPrevAnimElements]
     end

     local metadataPreviewFrames = previewMetadataObject('frames')
     local metadataPreviewSize   = previewMetadataObject('size')

     local metadataPreviewConfirmFrames = metadataPreviewFrames.confirm
     local metadataPreviewPressedFrames = metadataPreviewFrames.pressed
     local metadataPreviewColoredFrames = metadataPreviewFrames.colored
     local metadataPreviewStrumsFrames  = metadataPreviewFrames.strums
     for strumIndex = 1, 4 do
          local metadataPreviewConfirmAnim = previewMetadataObjectAnims('confirm', strumIndex)
          local metadataPreviewPressedAnim = previewMetadataObjectAnims('pressed', strumIndex)
          local metadataPreviewColoredAnim = previewMetadataObjectAnims('colored', strumIndex)
          local metadataPreviewStrumsAnim  = previewMetadataObjectAnims('strums', strumIndex)

          local previewSkinGroupTag    = F"previewSkinGroup{self.stateClass:upperAtStart()}-{strumIndex}"
          local previewSkinGroupSprite = F"{self.statePaths}/{currentPreviewDataSkins}"

          local previewSkinPositionX = 790 + (105*(strumIndex - 1))
          local previewSkinPositionY = 135

          makeAnimatedLuaSprite(previewSkinGroupTag, previewSkinGroupSprite, previewSkinPositionX, previewSkinPositionY)
          scaleObject(previewSkinGroupTag, metadataPreviewSize[1], metadataPreviewSize[2])
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewConfirmAnim.name, metadataPreviewConfirmAnim.prefix, previewMetadataByConfirmFrames)
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewPressedAnim.name, metadataPreviewPressedAnim.prefix, previewMetadataByPressedFrames)
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewColoredAnim.name, metadataPreviewColoredAnim.prefix, previewMetadataByColoredFrames)
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewStrumsAnim.name,  metadataPreviewStrumsAnim.prefix,  previewMetadataByStrumsFrames)

          --- Adds the offset for the given preview skins.
          ---@param metadataPreviewAnim table The specified preview animation to use for offsetting.
          ---@return number, number
          local function addMetadataPreviewOffset(metadataPreviewAnim)
               local PREVIEW_SKIN_CURRENT_OFFSET_X = getProperty(F"{previewSkinGroupTag}.offset.x")
               local PREVIEW_SKIN_CURRENT_OFFSET_Y = getProperty(F"{previewSkinGroupTag}.offset.y")
               local PREVIEW_SKIN_DATA_OFFSET_X    = metadataPreviewAnim.offsets[1]
               local PREVIEW_SKIN_DATA_OFFSET_Y    = metadataPreviewAnim.offsets[2]

               local PREVIEW_SKIN_OFFSET_X = PREVIEW_SKIN_CURRENT_OFFSET_X - PREVIEW_SKIN_DATA_OFFSET_X
               local PREVIEW_SKIN_OFFSET_Y = PREVIEW_SKIN_CURRENT_OFFSET_Y + PREVIEW_SKIN_DATA_OFFSET_Y
               return PREVIEW_SKIN_OFFSET_X, PREVIEW_SKIN_OFFSET_Y
          end
          addOffset(previewSkinGroupTag, metadataPreviewConfirmAnim.name, addMetadataPreviewOffset(metadataPreviewConfirmAnim))
          addOffset(previewSkinGroupTag, metadataPreviewPressedAnim.name, addMetadataPreviewOffset(metadataPreviewPressedAnim))
          addOffset(previewSkinGroupTag, metadataPreviewColoredAnim.name, addMetadataPreviewOffset(metadataPreviewColoredAnim))
          addOffset(previewSkinGroupTag, metadataPreviewStrumsAnim.name,  addMetadataPreviewOffset(metadataPreviewStrumsAnim))
          playAnim(previewSkinGroupTag, self.previewConstDataPreviewAnims['names']['strums'][strumIndex])
          setObjectCamera(previewSkinGroupTag, 'camHUD')
          addLuaSprite(previewSkinGroupTag)

          SkinNoteSave:set('previewMetadataByObjectStrums', self.stateClass..'Static', previewMetadataObjectAnims('strums', strumIndex, true))
          SkinNoteSave:set('previewMetadataByFramesStrums', self.stateClass..'Static', previewMetadataByFramesStrums)
          SkinNoteSave:set('previewMetadataBySize', self.stateClass..'Static', previewMetadataBySize)
          SkinNoteSave:set('previewSkinImagePath', self.stateClass..'Static', previewSkinImagePath)
     end

     setTextString('genInfoSkinName', currentPreviewDataNames)
     self:preview_animation(true)
end

--- Syncing of the position and offset of the selection highlight when searching, obviously for visual purposes.
---@return nil
function SkinNotesSearch:search_checkbox_sync()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerIDs = self.totalSkinObjectID[searchSkinPage]
          for checkboxIndex = 1, #self.checkboxSkinObjectType do
               local checkboxObjectTypes      = self.checkboxSkinObjectType[checkboxIndex]
               local checkboxObjectTypeTag    = self.checkboxSkinObjectType[checkboxIndex]:upperAtStart()
               local checkboxSkinIndex        = self.checkboxSkinObjectIndex[checkboxObjectTypes:lower()]
               local checkboxSkinIndexPresent = table.find(skinObjectsPerIDs, checkboxSkinIndex)
     
               local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = checkboxSkinIndex}
               local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
               if checkboxSkinIndex == self.selectSkinCurSelectedIndex or checkboxSkinIndex == checkboxSkinIndexPresent or luaSpriteExists(displaySkinIconButton) == true then
                    local displaySelectionHighlightX = ('displaySelection${select}.x'):interpol({select = checkboxObjectTypeTag})
                    local displaySelectionHighlightY = ('displaySelection${select}.y'):interpol({select = checkboxObjectTypeTag})
                    setProperty(displaySelectionHighlightX, getProperty(displaySkinIconButton..'.x'))
                    setProperty(displaySelectionHighlightY, getProperty(displaySkinIconButton..'.y'))
               end

               if checkboxSkinIndex == 0 or luaSpriteExists(displaySkinIconButton) == false then
                    removeLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
               else
                    addLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
               end
          end
     end

     if math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) == 0 then --! FAIL-SAFE; DO NOT DELETE
          for checkboxIndex = 1, #self.checkboxSkinObjectType do
               local checkboxObjectTypes   = self.checkboxSkinObjectType[checkboxIndex]
               local checkboxObjectTypeTag = self.checkboxSkinObjectType[checkboxIndex]:upperAtStart()
               local checkboxSkinIndex     = self.checkboxSkinObjectIndex[checkboxObjectTypes:lower()]

               local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = checkboxSkinIndex}
               local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)

               if checkboxSkinIndex == 0 or luaSpriteExists(displaySkinIconButton) == false then
                    removeLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
               else
                    addLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
               end
          end
     end
end

--- Collection group of search selection methods.
---@return nil
function SkinNotesSearch:search_selection()
     self:search_selection_byclick()
     self:search_selection_byhover()
     self:search_selection_cursor()
end

--- Main display skin button clicking functionality and animations.
--- Allowing the selecting of the corresponding skin in gameplay.
---@return nil
function SkinNotesSearch:search_selection_byclick()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerIDs      = self.totalSkinObjectID[searchSkinPage]
          local skinObjectsPerHovered  = self.totalSkinObjectHovered[searchSkinPage]
          local skinObjectsPerClicked  = self.totalSkinObjectClicked[searchSkinPage]
          local skinObjectsPerSelected = self.totalSkinObjectSelected[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          local displaySkinIconSkin     = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplate)
          local function displaySkinSelect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.selectSkinPreSelectedIndex == searchSkinIndex

               if byClick == true and skinObjectsPerClicked[searchSkinPresentIndex] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.selectSkinPreSelectedIndex = skinObjectsPerIDs[searchSkinPresentIndex]
                    self.selectSkinHasBeenClicked   = true

                    SkinNoteSave:set('selectSkinPreSelectedIndex', self.stateClass, self.selectSkinPreSelectedIndex)
                    skinObjectsPerClicked[searchSkinPresentIndex] = true
               end

               if byRelease == true and skinObjectsPerClicked[searchSkinPresentIndex] == true then
                    playAnim(displaySkinIconButton, 'selected', true)
     
                    self.selectSkinInitSelectedIndex = self.selectSkinCurSelectedIndex
                    self.selectSkinCurSelectedIndex  = skinObjectsPerIDs[searchSkinPresentIndex]
                    self.selectSkinPagePositionIndex = self.selectSkinPagePositionIndex
                    self.selectSkinHasBeenClicked    = false
                    
                    self:search_preview()
                    SkinNoteSave:set('selectSkinInitSelectedIndex', self.stateClass, self.selectSkinInitSelectedIndex)
                    SkinNoteSave:set('selectSkinCurSelectedIndex',  self.stateClass, self.selectSkinCurSelectedIndex)
                    skinObjectsPerSelected[searchSkinPresentIndex] = true
                    skinObjectsPerClicked[searchSkinPresentIndex]  = false
               end
          end
          local function displaySkinDeselect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.selectSkinPreSelectedIndex == searchSkinIndex
               if byClick == true and skinObjectsPerClicked[searchSkinPresentIndex] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.selectSkinPreSelectedIndex = skinObjectsPerIDs[searchSkinPresentIndex]
                    self.selectSkinHasBeenClicked   = true

                    SkinNoteSave:set('selectSkinPreSelectedIndex', self.stateClass, self.selectSkinPreSelectedIndex)
                    skinObjectsPerClicked[searchSkinPresentIndex] = true
               end

               if byRelease == true and skinObjectsPerClicked[searchSkinPresentIndex] == true then
                    playAnim(displaySkinIconButton, 'static', true)

                    self.selectSkinCurSelectedIndex = 0
                    self.selectSkinPreSelectedIndex = 0
                    self.selectSkinHasBeenClicked   = false

                    self:search_preview()
                    SkinNoteSave:set('selectSkinPreSelectedIndex', self.stateClass, self.selectSkinPreSelectedIndex)
                    SkinNoteSave:set('selectSkinCurSelectedIndex', self.stateClass, self.selectSkinCurSelectedIndex)
                    skinObjectsPerSelected[searchSkinPresentIndex] = false
                    skinObjectsPerClicked[searchSkinPresentIndex]  = false
                    skinObjectsPerHovered[searchSkinPresentIndex]  = false
               end
          end
          local function displaySkinAutoDeselect()
               self.selectSkinCurSelectedIndex = 0
               self.selectSkinPreSelectedIndex = 0
               self.selectSkinHasBeenClicked   = false

               self:search_preview()
               SkinNoteSave:set('selectSkinCurSelectedIndex', self.stateClass, self.selectSkinCurSelectedIndex)
               SkinNoteSave:set('selectSkinPreSelectedIndex', self.stateClass, self.selectSkinPreSelectedIndex)
               skinObjectsPerSelected[searchSkinPresentIndex] = false
               skinObjectsPerClicked[searchSkinPresentIndex]  = false
               skinObjectsPerHovered[searchSkinPresentIndex]  = false
          end

          local previewObjectCurAnim        = self.previewAnimationObjectPrevAnims[self.previewAnimationObjectIndex]
          local previewObjectMissingAnim    = self.previewAnimationObjectMissing[searchSkinPage][searchSkinPresentIndex]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]
          if skinObjectsPerSelected[searchSkinPresentIndex] == false and searchSkinIndex ~= self.selectSkinCurSelectedIndex and previewObjectCurMissingAnim == false then
               displaySkinSelect()
          end
          if skinObjectsPerSelected[searchSkinPresentIndex] == true then
               --displaySkinDeselect()
          end

          if skinObjectsPerSelected[searchSkinPresentIndex] == true and previewObjectCurMissingAnim == true then
               displaySkinAutoDeselect()
          end

          if searchSkinIndex == self.selectSkinInitSelectedIndex then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    playAnim(displaySkinIconButton, 'static', true)
               end

               self.selectSkinInitSelectedIndex = 0
               SkinNoteSave:set('selectSkinInitSelectedIndex', self.stateClass, self.selectSkinInitSelectedIndex)
               skinObjectsPerSelected[searchSkinPresentIndex]  = false
          end
     end
end

--- Main display skin button hovering functionality and animations.
--- Allowing the cursor's sprite to change its corresponding sprite when hovering for visual aid.
---@return nil
function SkinNotesSearch:search_selection_byhover()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerIDs      = self.totalSkinObjectID[searchSkinPage]
          local skinObjectsPerHovered  = self.totalSkinObjectHovered[searchSkinPage]
          local skinObjectsPerClicked  = self.totalSkinObjectClicked[searchSkinPage]
          local skinObjectsPerSelected = self.totalSkinObjectSelected[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if hoverObject(displaySkinIconButton, 'camHUD') == true then
               skinObjectsPerHovered[searchSkinPresentIndex] = true
          end
          if hoverObject(displaySkinIconButton, 'camHUD') == false then
               skinObjectsPerHovered[searchSkinPresentIndex] = false
          end

          local nonCurrentPreSelectedSkin = self.selectSkinPreSelectedIndex ~= searchSkinIndex
          local nonCurrentCurSelectedSkin = self.selectSkinCurSelectedIndex ~= searchSkinIndex
          if skinObjectsPerHovered[searchSkinPresentIndex] == true and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButton) == false then return end
               playAnim(displaySkinIconButton, 'hover', true)
          end
          if skinObjectsPerHovered[searchSkinPresentIndex] == false and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButton) == false then return end
               playAnim(displaySkinIconButton, 'static', true)
          end

          local previewObjectCurAnim        = self.previewAnimationObjectPrevAnims[self.previewAnimationObjectIndex]
          local previewObjectMissingAnim    = self.previewAnimationObjectMissing[searchSkinPage][searchSkinPresentIndex]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]
          if previewObjectCurMissingAnim == true then
               playAnim(displaySkinIconButton, 'blocked', true)
          end
     end
end

--- Main cursor functionality for the display skin button and its animations.
--- Allowing the cursor's sprite to change depending on its interaction (i.e. selecting and hovering).
---@return nil
function SkinNotesSearch:search_selection_cursor()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     if mouseClicked('left') or mousePressed('left') then 
          playAnim('mouseTexture', 'idleClick', true)
     else
          playAnim('mouseTexture', 'idle', true)
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerHovered  = self.totalSkinObjectHovered[searchSkinPage]
          local skinObjectsPerClicked  = self.totalSkinObjectClicked[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if hoverObject(displaySkinIconButton:gsub('%d+', tostring(self.selectSkinCurSelectedIndex)), 'camHUD') == true then
               goto skipSelectedSearchSkin -- disabled deselecting
          end

          if skinObjectsPerClicked[searchSkinPresentIndex] == true and luaSpriteExists(displaySkinIconButton) == true then
               playAnim('mouseTexture', 'handClick', true)
          end
          if skinObjectsPerHovered[searchSkinPresentIndex] == true and luaSpriteExists(displaySkinIconButton) == true then
               playAnim('mouseTexture', 'hand', true)
          end

          local previewObjectCurAnim        = self.previewAnimationObjectPrevAnims[self.previewAnimationObjectIndex]
          local previewObjectMissingAnim    = self.previewAnimationObjectMissing[searchSkinPage][searchSkinPresentIndex]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]
          if previewObjectCurMissingAnim == true then
               local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
               local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)

               if hoverObject(displaySkinIconButton, 'camHUD') == true then
                    if mouseClicked('left') then 
                         playSound('cancel') 
                    end

                    if mouseClicked('left') or mousePressed('left') then 
                         playAnim('mouseTexture', 'disabledClick', true)
                    else
                         playAnim('mouseTexture', 'disabled', true)
                    end
               end
          end
          ::skipSelectedSearchSkin::
     end
     
     if hoverObject('displaySliderIcon', 'camHUD') == true and self.totalSkinLimit == 1 then
          if mouseClicked('left') or mousePressed('left') then 
               playAnim('mouseTexture', 'disabledClick', true)
          else
               playAnim('mouseTexture', 'disabled', true)
          end

          if mouseClicked('left') then 
               playSound('cancel') 
          end
     end
end

return SkinNotesSearch