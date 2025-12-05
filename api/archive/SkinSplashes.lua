luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'
local SkinNotes = require 'mods.NoteSkin Selector Remastered.api.classes.skins.SkinNotes'

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

---@class SkinSplashes
local SkinSplashes = SkinNotes:new()

--- Initializes the creation of a skin state to display skins.
---@param stateClass
---@param stateStart string The given starting skin state to display first when created.
---@param stateType table[string] The given skin states within a group to display later.
---@param statePath table[string] The given corresponding image paths to each skin states.
---@return table
function SkinSplashes:new(stateClass, statePaths, statePrefix)
     local self = setmetatable({}, {__index = self})
     self.stateClass  = stateClass
     self.statePaths  = statePaths
     self.statePrefix = statePrefix

     return self
end

--- Loads multiple-unique data to the class itself, to be used later.
---@return nil
function SkinSplashes:load()
     self.totalSkins     = states.getTotalSkins(self.stateClass, self.statePaths)
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

     self.searchSkinObjectIndex = table.new(16, 0)
     self.searchSkinObjectPage  = table.new(16, 0)

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

     self.previewStaticDataDisplay = json.parse(getTextFromFile('json/splashes/default static data/dsd_display.json'))
     self.previewStaticDataPreview = json.parse(getTextFromFile('json/splashes/default static data/dsd_preview.json'))
     self.previewNoteStaticDataPreview = json.parse(getTextFromFile('json/notes/default static data/dsd_preview.json'))

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

--- Creates a 16 chunk display of the selected skins.
---@param index? integer The specified page index for the given chunk to display.
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

