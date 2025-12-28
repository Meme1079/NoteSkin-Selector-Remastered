luaDebugMode = true

local SkinSaves             = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'
local SkinNotes             = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotes'
local SkinSplashesPreview   = require 'mods.NoteSkin Selector Remastered.api.classes.skins.splashes.SkinSplashesPreview'
local SkinSplashesSearch    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.splashes.SkinSplashesSearch'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local switch         = global.switch
local createTimer    = funkinlua.createTimer
local clickObject    = funkinlua.clickObject
local pressedObject  = funkinlua.pressedObject
local releasedObject = funkinlua.releasedObject
local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionPress    = funkinlua.keyboardJustConditionPress
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

local SkinSplashSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

local MAX_NUMBER_CHUNK = 16

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

--- Main class for the splash skin state inherited by many of its extended subclasses.
---@class SkinSplashes: SkinSplashesPreview, SkinSplashesSearch
local SkinSplashes = inheritedClasses({
     inherit = {SkinNotes}, 
     extends = {SkinSplashesPreview, SkinSplashesSearch}
})

--- Main class for the splash skin state inherited by many of its extended subclasses.
---@param stateClass string The corresponding name for this skin state.
---@param statePath string The corresponding image path to display for this skin state.
---@param statePrefix string the corresponding image prefix name for this skin state. 
---@return SkinSplashes
function SkinSplashes:new(stateClass, statePaths, statePrefix)
     local self = setmetatable(setmetatable({}, self), {__index = self})
     self.stateClass  = stateClass
     self.statePaths  = statePaths
     self.statePrefix = statePrefix

     return self
end

