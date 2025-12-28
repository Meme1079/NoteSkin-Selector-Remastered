local F       = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string  = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local json    = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local global  = require 'mods.NoteSkin Selector Remastered.api.modules.global'

require 'table.new'

local MAX_NUMBER_CHUNK = 16

local states = {}
states.notes    = {prefix = 'NOTE_assets',  folder = 'noteSkins'}
states.splashes = {prefix = 'noteSplashes', folder = 'noteSplashes'}

--- Gets the total amount of skins it has.
---@param skin string The specified skin to find the total amount it currently has.
---@param withPath? boolean Wheather the result will include a path to the skin or not.
---@return table[table[string]]
function states.getTotalSkins(skin, withPath)
     local totalSkins = table.new(0xff, 0)
     local totalSkinPrefix = states[skin]['prefix']
     local totalSkinFolder = states[skin]['folder']

     local directorySkinLocalFolderPath = 'assets/shared/images/'..totalSkinFolder
     local directorySkinLocalFolder     = directoryFileList(directorySkinLocalFolderPath)
     for _,skins in next, directorySkinLocalFolder do
          if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               local includedPath = withPath == true and 'assets/shared/images/'..totalSkinFolder..'/' or ''
               totalSkins[#totalSkins + 1] = includedPath..skins:match('^('..totalSkinPrefix..'%-.+)%.png$')
          elseif skins:match('^('..totalSkinPrefix..')%.png$') then
               local includedPath = withPath == true and 'assets/shared/images/'..totalSkinFolder..'/' or ''
               table.insert(totalSkins, 1, includedPath..skins:match('^('..totalSkinPrefix..')%.png$'))
          end
     end

     local directorySkinFolderGroup = table.new(0xff, 0)
     local directorySkinFolderPath  = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder
     local directorySkinFolder      = directoryFileList(directorySkinFolderPath)
     for _,skins in next, directorySkinFolder do
          if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               local includedPath = withPath == true and totalSkinFolder..'/' or ''
               totalSkins[#totalSkins + 1] = includedPath..skins:match('^('..totalSkinPrefix..'%-.+)%.png$')
          elseif skins:match('^('..totalSkinPrefix..')%.png$') then
               local includedPath = withPath == true and totalSkinFolder..'/' or ''
               table.insert(totalSkins, 1, includedPath..skins:match('^('..totalSkinPrefix..')%.png$'))
          end 
          if not skins:match('%.%w+$') then
               table.insert(directorySkinFolderGroup, skins)
          end
     end

     for _,folders in next, directorySkinFolderGroup do
          local directorySkinSubFolderPath = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder..'/'..folders
          local directorySkinSubFolder     = directoryFileList(directorySkinSubFolderPath)

          for _,skins in next, directorySkinSubFolder do
               if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
                    local includedPath = withPath == true and totalSkinFolder..'/'..folders..'/' or folders..'/'
                    totalSkins[#totalSkins + 1] = includedPath..skins:match('^('..totalSkinPrefix..'%-.+)%.png$')
               elseif skins:match('^('..totalSkinPrefix..')%.png$') then
                    local includedPath = withPath == true and totalSkinFolder..'/'..folders..'/' or folders..'/'
                    table.insert(totalSkins, 1, includedPath..skins:match('^('..totalSkinPrefix..')%.png$'))
               end
          end
     end
     return totalSkins
end

--- Gets the total amount of skins it has and returns said names of the skin.
---@param skin string The specified skin to find the total amount it currently has.
---@return table[table[string]]
function states.getTotalSkinNames(skin)
     local totalSkins = table.new(0xff, 0)
     local totalSkinPrefix = states[skin]['prefix']
     local totalSkinFolder = states[skin]['folder']

     local directorySkinLocalFolderPath = 'assets/shared/images/'..totalSkinFolder
     local directorySkinLocalFolder     = directoryFileList(directorySkinLocalFolderPath)
     for _,skins in next, directorySkinLocalFolder do
          if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               totalSkins[#totalSkins + 1] = skins:match('^'..totalSkinPrefix..'%-(.+)%.png$'):upperAtStart()
          elseif skins:match('^('..totalSkinPrefix..')%.png$') then
               table.insert(totalSkins, 1, 'Funkin')
          end
     end

     local directorySkinFolderGroup = table.new(0xff, 0)
     local directorySkinFolderPath  = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder
     local directorySkinFolder      = directoryFileList(directorySkinFolderPath)
     for _,skins in next, directorySkinFolder do
          if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               totalSkins[#totalSkins + 1] = skins:match('^'..totalSkinPrefix..'%-(.+)%.png$'):upperAtStart()
          end
          if not skins:match('%.%w+$') then
               table.insert(directorySkinFolderGroup, skins)
          end
     end

     for _,folders in next, directorySkinFolderGroup do
          local directorySkinSubFolderPath = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder..'/'..folders
          local directorySkinSubFolder     = directoryFileList(directorySkinSubFolderPath)
          for _,skins in next, directorySkinSubFolder do
               if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
                    totalSkins[#totalSkins + 1] = skins:match('^'..totalSkinPrefix..'%-(.+)%.png$'):upperAtStart()
               end
          end
     end
     return totalSkins
end

--- Gets the maximum limit skin pages.
---@param skin string The specified skin to find the total amount it currently has.
---@return number
function states.getTotalSkinLimit(skin)
     local totalLimit = 1
     local totalSkins = states.getTotalSkins(skin)
     for page = 1, #totalSkins do
          if page % (16+1) == 0 then
               totalLimit = totalLimit + 1
          end
     end
     return totalLimit
end

---@alias byData string What metadata it should create for.
---| 'skins' # The skin's texture path
---| 'names' # The skin's name
---| 'ids'   # The skin's corresponding ID number
---| 'bools' # THe skin's togglable values

--- Gets multiple metadata properties for the data to be used for interaction.
--- Each data within metadata properties are spliced in every 16-index, inserted to their designated page array.
---@param skin string The specified skin to find the total amount it currently has.
---@param byData byData
---@return table[table[any]]
function states.getTotalSkinObjects(skin, byData)
     local byData = byData == nil and 'skins' or byData:lower()

     local totalSkinGroupIndex = 0
     local totalSkinObjects = table.new(0xff, 0)
     totalSkinObjects[skin] = table.new(0xff, 0)

     local totalSkins     = states.getTotalSkins(skin)
     local totalSkinNames = states.getTotalSkinNames(skin)
     for objects = 1, #totalSkins do
          if (objects-1) % 16 == 0 then --! DO NOT REMOVE PARENTHESIS
               totalSkinGroupIndex = totalSkinGroupIndex + 1
               totalSkinObjects[skin][totalSkinGroupIndex] = table.new(16, 0)
          end
     
          if objects % 16+1 ~= 0 then   --! DO NOT ADD PARENTHESIS
               local totalSkinObjectGroup = totalSkinObjects[skin][totalSkinGroupIndex]
               if byData == 'skins' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = totalSkins[objects]
               elseif byData == 'names' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = totalSkinNames[objects]
               elseif byData == 'ids' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = objects
               elseif byData == 'bools' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = false
               end
          end
     end
     return totalSkinObjects[skin]
end

--- Gets the skin's name each are spliced in every 16-index, inserted to their designated page array.
---@param skin string The specified skin to find the total amount it currently has.
---@return table[table[any]]
function states.getTotalSkinObjectNames(skin)
     local totalSkinObjectNameIndex = 0
     local totalSkinObjectNames = table.new(0xff, 0)
     totalSkinObjectNames[skin] = table.new(0xff, 0)

     local totalSkinNames = states.getTotalSkinNames(skin)
     for objects = 1, #totalSkinNames do
          if (objects-1) % 16 == 0 then --! DO NOT REMOVE PARENTHESIS
               totalSkinObjectNameIndex = totalSkinObjectNameIndex + 1
               totalSkinObjectNames[skin][totalSkinObjectNameIndex] = table.new(16, 0)
          end
     
          if objects % 16+1 ~= 0 then   --! DO NOT ADD PARENTHESIS
               local totalSkinObjectNameGroup = totalSkinObjectNames[skin][totalSkinObjectNameIndex]
               totalSkinObjectNameGroup[#totalSkinObjectNameGroup + 1] = totalSkinNames[objects]
          end
     end
     return totalSkinObjectNames[skin]
end

--- Gets the skin's index number each are spliced in every 16-index, inserted to their designated page array.
---@param skin string The specified skin to find the total amount it currently has.
---@return table[table[any]]
function states.getTotalSkinObjectIndexes(skin)
     local totalSkinObjectIndexesIndex = 0
     local totalSkinObjectIndexes = table.new(0xff, 0)
     totalSkinObjectIndexes[skin] = table.new(0xff, 0)

     local totalSkinNames = states.getTotalSkinNames(skin)
     for objects = 1, #totalSkinNames do
          if (objects-1) % 16 == 0 then --! DO NOT REMOVE PARENTHESIS
               totalSkinObjectIndexesIndex = totalSkinObjectIndexesIndex + 1
               totalSkinObjectIndexes[skin][totalSkinObjectIndexesIndex] = table.new(16, 0)
          end
     
          if objects % 16+1 ~= 0 then   --! DO NOT ADD PARENTHESIS
               local totalSkinObjectIndexesGroup = totalSkinObjectIndexes[skin][totalSkinObjectIndexesIndex]
               totalSkinObjectIndexesGroup[#totalSkinObjectIndexesGroup + 1] = objects
          end
     end
     return totalSkinObjectIndexes[skin]
end

--- Gets and calculates the positions for the slider functionality
--- If the current state has only one page, it will cause a calculation error, cuz of dividing zero.
--- If the error occured, it must have a piece of code to detect it to prevent visual bugs.
---@param skin The specified skin to contain the positions
---@return table[table[number]]
function states.getPageSkinSliderPositions(skin)
     local sliderTrackData = table.new(3, 0)
     sliderTrackData[skin] = {intervals = table.new(0xff, 0), semiIntervals = table.new(0xff, 0), pages = table.new(0xff, 0)}

     local totalSkinMax = states.getTotalSkinLimit(skin)-1
     local totalSliderHeight = 570
     for pages = 0, totalSkinMax+1 do
          local intervals     = (pages / totalSkinMax) * totalSliderHeight
          local semiIntervals = ( (((pages-1) / totalSkinMax) + (pages / totalSkinMax)) / 2) * totalSliderHeight

          table.insert(sliderTrackData[skin]['intervals'], intervals + 127)
          table.insert(sliderTrackData[skin]['semiIntervals'], semiIntervals + 127)
          table.insert(sliderTrackData[skin]['pages'], pages + 1)
     end

     local overIntervals     = (totalSkinMax + 1 / totalSkinMax) * totalSliderHeight
     local overSemiIntervals = ( (((totalSkinMax-1) / totalSkinMax) + (totalSkinMax / totalSkinMax)) / 2) * totalSliderHeight
     table.insert(sliderTrackData[skin]['intervals'], overIntervals + 127)
     table.insert(sliderTrackData[skin]['semiIntervals'], overSemiIntervals + 127)
     return sliderTrackData[skin]
end

--- Gets the total amount of skin metadata it has.
---@param skin string The specified skin to find the total amount of metadata it currently has.
---@param metadataFolder string The specified metadata folder to get the amount of metadata.
---@param converted? boolean An optional parameter, converts the JSON path into a real JSON data to utilize with.
---@return table<string, any>
function states.getMetadataSkins(skin, metadataFolder, converted)
     local totalSkins      = table.new(0xff, 0)
     local totalSkinPrefix = states[skin]['prefix']
     local totalSkinFolder = states[skin]['folder']

     local directorySkinLocalFolderGroup = {'funkin.json'}
     local directorySkinLocalFolderPath  = 'assets/shared/images/'..totalSkinFolder
     local directorySkinLocalFolder      = directoryFileList(directorySkinLocalFolderPath)
     for _,skins in next, directorySkinLocalFolder do
          if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               local skinName = skins:match('^'..totalSkinPrefix..'%-(.+)%.png$'):gsub('%s', '_'):lower()
               table.insert(directorySkinLocalFolderGroup, skinName..'.json')
          end
     end

     local directoryMetadataFolderGroup = table.new(0xff, 0)
     local directoryMetadataFolderPath  = 'mods/NoteSkin Selector Remastered/json/'..skin..'/'..metadataFolder
     local directoryMetadataFolder      = directoryFileList(directoryMetadataFolderPath)
     for _,skins in next, directoryMetadataFolder do
          if skins:match('.-%.json$') then
               local skinMetadataTemp = {skin = skin, metadata = metadataFolder, file = skins:match('.-%.json$')}
               local skinMetadata     = ('json/${skin}/${metadata}/${file}'):interpol(skinMetadataTemp)
               totalSkins[#totalSkins + 1] = skinMetadata
          end
          if not skins:match('%.%w+$') then
               table.insert(directoryMetadataFolderGroup, skins)
          end
     end

     for _,folders in next, directoryMetadataFolderGroup do
          local directoryMetadataSubFolderPath = 'mods/NoteSkin Selector Remastered/json/'..skin..'/'..metadataFolder..'/'..folders
          local directoryMetadataSubFolder     = directoryFileList(directoryMetadataSubFolderPath)
          for _,skins in next, directoryMetadataSubFolder do
               if skins:match('.-%.json$') then
                    local skinMetadataTemp = {skin = skin, metadata = metadataFolder, folder = folders, file = skins:match('.-%.json$')}
                    local skinMetadata     = ('json/${skin}/${metadata}/${folder}/${file}'):interpol(skinMetadataTemp)
                    totalSkins[#totalSkins + 1] = skinMetadata
               end
          end
     end

     table.sort(totalSkins) -- this table sort function is a heterosexual
     if converted == true then
          for objects, skins in next, totalSkins do
               if skins ~= '@void' then
                    totalSkins[objects] = json.parse(getTextFromFile(skins))
               end
          end
     end
     return totalSkins
end

--- Gets the skin's JSON in an ordered manner.
---@param skin string The specified skin to find the total amount of JSON data it currently has.
---@param metadataFolder string The specified metadata folder to get the amount of JSON data.
---@param converted boolean An optional parameter, converts the JSON path into a real JSON data to utilize with.
---@return table[table[any]]
function states.getMetadataSkinsOrdered(skin, metadataFolder, converted)
     local metadataOrderedSkins = {}
     for _,pages in next, states.getMetadataObjectSkins(skin, metadataFolder, converted) do
          for _,skins in next, pages do
               metadataOrderedSkins[#metadataOrderedSkins + 1] = skins
          end
     end
     return metadataOrderedSkins
end

--- Gets the skin's JSON each are spliced in every 16-index, inserted to their designated page array.
---@param skin string The specified skin to find the total amount of JSON data it currently has.
---@param metadataFolder string The specified metadata folder to get the amount of JSON data.
---@param converted? boolean An optional parameter, converts the JSON path into a real JSON data to utilize with.
---@return table[table[any]]
function states.getMetadataObjectSkins(skin, metadataFolder, converted)
     local stateMetadataObjectNames  = table.new(0xff, 0)
     local stateMetadataObjectDatas  = table.new(0xff, 0)
     local stateMetadataObjectFolder = table.new(0, 0xff) -- dictionary
     local stateMetadataObjectPaths  = table.new(0xff, 0)

     local totalSkinObjectMetadataIndex = 0
     local totalSkinObjectMetadatas = table.new(0xff, 0)
     totalSkinObjectMetadatas[skin] = table.new(0xff, 0)

     local totalSkinNames     = states.getTotalSkinNames(skin)
     local totalSkinMetadatas = states.getMetadataSkins(skin, metadataFolder)
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
                    goto skip_duplicate
               end
          end
          stateMetadataObjectPaths[nameIndex] = stateMetadataObjectNames[nameIndex]
          ::skip_duplicate::
     end

     for objects = 1, #stateMetadataObjectNames do
          if (objects-1) % 16 == 0 then --! DO NOT REMOVE PARENTHESIS
               totalSkinObjectMetadataIndex = totalSkinObjectMetadataIndex + 1
               totalSkinObjectMetadatas[skin][totalSkinObjectMetadataIndex] = table.new(16, 0)
          end
          if objects % 16+1 ~= 0 then   --! DO NOT ADD PARENTHESIS
               local totalSkinObjectMetadataGroup     = totalSkinObjectMetadatas[skin][totalSkinObjectMetadataIndex]
               local totalSkinObjectMetadataFindIndex = table.find(stateMetadataObjectNames, stateMetadataObjectPaths[objects])

               if stateMetadataObjectNames[totalSkinObjectMetadataFindIndex] == nil then
                    local metadataNames = stateMetadataObjectNames[objects]
                    local metadataPaths = stateMetadataObjectFolder[metadataNames]

                    if converted == true then
                         totalSkinObjectMetadataGroup[#totalSkinObjectMetadataGroup + 1] = json.parse(getTextFromFile(metadataPaths..metadataNames..'.json'))
                    else
                         totalSkinObjectMetadataGroup[#totalSkinObjectMetadataGroup + 1] = metadataPaths..metadataNames..'.json'
                    end
               else
                    totalSkinObjectMetadataGroup[#totalSkinObjectMetadataGroup + 1] = '@void'
               end
          end
     end
     return totalSkinObjectMetadatas[skin]
end

---
---@param previewSkinAnim table[any]
---@param previewSkinObjects table[any]
---@param skinLimit table[number]
---@return table[table[any]]
function states.getPreviewObjectMissingAnims(previewSkinAnim, previewSkinObjects, skinLimit)
     local totalPreviewMissingAnims = table.new(0, 0xff)
     for pages = 1, skinLimit do
          totalPreviewMissingAnims[pages] = table.new(0, 0xff)

          for previewIndex, previewValue in pairs(previewSkinObjects[pages]) do
               totalPreviewMissingAnims[pages][previewIndex] = table.new(0, 0xff)

               for animInd = 1, #previewSkinAnim do
                    local previewSkinAnimFilter = previewSkinAnim[animInd]
                    if previewValue['animations'] == nil then
                         totalPreviewMissingAnims[pages][previewIndex][previewSkinAnimFilter] = false
                         goto skip_previewMissingMetadata
                    end

                    if previewValue['animations'][previewSkinAnimFilter] == nil then
                         totalPreviewMissingAnims[pages][previewIndex][previewSkinAnimFilter] = true
                    else
                         totalPreviewMissingAnims[pages][previewIndex][previewSkinAnimFilter] = false
                    end
                    ::skip_previewMissingMetadata::
               end
          end
     end
     return totalPreviewMissingAnims
end

---@alias SkinData
---| 'ids'   # The ID of the skin.
---| 'names' # The name of the skin.

--- The heart of this method, see the method's description for reference.
---@param skin string The specified skin to find the total amount it currently has.
---@param skinPrefix string The specified skin prefix to be used for searching.
---@param skinData SkinData The present searched skin data to be used, either its: ID or name data.
---@param skinPath? boolean Include the skins relative file path or not.
---@return table The present skins from the given search input.
function states.calculateSearch(skin, skinPrefix, skinData, skinPath)
     local skinListTotal    = states.getTotalSkins(skin, false)
     local skinInputContent = getVar('skinSearchInput_textContent') or ''
     local skinMatchPattern = F"{skinPrefix}%-"

     local skinSearchResult = table.new(0xff, 0)
     for skinListTotalID = 1, #skinListTotal do
          local skinRawName   = skinListTotal[skinListTotalID]:match(F"{skinMatchPattern}(.+)")
          local skinRawFolder = skinListTotal[skinListTotalID]:match(F"(%w+/){skinMatchPattern}")
          local skinName   = skinRawName   == nil and 'funkin' or skinRawName
          local skinFolder = skinRawFolder == nil and ''       or skinRawFolder

          local skinInputContentFilter = skinInputContent:gsub('([%%%.%$%^%(%[])', '%%%1'):upper()
          local skinCapPatStartPos     = skinName:upper():find(skinInputContentFilter)
          if skinCapPatStartPos ~= nil and #table.keys(skinSearchResult) <= MAX_NUMBER_CHUNK then
               local skinFilePathName = skinFolder..skinMatchPattern:gsub('%%%-', '-')..skinName
               local skinFileName     = skinPath == true and skinFilePathName or skinName

               local skinDefMatch   = skinFileName:match(F"{skinMatchPattern}funkin")
               local skinFileFilter = skinDefMatch == nil and skinFileName or skinMatchPattern:gsub('%%%-', '')
               skinSearchResult[skinListTotalID] = skinFileFilter
          end
     end

     local skinSearchResultData = table.new(0xff, 0)
     for ids, names in pairs(skinSearchResult) do
          if names ~= nil and #table.keys(skinSearchResult) <= MAX_NUMBER_CHUNK then
               local skinDataValues    = {["ids"] = ids, ["names"] = names}
               local skinDataMetatable = {}
               function skinDataMetatable:__index()
                    return error("Invalid parameter value, either use: \"ids\" or \"names\"", 3)
               end
               skinSearchResultData[#skinSearchResultData+1] = setmetatable(skinDataValues, skinDataMetatable)[skinData]
          end
     end 
     return skinSearchResultData
end

return states