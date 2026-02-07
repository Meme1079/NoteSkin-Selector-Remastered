luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local DIRECTION        = global.DIRECTION
local MAX_NUMBER_CHUNK = global.MAX_NUMBER_CHUNK

local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

--- Childclass extension, main preview splashes component functionality for the splash skin state.
---@class SkinSplashesPreview
local SkinSplashesPreview = {}
local SkinSplashesGSave   = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

--- Creates the preview strums' graphic sprites and text.
---@return nil
function SkinSplashesPreview:preview()
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

          local skinPrevAnimElements = constantSkinPrevObjAnimNames[strumIndex]
          if metadataSkinPrevObj == '@void' or metadataSkinPrevObjAnim == nil then
               return constantSkinPrevObjAnim[animationName][skinPrevAnimElements]
          end
          if metadataSkinPrevObjAnim == nil then
               metadataSkinPrevObj['animations'] = constantSkinPrevObjAnim
               return constantSkinPrevObjAnim
          end
          if metadataSkinPrevObjAnim[animationName] == nil then
               metadataSkinPrevObj['animations'][animationName] = constantSkinPrevObjAnim[animationName]
               return constantSkinPrevObjAnim[animationName][skinPrevAnimElements]
          end
          return metadataSkinPrevObjAnim[animationName][skinPrevAnimElements]
     end

     local metadataPreviewFrames = previewMetadataObject('frames')
     local metadataPreviewSize   = previewMetadataObject('size')

     local metadataPreviewNoteSplash1Frames = metadataPreviewFrames.note_splash1
     local metadataPreviewNoteSplash2Frames = metadataPreviewFrames.note_splash2
     for strumIndex = 1, 4 do
          local metadataPreviewNoteSplash1 = previewMetadataObjectAnims('note_splash1', strumIndex)
          local metadataPreviewNoteSplash2 = previewMetadataObjectAnims('note_splash2', strumIndex)

          local previewSkinGroupTag    = F"previewSkinGroup{self.stateClass:upperAtStart()}-{strumIndex}"
          local previewSkinGroupSprite = F"{self.statePaths}/{currentPreviewDataSkins}"

          local previewSkinPositionX = 790 + (105*(strumIndex - 1))
          local previewSkinPositionY = 135
          makeAnimatedLuaSprite(previewSkinGroupTag, previewSkinGroupSprite, previewSkinPositionX, previewSkinPositionY)
          scaleObject(previewSkinGroupTag, metadataPreviewSize[1], metadataPreviewSize[2])
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewNoteSplash1.name, metadataPreviewNoteSplash1.prefix, metadataPreviewNoteSplash1Frames, false)
          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewNoteSplash2.name, metadataPreviewNoteSplash2.prefix, metadataPreviewNoteSplash2Frames, false)

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
          addOffset(previewSkinGroupTag, metadataPreviewNoteSplash1.name, addMetadataPreviewOffset(metadataPreviewNoteSplash1))
          addOffset(previewSkinGroupTag, metadataPreviewNoteSplash2.name, addMetadataPreviewOffset(metadataPreviewNoteSplash2))
          playAnim(previewSkinGroupTag, self.PREVIEW_CONST_METADATA_PREVIEW_ANIMS['names']['note_splash1'][strumIndex])
          setObjectCamera(previewSkinGroupTag, 'camHUD')
          addLuaSprite(previewSkinGroupTag)
          setProperty(F"{previewSkinGroupTag}.visible", false)
     end
     setTextString('skinStatePreviewName', currentPreviewDataNames)
end

