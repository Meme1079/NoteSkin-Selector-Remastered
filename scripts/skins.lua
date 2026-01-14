luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local ease      = require 'mods.NoteSkin Selector Remastered.api.libraries.ease.ease'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local keyboardJustDoublePressed = funkinlua.keyboardJustDoublePressed

local stateSkinMetadata = {}
function stateSkinMetadata:__index(index)
     return '@void'
end

local SkinStateSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')
SkinStateSave:init()

local stateSave_checkboxNoteIndexPlayer   = SkinStateSave:get('CHECKBOX_SKIN_OBJECT_CHARS_PLAYER', 'NOTES', 0)
local stateSave_checkboxNoteIndexOpponent = SkinStateSave:get('CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT', 'NOTES', 0)
local stateSave_checkboxSplashIndexPlayer = SkinStateSave:get('CHECKBOX_SKIN_OBJECT_CHARS_PLAYER', 'SPLASHES', 0)

local skinStaticDataNotes    = json.parse(getTextFromFile('json/notes/constant/skins.json'))
local skinStaticDataSplashes = json.parse(getTextFromFile('json/splashes/constant/skins.json'))

local getTotalSkinNotes       = setmetatable(states.getTotalSkins('notes', true), stateSkinMetadata)
local getTotalSkinSplashes    = setmetatable(states.getTotalSkins('splashes', true), stateSkinMetadata)
local getMetadataSkinNotes    = setmetatable(states.getMetadataSkinsOrdered('notes', 'skins', true), stateSkinMetadata)
local getMetadataSkinSplashes = setmetatable(states.getMetadataSkinsOrdered('splashes', 'skins', true), stateSkinMetadata)

local getNoteSkinImagePathPlayer   = getTotalSkinNotes[stateSave_checkboxNoteIndexPlayer]
local getNoteSkinImagePathOpponent = getTotalSkinNotes[stateSave_checkboxNoteIndexOpponent]
local getNoteSkinMetadataPlayer    = getMetadataSkinNotes[stateSave_checkboxNoteIndexPlayer]
local getNoteSkinMetadataOpponent  = getMetadataSkinNotes[stateSave_checkboxNoteIndexOpponent]

local getSplashesSkinImagePathPlayer = getTotalSkinSplashes[stateSave_checkboxSplashIndexPlayer]
local getSplashesSkinMetadataPlayer  = getMetadataSkinSplashes[stateSave_checkboxSplashIndexPlayer]
local function filterSkinImagePath(str)
     local filterLocalPath = 'assets/shared/images/'
     if str:match(filterLocalPath) then
          return str:gsub(filterLocalPath, '')
     end
     return str
end

--- Gets the skin's metadata object value from the strum properties.
---@param skinStaticDataType table The static data type to use in-place, if no value exists.
---@param skinMetadataType table The metadata object type to use.
---@param strumData string The element from the strum properties to use.
---@return any
local function skinsMetadataObjectData(skinStaticDataType, skinMetadataType, strumData)
     local skinMetadataObject         = skinMetadataType
     local skinMetadataObjectByAnim   = skinMetadataType.strums
     local skinStaticDataObjectByAnim = skinStaticDataType.strums
     if skinMetadataObject == '@void' or skinMetadataObjectByAnim == nil then
          return skinStaticDataObjectByAnim[strumData]
     end
     if skinMetadataObjectByAnim == nil then
          skinMetadataObjectByAnim['strums'] = skinStaticDataObjectByAnim
          return skinMetadataObjectByAnim
     end
     if skinMetadataObjectByAnim[strumData] == nil then
          skinMetadataObjectByAnim['strums'][strumData] = skinStaticDataObjectByAnim[strumData]
          return skinMetadataObjectByAnim[strumData]
     end
     return skinMetadataObjectByAnim[strumData]
end

