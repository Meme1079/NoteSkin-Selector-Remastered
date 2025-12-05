luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

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

--- Subclass dedicated for the preview strums component for the note skin state.
---@class SkinNotesPreview
local SkinNotesPreview = {}

--- Creates the selected skin's preview strums.
---@return nil
function SkinNotesPreview:preview()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     local curPage  = self.selectSkinPagePositionIndex
     local curIndex = self.selectSkinCurSelectedIndex
     local function getCurrentPreviewSkin(previewSkinArray)
          if curIndex == 0 or self.totalSkins[curIndex] == nil then
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

          local function previewMetadataObjectData(skinAnim, withElement)
               local previewMetadataObject         = getCurrentPreviewSkinObjectPreview
               local previewMetadataObjectByAnim   = getCurrentPreviewSkinObjectPreview.animations
               local previewMetadataObjectNames    = previewMetadataObjectAnims['names'][skinAnim]
               local previewStaticDataObjectByAnim = self.previewStaticDataPreview.animations
               if withElement == true then
                    if previewMetadataObject == '@void' or previewMetadataObjectByAnim == nil then
                         return previewStaticDataObjectByAnim[skinAnim]
                    end
                    if previewMetadataObjectByAnim == nil then
                         previewMetadataObject['animations'] = previewStaticDataObjectByAnim
                         return previewStaticDataObjectByAnim
                    end
                    if previewMetadataObjectByAnim[skinAnim] == nil then
                         previewMetadataObject['animations'][skinAnim] = previewStaticDataObjectByAnim[skinAnim]
                         return previewStaticDataObjectByAnim[skinAnim]
                    end
                    return previewMetadataObjectByAnim[skinAnim]
               end

               if previewMetadataObject == '@void' or previewMetadataObjectByAnim == nil then
                    return previewStaticDataObjectByAnim[skinAnim][previewMetadataObjectNames[strums]]
               end
               if previewMetadataObjectByAnim == nil then
                    previewMetadataObject['animations'] = previewStaticDataObjectByAnim
                    return previewStaticDataObjectByAnim
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

          local previewMetadataByObjectConfirm = previewMetadataObjectData('confirm')
          local previewMetadataByObjectPressed = previewMetadataObjectData('pressed')
          local previewMetadataByObjectColored = previewMetadataObjectData('colored')
          local previewMetadataByObjectStrums  = previewMetadataObjectData('strums')

          local previewMetadataByFramesConfirm = previewMetadataObjects('frames').confirm
          local previewMetadataByFramesPressed = previewMetadataObjects('frames').pressed
          local previewMetadataByFramesColored = previewMetadataObjects('frames').colored
          local previewMetadataByFramesStrums  = previewMetadataObjects('frames').strums
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
          previewSkinAnimation(previewMetadataByObjectConfirm, previewMetadataByFramesConfirm)
          previewSkinAnimation(previewMetadataByObjectPressed, previewMetadataByFramesPressed)
          previewSkinAnimation(previewMetadataByObjectColored, previewMetadataByFramesColored)
          previewSkinAnimation(previewMetadataByObjectStrums, previewMetadataByFramesStrums)

          playAnim(previewSkinGroup, previewMetadataObjectAnims['names']['strums'][strums])
          setObjectCamera(previewSkinGroup, 'camHUD')
          addLuaSprite(previewSkinGroup)

          SkinNoteSave:set('previewMetadataByObjectStrums', self.stateClass..'Static', previewMetadataObjectData('strums', true))
          SkinNoteSave:set('previewMetadataByFramesStrums', self.stateClass..'Static', previewMetadataByFramesStrums)
          SkinNoteSave:set('previewMetadataBySize', self.stateClass..'Static', previewMetadataBySize)
          SkinNoteSave:set('previewSkinImagePath', self.stateClass..'Static', previewSkinImagePath)
     end

     setTextString('genInfoSkinName', getCurrentPreviewSkinObjectNames)
     self:preview_animation(true)