--- Creates the noteskin strums' graphic sprites for visual support.
---@return nil
function SkinSplashesPreview:preview_notes()
     local SEARCH_INPUT_TEXT_CONTENT = getVar('SEARCH_INPUT_TEXT_CONTENT') or ''
     if #SEARCH_INPUT_TEXT_CONTENT > 0 then
          return
     end
     if self.stateClass == 'notes' then
          return
     end

     local metadataPreviewStrums = self.PREV_NOTES_METAOBJ_STRUMS_ANIMS
     local metadataPreviewFrames = self.PREV_NOTES_METAOBJ_STRUMS_FRAMES
     local metadataPreviewSize   = self.PREV_NOTES_METAOBJ_STRUMS_SIZE
     for strumIndex = 1, 4 do
          local previewSkinGroupTag    = F"previewSkinGroupNotes-{strumIndex}"
          local previewSkinGroupSprite = self.PREV_NOTES_METAOBJ_STRUMS_PATH

          local previewSkinPositionX = 790 + (105*(strumIndex - 1))
          local previewSkinPositionY = 135
          makeAnimatedLuaSprite(previewSkinGroupTag, previewSkinGroupSprite, previewSkinPositionX, previewSkinPositionY)
          scaleObject(previewSkinGroupTag, metadataPreviewSize[1], metadataPreviewSize[2])

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
          local previewMetadataDirectIndices = self.PREVIEW_CONST_METADATA_PREVIEW_ANIMS_NOTES['names']['strums'][strumIndex]
          local metadataPreviewStrumNames    = metadataPreviewStrums[previewMetadataDirectIndices]['name']
          local metadataPreviewStrumPrefixes = metadataPreviewStrums[previewMetadataDirectIndices]['prefix']

          addAnimationByPrefix(previewSkinGroupTag, metadataPreviewStrumNames, metadataPreviewStrumPrefixes, metadataPreviewFrames)
          addOffset(previewSkinGroupTag, metadataPreviewStrumNames, addMetadataPreviewOffset(metadataPreviewStrums[previewMetadataDirectIndices]))
          playAnim(previewSkinGroupTag, previewMetadataDirectIndices)
          setObjectCamera(previewSkinGroupTag, 'camHUD')
          addLuaSprite(previewSkinGroupTag)
     end
end

--- Creates the preview strums' animations, for testing its animations for visual aid.
---@return nil
function SkinSplashesPreview:preview_animation()
     if SkinSplashesGSave:get('PREVIEW_TOGGLE_ANIM_STATUS', 'SAVE', true) == false then
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
               previewMetadataObject['animations'][animationName] = constantSkinPrevObjAnim[animationName]
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
               note_splash1 = previewMetadataObjectAnims('note_splash1', strumIndex),
               note_splash2 = previewMetadataObjectAnims('note_splash2', strumIndex)
          }
          local previewSkinGroupTag   = F"previewSkinGroup{self.stateClass:upperAtStart()}-{strumIndex}"
          local previewSkinAnimations = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]

          if (conditionPressedLeft or conditionPressedRight) or mouseReleased('left') then
               setProperty(F"{previewSkinGroupTag}.visible", false)
          end
          if previewSkinObjectIsMissing() == false then
               if keyboardJustConditionPressed(getKeyBinds(strumIndex), not getVar('skinSearchInputFocus')) then
                    playAnim(previewSkinGroupTag, metadataPreviewAnimations[previewSkinAnimations]['name'], true)
                    setProperty(F"{previewSkinGroupTag}.visible", true)
               end
               if keyboardJustConditionReleased(getKeyBinds(strumIndex), not getVar('skinSearchInputFocus')) then
                    playAnim(previewSkinGroupTag, metadataPreviewAnimations['note_splash1']['name'], true)
                    setProperty(F"{previewSkinGroupTag}.visible", false)
               end
          end  
     end
end

--- Preview current animation name, that's literally it.
---@protected
---@return nil
function SkinSplashesPreview:preview_selection_name()
     local previewSkinAnimations    = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
     local previewSkinAnimationName = ''
     for prevSkinWords in previewSkinAnimations:gmatch('%w+') do
          local prevSkinWordsFilter = prevSkinWords:upperAtStart():gsub('_', ' '):gsub('(%w)(%d)', '%1 %2')
          previewSkinAnimationName = previewSkinAnimationName .. F"{prevSkinWordsFilter} "
     end

     previewSkinAnimationName = previewSkinAnimationName:sub(1, #previewSkinAnimationName-1)
     setTextString('previewSkinButtonSelectionText', previewSkinAnimationName)
end

return SkinSplashesPreview