--- Creates the selected skin's preview strums.
---@return nil
function SkinSplashes:preview()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     local curPage  = self.selectSkinPagePositionIndex
     local curIndex = self.selectSkinCurSelectedIndex
     local function getCurrentPreviewSkin(previewSkinArray)
          if curIndex == 0 then
               return previewSkinArray[1][1]
          end

          for pages = 1, self.totalSkinLimit do
               local presentObjectIndex = table.find(self.totalSkinObjectIndexes[pages], curIndex)
               if presentObjectIndex ~= nil then
                    return previewSkinArray[pages][presentObjectIndex]
               end
          end
     end

     local getCurrentPreviewSkinObjects       = getCurrentPreviewSkin(self.totalSkinObjects)
     local getCurrentPreviewSkinObjectNames   = getCurrentPreviewSkin(self.totalSkinObjectNames)
     local getCurrentPreviewSkinObjectPreview = getCurrentPreviewSkin(self.totalMetadataObjectPreview)
     for strums = 1, 4 do
          local previewSkinTemplate = {state = (self.stateClass):upperAtStart(), groupID = strums}
          local previewSkinGroup    = ('previewSkinGroup${state}-${groupID}'):interpol(previewSkinTemplate)

          local previewMetadataObjectAnims = {
               names = {
                    note_splash1 = {'left_splash1', 'down_splash1', 'up_splash1', 'right_splash1'},
                    note_splash2 = {'left_splash2', 'down_splash2', 'up_splash2', 'right_splash2'}
               },
               prefixes = {
                    note_splash1 = {'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1'},
                    note_splash2 = {'note splash purple 2', 'note splash blue 2', 'note splash green 2', 'note splash red 2'}
               },
               frames = {
                    note_splash1 = 24,
                    note_splash2 = 24
               }
          }

          local function previewMetadataObjectData(skinAnim)
               local previewMetadataObject         = getCurrentPreviewSkinObjectPreview
               local previewMetadataObjectByAnim   = getCurrentPreviewSkinObjectPreview.animations
               local previewStaticDataObjectByAnim = self.previewStaticDataPreview.animations

               local previewMetadataObjectNames = previewMetadataObjectAnims['names'][skinAnim]
               if previewMetadataObject == '@void' or previewMetadataObjectByAnim == nil then
                    return previewStaticDataObjectByAnim[skinAnim][previewMetadataObjectNames[strums]]
               end
               if previewMetadataObjectByAnim[skinAnim] == nil then
                    previewMetadataObject['animations'][skinAnim] = previewStaticDataObjectByAnim[skinAnim]
                    return previewStaticDataObjectByAnim[skinAnim][previewMetadataObjectNames[strums]]
               end
               return previewMetadataObjectByAnim[skinAnim][previewMetadataObjectNames[strums]]
          end
          local function previewMetadataObjects(element)
               local previewMetadataObject       = getCurrentPreviewSkinObjectPreview
               local previewMetadataObjectByElem = getCurrentPreviewSkinObjectPreview[element]

               if previewMetadataObject == '@void' or previewMetadataObjectByElem == nil then
                    return self.previewStaticDataPreview[element]
               end
               return previewMetadataObjectByElem
          end

          local previewMetadataByObjectNoteSplash1 = previewMetadataObjectData('note_splash1')
          local previewMetadataByObjectNoteSplash2 = previewMetadataObjectData('note_splash2')

          local previewMetadataByFramesNoteSplash1 = previewMetadataObjects('frames').note_splash1
          local previewMetadataByFramesNoteSplash2 = previewMetadataObjects('frames').note_splash2

          local previewMetadataBySize = previewMetadataObjects('size')
          
          local previewSkinImagePath = self.statePaths..'/'..getCurrentPreviewSkinObjects
          local previewSkinPositionX = 790 + (105*(strums-1))
          local previewSkinPositionY = 135
          makeAnimatedLuaSprite(previewSkinGroup, previewSkinImagePath, previewSkinPositionX, previewSkinPositionY)
          scaleObject(previewSkinGroup, previewMetadataBySize[1], previewMetadataBySize[2])

          local previewSkinAddAnimationPrefix = function(objectData, dataFrames)
               addAnimationByPrefix(previewSkinGroup, objectData.name, objectData.prefix, dataFrames, false)
          end
          local previewSkinGetOffsets = function(objectData, position)
               local previewSkinGroupOffsetX = getProperty(previewSkinGroup..'.offset.x')
               local previewSkinGroupOffsetY = getProperty(previewSkinGroup..'.offset.y')
               if position == 'x' then return previewSkinGroupOffsetX - objectData.offsets[1] end
               if position == 'y' then return previewSkinGroupOffsetY + objectData.offsets[2] end
          end
          local previewSkinAddOffsets = function(objectData)
               local previewSkinOffsetX = previewSkinGetOffsets(objectData, 'x')
               local previewSkinOffsetY = previewSkinGetOffsets(objectData, 'y')
               addOffset(previewSkinGroup, objectData.name, previewSkinOffsetX, previewSkinOffsetY)
          end
          
          local previewSkinAnimation = function(objectData, dataFrames)
               previewSkinAddAnimationPrefix(objectData, dataFrames)
               previewSkinAddOffsets(objectData)
          end
          previewSkinAnimation(previewMetadataByObjectNoteSplash1, previewMetadataByFramesNoteSplash1)
          previewSkinAnimation(previewMetadataByObjectNoteSplash2, previewMetadataByFramesNoteSplash2)
     
          setObjectCamera(previewSkinGroup, 'camHUD')
          setProperty(previewSkinGroup..'.visible', false)
          addLuaSprite(previewSkinGroup)
     end

     setTextString('genInfoSkinName', getCurrentPreviewSkinObjectNames)
     self:preview_animation(true)
end