end

--- Creates and loads the selected skin's preview animations.
---@param loadAnim? boolean Will only load the current skin's preview animations or not, bug fixing purposes.
---@return nil
function SkinNotesPreview:preview_animation(loadAnim)
     local loadAnim = loadAnim ~= nil and true or false

     local firstJustPressed  = callMethodFromClass('flixel.FlxG', 'keys.firstJustPressed', {''})
     local firstJustReleased = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})

     local firstJustInputPressed  = (firstJustPressed ~= -1 and firstJustPressed ~= nil)
     local firstJustInputReleased = (firstJustReleased ~= -1 and firstJustReleased ~= nil)
     local firstJustInputs        = (firstJustInputPressed or firstJustInputReleased)
     if not firstJustInputs and loadAnim == false then
          return
     end

     local curIndex = self.selectSkinCurSelectedIndex
     local function getCurrentPreviewSkin(previewSkinArray)
          if curIndex == 0 or self.totalSkins[curIndex] == nil then
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
               confirm = previewMetadataObjectData('confirm'), 
               pressed = previewMetadataObjectData('pressed'),
               colored = previewMetadataObjectData('colored'),
               strums  = previewMetadataObjectData('strums')
          }

          if previewSkinAnim == 'colored' then
               playAnim(previewSkinGroup, previewMetadataObjectGroupData['colored']['name'], true)
               goto skipPreviewMetadataAnim
          end

          --[[ 
               I've spent literal hours finding a solution to fix a stupid visual bug. Switching to preview 
               colored animations for the strums. Then using the preview animation buttons below will remain 
               the same previous animations until pressing a button to play an animation. 
               
               And for some reason adding "mouseReleased('left')" function to this "if" statement here below. 
               Somehow fucking solves this stupid issue, why? idk.

               Sometimes the strangest and unexpected random solutions literally solves a stupid problem.
                    ~ Meme1079
          ]]
          if (conditionPressedLeft or conditionPressedRight) or mouseReleased('left') then
               playAnim(previewSkinGroup, previewMetadataObjectGroupData['strums']['name'], true)
          end
          if keyboardJustConditionPressed(getKeyBinds(strums), not getVar('skinSearchInputFocus')) then
               local previewSkinAnimFilter = previewSkinAnim:gsub('%s+', '_'):gsub('_(%d)', '%1')
               playAnim(previewSkinGroup, previewMetadataObjectGroupData[previewSkinAnimFilter]['name'], true)
          end
          if keyboardJustConditionReleased(getKeyBinds(strums), not getVar('skinSearchInputFocus')) then
               playAnim(previewSkinGroup, previewMetadataObjectGroupData['strums']['name'], true)
          end
          ::skipPreviewMetadataAnim::
     end
end

--- Collection of similair methods of the preview selection function.
---@return nil
function SkinNotesPreview:preview_selection()
     self:preview_selection_moved()
     self:preview_selection_byclick()
     self:preview_selection_byhover()
     self:preview_selection_bycursor()
end

local previewSelectionToggle = false -- * ok who gaf
--- Changes the skin's preview animations by using keyboard keys.
---@return nil
function SkinNotesPreview:preview_selection_moved()
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
          SkinNoteSave:set('previewObjectIndex', self.stateClass, self.previewAnimationObjectIndex)
     end
     if conditionPressedRight and previewAnimationMaxIndex then
          self.previewAnimationObjectIndex = self.previewAnimationObjectIndex + 1
          previewSelectionToggle  = true

          playSound('ding', 0.5)
          SkinNoteSave:set('previewObjectIndex', self.stateClass, self.previewAnimationObjectIndex)
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
     setTextString('previewSkinButtonSelectionText', previewMetadataObjectAnims:upperAtStart())
end