--- Gets the skin's metadata object value.
---@param skinStaticDataType table The static data type to use in-place, if no value exists.
---@param skinMetadataType table The metadata object type to use.
---@param element string The element to use.
---@return any
local function skinsMetadataObjects(skinStaticDataType, skinMetadataType, element)
     local skinsMetadataObject       = skinMetadataType
     local skinsMetadataObjectByElem = skinMetadataType[element]
     if skinsMetadataObject == '@void' or skinsMetadataObjectByElem == nil then
          return skinStaticDataType[element]
     end
     return skinsMetadataObjectByElem
end

local skinMetadataObjectNotes = {
     player = {
          strums    = {
               height  = skinsMetadataObjectData(skinStaticDataNotes, getNoteSkinMetadataPlayer, 'height'),
               offsetX = skinsMetadataObjectData(skinStaticDataNotes, getNoteSkinMetadataPlayer, 'offsetX')
          },
          types     = skinsMetadataObjects(skinStaticDataNotes, getNoteSkinMetadataPlayer, 'types'),
          rgbshader = skinsMetadataObjects(skinStaticDataNotes, getNoteSkinMetadataPlayer, 'rgbshader')
     },
     opponent = {     
          strums    = {
               height  = skinsMetadataObjectData(skinStaticDataNotes, getNoteSkinMetadataOpponent, 'height'),
               offsetX = skinsMetadataObjectData(skinStaticDataNotes, getNoteSkinMetadataOpponent, 'offsetX')
          },
          types     = skinsMetadataObjects(skinStaticDataNotes, getNoteSkinMetadataOpponent, 'types'),
          rgbshader = skinsMetadataObjects(skinStaticDataNotes, getNoteSkinMetadataOpponent, 'rgbshader')
     }
}
local skinMetadataObjectSplashes = {
     types     = skinsMetadataObjects(skinStaticDataSplashes, getSplashesSkinMetadataPlayer, 'types'),
     rgbshader = skinsMetadataObjects(skinStaticDataSplashes, getSplashesSkinMetadataPlayer, 'rgbshader')
}

local skinMetadataObjectNotePlayer   = skinMetadataObjectNotes.player
local skinMetadataObjectNoteOpponent = skinMetadataObjectNotes.opponent
local fliterSkinNotePathPlayer       = filterSkinImagePath( getNoteSkinImagePathPlayer )
local fliterSkinNotePathOpponent     = filterSkinImagePath( getNoteSkinImagePathOpponent )

local skinMetadataObjectSplashPlayer = skinMetadataObjectSplashes
local filterSkinSplashesPathPlayer   = filterSkinImagePath( getSplashesSkinImagePathPlayer )

--- Initiate the noteskin's texture setup on its strum's texture and shader availability.
--- This also initiates the splashskin's texture setup.
---@return nil
local function onInitSkinTexture()
     if getPropertyFromClass('states.PlayState', 'stageUI') == 'pixel' then
          return
     end
     
     for memberStrums = 0,3 do
          if getNoteSkinImagePathPlayer  ~= '@void' then
               setPropertyFromGroup('playerStrums', memberStrums, 'texture', fliterSkinNotePathPlayer)
               setPropertyFromGroup('playerStrums', memberStrums, 'useRGBShader', skinMetadataObjectNotePlayer.rgbshader)
          end
          if getNoteSkinImagePathOpponent ~= '@void' then
               setPropertyFromGroup('opponentStrums', memberStrums, 'texture', fliterSkinNotePathOpponent)
               setPropertyFromGroup('opponentStrums', memberStrums, 'useRGBShader', skinMetadataObjectNoteOpponent.rgbshader)
          end
     end

     for memberIndex = 0, getProperty('unspawnNotes.length')-1 do
          if filterSkinSplashesPathPlayer ~= '@void' then
               setPropertyFromGroup('unspawnNotes', memberIndex, 'noteSplashData.texture', filterSkinSplashesPathPlayer)
               setPropertyFromGroup('unspawnNotes', memberIndex, 'noteSplashData.useRGBShader', skinMetadataObjectSplashPlayer.rgbshader)
          end
     end
end

function onCreatePost()
     onInitSkinTexture()
end

