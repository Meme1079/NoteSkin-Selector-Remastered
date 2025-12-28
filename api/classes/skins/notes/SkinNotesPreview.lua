luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

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

--- Childclass extension, main preview strums component functionality for the note skin state.
---@class SkinNotesPreview
local SkinNotesPreview = {}

--- Creates the preview strums' graphic sprites and its text.
---@return nil
function SkinNotesPreview:preview()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     --- Gets the skin's object data from the currently selected skin.
     ---@param skinObjects table The object to retreive its data.
     ---@return any
     local function currentPreviewSkinData(skinObjects)
          if self.selectSkinCurSelectedIndex == 0 or self.totalSkins[self.selectSkinCurSelectedIndex] == nil then
               return skinObjects[1][1] -- default value
          end

          for skinPages = 1, self.totalSkinLimit do -- checks if each page has an existing skin object
               local selectedSkinPage  = self.totalSkinObjectIndexes[skinPages]
               local selectedSkinIndex = table.find(selectedSkinPage, self.selectSkinCurSelectedIndex)
               if selectedSkinIndex ~= nil then
                    return skinObjects[skinPages][selectedSkinIndex]
               end
          end
     end

     local currentPreviewDataSkins    = currentPreviewSkinData(self.totalSkinObjects)
     local currentPreviewDataNames    = currentPreviewSkinData(self.totalSkinObjectNames)
     local currentPreviewMetadataPrev = currentPreviewSkinData(self.totalMetadataObjectPreview)

     --- Gets the skin's preview metadata object from its JSON.
     ---@param metadataName string The name of the metadata to be fetch.
     ---@return table
     local function previewMetadataObject(metadataName)
          local metadataSkinPrevObj         = currentPreviewMetadataPrev
          local metadataSkinPrevObjElements = currentPreviewMetadataPrev[metadataName]
          if metadataSkinPrevObj == '@void' or metadataSkinPrevObjElements == nil then
               return self.previewStaticDataPreview[metadataName]
          end
          return metadataSkinPrevObjElements
     end

     --- Same as the previous function above, helper function; this retreives mainly its animation from its JSON.
     ---@param animationName string The name of the animation metadata to be fetch.
     ---@param strumIndex number The strum index number to cycle each value.
     ---@param ?byAnimationGroup boolean Whether it will retreive by group or not.
     ---@return table
     local function previewMetadataObjectAnims(animationName, strumIndex, byAnimationGroup)
          local metadataSkinPrevObj     = currentPreviewMetadataPrev
          local metadataSkinPrevObjAnim = currentPreviewMetadataPrev.animations

          local constantSkinPrevObjAnimNames = self.previewConstDataPreviewAnims['names'][animationName]
          local constantSkinPrevObjAnim      = self.previewStaticDataPreview.animation
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

          local skinPrevAnimElements = constantSkinPrevObjAnimNames[strumIndex]
          if metadataSkinPrevObj == '@void' or metadataSkinPrevObjAnim == nil then
               return constantSkinPrevObjAnim[animationName][skinPrevAnimElements]
          end
          if metadataSkinPrevObjAnim == nil then
               previewMetadataObject['animations'] = constantSkinPrevObjAnim
               return constantSkinPrevObjAnim
          end
          if metadataSkinPrevObjAnim[animationName] == nil then
               previewMetadataObject['animations'][animationName] = constantSkinPrevObjAnim[skinAnim]
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
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewConfirmAnim.name, metadataPreviewConfirmAnim.prefix, previewMetadataByConfirmFrames)
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewPressedAnim.name, metadataPreviewPressedAnim.prefix, previewMetadataByPressedFrames)
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewColoredAnim.name, metadataPreviewColoredAnim.prefix, previewMetadataByColoredFrames)
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewStrumsAnim.name,  metadataPreviewStrumsAnim.prefix,  previewMetadataByStrumsFrames)

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
          playAnim(previewSkinGroupTag, self.previewConstDataPreviewAnims['names']['strums'][strumIndex])
          setObjectCamera(previewSkinGroupTag, 'camHUD')
          addLuaSprite(previewSkinGroupTag)

          SkinNoteSave:set('previewMetadataByObjectStrums', F"{self.stateClass}Static", previewMetadataObjectAnims('strums', strumIndex, true))
          SkinNoteSave:set('previewMetadataByFramesStrums', F"{self.stateClass}Static", metadataPreviewStrumsFrames)
          SkinNoteSave:set('previewMetadataBySize', F"{self.stateClass}Static", metadataPreviewSize)
          SkinNoteSave:set('previewSkinImagePath', F"{self.stateClass}Static", previewSkinGroupSprite)
     end
     setTextString('genInfoSkinName', currentPreviewDataNames)
     self:preview_animation(true)
end

