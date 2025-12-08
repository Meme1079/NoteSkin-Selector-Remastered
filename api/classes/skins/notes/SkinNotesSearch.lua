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

local MAX_NUMBER_CHUNK = 16

--- Childclass extension, main searching component functionality for the note skin state.
---@class SkinNotesSearch
local SkinNotesSearch = {}

--- Collection group of search methods.
---@return nil
function SkinNotesSearch:search()
     self:search_create()
     self:search_skins()
     self:search_selection()
     self:search_checkbox_sync()
end

--- Calculates and searches the nearest skin from the given input to be loaded.
---@return nil
function SkinNotesSearch:search_skins()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent <= 0 then
          return
     end

     local justReleased = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})
     if not (justReleased ~= -1 and justReleased ~= nil and getVar('skinSearchInputFocus') == true) then
          return
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

     local skinInputContent   = skinSearchInput_textContent
     local skinInputContentID = calculateSearch('ids', false)
     local skinSearchIndex = 0
     for searchPage = 1, #self.totalSkinObjectID do
          local totalSkinObjectIDs     = self.totalSkinObjectID[searchPage]
          local totalSkinObjectMerge   = table.merge(totalSkinObjectIDs, skinInputContentID)
          local totalSkinObjectPresent = table.singularity(totalSkinObjectMerge, true)

          for curPresentIndex = 1, #totalSkinObjectPresent do
               skinSearchIndex = skinSearchIndex + 1
               self.searchSkinObjectIndex[skinSearchIndex] = totalSkinObjectPresent[curPresentIndex]
               self.searchSkinObjectPage[skinSearchIndex]  = searchPage
          end
     end
end

--- Creates a chunk gallery of available display skins to select from when searching.
---@return nil
function SkinNotesSearch:search_create()
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
          local displaySkinMetadata_frames   = displaySkinMetadataJSON == '@void' and 24           or (displaySkinMetadataJSON.frames   or 24)
          local displaySkinMetadata_prefixes = displaySkinMetadataJSON == '@void' and 'arrowUP'    or (displaySkinMetadataJSON.prefixes or 'arrowUP')
          local displaySkinMetadata_size     = displaySkinMetadataJSON == '@void' and {0.55, 0.55} or (displaySkinMetadataJSON.size     or {0.55, 0.55})
          local displaySkinMetadata_offsets  = displaySkinMetadataJSON == '@void' and {0, 0}       or (displaySkinMetadataJSON.offsets  or {0, 0})

          local displaySkinImageTemplate = {path = self.statePaths, skin = filterSearchBySkin[ids]}
          local displaySkinImage         = ('${path}/${skin}'):interpol(displaySkinImageTemplate)

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

--- Creates the preview strums' graphic sprites and its text when searching.
---@return nil
function SkinNotesSearch:search_preview()
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

--- Syncing of the position and offset of the selection highlight when searching, obviously for visual purposes.
---@return nil
function SkinNotesSearch:search_checkbox_sync()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerIDs = self.totalSkinObjectID[searchSkinPage]
          for checkboxIndex = 1, #self.checkboxSkinObjectType do
               local checkboxObjectTypes      = self.checkboxSkinObjectType[checkboxIndex]
               local checkboxObjectTypeTag    = self.checkboxSkinObjectType[checkboxIndex]:upperAtStart()
               local checkboxSkinIndex        = self.checkboxSkinObjectIndex[checkboxObjectTypes:lower()]
               local checkboxSkinIndexPresent = table.find(skinObjectsPerIDs, checkboxSkinIndex)
     
               local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = checkboxSkinIndex}
               local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
               if checkboxSkinIndex == self.selectSkinCurSelectedIndex or checkboxSkinIndex == checkboxSkinIndexPresent or luaSpriteExists(displaySkinIconButton) == true then
                    local displaySelectionHighlightX = ('displaySelection${select}.x'):interpol({select = checkboxObjectTypeTag})
                    local displaySelectionHighlightY = ('displaySelection${select}.y'):interpol({select = checkboxObjectTypeTag})
                    setProperty(displaySelectionHighlightX, getProperty(displaySkinIconButton..'.x'))
                    setProperty(displaySelectionHighlightY, getProperty(displaySkinIconButton..'.y'))
               end

               if checkboxSkinIndex == 0 or luaSpriteExists(displaySkinIconButton) == false then
                    removeLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
               else
                    addLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
               end
          end
     end

     if math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) == 0 then --! FAIL-SAFE; DO NOT DELETE
          for checkboxIndex = 1, #self.checkboxSkinObjectType do
               local checkboxObjectTypes   = self.checkboxSkinObjectType[checkboxIndex]
               local checkboxObjectTypeTag = self.checkboxSkinObjectType[checkboxIndex]:upperAtStart()
               local checkboxSkinIndex     = self.checkboxSkinObjectIndex[checkboxObjectTypes:lower()]

               local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = checkboxSkinIndex}
               local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)

               if checkboxSkinIndex == 0 or luaSpriteExists(displaySkinIconButton) == false then
                    removeLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
               else
                    addLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
               end
          end
     end
