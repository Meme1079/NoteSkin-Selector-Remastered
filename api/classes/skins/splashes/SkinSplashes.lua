luaDebugMode = true

local SkinSaves            = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'
local SkinNotes            = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotes'
local SkinSplashesPreview  = require 'mods.NoteSkin Selector Remastered.api.classes.skins.splashes.SkinSplashesPreview'
local SkinSplashesSearch   = require 'mods.NoteSkin Selector Remastered.api.classes.skins.splashes.SkinSplashesSearch'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.newglobal'

local MAX_NUMBER_CHUNK = global.MAX_NUMBER_CHUNK
local inheritedClasses = global.inheritedClasses

--- Main class for the splash skin state inherited by many of its extended subclasses.
---@class SkinSplashes: SkinSplashesPreview, SkinSplashesSearch
local SkinSplashes = inheritedClasses({
     inherit = {SkinNotes},
     extends = {SkinSplashesPreview, SkinSplashesSearch}
})
local SkinSplashesGSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

--- Initializes the main attributes for the splashskin state.
---@param stateClass string The corresponding global name for this skin state.
---@param statePath string The corresponding global image path to display for this skin state.
---@param statePrefix string the corresponding global image prefix name for this skin state. 
---@return SkinSplashes
function SkinSplashes:new(stateClass, statePaths, statePrefix)
     local self = setmetatable(setmetatable({}, self), {__index = self})
     self.stateClass  = stateClass
     self.statePaths  = statePaths
     self.statePrefix = statePrefix

     return self
end