--- Creates the preview strums' animations.
---@param loadAnim? boolean Forcefully load the current skin animations, mainly for visual fixing purposes.
---@return nil
function SkinNotesPreview:preview_animation(loadAnim)
     local loadAnim = loadAnim ~= nil and true or false

     local firstJustPressed  = callMethodFromClass('flixel.FlxG', 'keys.firstJustPressed', {''})
     local firstJustReleased = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})
     local firstJustInputPressed  = firstJustPressed  ~= -1 and firstJustPressed  ~= nil
     local firstJustInputReleased = firstJustReleased ~= -1 and firstJustReleased ~= nil
     local firstJustInputs        = firstJustInputPressed or firstJustInputReleased
     if not firstJustInputs and loadAnim == false then
          return
     end

     --- Gets the skin's object data from the currently selected skin.
     ---@param skinObjects table The object to retreive its data.
     ---@return any
     local function currentPreviewSkinData(skinObjects)
          if self.selectSkinCurSelectedIndex == 0 or self.totalSkins[self.selectSkinCurSelectedIndex] == nil then
               return skinObjects[1][1] -- default value
          end

          for skinPages = 1, self.totalSkinLimit do -- checks if each page has an existing skin object
               local selectedSkinPage  = self.totalSkinObjectIndexes[skinPages]
               local selectedSkinIndex = table.find(selectedSkinPage, self.selectSkinCurSelectedIndex)
               if selectedSkinIndex ~= nil then
                    return skinObjects[skinPages][selectedSkinIndex]
               end
          end
     end

     local conditionPressedLeft  = keyboardJustConditionPressed('Z', not getVar('skinSearchInputFocus'))
     local conditionPressedRight = keyboardJustConditionPressed('X', not getVar('skinSearchInputFocus'))
     local currentPreviewMetadataPrev = currentPreviewSkinData(self.totalMetadataObjectPreview)

     --- Same as the previous function above, helper function; this retreives mainly its animation from its JSON.
     ---@param animationName string The name of the animation metadata to be fetch.
     ---@param strumIndex number The strum index number to cycle each value.
     ---@return table
     local function previewMetadataObjectAnims(animationName, strumIndex)
          local metadataSkinPrevObj     = currentPreviewMetadataPrev
          local metadataSkinPrevObjAnim = currentPreviewMetadataPrev.animations
          
          local constantSkinPrevObjAnimNames = self.previewConstDataPreviewAnims['names'][animationName]
          local constantSkinPrevObjAnim      = self.previewStaticDataPreview.animations

          local skinPrevAnimElements = constantSkinPrevObjAnimNames[strumIndex]
          if metadataSkinPrevObj == '@void' or metadataSkinPrevObjAnim == nil then
               return constantSkinPrevObjAnim[animationName][skinPrevAnimElements]
          end
          if metadataSkinPrevObjAnim[animationName] == nil then
               previewMetadataObject['animations'][animationName] = constantSkinPrevObjAnim[animationName]
               return constantSkinPrevObjAnim[animationName][skinPrevAnimElements]
          end
          return metadataSkinPrevObjAnim[animationName][skinPrevAnimElements]
     end

     for strumIndex = 1, 4 do
          local metadataPreviewAnimations = {
               confirm = previewMetadataObjectAnims('confirm', strumIndex),
               pressed = previewMetadataObjectAnims('pressed', strumIndex),
               colored = previewMetadataObjectAnims('colored', strumIndex),
               strums  = previewMetadataObjectAnims('strums',  strumIndex)
          }

          local previewSkinGroupTag   = F"previewSkinGroup{self.stateClass:upperAtStart()}-{strumIndex}"
          local previewSkinAnimations = self.previewAnimationObjectPrevAnims[self.previewAnimationObjectIndex]

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
          if keyboardJustConditionPressed(getKeyBinds(strumIndex), not getVar('skinSearchInputFocus')) then
               playAnim(previewSkinGroupTag, metadataPreviewAnimations[previewSkinAnimations]['name'], true)
          end
          if keyboardJustConditionReleased(getKeyBinds(strumIndex), not getVar('skinSearchInputFocus')) then
               playAnim(previewSkinGroupTag, metadataPreviewAnimations['strums']['name'], true)
          end
          ::SKIP_PREVIEW_ANIMATIONS::
     end
end

--- Collection group of preview strum selection methods.
---@return nil
function SkinNotesPreview:preview_selection()
     self:preview_selection_moved()
     self:preview_selection_byclick()
     self:preview_selection_byhover()
     self:preview_selection_bycursor()
end