---@return nil
function SkinSplashes:preview_notes()
     for strums = 1, 4 do
          local previewSkinTemplate = {state = ('Notes'):upperAtStart(), groupID = strums}
          local previewSkinGroup    = ('previewSkinGroup${state}-${groupID}'):interpol(previewSkinTemplate)

          local previewMetadataObjectAnims = {
               names = {
                    confirm = {'left_confirm', 'down_confirm', 'up_confirm', 'right_confirm'},
                    pressed = {'left_pressed', 'down_pressed', 'up_pressed', 'right_pressed'},
                    colored = {'left_colored', 'down_colored', 'up_colored', 'right_colored'},
                    strums  = {'left', 'down', 'up', 'right'}
               },
               prefixes = {
                    confirm = {'left confirm', 'down confirm', 'up confirm', 'right confirm'},
                    pressed = {'left press', 'down press', 'up press', 'right press'},
                    colored = {'purple0', 'blue0', 'green0', 'red0'},
                    strums  = {'arrowLEFT', 'arrowDOWN', 'arrowUP', 'arrowRIGHT'}
               },
               frames = {
                    confirm = 24,
                    pressed = 24,
                    colored = 24,
                    strums  = 24
               }
          }

          local previewMetadataBySize = self.noteStaticPreviewMetadataBySize

          local previewSkinImagePath = self.noteStaticPreviewSkinImagePath
          local previewSkinPositionX = 790 + (105*(strums-1))
          local previewSkinPositionY = 135
          makeAnimatedLuaSprite(previewSkinGroup, previewSkinImagePath, previewSkinPositionX, previewSkinPositionY)
          scaleObject(previewSkinGroup, previewMetadataBySize[1], previewMetadataBySize[2])

          local previewSkinAddAnimationPrefix = function(objectData, dataFrames)
               addAnimationByPrefix(previewSkinGroup, objectData.name, objectData.prefix, dataFrames, false)
          end
          local previewSkinGetOffsets = function(objectData, position)
               local previewSkinGroupOffsetX = getProperty(previewSkinGroup..'.offset.x')
               local previewSkinGroupOffsetY = getProperty(previewSkinGroup..'.offset.y')
               if position == 'x' then return previewSkinGroupOffsetX - objectData.offsets[1] end
               if position == 'y' then return previewSkinGroupOffsetY + objectData.offsets[2] end
          end
          local previewSkinAddOffsets = function(objectData)
               local previewSkinOffsetX = previewSkinGetOffsets(objectData, 'x')
               local previewSkinOffsetY = previewSkinGetOffsets(objectData, 'y')
               addOffset(previewSkinGroup, objectData.name, previewSkinOffsetX, previewSkinOffsetY)
          end

          local previewMetadataIndex = previewMetadataObjectAnims['names']['strums'][strums]
          local previewMetadataByObjectStrums = self.noteStaticPreviewMetadataByObjectStrums
          local previewMetadataByFramesStrums = self.noteStaticPreviewMetadataByFramesStrums
          previewSkinAddAnimationPrefix(previewMetadataByObjectStrums[previewMetadataIndex], previewMetadataByFramesStrums)
          previewSkinAddOffsets(previewMetadataByObjectStrums[previewMetadataIndex])

          playAnim(previewSkinGroup, previewMetadataObjectAnims['names']['strums'][strums])
          setObjectCamera(previewSkinGroup, 'camHUD')
          addLuaSprite(previewSkinGroup)

          local previewSkinSplashTemplate = {state = (self.stateClass):upperAtStart(), groupID = strums}
          local previewSkinSplashGroup    = ('previewSkinGroup${state}-${groupID}'):interpol(previewSkinSplashTemplate)
          setObjectOrder(previewSkinGroup, getObjectOrder(previewSkinSplashGroup)-1)
     end
end

