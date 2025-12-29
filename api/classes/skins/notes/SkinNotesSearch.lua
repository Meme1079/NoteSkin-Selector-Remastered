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

---@enum CHARACTERS
local CHARACTERS = {
     PLAYER   = 1,
     OPPONENT = 2
}

--- Childclass extension, main searching component functionality for the note skin state.
---@class SkinNotesSearch
local SkinNotesSearch = {}

--- Collection group of search methods.
---@return nil
function SkinNotesSearch:search()
     self:search_create()
     self:search_skins()
     self:search_selection()
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
     for searchPage = 1, #self.TOTAL_SKIN_OBJECTS_ID do
          local totalSkinObjectIDs     = self.TOTAL_SKIN_OBJECTS_ID[searchPage]
          local totalSkinObjectMerge   = table.merge(totalSkinObjectIDs, skinInputContentID)
          local totalSkinObjectPresent = table.singularity(totalSkinObjectMerge, true)

          for curPresentIndex = 1, #totalSkinObjectPresent do
               skinSearchIndex = skinSearchIndex + 1
               self.SEARCH_SKIN_OBJECT_IDS[skinSearchIndex]   = totalSkinObjectPresent[curPresentIndex]
               self.SEARCH_SKIN_OBJECT_PAGES[skinSearchIndex] = searchPage
          end
     end
     self:checkbox_sync()
     self:search_checkbox_sync()
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
          self:create(self.SELECT_SKIN_PAGE_INDEX)
          self:page_text()
          self:save_selection()
          return
     end
     
     for skinPages = 1, self.TOTAL_SKIN_LIMIT do
          for skinDisplays = 1, #self.TOTAL_SKIN_OBJECTS[skinPages] do
               if skinPages == skinIndex then
                    goto SKIP_SKIN_PAGE
               end

               local skinObjectID = self.TOTAL_SKIN_OBJECTS_ID[skinPages][skinDisplays]
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

     local currenMinPageRange = (self.SELECT_SKIN_PAGE_INDEX - 1) * MAX_NUMBER_CHUNK
     local currenMaxPageRange = self.SELECT_SKIN_PAGE_INDEX       * MAX_NUMBER_CHUNK
     currenMinPageRange = (currenMinPageRange == 0) and 1 or currenMinPageRange -- adjust for 1-based index

     local searchFilterSkinPageRange = table.tally(currenMinPageRange, currenMaxPageRange)
     local searchFilterSkinPresent   = table.singularity(table.merge(filterSearchByID, searchFilterSkinPageRange), false)
     local searchFilterSkinRange     = table.sub(searchFilterSkinPresent, 1, #filterSearchByName) -- adjust for present skins only
     self.SEARCH_SKIN_OBJECT_PRESENT = searchFilterSkinRange

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
               local metaObjectsDisplay = self.TOTAL_SKIN_METAOBJ_ORDERED_DISPLAY[tonumber(skinSearchIDs)]
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
     self:search_checkbox_sync()
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
          if self.SELECT_SKIN_CUR_SELECTION_INDEX == 0 or self.TOTAL_SKINS[self.SELECT_SKIN_CUR_SELECTION_INDEX] == nil then
               return skinObjects[1][1] -- default value
          end

          for skinPages = 1, self.TOTAL_SKIN_LIMIT do -- checks if each page has an existing skin object
               local selectedSkinPage  = self.TOTAL_SKIN_OBJECTS_INDICES[skinPages]
               local selectedSkinIndex = table.find(selectedSkinPage, self.SELECT_SKIN_CUR_SELECTION_INDEX)
               if selectedSkinIndex ~= nil then
                    return skinObjects[skinPages][selectedSkinIndex]
               end
          end
     end

     local currentPreviewDataSkins    = currentPreviewSkinData(self.TOTAL_SKIN_OBJECTS)
     local currentPreviewDataNames    = currentPreviewSkinData(self.TOTAL_SKIN_OBJECTS_NAMES)
     local currentPreviewMetadataPrev = currentPreviewSkinData(self.TOTAL_SKIN_METAOBJ_PREVIEW)

     --- Gets the skin's preview metadata object from its JSON.
     ---@param metadataName string The name of the metadata to be fetch.
     ---@return table
     local function previewMetadataObject(metadataName)
          local metadataSkinPrevObj         = currentPreviewMetadataPrev
          local metadataSkinPrevObjElements = currentPreviewMetadataPrev[metadataName]
          if metadataSkinPrevObj == '@void' or metadataSkinPrevObjElements == nil then
               return self.PREVIEW_CONST_METADATA_PREVIEW[metadataName]
          end
          return metadataSkinPrevObjElements
     end

     --- Same as the previous function above, helper function; this retreives mainly its animation from its JSON.
     ---@param animationName string The name of the animation metadata to be fetch.
     ---@param strumIndex number The strum index number to cycle each value.
     ---@param byAnimationGroup? boolean Whether it will retreive by group or not.
     ---@return table
     local function previewMetadataObjectAnims(animationName, strumIndex, byAnimationGroup)
          local metadataSkinPrevObj     = currentPreviewMetadataPrev
          local metadataSkinPrevObjAnim = currentPreviewMetadataPrev.animations

          local constantSkinPrevObjAnimNames = self.PREVIEW_CONST_METADATA_PREVIEW_ANIMS['names'][animationName]
          local constantSkinPrevObjAnim      = self.PREVIEW_CONST_METADATA_PREVIEW.animation
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
          playAnim(previewSkinGroupTag, self.PREVIEW_CONST_METADATA_PREVIEW_ANIMS['names']['strums'][strumIndex])
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

     for searchPages = 1, #self.SEARCH_SKIN_OBJECT_PAGES do
          local totalSkinObjectIDs = self.TOTAL_SKIN_OBJECTS_ID[tonumber(self.SEARCH_SKIN_OBJECT_PAGES[searchPages])]
          for CharNames, CharValues in pairs(CHARACTERS) do
               local checkboxSkinChars = self.CHECKBOX_SKIN_OBJECT_CHARS[CharValues]
               local CHECK_CHECKBOX_SKIN_INDEX_IS_CURRENT = checkboxSkinChars == self.SELECT_SKIN_CUR_SELECTION_INDEX
               local CHECK_CHECKBOX_SKIN_INDEX_IS_PRESENT = checkboxSkinChars == table.find(totalSkinObjectIDs, checkboxSkinChars) 

               local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{checkboxSkinChars}"
               local checkboxSkinSelectionTag = F"displaySelection{CharNames:upperAtStart(true)}"
               local checkboxSkinButtonTag    = F"selectionSkinButton{CharNames:upperAtStart(true)}"

               if CHECK_CHECKBOX_SKIN_INDEX_IS_CURRENT or CHECK_CHECKBOX_SKIN_INDEX_IS_PRESENT or luaSpriteExists(displaySkinIconButtonTag) == true then
                    setProperty(F"{checkboxSkinSelectionTag}.x", getProperty(F"{displaySkinIconButtonTag}.x"))
                    setProperty(F"{checkboxSkinSelectionTag}.y", getProperty(F"{displaySkinIconButtonTag}.y"))
               end
               if checkboxSkinChars == 0 or luaSpriteExists(checkboxSkinSelectionTag) == false then
                    removeLuaSprite(checkboxSkinSelectionTag, false)
               else
                    addLuaSprite(checkboxSkinSelectionTag, false)
               end
          end
     end

     for CharNames, CharValues in pairs(CHARACTERS) do --! DO NOT DELETE; VISUAL FIX STUFF
          local checkboxSkinChars        = self.CHECKBOX_SKIN_OBJECT_CHARS[CharValues]
          local checkboxSkinSelectionTag = F"displaySelection{CharNames:upperAtStart(true)}"

          local LENGHT_SEARCH_SKIN_OBJECT_IDS     = #self.SEARCH_SKIN_OBJECT_IDS     == 0
          local LENGTH_SEARCH_SKIN_OBJECT_PRESENT = #self.SEARCH_SKIN_OBJECT_PRESENT == 0
          local EXIST_SEARCH_SKIN_OBJECT_PRESENT  = table.find(self.SEARCH_SKIN_OBJECT_PRESENT, checkboxSkinChars, true) == nil
          if LENGHT_SEARCH_SKIN_OBJECT_IDS or LENGTH_SEARCH_SKIN_OBJECT_PRESENT or EXIST_SEARCH_SKIN_OBJECT_PRESENT or luaSpriteExists(checkboxSkinSelectionTag) == false then
               removeLuaSprite(checkboxSkinSelectionTag, false)
          else
               addLuaSprite(checkboxSkinSelectionTag, false)
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

     for searchIndex = 1, math.max(#self.SEARCH_SKIN_OBJECT_IDS, #self.SEARCH_SKIN_OBJECT_PAGES) do
          local searchSkinIndex = tonumber( self.SEARCH_SKIN_OBJECT_IDS[searchIndex] )
          local searchSkinPage  = tonumber( self.SEARCH_SKIN_OBJECT_PAGES[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.TOTAL_SKIN_OBJECTS_ID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerIDs      = self.TOTAL_SKIN_OBJECTS_ID[searchSkinPage]
          local skinObjectsPerHovered  = self.TOTAL_SKIN_OBJECTS_HOVERED[searchSkinPage]
          local skinObjectsPerClicked  = self.TOTAL_SKIN_OBJECTS_CLICKED[searchSkinPage]
          local skinObjectsPerSelected = self.TOTAL_SKIN_OBJECTS_SELECTED[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          local displaySkinIconSkin     = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplate)
          local function displaySkinSelect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.SELECT_SKIN_PRE_SELECTION_INDEX == searchSkinIndex

               if byClick == true and skinObjectsPerClicked[searchSkinPresentIndex] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.SELECT_SKIN_PRE_SELECTION_INDEX = skinObjectsPerIDs[searchSkinPresentIndex]
                    self.SELECT_SKIN_CLICKED_SELECTION   = true

                    SkinNoteSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
                    skinObjectsPerClicked[searchSkinPresentIndex] = true
               end

               if byRelease == true and skinObjectsPerClicked[searchSkinPresentIndex] == true then
                    playAnim(displaySkinIconButton, 'selected', true)
     
                    self.SELECT_SKIN_INIT_SELECTION_INDEX = self.SELECT_SKIN_CUR_SELECTION_INDEX
                    self.SELECT_SKIN_CUR_SELECTION_INDEX  = skinObjectsPerIDs[searchSkinPresentIndex]
                    self.SELECT_SKIN_PAGE_INDEX           = self.SELECT_SKIN_PAGE_INDEX
                    self.SELECT_SKIN_CLICKED_SELECTION    = false
                    
                    self:search_preview()
                    SkinNoteSave:set('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_INIT_SELECTION_INDEX)
                    SkinNoteSave:set('SELECT_SKIN_CUR_SELECTION_INDEX',  self.stateClass:upper(), self.SELECT_SKIN_CUR_SELECTION_INDEX)
                    skinObjectsPerSelected[searchSkinPresentIndex] = true
                    skinObjectsPerClicked[searchSkinPresentIndex]  = false
               end
          end
          local function displaySkinDeselect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.SELECT_SKIN_PRE_SELECTION_INDEX == searchSkinIndex
               if byClick == true and skinObjectsPerClicked[searchSkinPresentIndex] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.SELECT_SKIN_PRE_SELECTION_INDEX = skinObjectsPerIDs[searchSkinPresentIndex]
                    self.SELECT_SKIN_CLICKED_SELECTION   = true

                    SkinNoteSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
                    skinObjectsPerClicked[searchSkinPresentIndex] = true
               end

               if byRelease == true and skinObjectsPerClicked[searchSkinPresentIndex] == true then
                    playAnim(displaySkinIconButton, 'static', true)

                    self.SELECT_SKIN_CUR_SELECTION_INDEX = 0
                    self.SELECT_SKIN_PRE_SELECTION_INDEX = 0
                    self.SELECT_SKIN_CLICKED_SELECTION   = false

                    self:search_preview()
                    SkinNoteSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
                    SkinNoteSave:set('SELECT_SKIN_CUR_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_CUR_SELECTION_INDEX)
                    skinObjectsPerSelected[searchSkinPresentIndex] = false
                    skinObjectsPerClicked[searchSkinPresentIndex]  = false
                    skinObjectsPerHovered[searchSkinPresentIndex]  = false
               end
          end
          local function displaySkinAutoDeselect()
               self.SELECT_SKIN_CUR_SELECTION_INDEX = 0
               self.SELECT_SKIN_PRE_SELECTION_INDEX = 0
               self.SELECT_SKIN_CLICKED_SELECTION   = false

               self:search_preview()
               SkinNoteSave:set('SELECT_SKIN_CUR_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_CUR_SELECTION_INDEX)
               SkinNoteSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
               skinObjectsPerSelected[searchSkinPresentIndex] = false
               skinObjectsPerClicked[searchSkinPresentIndex]  = false
               skinObjectsPerHovered[searchSkinPresentIndex]  = false
          end

          local previewObjectCurAnim        = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewObjectMissingAnim    = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING[searchSkinPage][searchSkinPresentIndex]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]
          if skinObjectsPerSelected[searchSkinPresentIndex] == false and searchSkinIndex ~= self.SELECT_SKIN_CUR_SELECTION_INDEX and previewObjectCurMissingAnim == false then
               displaySkinSelect()
          end
          if skinObjectsPerSelected[searchSkinPresentIndex] == true then
               --displaySkinDeselect()
          end

          if skinObjectsPerSelected[searchSkinPresentIndex] == true and previewObjectCurMissingAnim == true then
               displaySkinAutoDeselect()
          end

          if searchSkinIndex == self.SELECT_SKIN_INIT_SELECTION_INDEX then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    playAnim(displaySkinIconButton, 'static', true)
               end

               self.SELECT_SKIN_INIT_SELECTION_INDEX = 0
               SkinNoteSave:set('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_INIT_SELECTION_INDEX)
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

     for searchIndex = 1, math.max(#self.SEARCH_SKIN_OBJECT_IDS, #self.SEARCH_SKIN_OBJECT_PAGES) do
          local searchSkinIndex = tonumber( self.SEARCH_SKIN_OBJECT_IDS[searchIndex] )
          local searchSkinPage  = tonumber( self.SEARCH_SKIN_OBJECT_PAGES[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.TOTAL_SKIN_OBJECTS_ID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerIDs      = self.TOTAL_SKIN_OBJECTS_ID[searchSkinPage]
          local skinObjectsPerHovered  = self.TOTAL_SKIN_OBJECTS_HOVERED[searchSkinPage]
          local skinObjectsPerClicked  = self.TOTAL_SKIN_OBJECTS_CLICKED[searchSkinPage]
          local skinObjectsPerSelected = self.TOTAL_SKIN_OBJECTS_SELECTED[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if hoverObject(displaySkinIconButton, 'camHUD') == true then
               skinObjectsPerHovered[searchSkinPresentIndex] = true
          end
          if hoverObject(displaySkinIconButton, 'camHUD') == false then
               skinObjectsPerHovered[searchSkinPresentIndex] = false
          end

          local nonCurrentPreSelectedSkin = self.SELECT_SKIN_PRE_SELECTION_INDEX ~= searchSkinIndex
          local nonCurrentCurSelectedSkin = self.SELECT_SKIN_CUR_SELECTION_INDEX ~= searchSkinIndex
          if skinObjectsPerHovered[searchSkinPresentIndex] == true and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButton) == false then return end
               playAnim(displaySkinIconButton, 'hover', true)
          end
          if skinObjectsPerHovered[searchSkinPresentIndex] == false and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButton) == false then return end
               playAnim(displaySkinIconButton, 'static', true)
          end

          local previewObjectCurAnim        = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewObjectMissingAnim    = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING[searchSkinPage][searchSkinPresentIndex]
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

     for searchIndex = 1, math.max(#self.SEARCH_SKIN_OBJECT_IDS, #self.SEARCH_SKIN_OBJECT_PAGES) do
          local searchSkinIndex = tonumber( self.SEARCH_SKIN_OBJECT_IDS[searchIndex] )
          local searchSkinPage  = tonumber( self.SEARCH_SKIN_OBJECT_PAGES[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.TOTAL_SKIN_OBJECTS_ID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerHovered  = self.TOTAL_SKIN_OBJECTS_HOVERED[searchSkinPage]
          local skinObjectsPerClicked  = self.TOTAL_SKIN_OBJECTS_CLICKED[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if hoverObject(displaySkinIconButton:gsub('%d+', tostring(self.SELECT_SKIN_CUR_SELECTION_INDEX)), 'camHUD') == true then
               goto skipSelectedSearchSkin -- disabled deselecting
          end

          if skinObjectsPerClicked[searchSkinPresentIndex] == true and luaSpriteExists(displaySkinIconButton) == true then
               playAnim('mouseTexture', 'handClick', true)
          end
          if skinObjectsPerHovered[searchSkinPresentIndex] == true and luaSpriteExists(displaySkinIconButton) == true then
               playAnim('mouseTexture', 'hand', true)
          end

          local previewObjectCurAnim        = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewObjectMissingAnim    = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING[searchSkinPage][searchSkinPresentIndex]
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
     
     if hoverObject('displaySliderIcon', 'camHUD') == true and self.TOTAL_SKIN_LIMIT == 1 then
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