end

--- Collection group of search selection methods.
---@return nil
function SkinNotesSearch:search_selection()
     self:search_selection_byclick()
     self:search_selection_byhover()
     self:search_selection_cursor()
end

--- Main display skin button clicking functionality and animations.
--- Allowing the selecting of the corresponding skin in gameplay.
---@return nil
function SkinNotesSearch:search_selection_byclick()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerIDs      = self.totalSkinObjectID[searchSkinPage]
          local skinObjectsPerHovered  = self.totalSkinObjectHovered[searchSkinPage]
          local skinObjectsPerClicked  = self.totalSkinObjectClicked[searchSkinPage]
          local skinObjectsPerSelected = self.totalSkinObjectSelected[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          local displaySkinIconSkin     = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplate)
          local function displaySkinSelect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.selectSkinPreSelectedIndex == searchSkinIndex

               if byClick == true and skinObjectsPerClicked[searchSkinPresentIndex] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.selectSkinPreSelectedIndex = skinObjectsPerIDs[searchSkinPresentIndex]
                    self.selectSkinHasBeenClicked   = true

                    SkinNoteSave:set('selectSkinPreSelectedIndex', self.stateClass, self.selectSkinPreSelectedIndex)
                    skinObjectsPerClicked[searchSkinPresentIndex] = true
               end

               if byRelease == true and skinObjectsPerClicked[searchSkinPresentIndex] == true then
                    playAnim(displaySkinIconButton, 'selected', true)
     
                    self.selectSkinInitSelectedIndex = self.selectSkinCurSelectedIndex
                    self.selectSkinCurSelectedIndex  = skinObjectsPerIDs[searchSkinPresentIndex]
                    self.selectSkinPagePositionIndex = self.selectSkinPagePositionIndex
                    self.selectSkinHasBeenClicked    = false
                    
                    self:search_preview()
                    SkinNoteSave:set('selectSkinInitSelectedIndex', self.stateClass, self.selectSkinInitSelectedIndex)
                    SkinNoteSave:set('selectSkinCurSelectedIndex',  self.stateClass, self.selectSkinCurSelectedIndex)
                    skinObjectsPerSelected[searchSkinPresentIndex] = true
                    skinObjectsPerClicked[searchSkinPresentIndex]  = false
               end
          end
          local function displaySkinDeselect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.selectSkinPreSelectedIndex == searchSkinIndex
               if byClick == true and skinObjectsPerClicked[searchSkinPresentIndex] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.selectSkinPreSelectedIndex = skinObjectsPerIDs[searchSkinPresentIndex]
                    self.selectSkinHasBeenClicked   = true

                    SkinNoteSave:set('selectSkinPreSelectedIndex', self.stateClass, self.selectSkinPreSelectedIndex)
                    skinObjectsPerClicked[searchSkinPresentIndex] = true
               end

               if byRelease == true and skinObjectsPerClicked[searchSkinPresentIndex] == true then
                    playAnim(displaySkinIconButton, 'static', true)

                    self.selectSkinCurSelectedIndex = 0
                    self.selectSkinPreSelectedIndex = 0
                    self.selectSkinHasBeenClicked   = false

                    self:search_preview()
                    SkinNoteSave:set('selectSkinPreSelectedIndex', self.stateClass, self.selectSkinPreSelectedIndex)
                    SkinNoteSave:set('selectSkinCurSelectedIndex', self.stateClass, self.selectSkinCurSelectedIndex)
                    skinObjectsPerSelected[searchSkinPresentIndex] = false
                    skinObjectsPerClicked[searchSkinPresentIndex]  = false
                    skinObjectsPerHovered[searchSkinPresentIndex]  = false
               end
          end
          local function displaySkinAutoDeselect()
               self.selectSkinCurSelectedIndex = 0
               self.selectSkinPreSelectedIndex = 0
               self.selectSkinHasBeenClicked   = false

               self:search_preview()
               SkinNoteSave:set('selectSkinCurSelectedIndex', self.stateClass, self.selectSkinCurSelectedIndex)
               SkinNoteSave:set('selectSkinPreSelectedIndex', self.stateClass, self.selectSkinPreSelectedIndex)
               skinObjectsPerSelected[searchSkinPresentIndex] = false
               skinObjectsPerClicked[searchSkinPresentIndex]  = false
               skinObjectsPerHovered[searchSkinPresentIndex]  = false
          end

          local previewObjectCurAnim        = self.previewAnimationObjectPrevAnims[self.previewAnimationObjectIndex]
          local previewObjectMissingAnim    = self.previewAnimationObjectMissing[searchSkinPage][searchSkinPresentIndex]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]
          if skinObjectsPerSelected[searchSkinPresentIndex] == false and searchSkinIndex ~= self.selectSkinCurSelectedIndex and previewObjectCurMissingAnim == false then
               displaySkinSelect()
          end
          if skinObjectsPerSelected[searchSkinPresentIndex] == true then
               --displaySkinDeselect()
          end

          if skinObjectsPerSelected[searchSkinPresentIndex] == true and previewObjectCurMissingAnim == true then
               displaySkinAutoDeselect()
          end

          if searchSkinIndex == self.selectSkinInitSelectedIndex then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    playAnim(displaySkinIconButton, 'static', true)
               end

               self.selectSkinInitSelectedIndex = 0
               SkinNoteSave:set('selectSkinInitSelectedIndex', self.stateClass, self.selectSkinInitSelectedIndex)
               skinObjectsPerSelected[searchSkinPresentIndex]  = false
          end
     end