--- Main click functionality when interacting any preview buttons when selecting one.
--- Allows the skin's preview animations along with the preview buttons displaying its animations.
---@return nil
function SkinNotesPreview:preview_selection_byclick()
     local function previewSelectionButtonClick(index, direct, value)
          local previewSkinButton = 'previewSkinButton'..direct:upperAtStart()

          local byPreviewButtonClick   = clickObject(previewSkinButton, 'camHUD')
          local byPreviewButtonRelease = mouseReleased('left')
          if byPreviewButtonClick == true and self.previewAnimationObjectClicked[index] == false then
               playAnim(previewSkinButton, 'hovered-pressed', true)
               self.previewAnimationObjectClicked[index] = true
          end
          if byPreviewButtonRelease == true and self.previewAnimationObjectClicked[index] == true then
               playAnim(previewSkinButton, 'static', true)
               playSound('ding', 0.5)

               self.previewAnimationObjectIndex          = self.previewAnimationObjectIndex + value
               self.previewAnimationObjectClicked[index] = false
               self:preview_animation(true)

               SkinNoteSave:set('previewObjectIndex', self.stateClass, self.previewAnimationObjectIndex)
          end
     end

     local previewAnimationMinIndex = self.previewAnimationObjectIndex > 1
     local previewAnimationMaxIndex = self.previewAnimationObjectIndex < #self.previewAnimationObjectPrevAnims
     if previewAnimationMinIndex == true then
          previewSelectionButtonClick(1, 'left', -1)
     end
     if previewAnimationMaxIndex == true then
          previewSelectionButtonClick(2, 'right', 1)
     end
end

--- Main hovering functionality when interacting any preview buttons when selecting any.
--- Allows the preview buttons to have a hover animation.
---@return nil
function SkinNotesPreview:preview_selection_byhover()
     local function previewSelectionButtonHover(index, direct, value)
          local previewSkinButton = 'previewSkinButton'..direct:upperAtStart()
          if self.previewAnimationObjectClicked[index] == true then
               return
          end

          if hoverObject(previewSkinButton, 'camHUD') == true then
               self.previewAnimationObjectHovered[index] = true
          end
          if hoverObject(previewSkinButton, 'camHUD') == false then
               self.previewAnimationObjectHovered[index] = false
          end

          if self.previewAnimationObjectHovered[index] == true then
               playAnim(previewSkinButton, 'hovered-static', true)
          end
          if self.previewAnimationObjectHovered[index] == false then
               playAnim(previewSkinButton, 'static', true)
          end
     end

     local previewAnimationMinIndex = self.previewAnimationObjectIndex > 1
     local previewAnimationMaxIndex = self.previewAnimationObjectIndex < #self.previewAnimationObjectPrevAnims
     if previewAnimationMinIndex == true then
          previewSelectionButtonHover(1, 'left')
     else
          playAnim('previewSkinButtonLeft', 'hovered-blocked', true)
          self.previewAnimationObjectHovered[1] = false
     end
     if previewAnimationMaxIndex == true then
          previewSelectionButtonHover(2, 'right')
     else
          playAnim('previewSkinButtonRight', 'hovered-blocked', true)
          self.previewAnimationObjectHovered[2] = false
     end
end

--- Main cursor functionality when interacting any preview buttons when selecting any.
--- Changes the cursor's texture depending on its interaction (i.e. selecting and hovering).
---@return nil
function SkinNotesPreview:preview_selection_bycursor()
     for previewObjects = 1, 2 do
          if self.previewAnimationObjectClicked[previewObjects] == true then
               playAnim('mouseTexture', 'handClick', true)
               return
          end
          if self.previewAnimationObjectHovered[previewObjects] == true then
               playAnim('mouseTexture', 'hand', true)
               return
          end
     end

     local conditionHoverLeft  = hoverObject('previewSkinButtonLeft', 'camHUD')
     local conditionHoverRight = hoverObject('previewSkinButtonRight', 'camHUD')
     if conditionHoverLeft or conditionHoverRight then
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

return SkinNotesPreview