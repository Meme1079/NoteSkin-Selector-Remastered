luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.newglobal'

local MAX_NUMBER_CHUNK = global.MAX_NUMBER_CHUNK

local calculateSearch = states.calculateSearch

--- Childclass extension, main search component functionality for the splash skin state.
---@class SkinSplashesSearch
local SkinSplashesSearch = {}
local SkinSplashesGSave  = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

--- Creates a 4x4 chunk gallery of skins to select from while searching.
---@private
---@return nil
function SkinSplashesSearch:search_create()
     local SEARCH_INPUT_CONTENT = getVar('skinSearchInput_textContent') or ''
     local SEARCH_INPUT_FOCUS   = getVar('skinSearchInputFocus') or false
     local FIRST_JUST_RELEASED  = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})
     if FIRST_JUST_RELEASED  == -1 or  SEARCH_INPUT_FOCUS == false then -- optimization purposes
          return
     end
     if SEARCH_INPUT_CONTENT == '' and SEARCH_INPUT_FOCUS == true  then -- optimization purposes
          self:create(self.SCROLLBAR_PAGE_INDEX)
          return
     end
     
     for skinPages = 1, self.TOTAL_SKIN_LIMIT do
          for skinDisplays = 1, #self.TOTAL_SKIN_OBJECTS[skinPages] do
               if skinPages == skinIndex then
                    goto SKIP_SKIN_PAGE
               end

               local skinObjectID = self.TOTAL_SKIN_OBJECTS_ID[skinPages][skinDisplays]
               local displaySkinIconTagButton = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{skinObjectID}"
               local displaySkinIconTagSkin   = F"displaySkinIconSkin{self.stateClass:upperAtStart()}-{skinObjectID}"
               if luaSpriteExists(displaySkinIconTagButton) == true and luaSpriteExists(displaySkinIconTagSkin) == true then
                    removeLuaSprite(displaySkinIconTagButton, true)
                    removeLuaSprite(displaySkinIconTagSkin, true)
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

          local SKIN_ROW_MAX_LENGTH    = 4
          local SKIN_SEARCH_MAX_LENGTH = calculateSearch(self.stateClass, self.statePrefix, 'names', true)
          for skinDisplays = 1, #SKIN_SEARCH_MAX_LENGTH do
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

     local filterSearchByID   = calculateSearch(self.stateClass, self.statePrefix, 'ids', false)
     local filterSearchByName = calculateSearch(self.stateClass, self.statePrefix, 'names', false)
     local filterSearchBySkin = calculateSearch(self.stateClass, self.statePrefix, 'names', true)

     local currenMinPageRange = (self.SCROLLBAR_PAGE_INDEX - 1) * MAX_NUMBER_CHUNK
     local currenMaxPageRange = self.SCROLLBAR_PAGE_INDEX       * MAX_NUMBER_CHUNK
     currenMinPageRange = (currenMinPageRange == 0) and 1 or currenMinPageRange -- adjust for 1-based index

     local searchFilterSkinPageRange = table.tally(currenMinPageRange, currenMaxPageRange)
     local searchFilterSkinPresent   = table.singularity(table.merge(filterSearchByID, searchFilterSkinPageRange), false)
     local searchFilterSkinRange     = table.sub(searchFilterSkinPresent, 1, #filterSearchByName) -- adjust for present skins only
     self.SEARCH_SKIN_OBJECT_PRESENT = searchFilterSkinRange

     for skinSearchIndex, skinSearchIDs in pairs(searchFilterSkinRange) do
          local displaySkinIconTagButton = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{skinSearchIDs}"
          local displaySkinIconTagSkin   = F"displaySkinIconSkin{self.stateClass:upperAtStart()}-{skinSearchIDs}"
          local displaySkinIconPosX = displaySkinIconPositions()[skinSearchIndex][1]
          local displaySkinIconPosY = displaySkinIconPositions()[skinSearchIndex][2]
          makeAnimatedLuaSprite(displaySkinIconTagButton, 'ui/buttons/display_button', displaySkinIconPosX, displaySkinIconPosY)
          addAnimationByPrefix(displaySkinIconTagButton, 'static', 'static')
          addAnimationByPrefix(displaySkinIconTagButton, 'selected', 'selected')
          addAnimationByPrefix(displaySkinIconTagButton, 'blocked', 'blocked')
          addAnimationByPrefix(displaySkinIconTagButton, 'hover', 'hovered-static')
          addAnimationByPrefix(displaySkinIconTagButton, 'pressed', 'hovered-pressed')
          playAnim(displaySkinIconTagButton, 'static', true)
          scaleObject(displaySkinIconTagButton, 0.8, 0.8)
          setObjectCamera(displaySkinIconTagButton, 'camHUD')
          setProperty(F"{displaySkinIconTagButton}.antialiasing", false)
          addLuaSprite(displaySkinIconTagButton)

          --- Gets the skins' display metadata value, acts as a helper function.
          --- Checks for any missing values and replaces it with its default value.
          ---@param metadata string The metadata element to get its value.
          ---@param constant any The constant default value, if the metadata element is missing.
          ---@return any
          local function displaySkinMetadata(metadata, constant)
               local metaObjectsDisplay = self.TOTAL_SKIN_METAOBJ_ORDERED_DISPLAY[tonumber(skinSearchIDs)]
               if metaObjectsDisplay           == '@void' then return constant end
               if metaObjectsDisplay[metadata] == nil     then return constant end
               return metaObjectsDisplay[metadata]
          end
          local displaySkinMetadataFrames   = displaySkinMetadata('frames',   12)
          local displaySkinMetadataPrefixes = displaySkinMetadata('prefixes', 'note splash green 1')
          local displaySkinMetadataSize     = displaySkinMetadata('size',     {0.4, 0.4})
          local displaySkinMetadataOffsets  = displaySkinMetadata('offsets',  {0, 0})

          local DISPLAY_SKIN_POSITION_OFFSET_X = 16.5
          local DISPLAY_SKIN_POSITION_OFFSET_Y = 12
          local displaySkinIconPosOffsetX = displaySkinIconPosX + DISPLAY_SKIN_POSITION_OFFSET_X
          local displaySkinIconPosOffsetY = displaySkinIconPosY + DISPLAY_SKIN_POSITION_OFFSET_Y

          local displaySkinIconSkinSprite = F"{self.statePaths}/{filterSearchBySkin[skinSearchIndex]}"
          makeAnimatedLuaSprite(displaySkinIconTagSkin, displaySkinIconSkinSprite, displaySkinIconPosOffsetX, displaySkinIconPosOffsetY)
          scaleObject(displaySkinIconTagSkin, displaySkinMetadataSize[1], displaySkinMetadataSize[2])
          addAnimationByPrefix(displaySkinIconTagSkin, 'static', displaySkinMetadataPrefixes, displaySkinMetadataFrames, true)

          local DISPLAY_SKIN_OFFSET_X = getProperty(F"{displaySkinIconTagSkin}.offset.x")
          local DISPLAY_SKIN_OFFSET_Y = getProperty(F"{displaySkinIconTagSkin}.offset.y")
          local displaySkinIconOffsetX = DISPLAY_SKIN_OFFSET_X - displaySkinMetadataOffsets[1]
          local displaySkinIconOffsetY = DISPLAY_SKIN_OFFSET_Y + displaySkinMetadataOffsets[2]
          addOffset(displaySkinIconTagSkin, 'static', displaySkinIconOffsetX, displaySkinIconOffsetY)
          playAnim(displaySkinIconTagSkin, 'static')
          setObjectCamera(displaySkinIconTagSkin, 'camHUD')
          addLuaSprite(displaySkinIconTagSkin)

          if skinSearchIndex > #filterSearchBySkin then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    removeLuaSprite(displaySkinIconButton, true)
                    removeLuaSprite(displaySkinIconSkin, true)
               end
          end
          self:save_selection()
     end
     self:search_checkbox_sync()
end

--- Creates the preview strums' graphic sprites and text while searching.
---@private
---@return nil
function SkinSplashesSearch:search_preview()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
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
               local selectedSkinPage  = self.TOTAL_SKIN_OBJECTS_INDICES[skinPages]
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
     self:preview_animation(true)
end

return SkinSplashesSearch