end

--- Main display skin button hovering functionality and animations.
--- Allowing the cursor's sprite to change its corresponding sprite when hovering for visual aid.
---@return nil
function SkinNotesSearch:search_selection_byhover()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerIDs      = self.totalSkinObjectID[searchSkinPage]
          local skinObjectsPerHovered  = self.totalSkinObjectHovered[searchSkinPage]
          local skinObjectsPerClicked  = self.totalSkinObjectClicked[searchSkinPage]
          local skinObjectsPerSelected = self.totalSkinObjectSelected[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if hoverObject(displaySkinIconButton, 'camHUD') == true then
               skinObjectsPerHovered[searchSkinPresentIndex] = true
          end
          if hoverObject(displaySkinIconButton, 'camHUD') == false then
               skinObjectsPerHovered[searchSkinPresentIndex] = false
          end

          local nonCurrentPreSelectedSkin = self.selectSkinPreSelectedIndex ~= searchSkinIndex
          local nonCurrentCurSelectedSkin = self.selectSkinCurSelectedIndex ~= searchSkinIndex
          if skinObjectsPerHovered[searchSkinPresentIndex] == true and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButton) == false then return end
               playAnim(displaySkinIconButton, 'hover', true)
          end
          if skinObjectsPerHovered[searchSkinPresentIndex] == false and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButton) == false then return end
               playAnim(displaySkinIconButton, 'static', true)
          end

          local previewObjectCurAnim        = self.previewAnimationObjectPrevAnims[self.previewAnimationObjectIndex]
          local previewObjectMissingAnim    = self.previewAnimationObjectMissing[searchSkinPage][searchSkinPresentIndex]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]
          if previewObjectCurMissingAnim == true then
               playAnim(displaySkinIconButton, 'blocked', true)
          end
     end
end

--- Main cursor functionality for the display skin button and its animations.
--- Allowing the cursor's sprite to change depending on its interaction (i.e. selecting and hovering).
---@return nil
function SkinNotesSearch:search_selection_cursor()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     if mouseClicked('left') or mousePressed('left') then 
          playAnim('mouseTexture', 'idleClick', true)
     else
          playAnim('mouseTexture', 'idle', true)
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerHovered  = self.totalSkinObjectHovered[searchSkinPage]
          local skinObjectsPerClicked  = self.totalSkinObjectClicked[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if hoverObject(displaySkinIconButton:gsub('%d+', tostring(self.selectSkinCurSelectedIndex)), 'camHUD') == true then
               goto skipSelectedSearchSkin -- disabled deselecting
          end

          if skinObjectsPerClicked[searchSkinPresentIndex] == true and luaSpriteExists(displaySkinIconButton) == true then
               playAnim('mouseTexture', 'handClick', true)
          end
          if skinObjectsPerHovered[searchSkinPresentIndex] == true and luaSpriteExists(displaySkinIconButton) == true then
               playAnim('mouseTexture', 'hand', true)
          end

          local previewObjectCurAnim        = self.previewAnimationObjectPrevAnims[self.previewAnimationObjectIndex]
          local previewObjectMissingAnim    = self.previewAnimationObjectMissing[searchSkinPage][searchSkinPresentIndex]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]
          if previewObjectCurMissingAnim == true then
               local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
               local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)

               if hoverObject(displaySkinIconButton, 'camHUD') == true then
                    if mouseClicked('left') then 
                         playSound('cancel') 
                    end

                    if mouseClicked('left') or mousePressed('left') then 
                         playAnim('mouseTexture', 'disabledClick', true)
                    else
                         playAnim('mouseTexture', 'disabled', true)
                    end
               end
          end
          ::skipSelectedSearchSkin::
     end
     
     if hoverObject('displaySliderIcon', 'camHUD') == true and self.totalSkinLimit == 1 then
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

return SkinNotesSearch