--- Creates and loads the selected skin's preview animations.
---@param loadAnim? boolean Will only load the current skin's preview animations or not, bug fixing purposes.
---@return nil
function SkinSplashes:preview_animation(loadAnim)
     local loadAnim = loadAnim ~= nil and true or false

     local firstJustPressed  = callMethodFromClass('flixel.FlxG', 'keys.firstJustPressed', {''})
     local firstJustReleased = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})

     local firstJustInputPressed  = (firstJustPressed  ~= -1 and firstJustPressed  ~= nil)
     local firstJustInputReleased = (firstJustReleased ~= -1 and firstJustReleased ~= nil)
     local firstJustInputs        = (firstJustInputPressed or firstJustInputReleased)
     if not firstJustInputs and loadAnim == false then
          return
     end

     local curIndex = self.selectSkinCurSelectedIndex
     local function getCurrentPreviewSkin(previewSkinArray)
          if curIndex == 0 then
               return previewSkinArray[1][1]
          end

          for pages = 1, self.totalSkinLimit do
               local presentObjectIndex = table.find(self.totalSkinObjectIndexes[pages], curIndex)
               if presentObjectIndex ~= nil then
                    return previewSkinArray[pages][presentObjectIndex]
               end
          end
     end

     local conditionPressedLeft  = keyboardJustConditionPressed('Z', not getVar('skinSearchInputFocus'))
     local conditionPressedRight = keyboardJustConditionPressed('X', not getVar('skinSearchInputFocus'))
     local getCurrentPreviewSkinObjectPreview = getCurrentPreviewSkin(self.totalMetadataObjectPreview)
     for strums = 1, 4 do
          local previewSkinTemplate = {state = (self.stateClass):upperAtStart(), groupID = strums}
          local previewSkinGroup    = ('previewSkinGroup${state}-${groupID}'):interpol(previewSkinTemplate)

          local previewMetadataObjectAnims = {
               names = {
                    note_splash1 = {'left_splash1', 'down_splash1', 'up_splash1', 'right_splash1'},
                    note_splash2 = {'left_splash2', 'down_splash2', 'up_splash2', 'right_splash2'}
               },
               prefixes = {
                    note_splash1 = {'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1'},
                    note_splash2 = {'note splash purple 2', 'note splash blue 2', 'note splash green 2', 'note splash red 2'}
               },
               frames = {
                    note_splash1 = 24,
                    note_splash2 = 24
               }
          }
          
          local previewSkinAnim = self.previewAnimationObjectPrevAnims[self.previewAnimationObjectIndex]
          local function previewMetadataObjectData(skinAnim)
               local previewMetadataObject         = getCurrentPreviewSkinObjectPreview
               local previewMetadataObjectByAnim   = getCurrentPreviewSkinObjectPreview.animations
               local previewStaticDataObjectByAnim = self.previewStaticDataPreview.animations

               local previewMetadataObjectNames = previewMetadataObjectAnims['names'][skinAnim]
               if previewMetadataObject == '@void' or previewMetadataObjectByAnim == nil then
                    return previewStaticDataObjectByAnim[skinAnim][previewMetadataObjectNames[strums]]
               end
               if previewMetadataObjectByAnim[skinAnim] == nil then
                    previewMetadataObject['animations'][skinAnim] = previewStaticDataObjectByAnim[skinAnim]
                    return previewStaticDataObjectByAnim[skinAnim][previewMetadataObjectNames[strums]]
               end
               return previewMetadataObjectByAnim[skinAnim][previewMetadataObjectNames[strums]]
          end

          local previewMetadataObjectGroupData = {
               note_splash1 = previewMetadataObjectData('note_splash1'), 
               note_splash2 = previewMetadataObjectData('note_splash2'),
          }

          if (conditionPressedLeft or conditionPressedRight) or mouseReleased('left') then
               setProperty(previewSkinGroup..'.visible', false)
          end
          if keyboardJustConditionPressed(getKeyBinds(strums), not getVar('skinSearchInputFocus')) then
               playAnim(previewSkinGroup, previewMetadataObjectGroupData[previewSkinAnim]['name'], true)
               setProperty(previewSkinGroup..'.visible', true)
          end
          if keyboardJustConditionReleased(getKeyBinds(strums), not getVar('skinSearchInputFocus')) then
               setProperty(previewSkinGroup..'.visible', false)
          end
     end
end

local previewSelectionToggle = false -- * ok who gaf
--- Changes the skin's preview animations by using keyboard keys.
---@return nil
function SkinSplashes:preview_selection_moved()
     local conditionPressedLeft  = keyboardJustConditionPressed('Z', not getVar('skinSearchInputFocus'))
     local conditionPressedRight = keyboardJustConditionPressed('X', not getVar('skinSearchInputFocus'))

     local previewAnimationMinIndex = self.previewAnimationObjectIndex > 1
     local previewAnimationMaxIndex = self.previewAnimationObjectIndex < #self.previewAnimationObjectPrevAnims
     local previewAnimationInverseMinIndex = self.previewAnimationObjectIndex <= 1
     local previewAnimationInverseMaxIndex = self.previewAnimationObjectIndex >= #self.previewAnimationObjectPrevAnims
     if conditionPressedLeft and previewAnimationMinIndex then
          self.previewAnimationObjectIndex = self.previewAnimationObjectIndex - 1
          previewSelectionToggle  = true

          playSound('ding', 0.5)
          SkinSplashSave:set('previewObjectIndex', self.stateClass, self.previewAnimationObjectIndex)
     end
     if conditionPressedRight and previewAnimationMaxIndex then
          self.previewAnimationObjectIndex = self.previewAnimationObjectIndex + 1
          previewSelectionToggle  = true

          playSound('ding', 0.5)
          SkinSplashSave:set('previewObjectIndex', self.stateClass, self.previewAnimationObjectIndex)
     end
     
     if previewSelectionToggle == true then --! DO NOT DELETE
          previewSelectionToggle = false
          return
     end

     if previewAnimationInverseMinIndex then
          playAnim('previewSkinInfoIconLeft', 'none', true)
          playAnim('previewSkinInfoIconRight', 'right', true)
     else
          playAnim('previewSkinInfoIconLeft', 'left', true)
     end

     if previewAnimationInverseMaxIndex then
          playAnim('previewSkinInfoIconLeft', 'left', true)
          playAnim('previewSkinInfoIconRight', 'none', true)
     else
          playAnim('previewSkinInfoIconRight', 'right', true)
     end

     local previewMetadataObjectAnims = self.previewAnimationObjectPrevAnims[self.previewAnimationObjectIndex]
     setTextString('previewSkinButtonSelectionText', previewMetadataObjectAnims:upperAtStart():gsub('_', ' '):gsub('(%w)(%d)', '%1 %2'))
