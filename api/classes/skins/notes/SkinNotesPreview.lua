luaDebugMode = true

local SkinSaves    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local DIRECTION        = global.DIRECTION
local MAX_NUMBER_CHUNK = global.MAX_NUMBER_CHUNK

local hoverObject                   = funkinlua.hoverObject
local clickObject                   = funkinlua.clickObject
local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

--- Childclass extension, main preview strums component functionality for the note skin state.
---@class SkinNotesPreview
local SkinNotesPreview = {}
local SkinNotesGSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

--- Creates the preview strums' graphic sprites and text.
---@return nil
function SkinNotesPreview:preview()
     local SEARCH_INPUT_TEXT_CONTENT = getVar('SEARCH_INPUT_TEXT_CONTENT') or ''
     if #SEARCH_INPUT_TEXT_CONTENT > 0 then
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
               local selectedSkinPage  = self.TOTAL_SKIN_OBJECTS_IDS[skinPages]
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
          local constantSkinPrevObjAnim      = self.PREVIEW_CONST_METADATA_PREVIEW.animations
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

          local metadataSkinPrevObj     = currentPreviewMetadataPrev
          local metadataSkinPrevObjAnim = currentPreviewMetadataPrev.animations
          
          local constantSkinPrevObjAnimNames = self.PREVIEW_CONST_METADATA_PREVIEW_ANIMS['names'][animationName]
          local constantSkinPrevObjAnim      = self.PREVIEW_CONST_METADATA_PREVIEW.animations

          local skinPrevAnimElements = constantSkinPrevObjAnimNames[strumIndex]
          if metadataSkinPrevObj == '@void' or metadataSkinPrevObjAnim == nil then
               return constantSkinPrevObjAnim[animationName][skinPrevAnimElements]
          end
          if metadataSkinPrevObjAnim[animationName] == nil then
               metadataSkinPrevObj['animations'][animationName] = constantSkinPrevObjAnim[animationName]
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
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewConfirmAnim.name, metadataPreviewConfirmAnim.prefix, metadataPreviewConfirmFrames)
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewPressedAnim.name, metadataPreviewPressedAnim.prefix, metadataPreviewPressedFrames)
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewColoredAnim.name, metadataPreviewColoredAnim.prefix, metadataPreviewColoredFrames)
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewStrumsAnim.name,  metadataPreviewStrumsAnim.prefix,  metadataPreviewStrumsFrames)

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

          SkinNotesGSave:set('PREV_NOTES_METAOBJ_STRUMS_ANIMS',  'PREVIEW', previewMetadataObjectAnims('strums', strumIndex, true))
          SkinNotesGSave:set('PREV_NOTES_METAOBJ_STRUMS_PATH',   'PREVIEW', previewSkinGroupSprite)
          SkinNotesGSave:set('PREV_NOTES_METAOBJ_STRUMS_FRAMES', 'PREVIEW', metadataPreviewStrumsFrames)
          SkinNotesGSave:set('PREV_NOTES_METAOBJ_STRUMS_SIZE',   'PREVIEW', metadataPreviewSize)
     end
     setTextString('skinStatePreviewName', currentPreviewDataNames)
end

