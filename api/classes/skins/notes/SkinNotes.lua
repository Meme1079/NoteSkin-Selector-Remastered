luaDebugMode = true

local SkinSaves          = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'
local SkinNotesPage      = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotesPage'
local SkinNotesSelection = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotesSelection'
local SkinNotesPreview   = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotesPreview'
local SkinNotesCheckbox  = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotesCheckbox'
local SkinNotesSearch    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.notes.SkinNotesSearch'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local math      = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

require 'table.new'

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

---@alias ParentClasses
---| 'extends' # The classes' extension from itself, not related from the superclass.
---| 'inherit' # The superclass that will be derived from this subclass.

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
---@class SkinNotes: SkinNotesPage, SkinNotesSelection, SkinNotesPreview, SkinNotesCheckbox, SkinNotesSearch
local SkinNotes = inheritedClasses({
     extends = {SkinNotesPage, SkinNotesSelection, SkinNotesPreview, SkinNotesCheckbox, SkinNotesSearch}
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
     self.selectSkinPagePositionIndex = selectPagePositionIndex -- current page index
     self.selectSkinInitSelectedIndex = selectInitSelectedIndex -- current pressed selected skin
     self.selectSkinPreSelectedIndex  = selectPreSelectedIndex  -- highlighting the current selected skin
     self.selectSkinCurSelectedIndex  = selectCurSelectedIndex  -- current selected skin index
     self.selectSkinHasBeenClicked    = false                   -- whether the skin display has been clicked or not

     -- Preview Animation Properties --

     self.previewStaticDataDisplay = json.parse(getTextFromFile('json/notes/default static data/dsd_display.json'))
     self.previewStaticDataPreview = json.parse(getTextFromFile('json/notes/default static data/dsd_preview.json'))
     self.previewStaticDataSkins   = json.parse(getTextFromFile('json/notes/default static data/dsd_skins.json'))

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

     self.searchSkinObjectIndex = table.new(16, 0)
     self.searchSkinObjectPage  = table.new(16, 0)
     self.searchAnimationObjectMissing = table.new(16, 0)
end

--- Checks for any error(s) within the classes' attribute properties, resetting to default if found.
---@return nil
function SkinNotes:load_preventError()
     local stateSkinTotalPath = setmetatable(states.getTotalSkins(self.stateClass, true), {
          __index = function(skinSelf, index)
               if index == 0 then
                    return '@void'
               end
               return '@error', index
          end
     })

     if stateSkinTotalPath[self.checkboxSkinObjectIndex.player]   == '@error' then
          self.checkboxSkinObjectIndex.player = 0
          SkinNoteSave:set('checkboxSkinObjectIndexPlayer', self.stateClass, 0)
     end
     if stateSkinTotalPath[self.checkboxSkinObjectIndex.opponent] == '@error' then
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
     for pages = self.totalSkinLimit, 1, -1 do
          if pages == self.selectSkinPagePositionIndex then
               self:create(pages)
          end
     end
end

--- Precaches the images within the note skin state, which improves optimization significantly.
---@return nil
function SkinNotes:precache()
     for _, skins in pairs(states.getTotalSkins(self.stateClass, true)) do
          precacheImage(skins)
     end
     precacheImage('ui/buttons/display_button')
end
 
--- Creates a chunk to display to selected specific skins to choose from.
---@param index? integer The given page-index for the chunk to display, if it exists.
---@return nil
function SkinNotes:create(index)
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
          local displaySkinMetadata_frames   = displaySkinMetadataJSON == '@void' and 24           or (displaySkinMetadataJSON.frames   or 24)
          local displaySkinMetadata_prefixes = displaySkinMetadataJSON == '@void' and 'arrowUP'    or (displaySkinMetadataJSON.prefixes or 'arrowUP')
          local displaySkinMetadata_size     = displaySkinMetadataJSON == '@void' and {0.55, 0.55} or (displaySkinMetadataJSON.size     or {0.55, 0.55})
          local displaySkinMetadata_offsets  = displaySkinMetadataJSON == '@void' and {0, 0}       or (displaySkinMetadataJSON.offsets  or {0, 0})

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

--- Destroys a chunk of the note skin state (page-index dependent), used only for switching states.
---@return nil
function SkinNotes:destroy()
     local curPage = self.selectSkinPagePositionIndex
     for displays = 1, #self.totalSkinObjects[curPage] do
          local displaySkinIconTemplates = {state = (self.stateClass):upperAtStart(), ID = self.totalSkinObjectID[curPage][displays]}
          local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
          local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)
          
          local displaySkinImageTemplate = {path = self.statePaths, skin = self.totalSkinObjects[curPage][displays]}
          local displaySkinImage = ('${path}/${skin}'):interpol(displaySkinImageTemplate)

          removeLuaSprite(displaySkinIconButton, true)
          removeLuaSprite(displaySkinIconSkin, true)
          removeLuaSprite(displaySkinImage, true)
     end

     for strums = 1, 4 do
          local previewSkinTemplate = {state = (self.stateClass):upperAtStart(), groupID = strums}
          local previewSkinGroup    = ('previewSkinGroup${state}-${groupID}'):interpol(previewSkinTemplate)
          removeLuaSprite(previewSkinGroup, true)
     end

     local function removeSectionSliderMarks(tag, sliderTrackIndex)
          local sectionSliderMarksTemplate = {state = (self.stateClass):upperAtStart(), tag = tag:upperAtStart(), index = sliderTrackIndex}
          local sectionSliderMarksTag = ('displaySliderMark${state}${tag}${index}'):interpol(sectionSliderMarksTemplate)
          removeLuaSprite(sectionSliderMarksTag, true)
     end
     for intervalIndex = 1, #self.sliderTrackIntervals do
          removeSectionSliderMarks('interval', intervalIndex)
     end
     for semiIntervalIndex = 2, #self.sliderTrackSemiIntervals do
          removeSectionSliderMarks('semiInterval', semiIntervalIndex)
     end
     callOnScripts('skinSearchInput_callResetSearch')
end

--- Saves the attributes current properties when exiting the main skin state.
---@return nil
function SkinNotes:save()
     if keyboardJustConditionPressed('ONE',    not getVar('skinSearchInputFocus')) then SkinNoteSave:flush() end
     if keyboardJustConditionPressed('ESCAPE', not getVar('skinSearchInputFocus')) then SkinNoteSave:flush() end
end

--- Loads the saved attribute properties and other elements for graphical correction.
---@return nil
function SkinNotes:save_load()
     self:create(self.selectSkinPagePositionIndex)
     self:checkbox_sync()

     if math.isReal(self.sliderTrackIntervals[self.selectSkinPagePositionIndex]) == true then
          setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.selectSkinPagePositionIndex])
     else
          setProperty('displaySliderIcon.y', 0)
     end
     playAnim('displaySliderIcon', 'static')
     setTextString('genInfoStateName', ' '..self.stateClass:upperAtStart())
end

--- Loads and syncs the saved selected highlight. 
---@return nil
function SkinNotes:save_selection()
     if self.selectSkinPreSelectedIndex == 0 then
          return
     end

     local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = self.selectSkinPreSelectedIndex}
     local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
     if luaSpriteExists(displaySkinIconButton) == true then
          playAnim(displaySkinIconButton, 'selected', true)

          local curIndex = self.selectSkinCurSelectedIndex - (16 * (self.selectSkinPagePositionIndex - 1))
          self.totalSkinObjectSelected[self.selectSkinPagePositionIndex][curIndex] = true
     end
end

return SkinNotes