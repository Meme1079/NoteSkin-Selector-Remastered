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

local MAX_NUMBER_CHUNK = 16

--- Childclass extension, main search component functionality for the splash skin state.
---@class SkinSplashesSearch
local SkinSplashesSearch = {}

--- Creates a chunk gallery of available display skins to select from when searching.
---@return nil
function SkinSplashesSearch:search_create()
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

     ---@alias SkinData
     ---| 'ids'   # The ID of the skin.
     ---| 'names' # The name of the skin.

     --- The heart of this method, see the method's description for reference.
     ---@param skinData SkinData The present searched skin data to be used, either its: ID or name data.
     ---@param skinPath? boolean Include the skins relative file path or not.
     ---@return table The present skins from the given search input.
     local function calculateSearch(skinData, skinPath)
          local skinListTotal    = self.totalSkins
          local skinMatchPattern = self.statePrefix..'%-'
          local skinInputContent = skinSearchInput_textContent

          local skinSearchResult = {}
          for skinListTotalID = 1, #skinListTotal do
               local skinRawName   = skinListTotal[skinListTotalID]:match(skinMatchPattern..'(.+)')
               local skinRawFolder = skinListTotal[skinListTotalID]:match('(%w+/)'..skinMatchPattern)
               local skinName   = skinRawName   == nil and 'funkin' or skinRawName
               local skinFolder = skinRawFolder == nil and ''       or skinRawFolder

               local skinInputContentFilter = skinInputContent:gsub('([%%%.%$%^%(%[])', '%%%1'):upper()
               local skinCapPatStartPos     = skinName:upper():find(skinInputContentFilter)
               if skinCapPatStartPos ~= nil and #table.keys(skinSearchResult) <= MAX_NUMBER_CHUNK then
                    local skinFilePathName = skinFolder..skinMatchPattern:gsub('%%%-', '-')..skinName
                    local skinFileName     = skinPath == true and skinFilePathName or skinName

                    local skinDefMatch   = skinFileName:match(skinMatchPattern..'funkin')
                    local skinFileFilter = skinDefMatch == nil and skinFileName or match:gsub('%%%-', '')
                    skinSearchResult[skinListTotalID] = skinFileFilter
               end
          end

          local skinSearchResultData = {}
          for ids, names in pairs(skinSearchResult) do
               if names ~= nil and #table.keys(skinSearchResult) <= MAX_NUMBER_CHUNK then
                    local skinDataValues = {["ids"] = ids, ["names"] = names}
                    local skinDataMeta   = {
                         __index = function() 
                              return error("Invalid parameter value, either use: \"ids\" or \"names\"", 3)
                         end
                    }
                    skinSearchResultData[#skinSearchResultData+1] = setmetatable(skinDataValues, skinDataMeta)[skinData]
               end
          end 
          return skinSearchResultData
     end

     --- Calculates the display skins position.
     ---@return table[number]
     local function displaySkinPositions()
          local displaySkinIndexes   = {x = 0, y = 0}
          local displaySkinPositions = {}
          for displays = 1, MAX_NUMBER_CHUNK do
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
     local filterSearchByID   = calculateSearch('ids',   false)
     local filterSearchByName = calculateSearch('names', false)
     local filterSearchBySkin = calculateSearch('names', true)

     local currenMinPage = (self.selectSkinPagePositionIndex - 1) * MAX_NUMBER_CHUNK
     local currenMinPageIndex = currenMinPage == 0 and 1 or currenMinPage
     local currenMaxPageIndex = self.selectSkinPagePositionIndex * MAX_NUMBER_CHUNK

     local searchFilterSkinsDefault = table.tally(currenMinPageIndex, currenMaxPageIndex)
     local searchFilterSkinsTyped   = table.singularity(table.merge(filterSearchByID, searchFilterSkinsDefault), false)

     local searchFilterSkinsSubDefault = table.sub(searchFilterSkinsDefault, 1, MAX_NUMBER_CHUNK)
     local searchFilterSkinsSubTyped   = table.sub(searchFilterSkinsTyped, 1, MAX_NUMBER_CHUNK)
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
               if ids == MAX_NUMBER_CHUNK then 
                    return 
               end
          end
          self:save_selection()
     end
end

--- Creates the preview splashes' graphic sprites and its text when searching.
---@return nil
function SkinSplashesSearch:search_preview()
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

return SkinSplashesSearch