--- Creates the preview strums' animations, for testing its animations for visual aid.
---@return nil
function SkinNotesPreview:preview_animation()
     if SkinNotesGSave:get('PREVIEW_TOGGLE_ANIM_STATUS', 'SAVE', true) == false then
          return
     end
     
     local firstJustPressed  = callMethodFromClass('flixel.FlxG', 'keys.firstJustPressed', {''})
     local firstJustReleased = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})
     local firstJustInputPressed  = firstJustPressed  == -1 and firstJustPressed  == nil
     local firstJustInputReleased = firstJustReleased == -1 and firstJustReleased == nil
     if firstJustInputPressed or firstJustInputReleased then
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
               local selectedSkinPage  = self.TOTAL_SKIN_OBJECTS_IDS[skinPages]
               local selectedSkinIndex = table.find(selectedSkinPage, self.SELECT_SKIN_CUR_SELECTION_INDEX)
               if selectedSkinIndex ~= nil then
                    return skinObjects[skinPages][selectedSkinIndex]
               end
          end
     end
     local conditionPressedLeft  = keyboardJustConditionPressed('Z', not getVar('skinSearchInputFocus'))
     local conditionPressedRight = keyboardJustConditionPressed('X', not getVar('skinSearchInputFocus'))
     local currentPreviewMetadataPrev = currentPreviewSkinData(self.TOTAL_SKIN_METAOBJ_PREVIEW)

     --- Same as the previous function above, helper function; this retreives mainly its animation from its JSON.
     ---@param animationName string The name of the animation metadata to be fetch.
     ---@param strumIndex number The strum index number to cycle each value.
     ---@return table
     local function previewMetadataObjectAnims(animationName, strumIndex)
          local metadataSkinPrevObj     = currentPreviewMetadataPrev
          local metadataSkinPrevObjAnim = currentPreviewMetadataPrev.animations
          
          local constantSkinPrevObjAnimNames = self.PREVIEW_CONST_METADATA_PREVIEW_ANIMS['names'][animationName]
          local constantSkinPrevObjAnim      = self.PREVIEW_CONST_METADATA_PREVIEW.animations

          local skinPrevAnimElements = constantSkinPrevObjAnimNames[strumIndex]
          if metadataSkinPrevObj == '@void' or metadataSkinPrevObjAnim == nil then
               return constantSkinPrevObjAnim[animationName][skinPrevAnimElements]
          end
          if metadataSkinPrevObjAnim[animationName] == nil then
               metadataSkinPrevObj['animations'][animationName] = constantSkinPrevObjAnim[animationName]
               return constantSkinPrevObjAnim[animationName][skinPrevAnimElements]
          end
          return metadataSkinPrevObjAnim[animationName][skinPrevAnimElements]
     end

     --- Checks if said skin is missing an animation for preview, helper function.
     ---@return boolean
     local function previewSkinObjectIsMissing()
          local selectSkinPageIndex      = self.SELECT_SKIN_PAGE_INDEX
          local selectSkinCurSelectIndex = self.SELECT_SKIN_CUR_SELECTION_INDEX
          local previewSkinObjectAnims   = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewSkinMissingAnims  = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING

          local selectSkinCurSelectByChunk = selectSkinCurSelectIndex % MAX_NUMBER_CHUNK
          local selectSkinCurSelectFixed   = selectSkinCurSelectByChunk == 0 and MAX_NUMBER_CHUNK or selectSkinCurSelectByChunk
          if previewSkinMissingAnims[selectSkinPageIndex][selectSkinCurSelectFixed] == nil then
               return true
          end
          return previewSkinMissingAnims[selectSkinPageIndex][selectSkinCurSelectFixed][previewSkinObjectAnims]
     end

     for strumIndex = 1, 4 do
          local metadataPreviewAnimations = {
               confirm = previewMetadataObjectAnims('confirm', strumIndex),
               pressed = previewMetadataObjectAnims('pressed', strumIndex),
               colored = previewMetadataObjectAnims('colored', strumIndex),
               strums  = previewMetadataObjectAnims('strums',  strumIndex)
          }
          local previewSkinGroupTag   = F"previewSkinGroup{self.stateClass:upperAtStart()}-{strumIndex}"
          local previewSkinAnimations = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]

          if previewSkinAnimations == 'colored' then
               playAnim(previewSkinGroupTag, metadataPreviewAnimations['colored']['name'], true)
               goto SKIP_PREVIEW_ANIMATIONS
          end

          --[[ 
               I've spent literal hours finding a solution to fix a stupid visual bug. Switching to preview 
               colored animations for the strums. Then using the preview animation buttons below will remain 
               the same previous animations until pressing a button to play an animation. 
               
               And for some reason adding "mouseReleased('left')" function to this "if" statement here below. 
               Somehow fucking solves this stupid issue, why? idk.

               Sometimes the strangest and unexpected random solutions literally solves a stupid problem.
                    ~ MemeFlavor
          ]]
          if (conditionPressedLeft or conditionPressedRight) or mouseReleased('left') then
               playAnim(previewSkinGroupTag, metadataPreviewAnimations['strums']['name'], true)
          end

          if previewSkinObjectIsMissing() == false then
               if keyboardJustConditionPressed(getKeyBinds(strumIndex), not getVar('skinSearchInputFocus')) then
                    playAnim(previewSkinGroupTag, metadataPreviewAnimations[previewSkinAnimations]['name'], true)
               end
               if keyboardJustConditionReleased(getKeyBinds(strumIndex), not getVar('skinSearchInputFocus')) then
                    playAnim(previewSkinGroupTag, metadataPreviewAnimations['strums']['name'], true)
               end
          end
          ::SKIP_PREVIEW_ANIMATIONS::
     end