--- Loads in the component attributes, including its saved value for the splashskin state.
--- All of the component attributes are VERY IMPORTNAT, so uh don't touch it pls.
---@return nil
function SkinSplashes:load()
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

     local SCROLLBAR_PAGE_INDEX = SkinSplashesGSave:get('SCROLLBAR_PAGE_INDEX', self.stateClass:upper(), 1)

     self.SCROLLBAR_PAGE_INDEX          = SCROLLBAR_PAGE_INDEX
     self.SCROLLBAR_TRACK_THUMB_PRESSED = false
     self.SCROLLBAR_TRACK_MAJOR_SNAP    = states.getPageSkinSliderPositions(self.stateClass).intervals
     self.SCROLLBAR_TRACK_MINOR_SNAP    = states.getPageSkinSliderPositions(self.stateClass).semiIntervals

     -- Display Selection Properties --

     local SELECT_SKIN_PAGE_INDEX           = SkinSplashesGSave:get('SELECT_SKIN_PAGE_INDEX',           self.stateClass:upper(), 1)
     local SELECT_SKIN_INIT_SELECTION_INDEX = SkinSplashesGSave:get('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), 1)
     local SELECT_SKIN_PRE_SELECTION_INDEX  = SkinSplashesGSave:get('SELECT_SKIN_PRE_SELECTION_INDEX',  self.stateClass:upper(), 1)
     local SELECT_SKIN_CUR_SELECTION_INDEX  = SkinSplashesGSave:get('SELECT_SKIN_CUR_SELECTION_INDEX',  self.stateClass:upper(), 1)

     self.SELECT_SKIN_PAGE_INDEX           = SELECT_SKIN_PAGE_INDEX           -- current page index
     self.SELECT_SKIN_INIT_SELECTION_INDEX = SELECT_SKIN_INIT_SELECTION_INDEX -- current pressed selected skin
     self.SELECT_SKIN_PRE_SELECTION_INDEX  = SELECT_SKIN_PRE_SELECTION_INDEX  -- highlighting the current selected skin
     self.SELECT_SKIN_CUR_SELECTION_INDEX  = SELECT_SKIN_CUR_SELECTION_INDEX  -- current selected skin index
     self.SELECT_SKIN_CLICKED_SELECTION    = false                            -- whether the skin display has been clicked or not

     -- Preview Animation Properties --

     local PREVIEW_SKIN_OBJECT_INDEX = SkinSplashesGSave:get('PREVIEW_SKIN_OBJECT_INDEX', self.stateClass:upper(), 1)

     self.PREVIEW_CONST_METADATA_DISPLAY       = json.parse(getTextFromFile('json/splashes/constant/display.json'))
     self.PREVIEW_CONST_METADATA_PREVIEW       = json.parse(getTextFromFile('json/splashes/constant/preview.json'))
     self.PREVIEW_CONST_METADATA_PREVIEW_ANIMS = json.parse(getTextFromFile('json/splashes/constant/preview_anims.json'))
     self.PREVIEW_CONST_METADATA_STRUMS        = json.parse(getTextFromFile('json/splashes/constant/strums.json'))
     self.PREVIEW_CONST_METADATA_SKINS         = json.parse(getTextFromFile('json/splashes/constant/skins.json'))

     self.PREVIEW_CONST_METADATA_PREVIEW_ANIMS_NOTES = json.parse(getTextFromFile('json/notes/constant/preview_anims.json'))

     self.PREVIEW_SKIN_OBJECT_INDEX         = PREVIEW_SKIN_OBJECT_INDEX
     self.PREVIEW_SKIN_OBJECT_ANIMS         = {'note_splash1', 'note_splash2'}
     self.PREVIEW_SKIN_OBJECT_ANIMS_HOVERED = {false, false} -- use the fuckass DIRECTION enum for reference
     self.PREVIEW_SKIN_OBJECT_ANIMS_CLICKED = {false, false} -- use the fuckass DIRECTION enum for reference
     self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING = states.getPreviewObjectMissingAnims(
          {'note_splash1', 'note_splash2'},
          self.TOTAL_SKIN_METAOBJ_PREVIEW,
          self.TOTAL_SKIN_LIMIT
     )

     -- Checkbox Skin Properties --

     local CHECKBOX_SKIN_OBJECT_CHARS_PLAYER = SkinSplashesGSave:get('CHECKBOX_SKIN_OBJECT_CHARS_PLAYER', self.stateClass:upper(), 0)

     self.CHECKBOX_SKIN_OBJECT_HOVERED = {false} -- use the fuckass CHARACTERS enum for reference
     self.CHECKBOX_SKIN_OBJECT_CLICKED = {false} -- use the fuckass CHARACTERS enum for reference
     self.CHECKBOX_SKIN_OBJECT_CHARS   = {CHECKBOX_SKIN_OBJECT_CHARS_PLAYER}
     self.CHECKBOX_SKIN_OBJECT_TOGGLE  = {false}
     self.CHECKBOX_SKIN_OBJECT_PRESENT = {1}     -- use for skins that are only present for specific characters
     
     -- Search Properties --

     self.SEARCH_SKIN_OBJECT_IDS           = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_PAGES         = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_PRESENT       = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_ANIMS_MISSING = table.new(MAX_NUMBER_CHUNK, 0)

     -- Note Preview Properties --

     local PREV_NOTES_METAOBJ_STRUMS_ANIMS  = SkinSplashesGSave:get('PREV_NOTES_METAOBJ_STRUMS_ANIMS',  '', self.PREVIEW_CONST_METADATA_STRUMS)
     local PREV_NOTES_METAOBJ_STRUMS_PATH   = SkinSplashesGSave:get('PREV_NOTES_METAOBJ_STRUMS_PATH',   '', {24, 24, 24, 24})
     local PREV_NOTES_METAOBJ_STRUMS_FRAMES = SkinSplashesGSave:get('PREV_NOTES_METAOBJ_STRUMS_FRAMES', '', {0.65, 0.65, 0.65, 0.65})
     local PREV_NOTES_METAOBJ_STRUMS_SIZE   = SkinSplashesGSave:get('PREV_NOTES_METAOBJ_STRUMS_SIZE',   '', {0.65, 0.65, 0.65, 0.65})
     self.PREV_NOTES_METAOBJ_STRUMS_ANIMS   = PREV_NOTES_METAOBJ_STRUMS_ANIMS
     self.PREV_NOTES_METAOBJ_STRUMS_PATH    = PREV_NOTES_METAOBJ_STRUMS_PATH
     self.PREV_NOTES_METAOBJ_STRUMS_FRAMES  = PREV_NOTES_METAOBJ_STRUMS_FRAMES
     self.PREV_NOTES_METAOBJ_STRUMS_SIZE    = PREV_NOTES_METAOBJ_STRUMS_SIZE
end

--- Creates a 4x4 chunk gallery of skins to select from.
---@param page? integer The given page index number for the chunk to display at, if said chunk number exists.
---@return nil
function SkinSplashes:create(page)
     local page = page == nil and 1 or page

     for skinPages = 1, self.TOTAL_SKIN_LIMIT do
          for skinDisplays = 1, #self.TOTAL_SKIN_OBJECTS[skinPages] do
               if skinPages == page then
                    goto SKIP_SKIN_PAGE
               end

               local skinObjectID = self.TOTAL_SKIN_OBJECTS_ID[skinPages][skinDisplays]
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
          local skinObjectsID = self.TOTAL_SKIN_OBJECTS_ID[page][skinDisplays]
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
          local displaySkinMetadataFrames   = displaySkinMetadata('frames',   12)
          local displaySkinMetadataPrefixes = displaySkinMetadata('prefixes', 'note splash green 1')
          local displaySkinMetadataSize     = displaySkinMetadata('size',     {0.4, 0.4})
          local displaySkinMetadataOffsets  = displaySkinMetadata('offsets',  {0, 0})

          local DISPLAY_SKIN_POSITION_OFFSET_X = 16.5
          local DISPLAY_SKIN_POSITION_OFFSET_Y = 12
          local displaySkinIconPositionX = displaySkinIconPosX + DISPLAY_SKIN_POSITION_OFFSET_X
          local displaySkinIconPositionY = displaySkinIconPosY + DISPLAY_SKIN_POSITION_OFFSET_Y

          local displaySkinIconSprite = F"{self.statePaths}/{skinObjects}"
          makeAnimatedLuaSprite(displaySkinIconSkinTag, displaySkinIconSprite, displaySkinIconPositionX, displaySkinIconPositionY)
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
     self:preview_notes()
end

return SkinSplashes