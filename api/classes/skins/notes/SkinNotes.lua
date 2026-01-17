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
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local CHARACTERS       = global.CHARACTERS
local MAX_NUMBER_CHUNK = global.MAX_NUMBER_CHUNK
local inheritedClasses = global.inheritedClasses

--- Main class for the noteskin state inherited by many of its extended subclasses.
---@class SkinNotes: SkinNotesPage, SkinNotesSelection, SkinNotesPreview, SkinNotesCheckbox, SkinNotesSearch, SkinNotesSave
local SkinNotes = inheritedClasses({
     extends = {SkinNotesPage, SkinNotesSelection, SkinNotesPreview, SkinNotesCheckbox, SkinNotesSearch, SkinNotesSave}
})
local SkinNotesGSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

--- Initializes the main attributes for the noteskin state.
---@param stateClass string The corresponding global name for this skin state.
---@param statePath string The corresponding global image path to display for this skin state.
---@param statePrefix string the corresponding global image prefix name for this skin state. 
---@return SkinNotes
function SkinNotes:new(stateClass, statePaths, statePrefix)
     local self = setmetatable(setmetatable({}, self), {__index = self})
     self.stateClass  = stateClass
     self.statePaths  = statePaths
     self.statePrefix = statePrefix

     return self
end

--- Loads in the component attributes, including its saved value for the noteskin state.
--- All of the component attributes are VERY IMPORTNAT, so uh don't touch it pls.
---@return nil
function SkinNotes:load()
     self.TOTAL_SKINS       = states.getTotalSkins(self.stateClass, false)
     self.TOTAL_SKINS_PATHS = states.getTotalSkins(self.stateClass, true)
     --self.TOTAL_SKINS_NAMES = states.getTotalSkinNames(self.stateClass)

     -- Object Properties --

     self.TOTAL_SKIN_LIMIT         = states.getTotalPageLimit(self.stateClass)
     self.TOTAL_SKIN_OBJECTS       = states.getTotalSkinObjects(self.stateClass)
     self.TOTAL_SKIN_OBJECTS_IDS   = states.getTotalSkinObjects(self.stateClass, 'ids')
     self.TOTAL_SKIN_OBJECTS_NAMES = states.getTotalSkinObjects(self.stateClass, 'names')

     -- Display Properties --
     
     self.TOTAL_SKIN_OBJECTS_HOVERED  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.TOTAL_SKIN_OBJECTS_CLICKED  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.TOTAL_SKIN_OBJECTS_SELECTED = states.getTotalSkinObjects(self.stateClass, 'bools')

     self.TOTAL_SKIN_METAOBJ_DISPLAY  = states.getTotalMetadataSkinObjects(self.stateClass, 'display', true)
     self.TOTAL_SKIN_METAOBJ_PREVIEW  = states.getTotalMetadataSkinObjects(self.stateClass, 'preview', true)
     --self.TOTAL_SKIN_METAOBJ_SKINS    = states.getTotalMetadataSkinObjects(self.stateClass, 'skins', true)

     self.TOTAL_SKIN_METAOBJ_ALL_DISPLAY = states.getTotalMetadataSkinObjectAll(self.stateClass, 'display', true)
     --self.TOTAL_SKIN_METAOBJ_ALL_PREVIEW = states.getTotalMetadataSkinObjectAll(self.stateClass, 'preview', true)

     -- Scrollbar Properties --

     local SCROLLBAR_PAGE_INDEX = SkinNotesGSave:get('SCROLLBAR_PAGE_INDEX', self.stateClass:upper(), 1)

     self.SCROLLBAR_PAGE_INDEX          = SCROLLBAR_PAGE_INDEX
     self.SCROLLBAR_TRACK_THUMB_PRESSED = false
     self.SCROLLBAR_TRACK_MAJOR_SNAP    = states.calculateScrollbarPositions(self.stateClass).major
     self.SCROLLBAR_TRACK_MINOR_SNAP    = states.calculateScrollbarPositions(self.stateClass).minor

     -- Display Selection Properties --
     
     local SELECT_SKIN_PAGE_INDEX           = SkinNotesGSave:get('SELECT_SKIN_PAGE_INDEX',           self.stateClass:upper(), 1)
     local SELECT_SKIN_INIT_SELECTION_INDEX = SkinNotesGSave:get('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), 1)
     local SELECT_SKIN_PRE_SELECTION_INDEX  = SkinNotesGSave:get('SELECT_SKIN_PRE_SELECTION_INDEX',  self.stateClass:upper(), 1)
     local SELECT_SKIN_CUR_SELECTION_INDEX  = SkinNotesGSave:get('SELECT_SKIN_CUR_SELECTION_INDEX',  self.stateClass:upper(), 1)

     self.SELECT_SKIN_PAGE_INDEX           = SELECT_SKIN_PAGE_INDEX           -- current page index
     self.SELECT_SKIN_INIT_SELECTION_INDEX = SELECT_SKIN_INIT_SELECTION_INDEX -- current pressed selected skin
     self.SELECT_SKIN_PRE_SELECTION_INDEX  = SELECT_SKIN_PRE_SELECTION_INDEX  -- highlighting the current selected skin
     self.SELECT_SKIN_CUR_SELECTION_INDEX  = SELECT_SKIN_CUR_SELECTION_INDEX  -- current selected skin index
     self.SELECT_SKIN_CLICKED_SELECTION    = false                            -- whether the skin display has been clicked or not

     -- Preview Animation Properties --

     local PREVIEW_SKIN_OBJECT_INDEX = SkinNotesGSave:get('PREVIEW_SKIN_OBJECT_INDEX', self.stateClass:upper(), 1)

     --self.PREVIEW_CONST_METADATA_DISPLAY       = json.parse(getTextFromFile('json/notes/constant/display.json'))
     self.PREVIEW_CONST_METADATA_PREVIEW       = json.parse(getTextFromFile('json/notes/constant/preview.json'))
     self.PREVIEW_CONST_METADATA_PREVIEW_ANIMS = json.parse(getTextFromFile('json/notes/constant/preview_anims.json'))
     --self.PREVIEW_CONST_METADATA_SKINS         = json.parse(getTextFromFile('json/notes/constant/skins.json'))

     self.PREVIEW_SKIN_OBJECT_INDEX         = PREVIEW_SKIN_OBJECT_INDEX
     self.PREVIEW_SKIN_OBJECT_ANIMS         = {'confirm', 'pressed', 'colored'}
     self.PREVIEW_SKIN_OBJECT_ANIMS_HOVERED = {false, false} -- use the fuckass DIRECTION enum for reference
     self.PREVIEW_SKIN_OBJECT_ANIMS_CLICKED = {false, false} -- use the fuckass DIRECTION enum for reference
     self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING = states.getTotalPreviewMissingAnimObjects(
          {'strums', 'confirm', 'pressed', 'colored'},
          self.TOTAL_SKIN_METAOBJ_PREVIEW,
          self.TOTAL_SKIN_LIMIT
     )

     -- Checkbox Skin Properties --

     local CHECKBOX_SKIN_OBJECT_CHARS_PLAYER   = SkinNotesGSave:get('CHECKBOX_SKIN_OBJECT_CHARS_PLAYER',   self.stateClass:upper(), 0)
     local CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT = SkinNotesGSave:get('CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT', self.stateClass:upper(), 0)

     self.CHECKBOX_SKIN_OBJECT_HOVERED = {false, false} -- use the fuckass CHARACTERS enum for reference
     self.CHECKBOX_SKIN_OBJECT_CLICKED = {false, false} -- use the fuckass CHARACTERS enum for reference
     self.CHECKBOX_SKIN_OBJECT_CHARS   = {CHECKBOX_SKIN_OBJECT_CHARS_PLAYER, CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT}
     self.CHECKBOX_SKIN_OBJECT_TOGGLE  = {false, false}
     self.CHECKBOX_SKIN_OBJECT_PRESENT = {1, 2}         -- use for skins that are only present for specific characters

     -- Search Properties --

     self.SEARCH_SKIN_OBJECT_IDS           = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_PAGES         = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_PRESENT       = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_ANIMS_MISSING = table.new(MAX_NUMBER_CHUNK, 0)
end

--- Handles for any error(s) within the component attributes' value, resetting if found.
---@return nil
function SkinNotes:load_handling()
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
          SkinNotesGSave:set('CHECKBOX_SKIN_OBJECT_CHARS_PLAYER', self.stateClass:upper(), 0)
     end
     if skinTotalSkinPaths[self.CHECKBOX_SKIN_OBJECT_CHARS[CHARACTERS.OPPONENT]] == '@error' then
          self.CHECKBOX_SKIN_OBJECT_CHARS[CHARACTERS.OPPONENT] = 0
          SkinNotesGSave:set('CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT', self.stateClass:upper(), 0)
     end

     local pageSkinIsOverflow    = self.SCROLLBAR_PAGE_INDEX <= 0 or self.SCROLLBAR_PAGE_INDEX > self.TOTAL_SKIN_LIMIT
     local pageSkinIsNonExistent = self.SCROLLBAR_PAGE_INDEX ~= self.SCROLLBAR_PAGE_INDEX
     if (pageSkinIsOverflow or pageSkinIsNonExistent) then
          self.SELECT_SKIN_PAGE_INDEX = 1
          SkinNotesGSave:set('SELECT_SKIN_PAGE_INDEX', self.stateClass:upper(), 1)
     end

     if self.PREVIEW_SKIN_OBJECT_INDEX <= 0 or self.PREVIEW_SKIN_OBJECT_INDEX > #self.PREVIEW_SKIN_OBJECT_ANIMS then
          self.PREVIEW_SKIN_OBJECT_INDEX = 1
          SkinNotesGSave:set('PREVIEW_SKIN_OBJECT_INDEX', self.stateClass:upper(), 1)
     end
end

--- Generates the main components for the noteskin state functionality.
---@return nil
function SkinNotes:generate()
     for _, skinPaths in pairs(self.TOTAL_SKINS_PATHS) do
          precacheImage(skinPaths)
     end

     self:save_load()
     self:checkbox()
     self:preview()
     self:page_scrollbar_snaps()
end

--- Creates a 4x4 chunk gallery of skins to select from.
---@param page? integer The given page index number for the chunk to display at, if said chunk number exists.
---@return nil
function SkinNotes:create(page)
     local page = (page == nil) and 1 or page

     for skinPages = 1, self.TOTAL_SKIN_LIMIT do
          for skinDisplays = 1, #self.TOTAL_SKIN_OBJECTS[skinPages] do
               if skinPages == page then
                    goto SKIP_SKIN_PAGE
               end

               local skinObjectID = self.TOTAL_SKIN_OBJECTS_IDS[skinPages][skinDisplays]
               local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{skinObjectID}"
               local displaySkinIconSkinTag   = F"displaySkinIconSkin{self.stateClass:upperAtStart()}-{skinObjectID}"
               if luaSpriteExists(displaySkinIconButtonTag) == true and luaSpriteExists(displaySkinIconSkinTag) == true then
                    removeLuaSprite(displaySkinIconButtonTag, true)
                    removeLuaSprite(displaySkinIconSkinTag, true)
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
          for skinDisplays = 1, #self.TOTAL_SKIN_OBJECTS[page] do
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

     for skinDisplays = 1, #self.TOTAL_SKIN_OBJECTS[page] do
          local skinObjectsID = self.TOTAL_SKIN_OBJECTS_IDS[page][skinDisplays]
          local skinObjects   = self.TOTAL_SKIN_OBJECTS[page][skinDisplays]

          local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{skinObjectsID}"
          local displaySkinIconSkinTag   = F"displaySkinIconSkin{self.stateClass:upperAtStart()}-{skinObjectsID}"
          local displaySkinIconPosX = displaySkinIconPositions()[skinDisplays][1]
          local displaySkinIconPosY = displaySkinIconPositions()[skinDisplays][2]
          makeAnimatedLuaSprite(displaySkinIconButtonTag, 'ui/buttons/display_button', displaySkinIconPosX, displaySkinIconPosY)
          addAnimationByPrefix(displaySkinIconButtonTag, 'static', 'static')
          addAnimationByPrefix(displaySkinIconButtonTag, 'selected', 'selected')
          addAnimationByPrefix(displaySkinIconButtonTag, 'blocked', 'blocked')
          addAnimationByPrefix(displaySkinIconButtonTag, 'hover', 'hovered-static')
          addAnimationByPrefix(displaySkinIconButtonTag, 'pressed', 'hovered-pressed')
          playAnim(displaySkinIconButtonTag, 'static', true)
          scaleObject(displaySkinIconButtonTag, 0.8, 0.8)
          setObjectCamera(displaySkinIconButtonTag, 'camHUD')
          setProperty(F"{displaySkinIconButtonTag}.antialiasing", false)
          addLuaSprite(displaySkinIconButtonTag)

          --- Gets the skins' display metadata value, acts as a helper function.
          --- Checks for any missing values and replaces it with its default value.
          ---@param metadata string The metadata element to get its value.
          ---@param constant any The constant default value, if the metadata element is missing.
          ---@return any
          local function displaySkinMetadata(metadata, constant)
               local metaObjectsDisplay = self.TOTAL_SKIN_METAOBJ_DISPLAY[page][skinDisplays] 
               if metaObjectsDisplay == '@void' then 
                    return constant 
               end
               if metaObjectsDisplay[metadata] == nil then 
                    return constant 
               end
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

          local displaySkinIconSprite = F"{self.statePaths}/{skinObjects}"
          makeAnimatedLuaSprite(displaySkinIconSkinTag, displaySkinIconSprite, displaySkinIconPosOffsetX, displaySkinIconPosOffsetY)
          scaleObject(displaySkinIconSkinTag, displaySkinMetadataSize[1], displaySkinMetadataSize[2])
          addAnimationByPrefix(displaySkinIconSkinTag, 'static', displaySkinMetadataPrefixes, displaySkinMetadataFrames, true)

          local DISPLAY_SKIN_OFFSET_X = getProperty(F"{displaySkinIconSkinTag}.offset.x")
          local DISPLAY_SKIN_OFFSET_Y = getProperty(F"{displaySkinIconSkinTag}.offset.y")
          local displaySkinIconOffsetX = DISPLAY_SKIN_OFFSET_X - displaySkinMetadataOffsets[1]
          local displaySkinIconOffsetY = DISPLAY_SKIN_OFFSET_Y + displaySkinMetadataOffsets[2]
          addOffset(displaySkinIconSkinTag, 'static', displaySkinIconOffsetX, displaySkinIconOffsetY)
          playAnim(displaySkinIconSkinTag, 'static')
          setObjectCamera(displaySkinIconSkinTag, 'camHUD')
          addLuaSprite(displaySkinIconSkinTag)
     end
     self:page_text()
     self:save_selection()
end

--- Destroys the chunk gallery of skins, depending on its current page index.
--- Only used for switching from different skin states.
---@return nil
function SkinNotes:destroy()
     for skinDisplays = 1, #self.TOTAL_SKIN_OBJECTS[self.SCROLLBAR_PAGE_INDEX] do
          local skinObjectID = self.TOTAL_SKIN_OBJECTS_IDS[self.SCROLLBAR_PAGE_INDEX][skinDisplays]
          local skinObjects  = self.TOTAL_SKIN_OBJECTS[self.SCROLLBAR_PAGE_INDEX][skinDisplays]

          local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{skinObjectID}"
          local displaySkinIconSkinTag   = F"displaySkinIconSkin{self.stateClass:upperAtStart()}-{skinObjectID}"
          local displaySkinIconSprite    = F"{self.statePaths}/{skinObjects}"
          removeLuaSprite(displaySkinIconButtonTag, true)
          removeLuaSprite(displaySkinIconSkinTag, true)
          removeLuaSprite(displaySkinIconSprite, true)
     end
     for CharNames, _ in pairs(CHARACTERS) do
          local checkboxSkinButtonTag    = F"selectionSkinButton{CharNames:upperAtStart(true)}"
          local checkboxSkinTitleTag     = F"selectionSkinTextButton{CharNames:upperAtStart(true)}"
          local checkboxSkinSelectionTag = F"displaySelection{CharNames:upperAtStart(true)}"
          removeLuaSprite(checkboxSkinButtonTag, true)
          removeLuaSprite(checkboxSkinTitleTag, true)
          removeLuaSprite(checkboxSkinSelectionTag, false)
     end

     local function removeSnapMarks(scrollbarTrackSnapIndex, scrollbarTrackMetadataName)
          local displaySliderMarkTag = F"displaySliderMark{self.stateClass:upperAtStart()}{scrollbarTrackMetadataName}{scrollbarTrackSnapIndex}"
          removeLuaSprite(displaySliderMarkTag, true)
     end
     for majorSnapIndex = 1, #self.SCROLLBAR_TRACK_MAJOR_SNAP do
          removeSnapMarks(majorSnapIndex, 'Major')
     end
     for minorSnapIndex = 2, #self.SCROLLBAR_TRACK_MINOR_SNAP do -- 2-index start, prevent an extra snap mark sprite
          removeSnapMarks(minorSnapIndex, 'Minor')
     end
     callOnScripts('skinSearchInput_callResetSearch')
end

return SkinNotes