--- Loads multiple attribute properties (including its save data) for the class, used after initialization.
---@return nil
function SkinSplashes:load()
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
     
     -- Search Properties --

     self.searchSkinObjectIndex = table.new(MAX_NUMBER_CHUNK, 0)
     self.searchSkinObjectPage  = table.new(MAX_NUMBER_CHUNK, 0)

     -- Slider Properties --

     self.sliderPageIndex          = 1
     self.sliderTrackPageIndex     = 1
     self.sliderTrackPressed       = false
     self.sliderTrackToggle        = false
     self.sliderTrackIntervals     = states.getPageSkinSliderPositions(self.stateClass).intervals
     self.sliderTrackSemiIntervals = states.getPageSkinSliderPositions(self.stateClass).semiIntervals

     -- Display Selection Properties --
     
     local selectPagePositionIndex = SkinSplashSave:get('selectSkinPagePositionIndex', self.stateClass, 1)
     local selectInitSelectedIndex = SkinSplashSave:get('selectSkinInitSelectedIndex', self.stateClass, 1)
     local selectPreSelectedIndex  = SkinSplashSave:get('selectSkinPreSelectedIndex',  self.stateClass, 1)
     local selectCurSelectedIndex  = SkinSplashSave:get('selectSkinCurSelectedIndex',  self.stateClass, 1)
     self.selectSkinPagePositionIndex = selectPagePositionIndex -- current page index
     self.selectSkinInitSelectedIndex = selectInitSelectedIndex -- current pressed selected skin
     self.selectSkinPreSelectedIndex  = selectPreSelectedIndex  -- highlighting the current selected skin
     self.selectSkinCurSelectedIndex  = selectCurSelectedIndex  -- current selected skin index
     self.selectSkinHasBeenClicked    = false                   -- whether the skin display has been clicked or not

     -- Preview Animation Properties --

     self.previewStaticDataDisplay = json.parse(getTextFromFile('json/splashes/constant/display.json'))
     self.previewStaticDataPreview = json.parse(getTextFromFile('json/splashes/constant/preview.json'))
     self.previewStaticDataSkins   = json.parse(getTextFromFile('json/splashes/constant/skins.json'))
     self.previewNoteStaticDataPreview = json.parse(getTextFromFile('json/notes/constant/preview.json'))
     self.previewConstDataPreviewAnims = json.parse(getTextFromFile('json/splashes/constant/preview_anims.json'))

     self.previewAnimationObjectHovered = {false, false}
     self.previewAnimationObjectClicked = {false, false}

     local previewObjectIndex = SkinSplashSave:get('previewObjectIndex', self.stateClass, 1)
     self.previewAnimationObjectIndex     = previewObjectIndex
     self.previewAnimationObjectPrevAnims = {'note_splash1', 'note_splash2'}

     local previewObjectAnims    = {'note_splash1', 'note_splash2'}
     local previewObjectMetadata = self.totalMetadataObjectPreview
     self.previewAnimationObjectMissing = states.getPreviewObjectMissingAnims(previewObjectAnims, previewObjectMetadata, self.totalSkinLimit)

     -- Checkbox Skin Properties --

     self.checkboxSkinObjectHovered = {false, false}
     self.checkboxSkinObjectClicked = {false, false}

     local checkboxIndexPlayer   = SkinSplashSave:get('checkboxSkinObjectIndexPlayer',   self.stateClass, 0)
     local checkboxIndexOpponent = SkinSplashSave:get('checkboxSkinObjectIndexOpponent', self.stateClass, 0)
     self.checkboxSkinObjectIndex  = {player = checkboxIndexPlayer}
     self.checkboxSkinObjectToggle = {player = false}
     self.checkboxSkinObjectType   = table.keys(self.checkboxSkinObjectIndex)

     -- Note Preview Properties --

     local notePreviewStrumAnimation = {
          left  = {prefix = "arrowLEFT",  name = "left",  offsets = {0,0}},
          down  = {prefix = "arrowDOWN",  name = "down",  offsets = {0,0}},
          up    = {prefix = "arrowUP",    name = "up",    offsets = {0,0}},
          right = {prefix = "arrowRIGHT", name = "right", offsets = {0,0}}
     }

     local previewMetadataByObjectStrums = SkinSplashSave:get('previewMetadataByObjectStrums', 'notesStatic', notePreviewStrumAnimation)
     local previewMetadataByFramesStrums = SkinSplashSave:set('previewMetadataByFramesStrums', 'notesStatic', {24, 24, 24, 24})
     local previewMetadataBySize         = SkinSplashSave:get('previewMetadataBySize',         'notesStatic', {0.65, 0.65, 0.65, 0.65})
     local previewSkinImagePath          = SkinSplashSave:get('previewSkinImagePath',          'notesStatic', 'noteSkins/NOTE_assets')
     self.noteStaticPreviewMetadataByObjectStrums = previewMetadataByObjectStrums
     self.noteStaticPreviewMetadataByFramesStrums = previewMetadataByFramesStrums
     self.noteStaticPreviewMetadataBySize         = previewMetadataBySize
     self.noteStaticPreviewSkinImagePath          = previewSkinImagePath
end