local previewSelectionToggle = false -- * Important, but ignore this lmao
--- Main preview strum animation selecting functionality.
--- Allowing the selecting of specific strum animations, for visual aid purposes.
---@return nil
function SkinNotesPreview:preview_selection_moved()
     local conditionPressedLeft  = keyboardJustConditionPressed('Z', not getVar('skinSearchInputFocus'))
     local conditionPressedRight = keyboardJustConditionPressed('X', not getVar('skinSearchInputFocus'))

     local previewAnimationMinIndex = self.previewAnimationObjectIndex > 1
     local previewAnimationMaxIndex = self.previewAnimationObjectIndex < #self.previewAnimationObjectPrevAnims
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

     if not previewAnimationMinIndex then
          playAnim('previewSkinInfoIconLeft', 'none', true)
          playAnim('previewSkinInfoIconRight', 'right', true)
     else
          playAnim('previewSkinInfoIconLeft', 'left', true)
     end
     if not previewAnimationMaxIndex then
          playAnim('previewSkinInfoIconLeft', 'left', true)
          playAnim('previewSkinInfoIconRight', 'none', true)
     else
          playAnim('previewSkinInfoIconRight', 'right', true)
     end

     local previewSkinAnimations = self.previewAnimationObjectPrevAnims[self.previewAnimationObjectIndex]
     setTextString('previewSkinButtonSelectionText', previewSkinAnimations:upperAtStart())
end

--- Main preview strum button clicking functionality and animations.
--- Allowing the selecting of the corresponding skin in gameplay.
---@return nil
function SkinNotesPreview:preview_selection_byclick()
     ---@enum DIRECTION
     local DIRECTION = {
          LEFT  = 1,
          RIGHT = 2
     }
     local function previewSelectionButtonClick(directIndex, directName, iteration)
          local previewSkinButtonTag = F"previewSkinButton{directName:upperAtStart()}"

          local byPreviewButtonClick   = clickObject(previewSkinButtonTag, 'camHUD')
          local byPreviewButtonRelease = mouseReleased('left')
          
          if byPreviewButtonClick == true and self.previewAnimationObjectClicked[directIndex] == false then
               playAnim(previewSkinButtonTag, 'hovered-pressed', true)
               self.previewAnimationObjectClicked[directIndex] = true
          end
          if byPreviewButtonRelease == true and self.previewAnimationObjectClicked[directIndex] == true then
               playAnim(previewSkinButtonTag, 'static', true)
               playSound('ding', 0.5)

               self.previewAnimationObjectIndex          = self.previewAnimationObjectIndex + iteration
               self.previewAnimationObjectClicked[directIndex] = false
               self:preview_animation(true)

               SkinNoteSave:set('previewObjectIndex', self.stateClass, self.previewAnimationObjectIndex)
          end
     end

     local previewAnimationMinIndex = self.previewAnimationObjectIndex > 1
     local previewAnimationMaxIndex = self.previewAnimationObjectIndex < #self.previewAnimationObjectPrevAnims
     if previewAnimationMinIndex == true then
          previewSelectionButtonClick(DIRECTION.LEFT, 'left', -1)
     end
     if previewAnimationMaxIndex == true then
          previewSelectionButtonClick(DIRECTION.RIGHT, 'right', 1)
     end
end

--- Main preview strum button hovering functionality and animations.
--- Allowing the cursor's sprite to change its corresponding sprite when hovering for visual aid.
---@return nil
function SkinNotesPreview:preview_selection_byhover()
     ---@enum DIRECTION
     local DIRECTION = {
          LEFT  = 1,
          RIGHT = 2
     }
     local function previewSelectionButtonHover(directIndex, directName)
          local previewSkinButtonTag = F"previewSkinButton{directName:upperAtStart()}"
          if self.previewAnimationObjectClicked[directIndex] == true then
               return
          end

          if hoverObject(previewSkinButtonTag, 'camHUD') == true then
               self.previewAnimationObjectHovered[directIndex] = true
          end
          if hoverObject(previewSkinButtonTag, 'camHUD') == false then
               self.previewAnimationObjectHovered[directIndex] = false
          end

          if self.previewAnimationObjectHovered[directIndex] == true then
               playAnim(previewSkinButtonTag, 'hovered-static', true)
          end
          if self.previewAnimationObjectHovered[directIndex] == false then
               playAnim(previewSkinButtonTag, 'static', true)
          end
     end

     local previewAnimationMinIndex = self.previewAnimationObjectIndex > 1
     local previewAnimationMaxIndex = self.previewAnimationObjectIndex < #self.previewAnimationObjectPrevAnims
     if previewAnimationMinIndex == true then
          previewSelectionButtonHover(DIRECTION.LEFT, 'left')
     else
          playAnim('previewSkinButtonLeft', 'hovered-blocked', true)
          self.previewAnimationObjectHovered[DIRECTION.LEFT] = false
     end
     if previewAnimationMaxIndex == true then
          previewSelectionButtonHover(DIRECTION.RIGHT, 'right')
     else
          playAnim('previewSkinButtonRight', 'hovered-blocked', true)
          self.previewAnimationObjectHovered[DIRECTION.RIGHT] = false
     end
end

--- Main cursor functionality for the preview strum and its animations.
--- Allowing the cursor's sprite to change depending on its interaction (i.e. selecting and hovering).
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