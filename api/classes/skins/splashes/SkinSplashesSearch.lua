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

--- Subclass dedicated for the search component for the splash skin state.
---@class SkinSplashesSearch
local SkinSplashesSearch = {}

--- Creates a 16 chunk display of the selected search skins.
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