end

--- Creates a 16 chunk display of the selected search skins.
---@return nil
function SkinSplashes:search_create()
     local justReleased = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})
     if not (justReleased ~= -1 and justReleased ~= nil and getVar('skinSearchInputFocus') == true) then
          return
     end

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent')
     if skinSearchInput_textContent == '' and getVar('skinSearchInputFocus') == true then
          self:create(self.selectSkinPagePositionIndex)
          self:page_text()
          self:save_selection()
          return
     end

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

     --- Searches the closest skin name it can possibly find
     ---@param list table[string] The given list of skins for the algorithm to do its work.
     ---@param input string The given input to search the closest skins.
     ---@param element string What element it can return either its 'id' or 'skins'.
     ---@param match string The prefix of the skin to match.
     ---@param allowPath? boolean Wheather it will include a path or not.
     ---@return table
     local function filter_search(list, input, element, match, allowPath)
          local search_result = {}
          for i = 1, #list, 1 do
               local startName   = list[i]:match(match..'(.+)')  == nil and 'funkin' or list[i]:match(match..'(.+)')
               local startFolder = list[i]:match('(.+/)'..match) == nil and ''       or list[i]:match('(.+/)'..match)

               local startPos = startName:upper():find(input:gsub('([%%%.%$%^%(%[])', '%%%1'):upper())
               local wordPos  = startPos == nil and -1 or startPos
               if wordPos > -1 and #search_result < 16 then
                    local p = allowPath == true and startFolder..match:gsub('%%%-', '-')..startName or startName
                    search_result[i] = p:match(match..'funkin') == nil and p or match:gsub('%%%-', '')
               end
          end

          local search_resultFilter = {}
          for ids, skins in pairs(search_result) do
               if skins ~= nil and #search_resultFilter < 16 then
                    if element == 'skins' then
                         search_resultFilter[#search_resultFilter + 1] = skins
                    elseif element == 'ids' then
                         search_resultFilter[#search_resultFilter + 1] = ids
                    end
               end
          end 
          return search_resultFilter
     end

     local function displaySkinPositions()
          local displaySkinIndexes   = {x = 0, y = 0}
          local displaySkinPositions = {}
          for displays = 1, 16 do
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

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent')
     local filterSearchByID   = filter_search(self.totalSkins, skinSearchInput_textContent or '', 'ids', self.statePrefix..'%-', false)
     local filterSearchByName = filter_search(self.totalSkins, skinSearchInput_textContent or '', 'skins', self.statePrefix..'%-', false)
     local filterSearchBySkin = filter_search(self.totalSkins, skinSearchInput_textContent or '', 'skins', self.statePrefix..'%-', true)

     local currenMinPage = (self.selectSkinPagePositionIndex - 1) * 16
     local currenMinPageIndex = currenMinPage == 0 and 1 or currenMinPage
     local currenMaxPageIndex = self.selectSkinPagePositionIndex * 16

     local searchFilterSkinsDefault = table.tally(currenMinPageIndex, currenMaxPageIndex)
     local searchFilterSkinsTyped   = table.singularity(table.merge(filterSearchByID, searchFilterSkinsDefault), false)

     local searchFilterSkinsSubDefault = table.sub(searchFilterSkinsDefault, 1, 16)
     local searchFilterSkinsSubTyped   = table.sub(searchFilterSkinsTyped, 1, 16)
     local searchFilterSkins = #filterSearchByID == 0 and searchFilterSkinsSubDefault or searchFilterSkinsSubTyped
     for ids, displays in pairs(searchFilterSkins) do
          if #filterSearchByID    == 0 then return end -- !DO NOT DELETE
          if #filterSearchByName < ids then return end -- !DO NOT DELETE

          local displaySkinIconTemplates = {state = (self.stateClass):upperAtStart(), ID = displays}
          local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
          local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)

          local displaySkinPositionX = displaySkinPositions()[ids][1]
          local displaySkinPositionY = displaySkinPositions()[ids][2]
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

          local displaySkinMetadataJSON = self.totalMetadataOrderedDisplay[tonumber(displays)]
          local displaySkinMetadata_frames   = displaySkinMetadataJSON == '@void' and 12                    or (displaySkinMetadataJSON.frames   or 12)
          local displaySkinMetadata_prefixes = displaySkinMetadataJSON == '@void' and 'note splash green 1' or (displaySkinMetadataJSON.prefixes or 'note splash green 1')
          local displaySkinMetadata_size     = displaySkinMetadataJSON == '@void' and {0.4, 0.4}            or (displaySkinMetadataJSON.size     or {0.4, 0.4})
          local displaySkinMetadata_offsets  = displaySkinMetadataJSON == '@void' and {0, 0}                or (displaySkinMetadataJSON.offsets  or {0, 0})

          local displaySkinImageTemplate = {path = self.statePaths, skin = filterSearchBySkin[ids]}
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

          if ids > #filterSearchBySkin then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    removeLuaSprite(displaySkinIconButton, true)
                    removeLuaSprite(displaySkinIconSkin, true)
               end
          end

          if #filterSearchBySkin == 0 then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    return
               end
               
               for _ in pairs(searchFilterSkins) do -- lmao
                    local displaySkinIconTemplates = {state = (self.stateClass):upperAtStart(), ID = displays}
                    local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
                    local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)

                    removeLuaSprite(displaySkinIconButton, true)
                    removeLuaSprite(displaySkinIconSkin, true)
               end
               if ids == 16 then 
                    return 
               end
          end
          self:save_selection()
     end
