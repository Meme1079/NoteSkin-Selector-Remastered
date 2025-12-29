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

local SkinNoteSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

local MAX_NUMBER_CHUNK = 16

---@enum CHARACTERS
local CHARACTERS = {
     PLAYER   = 1,
     OPPONENT = 2
}

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
--- * All attribute properties are PROTECTED (i.e. not accessible outside this class and its subclasses), hence the CAPITALIZATION format.
---@return nil
function SkinNotes:load()
     self.TOTAL_SKINS       = states.getTotalSkins(self.stateClass, false)
     self.TOTAL_SKINS_PATHS = states.getTotalSkins(self.stateClass, true)
     self.TOTAL_SKINS_NAMES = states.getTotalSkinNames(self.stateClass)

     -- Object Properties --

     self.TOTAL_SKIN_LIMIT           = states.getTotalSkinLimit(self.stateClass)
     self.TOTAL_SKIN_OBJECTS         = states.getTotalSkinObjects(self.stateClass)
     self.TOTAL_SKIN_OBJECTS_ID      = states.getTotalSkinObjects(self.stateClass, 'ids')
     self.TOTAL_SKIN_OBJECTS_NAMES   = states.getTotalSkinObjects(self.stateClass, 'names')
     self.TOTAL_SKIN_OBJECTS_INDICES = states.getTotalSkinObjectIndexes(self.stateClass)

     -- Display Properties --
     
     self.TOTAL_SKIN_OBJECTS_HOVERED  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.TOTAL_SKIN_OBJECTS_CLICKED  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.TOTAL_SKIN_OBJECTS_SELECTED = states.getTotalSkinObjects(self.stateClass, 'bools')

     self.TOTAL_SKIN_METAOBJ_DISPLAY  = states.getMetadataObjectSkins(self.stateClass, 'display', true)
     self.TOTAL_SKIN_METAOBJ_PREVIEW  = states.getMetadataObjectSkins(self.stateClass, 'preview', true)
     self.TOTAL_SKIN_METAOBJ_SKINS    = states.getMetadataObjectSkins(self.stateClass, 'skins', true)

     self.TOTAL_SKIN_METAOBJ_ORDERED_DISPLAY = states.getMetadataSkinsOrdered(self.stateClass, 'display', true)
     self.TOTAL_SKIN_METAOBJ_ORDERED_PREVIEW = states.getMetadataSkinsOrdered(self.stateClass, 'preview', true)
     self.TOTAL_SKIN_METAOBJ_ORDERED_SKINS   = states.getMetadataSkinsOrdered(self.stateClass, 'skins', true)

     -- Slider Properties --

     self.SCROLLBAR_PAGE_INDEX          = 1
     self.SCROLLBAR_TRACK_PAGE_INDEX    = 1
     self.SCROLLBAR_TRACK_THUMB_PRESSED = false
     self.SCROLLBAR_TRACK_TOGGLE        = false
     self.SCROLLBAR_TRACK_MAJOR_SNAP    = states.getPageSkinSliderPositions(self.stateClass).intervals
     self.SCROLLBAR_TRACK_MINOR_SNAP    = states.getPageSkinSliderPositions(self.stateClass).semiIntervals

     -- Display Selection Properties --
     
     local SELECT_SKIN_PAGE_INDEX           = SkinNoteSave:get('SELECT_SKIN_PAGE_INDEX',           self.stateClass:upper(), 1)
     local SELECT_SKIN_INIT_SELECTION_INDEX = SkinNoteSave:get('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), 1)
     local SELECT_SKIN_PRE_SELECTION_INDEX  = SkinNoteSave:get('SELECT_SKIN_PRE_SELECTION_INDEX',  self.stateClass:upper(), 1)
     local SELECT_SKIN_CUR_SELECTION_INDEX  = SkinNoteSave:get('SELECT_SKIN_CUR_SELECTION_INDEX',  self.stateClass:upper(), 1)

     self.SELECT_SKIN_PAGE_INDEX           = SELECT_SKIN_PAGE_INDEX           -- current page index
     self.SELECT_SKIN_INIT_SELECTION_INDEX = SELECT_SKIN_INIT_SELECTION_INDEX -- current pressed selected skin
     self.SELECT_SKIN_PRE_SELECTION_INDEX  = SELECT_SKIN_PRE_SELECTION_INDEX  -- highlighting the current selected skin
     self.SELECT_SKIN_CUR_SELECTION_INDEX  = SELECT_SKIN_CUR_SELECTION_INDEX  -- current selected skin index
     self.SELECT_SKIN_CLICKED_SELECTION    = false                            -- whether the skin display has been clicked or not

     -- Preview Animation Properties --

     local PREVIEW_SKIN_OBJECT_INDEX = SkinNoteSave:get('PREVIEW_SKIN_OBJECT_INDEX', self.stateClass:upper(), 1)

     self.PREVIEW_CONST_METADATA_DISPLAY       = json.parse(getTextFromFile('json/notes/constant/display.json'))
     self.PREVIEW_CONST_METADATA_PREVIEW       = json.parse(getTextFromFile('json/notes/constant/preview.json'))
     self.PREVIEW_CONST_METADATA_PREVIEW_ANIMS = json.parse(getTextFromFile('json/notes/constant/preview_anims.json'))
     self.PREVIEW_CONST_METADATA_SKINS         = json.parse(getTextFromFile('json/notes/constant/skins.json'))

     self.PREVIEW_SKIN_OBJECT_INDEX         = PREVIEW_SKIN_OBJECT_INDEX
     self.PREVIEW_SKIN_OBJECT_ANIMS         = {'confirm', 'pressed', 'colored'}
     self.PREVIEW_SKIN_OBJECT_ANIMS_HOVERED = {false, false} -- use the fuckass DIRECTION enum for reference
     self.PREVIEW_SKIN_OBJECT_ANIMS_CLICKED = {false, false} -- use the fuckass DIRECTION enum for reference
     self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING = states.getPreviewObjectMissingAnims(
          {'strums', 'confirm', 'pressed', 'colored'},
          self.TOTAL_SKIN_METAOBJ_PREVIEW,
          self.TOTAL_SKIN_LIMIT
     )

     -- Checkbox Skin Properties --

     local CHECKBOX_SKIN_OBJECT_CHARS_PLAYER   = SkinNoteSave:get('CHECKBOX_SKIN_OBJECT_CHARS_PLAYER',   self.stateClass:upper(), 0)
     local CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT = SkinNoteSave:get('CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT', self.stateClass:upper(), 0)

     self.CHECKBOX_SKIN_OBJECT_HOVERED = {false, false} -- use the fuckass CHARACTERS enum for reference
     self.CHECKBOX_SKIN_OBJECT_CLICKED = {false, false} -- use the fuckass CHARACTERS enum for reference
     self.CHECKBOX_SKIN_OBJECT_CHARS   = {CHECKBOX_SKIN_OBJECT_CHARS_PLAYER, CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT}
     self.CHECKBOX_SKIN_OBJECT_TOGGLE  = {false, false}

     -- Search Properties --

     self.SEARCH_SKIN_OBJECT_IDS           = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_PAGES         = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_PRESENT       = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_ANIMS_MISSING = table.new(MAX_NUMBER_CHUNK, 0)
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

     local skinTotalSkinPaths = setmetatable(self.TOTAL_SKINS_PATHS, skinTotalSkinMetatable)
     if skinTotalSkinPaths[self.CHECKBOX_SKIN_OBJECT_CHARS[CHARACTERS.PLAYER]]   == '@error' then
          self.CHECKBOX_SKIN_OBJECT_CHARS[CHARACTERS.PLAYER] = 0
          SkinNoteSave:set('CHECKBOX_SKIN_OBJECT_CHARS_PLAYER', self.stateClass:upper(), 0)
     end
     if skinTotalSkinPaths[self.CHECKBOX_SKIN_OBJECT_CHARS[CHARACTERS.OPPONENT]] == '@error' then
          self.CHECKBOX_SKIN_OBJECT_CHARS[CHARACTERS.OPPONENT] = 0
          SkinNoteSave:set('CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT', self.stateClass:upper(), 0)
     end

     if self.SELECT_SKIN_PAGE_INDEX <= 0 or self.SELECT_SKIN_PAGE_INDEX > self.TOTAL_SKIN_LIMIT then
          self.SCROLLBAR_PAGE_INDEX      = 1
          self.SCROLLBAR_TRACK_PAGE_INDEX = 1

          self.SELECT_SKIN_PAGE_INDEX = 1
          SkinNoteSave:set('selectSkinPagePositionIndex', self.stateClass, 1)
     end
     if self.PREVIEW_SKIN_OBJECT_INDEX <= 0 or self.PREVIEW_SKIN_OBJECT_INDEX > #self.PREVIEW_SKIN_OBJECT_ANIMS then
          self.PREVIEW_SKIN_OBJECT_INDEX = 1
          SkinNoteSave:set('PREVIEW_SKIN_OBJECT_INDEX', self.stateClass:upper(), 1)
     end
end

--- Preloads multiple chunks by moving from page to page, which (might) improves optimization significantly.
---@return nil
function SkinNotes:preload()
     for skinPages = self.TOTAL_SKIN_LIMIT, 1, -1 do
          if skinPages == self.SELECT_SKIN_PAGE_INDEX then
               self:create(skinPages)
          end
     end
end

--- Precaches the images within the note skin state, which improves optimization significantly.
---@return nil
function SkinNotes:precache()
     for _, skinPaths in pairs(self.TOTAL_SKINS_PATHS) do
          precacheImage(skinPaths)
     end
     precacheImage('ui/buttons/display_button')
end
 
--- Creates a chunk gallery of available display skins to select from.
---@param skinIndex? integer The given page-index for the chunk to display, if it exists.
---@return nil
function SkinNotes:create(skinIndex)
     local skinIndex = (skinIndex == nil) and 1 or skinIndex

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

          local SKIN_ROW_MAX_LENGTH = 4
          for skinDisplays = 1, #self.TOTAL_SKIN_OBJECTS[skinIndex] do
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

     for skinDisplays = 1, #self.TOTAL_SKIN_OBJECTS[skinIndex] do
          local skinObjectsID = self.TOTAL_SKIN_OBJECTS_ID[skinIndex][skinDisplays]
          local skinObjects   = self.TOTAL_SKIN_OBJECTS[skinIndex][skinDisplays]

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
               local metaObjectsDisplay = self.TOTAL_SKIN_METAOBJ_DISPLAY[skinIndex][skinDisplays] 
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
     for skinDisplays = 1, #self.TOTAL_SKIN_OBJECTS[self.SELECT_SKIN_PAGE_INDEX] do
          local skinObjectID = self.TOTAL_SKIN_OBJECTS_ID[self.SELECT_SKIN_PAGE_INDEX][skinDisplays]
          local skinObjects  = self.TOTAL_SKIN_OBJECTS[self.SELECT_SKIN_PAGE_INDEX][skinDisplays]

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
     for intervalIndex = 1, #self.SCROLLBAR_TRACK_MAJOR_SNAP do
          destroySliderMarkObjects('interval', intervalIndex)
     end
     for semiIntervalIndex = 2, #self.SCROLLBAR_TRACK_MINOR_SNAP do
          destroySliderMarkObjects('semiInterval', semiIntervalIndex)
     end

     for skinPreviewStrums = 1, 4 do
          local previewSkinGroup = F"previewSkinGroup{self.stateClass:upperAtStart()}{skinPreviewStrums}"          
          removeLuaSprite(previewSkinGroup, true)
     end
     callOnScripts('skinSearchInput_callResetSearch')
end

return SkinNotes