end

--- Preview selection component group.
---@return nil
function SkinNotesPreview:preview_selection()
     self:preview_selection_moved()
     self:preview_selection_byclick()
     self:preview_selection_byhover()
     self:preview_selection_bycursor()
end

local PREVIEW_SELECTION_TOGGLE = false -- * Important, but ignore this lmao
--- Preview main strum animation selection functionality.
---@private
---@return nil
function SkinNotesPreview:preview_selection_moved()
     local conditionPressedLeft  = keyboardJustConditionPressed('Z', not getVar('skinSearchInputFocus'))
     local conditionPressedRight = keyboardJustConditionPressed('X', not getVar('skinSearchInputFocus'))

     local previewAnimationMinIndex = self.PREVIEW_SKIN_OBJECT_INDEX > 1
     local previewAnimationMaxIndex = self.PREVIEW_SKIN_OBJECT_INDEX < #self.PREVIEW_SKIN_OBJECT_ANIMS
     if conditionPressedLeft and previewAnimationMinIndex then
          self.PREVIEW_SKIN_OBJECT_INDEX = self.PREVIEW_SKIN_OBJECT_INDEX - 1
          PREVIEW_SELECTION_TOGGLE  = true

          playSound('ding', 0.5)
          SkinNotesGSave:set('PREVIEW_SKIN_OBJECT_INDEX', self.stateClass:upper(), self.PREVIEW_SKIN_OBJECT_INDEX)
     end
     if conditionPressedRight and previewAnimationMaxIndex then
          self.PREVIEW_SKIN_OBJECT_INDEX = self.PREVIEW_SKIN_OBJECT_INDEX + 1
          PREVIEW_SELECTION_TOGGLE  = true

          playSound('ding', 0.5)
          SkinNotesGSave:set('PREVIEW_SKIN_OBJECT_INDEX', self.stateClass:upper(), self.PREVIEW_SKIN_OBJECT_INDEX)
     end
     
     if PREVIEW_SELECTION_TOGGLE == true then --! DO NOT DELETE
          PREVIEW_SELECTION_TOGGLE = false
          return
     end

     if not previewAnimationMinIndex then
          playAnim('preivewSkinButtonIconLeft', 'none', true)
          playAnim('previewSkinButtonIconRight', 'right', true)
     else
          playAnim('preivewSkinButtonIconLeft', 'left', true)
     end
     if not previewAnimationMaxIndex then
          playAnim('preivewSkinButtonIconLeft', 'left', true)
          playAnim('previewSkinButtonIconRight', 'none', true)
     else
          playAnim('previewSkinButtonIconRight', 'right', true)
     end
     self:preview_selection_name()
end

--- Preview main strum animation selection button clicking functionality and animations.
---@private
---@return nil
function SkinNotesPreview:preview_selection_byclick()
     local function previewSelectionButtonClick(directIndex, directName, iteration)
          local previewSkinButtonTag = F"previewSkinButton{directName:upperAtStart()}"

          local previewSkinButtonClicked  = clickObject(previewSkinButtonTag, 'camHUD')
          local previewSkinButtonReleased = mouseReleased('left')
          
          if previewSkinButtonClicked == true and self.PREVIEW_SKIN_OBJECT_ANIMS_CLICKED[directIndex] == false then
               playAnim(previewSkinButtonTag, 'hovered-pressed', true)
               self.PREVIEW_SKIN_OBJECT_ANIMS_CLICKED[directIndex] = true
          end
          if previewSkinButtonReleased == true and self.PREVIEW_SKIN_OBJECT_ANIMS_CLICKED[directIndex] == true then
               playAnim(previewSkinButtonTag, 'static', true)
               playSound('ding', 0.5)

               self.PREVIEW_SKIN_OBJECT_INDEX                      = self.PREVIEW_SKIN_OBJECT_INDEX + iteration
               self.PREVIEW_SKIN_OBJECT_ANIMS_CLICKED[directIndex] = false

               SkinNotesGSave:set('PREVIEW_SKIN_OBJECT_INDEX', self.stateClass:upper(), self.PREVIEW_SKIN_OBJECT_INDEX)
          end
     end

     local previewAnimationMinIndex = self.PREVIEW_SKIN_OBJECT_INDEX > 1
     local previewAnimationMaxIndex = self.PREVIEW_SKIN_OBJECT_INDEX < #self.PREVIEW_SKIN_OBJECT_ANIMS
     if previewAnimationMinIndex == true then
          previewSelectionButtonClick(DIRECTION.LEFT, 'left', -1)
     end
     if previewAnimationMaxIndex == true then
          previewSelectionButtonClick(DIRECTION.RIGHT, 'right', 1)
     end
