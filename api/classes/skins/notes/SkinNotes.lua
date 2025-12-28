luaDebugMode = true

local SkinSaves          = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'
local SkinNotesPage      = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotesPage'
local SkinNotesSelection = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotesSelection'
local SkinNotesPreview   = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotesPreview'
local SkinNotesCheckbox  = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotesCheckbox'
local SkinNotesSearch    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotesSearch'
local SkinNotesSave      = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotesSave'

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

local MAX_NUMBER_CHUNK = 16

local SkinNoteSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

---@alias ParentClasses
---| 'inherit' # The child class to inherit and derived from its based parent class.
---| 'extends' # The extension properties of this class. 

--- Allows for the classes inherit multiple parent classes either as an inherit or extension.
---@param parentClasses ParentClasses The multiple classes to inherit.
---@return table Returns all the parent classes into one table.
local function inheritedClasses(parentClasses)
     local parentClassesOutput = {}
     if parentClasses.extends ~= nil then
          for _, classes in pairs(parentClasses.extends) do
               parentClassesOutput[#parentClassesOutput+1] = classes
          end
     end
     if parentClasses.inherit ~= nil then
          for _, classes in pairs(parentClasses.inherit) do
               parentClassesOutput[#parentClassesOutput+1] = classes
          end
     end

     local classes = {}
     function classes:__index(index)
          for classesIndex = 1, #parentClassesOutput do
               local result = parentClassesOutput[classesIndex][index]
               if result then
                    return result
               end
          end
          return nil
     end
     return setmetatable({}, classes)
end

--- Main class for the note skin state inherited by many of its extended subclasses.
---@class SkinNotes: SkinNotesPage, SkinNotesSelection, SkinNotesPreview, SkinNotesCheckbox, SkinNotesSearch, SkinNotesSave
local SkinNotes = inheritedClasses({
     extends = {SkinNotesPage, SkinNotesSelection, SkinNotesPreview, SkinNotesCheckbox, SkinNotesSearch, SkinNotesSave}
})

--- Initializes the attributes for the note skin state to use.
---@param stateClass string The corresponding name for this skin state.
---@param statePath string The corresponding image path to display for this skin state.
---@param statePrefix string the corresponding image prefix name for this skin state. 
---@return SkinNotes
function SkinNotes:new(stateClass, statePaths, statePrefix)
     local self = setmetatable(setmetatable({}, self), {__index = self})
     self.stateClass  = stateClass
     self.statePaths  = statePaths
     self.statePrefix = statePrefix

     return self
end

--- Loads multiple attribute properties (including its save data) for the class, used after initialization.
---@return nil
function SkinNotes:load()
     self.totalSkins     = states.getTotalSkins(self.stateClass, false)
     self.totalSkinPaths = states.getTotalSkins(self.stateClass, true)
     self.totalSkinNames = states.getTotalSkinNames(self.stateClass)

     -- Object Properties --

     self.totalSkinLimit         = states.getTotalSkinLimit(self.stateClass)
     self.totalSkinObjects       = states.getTotalSkinObjects(self.stateClass)
     self.totalSkinObjectID      = states.getTotalSkinObjects(self.stateClass, 'ids')
     self.totalSkinObjectNames   = states.getTotalSkinObjects(self.stateClass, 'names')
     self.totalSkinObjectIndexes = states.getTotalSkinObjectIndexes(self.stateClass)

     -- Display Properties --
     
     self.totalSkinObjectHovered  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.totalSkinObjectClicked  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.totalSkinObjectSelected = states.getTotalSkinObjects(self.stateClass, 'bools')

     self.totalMetadataObjectDisplay  = states.getMetadataObjectSkins(self.stateClass, 'display', true)
     self.totalMetadataObjectPreview  = states.getMetadataObjectSkins(self.stateClass, 'preview', true)
     self.totalMetadataObjectSkins    = states.getMetadataObjectSkins(self.stateClass, 'skins', true)

     self.totalMetadataOrderedDisplay = states.getMetadataSkinsOrdered(self.stateClass, 'display', true)
     self.totalMetadataOrderedPreview = states.getMetadataSkinsOrdered(self.stateClass, 'preview', true)
     self.totalMetadataOrderedSkins   = states.getMetadataSkinsOrdered(self.stateClass, 'skins', true)

     -- Slider Properties --

     self.sliderPageIndex          = 1
     self.sliderTrackPageIndex     = 1
     self.sliderTrackPressed       = false
     self.sliderTrackToggle        = false
     self.sliderTrackIntervals     = states.getPageSkinSliderPositions(self.stateClass).intervals
     self.sliderTrackSemiIntervals = states.getPageSkinSliderPositions(self.stateClass).semiIntervals

     -- Display Selection Properties --
     
     local selectPagePositionIndex = SkinNoteSave:get('selectSkinPagePositionIndex', self.stateClass, 1)
     local selectInitSelectedIndex = SkinNoteSave:get('selectSkinInitSelectedIndex', self.stateClass, 1)
     local selectPreSelectedIndex  = SkinNoteSave:get('selectSkinPreSelectedIndex',  self.stateClass, 1)
     local selectCurSelectedIndex  = SkinNoteSave:get('selectSkinCurSelectedIndex',  self.stateClass, 1)

     self.selectSkinPagePositionIndex = selectCurSelectedIndex -- current page index
     self.selectSkinInitSelectedIndex = selectInitSelectedIndex -- current pressed selected skin
     self.selectSkinPreSelectedIndex  = selectPreSelectedIndex  -- highlighting the current selected skin
     self.selectSkinCurSelectedIndex  = selectCurSelectedIndex  -- current selected skin index
     self.selectSkinHasBeenClicked    = false                   -- whether the skin display has been clicked or not

     -- Preview Animation Properties --

     self.previewStaticDataDisplay = json.parse(getTextFromFile('json/notes/constant/display.json'))
     self.previewStaticDataPreview = json.parse(getTextFromFile('json/notes/constant/preview.json'))
     self.previewStaticDataSkins   = json.parse(getTextFromFile('json/notes/constant/skins.json'))
     self.previewConstDataPreviewAnims = json.parse(getTextFromFile('json/notes/constant/preview_anims.json'))

     self.previewAnimationObjectHovered = {false, false}
     self.previewAnimationObjectClicked = {false, false}

     local previewObjectIndex = SkinNoteSave:get('previewObjectIndex', self.stateClass, 1)
     self.previewAnimationObjectIndex     = previewObjectIndex
     self.previewAnimationObjectPrevAnims = {'confirm', 'pressed', 'colored'}

     local previewObjectAnims    = {'strums', 'confirm', 'pressed', 'colored'}
     local previewObjectMetadata = self.totalMetadataObjectPreview
     self.previewAnimationObjectMissing = states.getPreviewObjectMissingAnims(previewObjectAnims, previewObjectMetadata, self.totalSkinLimit)

     -- Checkbox Skin Properties --

     self.checkboxSkinObjectHovered = {false, false}
     self.checkboxSkinObjectClicked = {false, false}

     local checkboxIndexPlayer   = SkinNoteSave:get('checkboxSkinObjectIndexPlayer',   self.stateClass, 0)
     local checkboxIndexOpponent = SkinNoteSave:get('checkboxSkinObjectIndexOpponent', self.stateClass, 0)
     self.checkboxSkinObjectIndex  = {player = checkboxIndexPlayer,  opponent = checkboxIndexOpponent}
     self.checkboxSkinObjectToggle = {player = false,                opponent = false}
     self.checkboxSkinObjectType   = table.keys(self.checkboxSkinObjectIndex)

     -- Search Properties --

     self.searchSkinObjectIndex = table.new(MAX_NUMBER_CHUNK, 0)
     self.searchSkinObjectPage  = table.new(MAX_NUMBER_CHUNK, 0)
     self.searchAnimationObjectMissing = table.new(MAX_NUMBER_CHUNK, 0)
end

--- Checks for any error(s) within the classes' attribute properties, resetting to default if found.
---@return nil
function SkinNotes:load_preventError()
     local skinTotalSkinMetatable = {}
     function skinTotalSkinMetatable:__index(index)
          if index == 0 then
               return '@void'
               end
          return '@error', index
     end

     local skinTotalSkinPaths = setmetatable(self.totalSkinPaths, skinTotalSkinMetatable)
     if skinTotalSkinPaths[self.checkboxSkinObjectIndex.player]   == '@error' then
          self.checkboxSkinObjectIndex.player = 0
          SkinNoteSave:set('checkboxSkinObjectIndexPlayer', self.stateClass, 0)
     end
     if skinTotalSkinPaths[self.checkboxSkinObjectIndex.opponent] == '@error' then
          self.checkboxSkinObjectIndex.opponent = 0
          SkinNoteSave:set('checkboxSkinObjectIndexOpponent', self.stateClass, 0)
     end

     if self.selectSkinPagePositionIndex <= 0 or self.selectSkinPagePositionIndex > self.totalSkinLimit then
          self.sliderPageIndex      = 1
          self.sliderTrackPageIndex = 1

          self.selectSkinPagePositionIndex = 1
          SkinNoteSave:set('selectSkinPagePositionIndex', self.stateClass, 1)
     end
     if self.previewAnimationObjectIndex <= 0 or self.previewAnimationObjectIndex > #self.previewAnimationObjectPrevAnims then
          self.previewAnimationObjectIndex = 1
          SkinNoteSave:set('previewObjectIndex', self.stateClass, 1)
     end
end

--- Preloads multiple chunks by moving from page to page, which (might) improves optimization significantly.
---@return nil
function SkinNotes:preload()
     for skinPages = self.totalSkinLimit, 1, -1 do
          if skinPages == self.selectSkinPagePositionIndex then
               self:create(skinPages)
          end
     end
end

--- Precaches the images within the note skin state, which improves optimization significantly.
---@return nil
function SkinNotes:precache()
     for _, skinPaths in pairs(self.totalSkinPaths) do
          precacheImage(skinPaths)
     end
     precacheImage('ui/buttons/display_button')
end
 
--- Creates a chunk gallery of available display skins to select from.
---@param skinIndex? integer The given page-index for the chunk to display, if it exists.
---@return nil
function SkinNotes:create(skinIndex)
     local skinIndex = (skinIndex == nil) and 1 or skinIndex

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

          local SKIN_ROW_MAX_LENGTH = 4
          for skinDisplays = 1, #self.totalSkinObjects[skinIndex] do
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

     for skinDisplays = 1, #self.totalSkinObjects[skinIndex] do
          local skinObjectsID = self.totalSkinObjectID[skinIndex][skinDisplays]
          local skinObjects   = self.totalSkinObjects[skinIndex][skinDisplays]

          local displaySkinIconTagButton = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{skinObjectsID}"
          local displaySkinIconTagSkin   = F"displaySkinIconSkin{self.stateClass:upperAtStart()}-{skinObjectsID}"
          local displaySkinIconPosX = displaySkinIconPositions()[skinDisplays][1]
          local displaySkinIconPosY = displaySkinIconPositions()[skinDisplays][2]
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
               local metaObjectsDisplay = self.totalMetadataObjectDisplay[skinIndex][skinDisplays] 
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
          local displaySkinIconPositionX = displaySkinIconPosX + DISPLAY_SKIN_POSITION_OFFSET_X
          local displaySkinIconPositionY = displaySkinIconPosY + DISPLAY_SKIN_POSITION_OFFSET_Y

          local displaySkinIconSprite = F"{self.statePaths}/{skinObjects}"
          makeAnimatedLuaSprite(displaySkinIconTagSkin, displaySkinIconSprite, displaySkinIconPositionX, displaySkinIconPositionY)
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
     end

     self:page_text()
     self:save_selection()
end

--- Destroys a chunk of the note skin state (page-index dependent), used only for switching states.
---@return nil
function SkinNotes:destroy()
     for skinDisplays = 1, #self.totalSkinObjects[self.selectSkinPagePositionIndex] do
          local skinObjectID = self.totalSkinObjectID[self.selectSkinPagePositionIndex][skinDisplays]
          local skinObjects  = self.totalSkinObjects[self.selectSkinPagePositionIndex][skinDisplays]

          local displaySkinIconTagButton = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{skinObjectID}"
          local displaySkinIconTagSkin   = F"displaySkinIconSkin{self.stateClass:upperAtStart()}-{skinObjectID}"
          local displaySkinIconSprite    = F"{self.statePaths}/{skinObjects}"
          removeLuaSprite(displaySkinIconTagButton, true)
          removeLuaSprite(displaySkinIconTagSkin, true)
          removeLuaSprite(displaySkinIconSprite, true)
     end

     --- Destroyes the slider marks within sliderbar tracks.
     ---@param intervalType string The interval type to be destroyed, either: interval or semiInterval.
     ---@param intervalPageIndex number The interval page index to be destroyed.
     ---@return nil
     local function destroySliderMarkObjects(intervalType, intervalPageIndex)
          local INTERVAL_TYPE_UPPER = intervalType:upperAtStart()
          local INTERVAL_PAGE_INDEX = intervalPageIndex

          local displaySliderMarkTag = F"displaySliderMark{self.stateClass:upperAtStart()}{INTERVAL_TYPE_UPPER}{INTERVAL_PAGE_INDEX}"
          removeLuaSprite(displaySliderMarkTag, true)
     end
     for intervalIndex = 1, #self.sliderTrackIntervals do
          destroySliderMarkObjects('interval', intervalIndex)
     end
     for semiIntervalIndex = 2, #self.sliderTrackSemiIntervals do
          destroySliderMarkObjects('semiInterval', semiIntervalIndex)
     end

     for skinPreviewStrums = 1, 4 do
          local previewSkinGroup = F"previewSkinGroup{self.stateClass:upperAtStart()}{skinPreviewStrums}"          
          removeLuaSprite(previewSkinGroup, true)
     end
     callOnScripts('skinSearchInput_callResetSearch')
end

return SkinNotes