end

--- Creates and loads the selected search skin's preview strums.
---@return nil
function SkinSplashes:search_preview()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     local curIndex = self.selectSkinCurSelectedIndex
     local function previewSearchSkinIndex()
          for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
               local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )

               local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
               local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
               if releasedObject(displaySkinIconButton, 'camHUD') then
                    return searchSkinIndex
               end
          end
     end

     local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = previewSearchSkinIndex()}
     local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
     if releasedObject(displaySkinIconButton, 'camHUD') then
          local function getCurrentPreviewSkin(previewSkinArray)
               if curIndex == 0 then
                    return previewSkinArray[1][1]
               end

               for pages = 1, self.totalSkinLimit do
                    local presentObjectIndex = table.find(self.totalSkinObjectIndexes[pages], curIndex)
                    if presentObjectIndex ~= nil then
                         return previewSkinArray[pages][presentObjectIndex]
                    end
               end
          end
     
          local getCurrentPreviewSkinObjects       = getCurrentPreviewSkin(self.totalSkinObjects)
          local getCurrentPreviewSkinObjectNames   = getCurrentPreviewSkin(self.totalSkinObjectNames)
          local getCurrentPreviewSkinObjectPreview = getCurrentPreviewSkin(self.totalMetadataObjectPreview)
          for strums = 1, 4 do
               local previewSkinTemplate = {state = (self.stateClass):upperAtStart(), groupID = strums}
               local previewSkinGroup    = ('previewSkinGroup${state}-${groupID}'):interpol(previewSkinTemplate)
     
               local previewMetadataObjectAnims = {
                    names = {
                         note_splash1 = {'left_splash1', 'down_splash1', 'up_splash1', 'right_splash1'},
                         note_splash2 = {'left_splash2', 'down_splash2', 'up_splash2', 'right_splash2'}
                    },
                    prefixes = {
                         note_splash1 = {'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1'},
                         note_splash2 = {'note splash purple 2', 'note splash blue 2', 'note splash green 2', 'note splash red 2'}
                    },
                    frames = {
                         note_splash1 = 24,
                         note_splash2 = 24
                    }
               }
     
               local function previewMetadataObjectData(skinAnim)
                    local previewMetadataObject         = getCurrentPreviewSkinObjectPreview
                    local previewMetadataObjectByAnim   = getCurrentPreviewSkinObjectPreview.animations
                    local previewStaticDataObjectByAnim = self.previewStaticDataPreview.animations
     
                    local previewMetadataObjectNames = previewMetadataObjectAnims['names'][skinAnim]
                    if previewMetadataObject == '@void' or previewMetadataObjectByAnim == nil then
                         return previewStaticDataObjectByAnim[skinAnim][previewMetadataObjectNames[strums]]
                    end
                    if previewMetadataObjectByAnim[skinAnim] == nil then
                         previewMetadataObject['animations'][skinAnim] = previewStaticDataObjectByAnim[skinAnim]
                         return previewStaticDataObjectByAnim[skinAnim][previewMetadataObjectNames[strums]]
                    end
                    return previewMetadataObjectByAnim[skinAnim][previewMetadataObjectNames[strums]]
               end
               local function previewMetadataObjects(element)
                    local previewMetadataObject       = getCurrentPreviewSkinObjectPreview
                    local previewMetadataObjectByElem = getCurrentPreviewSkinObjectPreview[element]
     
                    if previewMetadataObject == '@void' or previewMetadataObjectByElem == nil then
                         return self.previewStaticDataPreview[element]
                    end
                    return previewMetadataObjectByElem
               end
     
               local previewMetadataByObjectNoteSplash1 = previewMetadataObjectData('note_splash1')
               local previewMetadataByObjectNoteSplash2 = previewMetadataObjectData('note_splash2')
     
               local previewMetadataByFramesNoteSplash1 = previewMetadataObjects('frames').note_splash1
               local previewMetadataByFramesNoteSplash2 = previewMetadataObjects('frames').note_splash2
     
               local previewMetadataBySize = previewMetadataObjects('size')
               
               local previewSkinImagePath = self.statePaths..'/'..getCurrentPreviewSkinObjects
               local previewSkinPositionX = 790 + (105*(strums-1))
               local previewSkinPositionY = 135
               makeAnimatedLuaSprite(previewSkinGroup, previewSkinImagePath, previewSkinPositionX, previewSkinPositionY)
               scaleObject(previewSkinGroup, previewMetadataBySize[1], previewMetadataBySize[2])
     
               local previewSkinAddAnimationPrefix = function(objectData, dataFrames)
                    addAnimationByPrefix(previewSkinGroup, objectData.name, objectData.prefix, dataFrames, false)
               end
               local previewSkinGetOffsets = function(objectData, position)
                    local previewSkinGroupOffsetX = getProperty(previewSkinGroup..'.offset.x')
                    local previewSkinGroupOffsetY = getProperty(previewSkinGroup..'.offset.y')
                    if position == 'x' then return previewSkinGroupOffsetX - objectData.offsets[1] end
                    if position == 'y' then return previewSkinGroupOffsetY + objectData.offsets[2] end
               end
               local previewSkinAddOffsets = function(objectData)
                    local previewSkinOffsetX = previewSkinGetOffsets(objectData, 'x')
                    local previewSkinOffsetY = previewSkinGetOffsets(objectData, 'y')
                    addOffset(previewSkinGroup, objectData.name, previewSkinOffsetX, previewSkinOffsetY)
               end
               
               local previewSkinAnimation = function(objectData, dataFrames)
                    previewSkinAddAnimationPrefix(objectData, dataFrames)
                    previewSkinAddOffsets(objectData)
               end
               previewSkinAnimation(previewMetadataByObjectNoteSplash1, previewMetadataByFramesNoteSplash1)
               previewSkinAnimation(previewMetadataByObjectNoteSplash2, previewMetadataByFramesNoteSplash2)
               
               setObjectCamera(previewSkinGroup, 'camHUD')
               setProperty(previewSkinGroup..'.visible', false)
               addLuaSprite(previewSkinGroup)
          end
     
          setTextString('genInfoSkinName', getCurrentPreviewSkinObjectNames)
     end
     self:preview_animation(true)
end 

return SkinSplashes