function onCountdownStarted() -- A fail-safe, if initaiting the noteskin's texture setup fails this will be called
     onInitSkinTexture()
end

function onSpawnNote(memberIndex, noteData, noteType, isSustainNote, strumTime)
     if getPropertyFromClass('states.PlayState', 'stageUI') == 'pixel' then
          return
     end

     local songSpeed    = getProperty('songSpeed')
     local songPlayRate = getProperty('playbackRate')
     local noteSustainHeight = stepCrochet / 100 * 1.05 * songSpeed / songPlayRate

     local ultimateSwagWidth = getPropertyFromClass('objects.Note', 'swagWidth')
     local ultimateNoteWidth = getPropertyFromGroup('notes', memberIndex, 'width')
     local ultimateWidth     = (ultimateSwagWidth - ultimateNoteWidth) / 2

     --- Sets the note's sustain tail and tail-end properties to match properly
     ---@param skinMetadataObjectType table The metadata object type of the skin.
     ---@return nil
     local function setPropertySustainGroup(skinMetadataObjectType)
          if isSustainNote == false then
               return
          end
          setPropertyFromGroup('notes', memberIndex, 'offsetX', ultimateWidth - skinMetadataObjectType.strums.offsetX)

          local isTailName = getProperty('game.notes.members['..memberIndex..'].animation.curAnim.name')
          local isTailNote = stringEndsWith(isTailName, 'end')
          if not isTailNote then
               local sustainNoteHeight = noteSustainHeight / skinMetadataObjectType.strums.height % noteSustainHeight
               if skinMetadataObjectType.strums.height == 0 then --! IF NO VALUE ADDED; DO NOT DELETE 
                    setPropertyFromGroup('notes', memberIndex, 'scale.y', noteSustainHeight)
               else
                    setPropertyFromGroup('notes', memberIndex, 'scale.y', sustainNoteHeight)
               end
          end
     end

     if getPropertyFromGroup('notes', memberIndex, 'mustPress') then
          local isTypeExist = table.find(skinMetadataObjectNotePlayer.types, noteType)
          if getNoteSkinImagePathPlayer ~= '@void' and isTypeExist ~= nil then
               setPropertyFromGroup('notes', memberIndex, 'texture', fliterSkinNotePathPlayer);
               setPropertyFromGroup('notes', memberIndex, 'rgbShader.enabled', skinMetadataObjectNotePlayer.rgbshader)
               setPropertySustainGroup(skinMetadataObjectNotePlayer)
               updateHitboxFromGroup('notes', memberIndex)
          end
     else
          local isTypeExist = table.find(skinMetadataObjectNoteOpponent.types, noteType)
          if getNoteSkinImagePathOpponent ~= '@void' and isTypeExist ~= nil then
               setPropertyFromGroup('notes', memberIndex, 'texture', fliterSkinNotePathOpponent);
               setPropertyFromGroup('notes', memberIndex, 'rgbShader.enabled', skinMetadataObjectNoteOpponent.rgbshader)
               setPropertySustainGroup(skinMetadataObjectNoteOpponent)
               updateHitboxFromGroup('notes', memberIndex)
          end
     end
end

local function skinSelectionScreen()
     if getPropertyFromClass('states.PlayState', 'stageUI') == 'pixel' then
          debugPrint('Pixel skin support is not available in this version!', 'ff0000')
          return
     end

     SkinStateSave:set('dataSongName', '', songName)
     SkinStateSave:set('dataDiffID',   '', tostring(difficulty))
     SkinStateSave:set('dataDiffList', '', getPropertyFromClass('backend.Difficulty', 'list'))

     loadNewSong('Skin Selector', 2, {'Easy', 'Normal', 'Hard'})
end

function onUpdatePost(elapsed)
     if getModSetting('enable_double-tapping_safe', modFolder) == true then
          if keyboardJustDoublePressed('TAB') then
               skinSelectionScreen()
          end
     else
          if keyboardJustPressed('TAB') then
               skinSelectionScreen()
          end
     end
end