--- Creates a chunk gallery of available display skins to select from.
---@param index? integer The given page-index for the chunk to display, if it exists.
---@return nil
function SkinSplashes:create(index)
     local index = index == nil and 1 or index

     for pages = 1, self.totalSkinLimit do
          for displays = 1, #self.totalSkinObjects[pages] do
               if pages == index then
                    goto continue_removeNonCurrentPages
               end

               local displaySkinIconTemplates = {state = (self.stateClass):upperAtStart(), ID = self.totalSkinObjectID[pages][displays]}
               local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
               local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    removeLuaSprite(displaySkinIconButton, true)
                    removeLuaSprite(displaySkinIconSkin, true)
               end
               ::continue_removeNonCurrentPages::
          end
     end

     local function displaySkinPositions()
          local displaySkinIndexes   = {x = 0, y = 0}
          local displaySkinPositions = {}
          for displays = 1, #self.totalSkinObjects[index] do
               if (displays-1) % 4 == 0 then
                    displaySkinIndexes.x = 0
                    displaySkinIndexes.y = displaySkinIndexes.y + 1
               else
                    displaySkinIndexes.x = displaySkinIndexes.x + 1
               end

               local displaySkinPositionX = 20  + (170 * displaySkinIndexes.x) - (25 * displaySkinIndexes.x)
               local displaySkinPositionY = -20 + (180 * displaySkinIndexes.y) - (30 * displaySkinIndexes.y)
               displaySkinPositions[#displaySkinPositions + 1] = {displaySkinPositionX, displaySkinPositionY}
          end
          return displaySkinPositions
     end

     for displays = 1, #self.totalSkinObjects[index] do
          local displaySkinIconTemplates = {state = (self.stateClass):upperAtStart(), ID = self.totalSkinObjectID[index][displays]}
          local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
          local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)

          local displaySkinPositionX = displaySkinPositions()[displays][1]
          local displaySkinPositionY = displaySkinPositions()[displays][2]
          makeAnimatedLuaSprite(displaySkinIconButton, 'ui/buttons/display_button', displaySkinPositionX, displaySkinPositionY)
          addAnimationByPrefix(displaySkinIconButton, 'static', 'static')
          addAnimationByPrefix(displaySkinIconButton, 'selected', 'selected')
          addAnimationByPrefix(displaySkinIconButton, 'blocked', 'blocked')
          addAnimationByPrefix(displaySkinIconButton, 'hover', 'hovered-static')
          addAnimationByPrefix(displaySkinIconButton, 'pressed', 'hovered-pressed')
          playAnim(displaySkinIconButton, 'static', true)
          scaleObject(displaySkinIconButton, 0.8, 0.8)
          setObjectCamera(displaySkinIconButton, 'camHUD')
          setProperty(displaySkinIconButton..'.antialiasing', false)
          addLuaSprite(displaySkinIconButton)

          local displaySkinMetadataJSON = self.totalMetadataObjectDisplay[index][displays]
          local displaySkinMetadata_frames   = displaySkinMetadataJSON == '@void' and 12                    or (displaySkinMetadataJSON.frames   or 12)
          local displaySkinMetadata_prefixes = displaySkinMetadataJSON == '@void' and 'note splash green 1' or (displaySkinMetadataJSON.prefixes or 'note splash green 1')
          local displaySkinMetadata_size     = displaySkinMetadataJSON == '@void' and {0.4, 0.4}            or (displaySkinMetadataJSON.size     or {0.4, 0.4})
          local displaySkinMetadata_offsets  = displaySkinMetadataJSON == '@void' and {0, 0}                or (displaySkinMetadataJSON.offsets  or {0, 0})

          local displaySkinImageTemplate = {path = self.statePaths, skin = self.totalSkinObjects[index][displays]}
          local displaySkinImage = ('${path}/${skin}'):interpol(displaySkinImageTemplate)

          local displaySkinImagePositionX = displaySkinPositionX + 16.5
          local displaySkinImagePositionY = displaySkinPositionY + 12
          makeAnimatedLuaSprite(displaySkinIconSkin, displaySkinImage, displaySkinImagePositionX, displaySkinImagePositionY)
          scaleObject(displaySkinIconSkin, displaySkinMetadata_size[1], displaySkinMetadata_size[2])
          addAnimationByPrefix(displaySkinIconSkin, 'static', displaySkinMetadata_prefixes, displaySkinMetadata_frames, true)

          local curOffsetX = getProperty(displaySkinIconSkin..'.offset.x')
          local curOffsetY = getProperty(displaySkinIconSkin..'.offset.y')
          addOffset(displaySkinIconSkin, 'static', curOffsetX - displaySkinMetadata_offsets[1], curOffsetY + displaySkinMetadata_offsets[2])
          playAnim(displaySkinIconSkin, 'static')
          setObjectCamera(displaySkinIconSkin, 'camHUD')
          addLuaSprite(displaySkinIconSkin)
     end

     self:page_text()
     self:save_selection()
end

return SkinSplashes