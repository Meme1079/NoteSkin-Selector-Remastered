luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

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

--- Subclass dedicated for the preview splashes component for the splash skin state.
---@class SkinSplashesPreview
local SkinSplashesPreview = {}

--- Creates the selected skin's preview splashes.
---@return nil
function SkinSplashesPreview:preview()
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

--- Creates the current selected note skin within the splash skin state.
---@return nil
function SkinSplashesPreview:preview_notes()
     for strums = 1, 4 do
          local previewSkinTemplate = {state = 'Notes', groupID = strums}
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
function SkinSplashesPreview:preview_animation(loadAnim)
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
function SkinSplashesPreview:preview_selection_moved()
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

return SkinSplashesPreview