end

--- Preview main strum animation selection button hovering functionality and animations.
---@private
---@return nil
function SkinNotesPreview:preview_selection_byhover()
     local function previewSelectionButtonHover(directIndex, directName)
          local previewSkinButtonTag = F"previewSkinButton{directName:upperAtStart()}"
          if self.PREVIEW_SKIN_OBJECT_ANIMS_CLICKED[directIndex] == true then
               return
          end

          if hoverObject(previewSkinButtonTag, 'camHUD') == true then
               self.PREVIEW_SKIN_OBJECT_ANIMS_HOVERED[directIndex] = true
          end
          if hoverObject(previewSkinButtonTag, 'camHUD') == false then
               self.PREVIEW_SKIN_OBJECT_ANIMS_HOVERED[directIndex] = false
          end

          if self.PREVIEW_SKIN_OBJECT_ANIMS_HOVERED[directIndex] == true then
               playAnim(previewSkinButtonTag, 'hovered-static', true)
          end
          if self.PREVIEW_SKIN_OBJECT_ANIMS_HOVERED[directIndex] == false then
               playAnim(previewSkinButtonTag, 'static', true)
          end
     end

     local previewAnimationMinIndex = self.PREVIEW_SKIN_OBJECT_INDEX > 1
     local previewAnimationMaxIndex = self.PREVIEW_SKIN_OBJECT_INDEX < #self.PREVIEW_SKIN_OBJECT_ANIMS
     if previewAnimationMinIndex == true then
          previewSelectionButtonHover(DIRECTION.LEFT, 'left')
     else
          playAnim('previewSkinButtonLeft', 'hovered-blocked', true)
          self.PREVIEW_SKIN_OBJECT_ANIMS_HOVERED[DIRECTION.LEFT] = false
     end
     if previewAnimationMaxIndex == true then
          previewSelectionButtonHover(DIRECTION.RIGHT, 'right')
     else
          playAnim('previewSkinButtonRight', 'hovered-blocked', true)
          self.PREVIEW_SKIN_OBJECT_ANIMS_HOVERED[DIRECTION.RIGHT] = false
     end
end

--- Preview main strum animation selection button hovering functionality and animations.
---@private
---@return nil
function SkinNotesPreview:preview_selection_bycursor()
     for _, DirectValues in pairs(DIRECTION) do
          if self.PREVIEW_SKIN_OBJECT_ANIMS_CLICKED[DirectValues] == true then
               playAnim('mouseTexture', 'handClick', true)
               return
          end
          if self.PREVIEW_SKIN_OBJECT_ANIMS_HOVERED[DirectValues] == true then
               playAnim('mouseTexture', 'hand', true)
               return
          end
     end

     local previewSkinButtonLeftHovered  = hoverObject('previewSkinButtonLeft', 'camHUD')
     local previewSkinButtonRightHovered = hoverObject('previewSkinButtonRight', 'camHUD')
     if previewSkinButtonLeftHovered or previewSkinButtonRightHovered then
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

--- Preview current animation name, that's literally it.
---@protected
---@return nil
function SkinNotesPreview:preview_selection_name()
     local previewSkinAnimations    = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
     local previewSkinAnimationName = previewSkinAnimations:upperAtStart()
     setTextString('previewSkinButtonSelectionText', previewSkinAnimationName)
end

return SkinNotesPreview