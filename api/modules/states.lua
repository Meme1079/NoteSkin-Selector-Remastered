local F       = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string  = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table   = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json    = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local global  = require 'mods.NoteSkin Selector Remastered.api.modules.global'

---@enum ELEMENTS
local ELEMENTS = {
     SKINS = 'skins',
     NAMES = 'names',
     IDS   = 'ids',
     BOOLS = 'bools'
}
---@enum DATA
local DATA = {
     NAMES = 'names',
     IDS   = 'ids'
}

local MAX_NUMBER_CHUNK    = global.MAX_NUMBER_CHUNK
local MAX_ALLOCATED_SPACE = global.MAX_ALLOCATED_SPACE

---@module
local states = {
     notes    = {prefix = 'NOTE_assets',  folder = 'noteSkins'},
     splashes = {prefix = 'noteSplashes', folder = 'noteSplashes'}
}

--- Gets the current total amount skins contain within an array.
---@param skin string The specified skin to get its current total amount.
---@param withPath? boolean Includes the skins directory path.
---@return string[]
function states.getTotalSkins(skin, withPath)
     local totalSkins = table.new(MAX_ALLOCATED_SPACE, 0)
     local totalSkinPrefix = states[skin]['prefix']
     local totalSkinFolder = states[skin]['folder']

     local directorySkinLocalFolderPath = F"assets/shared/images/{totalSkinFolder}"
     local directorySkinLocalFolder     = directoryFileList(directorySkinLocalFolderPath)
     for _,skins in ipairs(directorySkinLocalFolder) do
          local skinMatchFile    = F"^({totalSkinPrefix}%-.+)%.png$"
          local skinMatchDefault = F"^({totalSkinPrefix})%.png$"
          local skinIncludedPath = F"{directorySkinLocalFolderPath}/"
          if skins:match(skinMatchFile) then
               local includedPath = withPath == true and skinIncludedPath or ''
               totalSkins[#totalSkins + 1] = includedPath..skins:match(skinMatchFile)
          elseif skins:match(skinMatchDefault) then
               local includedPath = withPath == true and skinIncludedPath or ''
               table.insert(totalSkins, 1, includedPath..skins:match(skinMatchDefault))
          end
     end
     
     local directorySkinFolderGroup = table.new(MAX_ALLOCATED_SPACE, 0)
     local directorySkinFolderPath  = F"mods/NoteSkin Selector Remastered/images/{totalSkinFolder}"
     local directorySkinFolder      = directoryFileList(directorySkinFolderPath)
     for _,skins in ipairs(directorySkinFolder) do
          local skinMatchFile    = F"^({totalSkinPrefix}%-.+)%.png$"
          local skinMatchDefault = F"^({totalSkinPrefix})%.png$"
          local skinIncludedPath = F"{totalSkinFolder}/"
          if skins:match(skinMatchFile) then
               local includedPath = withPath == true and skinIncludedPath or ''
               totalSkins[#totalSkins + 1] = includedPath..skins:match(skinMatchFile)
          elseif skins:match(skinMatchDefault) then
               local includedPath = withPath == true and skinIncludedPath or ''
               table.insert(totalSkins, 1, includedPath..skins:match(skinMatchDefault))
          end 
          if not skins:match('%.%w+$') then
               table.insert(directorySkinFolderGroup, skins)
          end
     end

     for _,folders in ipairs(directorySkinFolderGroup) do
          local directorySkinSubFolderPath = F"mods/NoteSkin Selector Remastered/images/{totalSkinFolder}/{folders}"
          local directorySkinSubFolder     = directoryFileList(directorySkinSubFolderPath)

          for _,skins in ipairs(directorySkinSubFolder) do
               local skinMatchFile    = F"^({totalSkinPrefix}%-.+)%.png$"
               local skinMatchDefault = F"^({totalSkinPrefix})%.png$"
               local skinIncludedPath = F"{totalSkinFolder}/{folders}/"
               if skins:match(skinMatchFile) then
                    local includedPath = withPath == true and skinIncludedPath or F"{folders}/"
                    totalSkins[#totalSkins + 1] = includedPath..skins:match(skinMatchFile)
               elseif skins:match(skinMatchDefault) then
                    local includedPath = withPath == true and skinIncludedPath or F"{folders}/"
                    table.insert(totalSkins, 1, includedPath..skins:match(skinMatchDefault))
               end
          end
     end
     return totalSkins
end

--- Gets each name of the total amount of skins contain within an array.
---@param skin string The specified skin to get each name of the skin.
---@return string[]
function states.getTotalSkinNames(skin)
     local totalSkins = table.new(MAX_ALLOCATED_SPACE, 0)
     local totalSkinPrefix = states[skin]['prefix']
     local totalSkinFolder = states[skin]['folder']

     local directorySkinLocalFolderPath = F"assets/shared/images/{totalSkinFolder}"
     local directorySkinLocalFolder     = directoryFileList(directorySkinLocalFolderPath)
     for _,skins in ipairs(directorySkinLocalFolder) do
          local skinMatchFile    = F"^({totalSkinPrefix}%-.+)%.png$"
          local skinMatchName    = F"^{totalSkinPrefix}%-(.+)%.png$"
          local skinMatchDefault = F"^({totalSkinPrefix})%.png$"
          if skins:match(skinMatchFile) then
               totalSkins[#totalSkins + 1] = skins:match(skinMatchName):upperAtStart()
          elseif skins:match(skinMatchDefault) then
               table.insert(totalSkins, 1, 'Funkin')
          end
     end

     local directorySkinFolderGroup = table.new(MAX_ALLOCATED_SPACE, 0)
     local directorySkinFolderPath  = F"mods/NoteSkin Selector Remastered/images/{totalSkinFolder}"
     local directorySkinFolder      = directoryFileList(directorySkinFolderPath)
     for _,skins in ipairs(directorySkinFolder) do
          local skinMatchFile = F"^({totalSkinPrefix}%-.+)%.png$"
          local skinMatchName = F"^{totalSkinPrefix}%-(.+)%.png$"
          if skins:match(skinMatchFile) then
               totalSkins[#totalSkins + 1] = skins:match(skinMatchName):upperAtStart()
          end
          if not skins:match('%.%w+$') then
               table.insert(directorySkinFolderGroup, skins)
          end
     end

     for _,folders in ipairs(directorySkinFolderGroup) do
          local directorySkinSubFolderPath = F"{directorySkinFolderPath}/{folders}"
          local directorySkinSubFolder     = directoryFileList(directorySkinSubFolderPath)
          for _,skins in next, directorySkinSubFolder do
               local skinMatchFile = F"^({totalSkinPrefix}%-.+)%.png$"
               local skinMatchName = F"^{totalSkinPrefix}%-(.+)%.png$"
               if skins:match(skinMatchFile) then
                    totalSkins[#totalSkins + 1] = skins:match(skinMatchName):upperAtStart()
               end
          end
     end
     return totalSkins
end

--- Gets the maximum page limit, that's it.
---@param skin string The specified skin to get its maximum page limit.
---@return number
function states.getTotalPageLimit(skin)
     local totalLimit = 1
     local totalSkins = states.getTotalSkins(skin)
     for skins = 1, #totalSkins do
          if skins % (MAX_NUMBER_CHUNK+1) == 0 then
               totalLimit = totalLimit + 1
          end
     end
     return totalLimit
end

--- Gets certain element properties for each corresponding skins, which is used for interactions.
--- Each skins are contain within an array corresponding to their page.
---@param skin string The specified skin to get its specific elements.
---@param elements ELEMENTS The specified element property for each skin to inherit.
---@return table[any[]]
function states.getTotalSkinObjects(skin, elements)
     local elements = elements == nil and 'skins' or elements:lower()

     local totalSkinGroupIndex = 0
     local totalSkinObjects = table.new(0, 2) --* change this, if new state has been added
     totalSkinObjects[skin] = table.new(MAX_ALLOCATED_SPACE, 0)

     local totalSkins     = states.getTotalSkins(skin)
     local totalSkinNames = states.getTotalSkinNames(skin)
     for objects = 1, #totalSkins do
          if (objects-1) % MAX_NUMBER_CHUNK == 0 then --! leave this weird code alone, it might break everything I loved
               totalSkinGroupIndex = totalSkinGroupIndex + 1
               totalSkinObjects[skin][totalSkinGroupIndex] = table.new(MAX_NUMBER_CHUNK, 0)
          end
          
          local totalSkinObjectGroup = totalSkinObjects[skin][totalSkinGroupIndex]
          if elements == ELEMENTS.SKINS then
               table.insert(totalSkinObjectGroup, totalSkins[objects])
          elseif elements == ELEMENTS.NAMES then
               table.insert(totalSkinObjectGroup, totalSkinNames[objects])
          elseif elements == ELEMENTS.IDS then
               table.insert(totalSkinObjectGroup, objects)
          elseif elements == ELEMENTS.BOOLS then
               table.insert(totalSkinObjectGroup, false)
          else
               error(F"Unidentified element argument: {elements}", 2)
          end
     end
     return totalSkinObjects[skin]
end

--- Calculates the positions for the corresponding range for each page.
--- If there's only a single page, it will cause a calculation error (due to dividing zero)
--- If the error occured, it must have condition check for multiple pages; preventing any weird stuff from happening.
---@param skin The specified skin to calculate the amount of positions.
---@return string<string, number[]>
function states.calculateScrollbarPositions(skin)
     local sliderTrackData = table.new(0, 3)
     sliderTrackData[skin] = {
          major = table.new(MAX_ALLOCATED_SPACE, 0), 
          minor = table.new(MAX_ALLOCATED_SPACE, 0), 
          pages = table.new(MAX_ALLOCATED_SPACE, 0)
     }

     local totalSkinMax = states.getTotalPageLimit(skin)-1
     local totalSliderHeight = 570
     for pages = 0, totalSkinMax+1 do
          local major = (pages / totalSkinMax) * totalSliderHeight
          local minor = ( (((pages-1) / totalSkinMax) + (pages / totalSkinMax)) / 2) * totalSliderHeight

          table.insert(sliderTrackData[skin]['major'], major + 127)
          table.insert(sliderTrackData[skin]['minor'], minor + 127)
          table.insert(sliderTrackData[skin]['pages'], pages + 1)
     end

     local overMajor = (totalSkinMax+1) * totalSliderHeight
     local overMinor = ((totalSkinMax-1) + (totalSkinMax/2)) * totalSliderHeight
     table.insert(sliderTrackData[skin]['major'], overMajor + 127)
     table.insert(sliderTrackData[skin]['minor'], overMinor + 127)
     table.remove(sliderTrackData[skin]['pages'], #sliderTrackData[skin]['pages'])
     return sliderTrackData[skin]
end

--- Calculates the nearest skin given by its input.
---@param skin string The specified skin to calculate the nearest skin.
---@param prefix string The prefix of said skin to search throughout its files.
---@param data DATA The specified data to be utilize with.
---@param withPath? boolean Includes the skins directory path.
---@return string[]|number[]
function states.calculateSearch(skin, prefix, data, withPath)
     local skinInputContent = getVar('SEARCH_INPUT_TEXT_CONTENT') or ''
     local skinListTotal    = states.getTotalSkins(skin, false)
     local skinMatchPattern = F"{prefix}%-"

     local skinSearchResult = table.new(MAX_ALLOCATED_SPACE, 0)
     for skinListTotalID = 1, #skinListTotal do
          local skinRawName   = skinListTotal[skinListTotalID]:match(F"{skinMatchPattern}(.+)")
          local skinRawFolder = skinListTotal[skinListTotalID]:match(F"(%w+/){skinMatchPattern}")
          local skinName   = skinRawName   == nil and 'funkin' or skinRawName
          local skinFolder = skinRawFolder == nil and ''       or skinRawFolder

          local skinInputContentFilter = skinInputContent:gsub('([%%%.%$%^%(%[])', '%%%1'):upper()
          local skinCapturedPosition   = skinName:upper():find(skinInputContentFilter)
          if skinCapturedPosition ~= nil then
               local skinFilePathName = skinFolder..skinMatchPattern:gsub('%%%-', '-')..skinName
               local skinFileName     = withPath == true and skinFilePathName or skinName

               local skinDefMatch   = skinFileName:match(F"{skinMatchPattern}funkin")
               local skinFileFilter = skinDefMatch == nil and skinFileName or skinMatchPattern:gsub('%%%-', '')
               skinSearchResult[skinListTotalID] = skinFileFilter
          end
     end

     local skinSearchData       = table.new(0, 2)
     local skinSearchDataResult = table.new(MAX_ALLOCATED_SPACE, 0)
     for ids, names in pairs(skinSearchResult) do
          if names ~= nil then
               skinSearchData['ids'], skinSearchData['names'] = ids, names
               table.insert(skinSearchDataResult, skinSearchData[DATA[data:upper()]])
          end
     end
     return skinSearchDataResult
end

--- Gets the current total amount of skin metadata directory path contain within an array.
---@param skin string The specified skin to get its current total amount.
---@param folder string The specified metadata folder to get the total amount.
---@return table<string, any>
function states.getTotalMetadataSkins(skin, folder)
     local totalSkins      = table.new(MAX_ALLOCATED_SPACE, 0)
     local totalSkinPrefix = states[skin]['prefix']
     local totalSkinFolder = states[skin]['folder']

     local directorySkinLocalFolderGroup = {'funkin.json'}
     local directorySkinLocalFolderPath  = F"assets/shared/images/{totalSkinFolder}"
     local directorySkinLocalFolder      = directoryFileList(directorySkinLocalFolderPath)
     for _,skins in ipairs(directorySkinLocalFolder) do
          local skinMatchFile = F"^({totalSkinPrefix}%-.+)%.png$"
          local skinMatchName = F"^{totalSkinPrefix}%-(.+)%.png$"
          if skins:match(skinMatchFile) then
               local skinName = skins:match(skinMatchName:gsub('%s', '_')):lower()
               table.insert(directorySkinLocalFolderGroup, F"{skinName}.json")
          end
     end

     local directoryMetadataFolderGroup = table.new(MAX_ALLOCATED_SPACE, 0)
     local directoryMetadataFolderPath  = F"mods/NoteSkin Selector Remastered/json/{skin}/{folder}"
     local directoryMetadataFolder      = directoryFileList(directoryMetadataFolderPath)
     for _,skins in ipairs(directoryMetadataFolder) do
          local files = skins:match('.-%.json$')
          if files then
               table.insert(totalSkins, F"json/{skin}/{folder}/{files}")
          end
          if not skins:match('%.%w+$') then
               table.insert(directoryMetadataFolderGroup, skins)
          end
     end

     for _,subfolders in ipairs(directoryMetadataFolderGroup) do
          local directoryMetadataSubFolderPath = F"mods/NoteSkin Selector Remastered/json/{skin}/{folder}/{subfolders}"
          local directoryMetadataSubFolder     = directoryFileList(directoryMetadataSubFolderPath)
          for _,skins in ipairs(directoryMetadataSubFolder) do
               local files = skins:match('.-%.json$')
               if files then
                    table.insert(totalSkins, F"json/{skin}/{folder}/{subfolders}/{files}")
               end
          end
     end

     table.sort(totalSkins, function(comp1, comp2)
          return comp1:match('%w+%.json$'):byte(1) < comp2:match('%w+%.json$'):byte(1)
     end)
     return totalSkins
end

--- Gets the current total amount of skin metadata contain within their corresponding page array.
---@param skin string The specified skin to get its current total amount.
---@param folder string The specified metadata folder to get the total amount.
---@param converted? boolean Converts the metadata directory path into a real JSON data.
---@return table[table[any]]
function states.getTotalMetadataSkinObjects(skin, folder, converted)
     local stateMetadataObjectNames  = table.new(MAX_ALLOCATED_SPACE, 0)
     local stateMetadataObjectDatas  = table.new(MAX_ALLOCATED_SPACE, 0)
     local stateMetadataObjectFolder = table.new(0, MAX_ALLOCATED_SPACE)
     local stateMetadataObjectPaths  = table.new(0, MAX_ALLOCATED_SPACE)

     local totalSkinObjectMetadataIndex = 0
     local totalSkinObjectMetadatas = table.new(0, MAX_ALLOCATED_SPACE)
     totalSkinObjectMetadatas[skin] = table.new(0, MAX_ALLOCATED_SPACE)

     local totalSkinNames     = states.getTotalSkinNames(skin)
     local totalSkinMetadatas = states.getTotalMetadataSkins(skin, folder)
     for objects = 1, #totalSkinNames do
          table.insert(stateMetadataObjectNames, objects, totalSkinNames[objects]:gsub('%s', '_'):lower())

          if totalSkinMetadatas[objects] ~= nil then
               stateMetadataObjectDatas[objects] = totalSkinMetadatas[objects]:match('.+/(.-)%.json')
               stateMetadataObjectFolder[stateMetadataObjectDatas[objects]] = totalSkinMetadatas[objects]:match('(.+/).-%.json')
          end
     end

     for nameIndex = 1, #stateMetadataObjectNames do
          for dataIndex = 1, #stateMetadataObjectDatas do 
               if stateMetadataObjectNames[nameIndex] == stateMetadataObjectDatas[dataIndex] then
                    goto SKIP_DUPLICATE
               end
          end
          stateMetadataObjectPaths[nameIndex] = stateMetadataObjectNames[nameIndex]
          ::SKIP_DUPLICATE::
     end

     for objects = 1, #stateMetadataObjectNames do
          if (objects-1) % MAX_NUMBER_CHUNK == 0 then --! DO NOT REMOVE PARENTHESIS
               totalSkinObjectMetadataIndex = totalSkinObjectMetadataIndex + 1
               totalSkinObjectMetadatas[skin][totalSkinObjectMetadataIndex] = table.new(MAX_NUMBER_CHUNK, 0)
          end
          if objects % MAX_NUMBER_CHUNK+1 ~= 0 then   --! DO NOT ADD PARENTHESIS
               local totalSkinObjectMetadataGroup     = totalSkinObjectMetadatas[skin][totalSkinObjectMetadataIndex]
               local totalSkinObjectMetadataFindIndex = table.find(stateMetadataObjectNames, stateMetadataObjectPaths[objects])

               if stateMetadataObjectNames[totalSkinObjectMetadataFindIndex] == nil then
                    local metadataNames  = stateMetadataObjectNames[objects]
                    local metadataFolder = stateMetadataObjectFolder[metadataNames]
                    local metadataPaths  = F"{metadataFolder}{metadataNames}.json"

                    local metadataValue = converted == true and json.parse(getTextFromFile(metadataPaths)) or metadataPaths
                    table.insert(totalSkinObjectMetadataGroup, metadataValue)
               else
                    totalSkinObjectMetadataGroup[#totalSkinObjectMetadataGroup + 1] = '@void'
               end
          end
     end
     return totalSkinObjectMetadatas[skin]
end

--- Same as the previous method, but it's stored within one big ass array.
---@see states.getTotalMetadataSkinObjects
---@param skin string The specified skin to get its current total amount.
---@param folder string The specified metadata folder to get the total amount.
---@param converted? boolean Converts the metadata directory path into a real JSON data.
---@return table[any[]]
function states.getTotalMetadataSkinObjectAll(skin, folder, converted) -- ipairs fixes somehow fixes a weird bug (T_T)
     local metadataOrderedSkins = {}
     for _,objects in ipairs(states.getTotalMetadataSkinObjects(skin, folder, converted)) do 
          for _,skins in ipairs(objects) do
               metadataOrderedSkins[#metadataOrderedSkins + 1] = skins
          end
     end
     return metadataOrderedSkins
end

--- Gets the current total amount of missing animations for each skin animations.
---@param skinAnim string[] The skin animation array to get for each missing animations.
---@param skinObjects table[table[any]] The skin preview metadata.
---@param skinLimit number The maximum page limit to loop throughout the skin preview metadata.
---@return table[table[any]]
function states.getTotalPreviewMissingAnimObjects(skinAnim, skinObjects, skinLimit)
     local totalPreviewMissingAnims = table.new(0, MAX_ALLOCATED_SPACE)
     local function insertPreviewMissingAnims(pages, previewIndex, previewValue)
          for skinAnimIndex = 1, #skinAnim do
               local skinAnimFilter  = skinAnim[skinAnimIndex]
               local skinAnimMissing = totalPreviewMissingAnims[pages][previewIndex]
               if previewValue['animations'] == nil then
                    skinAnimMissing[skinAnimFilter] = false
                    goto SKIP_PREVIEW_MISSING_METADATA
               end

               local previewValueAnimExists = previewValue['animations'][skinAnimFilter]
               skinAnimMissing[skinAnimFilter] = previewValueAnimExists == nil and true or false
               ::SKIP_PREVIEW_MISSING_METADATA::
          end
     end

     for pages = 1, skinLimit do
          totalPreviewMissingAnims[pages] = table.new(0, MAX_ALLOCATED_SPACE)
          for previewIndex, previewValue in pairs(skinObjects[pages]) do
               totalPreviewMissingAnims[pages][previewIndex] = table.new(0, MAX_ALLOCATED_SPACE)
               insertPreviewMissingAnims(pages, previewIndex, previewValue)
          end
     end
     return totalPreviewMissingAnims
end

return states