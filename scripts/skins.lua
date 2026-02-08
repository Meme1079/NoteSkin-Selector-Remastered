luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'

local keyboardJustDoublePressed = funkinlua.keyboardJustDoublePressed

local SkinStatesGSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')
SkinStatesGSave:init()

local skinMetadataVoid = {}
function skinMetadataVoid:__index()
     return '@void'
end

-- Skin State Variables --

local NOTES_CHECKBOX_SKIN_OBJECT_CHARS_PLAYER    = SkinStatesGSave:get('CHECKBOX_SKIN_OBJECT_CHARS_PLAYER', 'NOTES', 0)
local NOTES_CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT  = SkinStatesGSave:get('CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT', 'NOTES', 0)

local staticMetaConstSkinNotes   = json.parse(getTextFromFile('json/notes/constant/skins.json'))
local staticTotalSkinNotes       = states.getTotalSkins('notes', true)
local staticTotalMetaobjAllNotes = states.getTotalMetadataSkinObjectAll('notes', 'skins', true)
setmetatable(staticTotalSkinNotes, skinMetadataVoid)
setmetatable(staticTotalMetaobjAllNotes, skinMetadataVoid)

local skinSpritePathNotePlayer          = staticTotalSkinNotes[NOTES_CHECKBOX_SKIN_OBJECT_CHARS_PLAYER]
local skinSpritePathNoteOpponent        = staticTotalSkinNotes[NOTES_CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT]
local skinMetadataObjectAllNotePlayer   = staticTotalMetaobjAllNotes[NOTES_CHECKBOX_SKIN_OBJECT_CHARS_PLAYER]
local skinMetadataObjectAllNoteOpponent = staticTotalMetaobjAllNotes[NOTES_CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT]

local SPLASHES_CHECKBOX_SKIN_OBJECT_CHARS_PLAYER = SkinStatesGSave:get('CHECKBOX_SKIN_OBJECT_CHARS_PLAYER', 'SPLASHES', 0)

local staticMetaConstSkinSplashes   = json.parse(getTextFromFile('json/splashes/constant/skins.json'))
local staticTotalSkinSplashes       = states.getTotalSkins('splashes', true)
local staticTotalMetaobjAllSplashes = states.getTotalMetadataSkinObjectAll('splashes', 'skins', true)
setmetatable(staticTotalSkinSplashes, skinMetadataVoid)
setmetatable(staticTotalMetaobjAllSplashes, skinMetadataVoid)

local skinSpritePathSplashPlayer        = staticTotalSkinSplashes[SPLASHES_CHECKBOX_SKIN_OBJECT_CHARS_PLAYER]
local skinMetadataObjectAllSplashPlayer = staticTotalMetaobjAllSplashes[SPLASHES_CHECKBOX_SKIN_OBJECT_CHARS_PLAYER]

-- Skin State Functions & Classes --

--- Gets the skin's strum metadata object property values.
---@param metadataConst table<string, any> The skin metadata object constant for default values.
---@param metadata table<string, any> The skin metadata object to get its values.
---@param element string The specified element to retrieve from the skin metadata.
---@return table<string, any>
local function skinsMetadataObjectStrums(metadataConst, metadata, element)
     assert(metadata.strums ~= nil, "Trying to get the non-existing strum element array within the metadata")
     assert(element ~= nil,         "Trying to get an unidentified value within the metadata\'s strum JSON")
     local skinMetadataObject         = metadata
     local skinMetadataObjectByAnim   = metadata.strums
     local skinStaticDataObjectByAnim = metadataConst.strums
     if skinMetadataObject == '@void' or skinMetadataObjectByAnim == nil then
          return skinStaticDataObjectByAnim[element]
     end
     if skinMetadataObjectByAnim == nil then
          skinMetadataObjectByAnim['strums'] = skinStaticDataObjectByAnim
          return skinMetadataObjectByAnim
     end
     if skinMetadataObjectByAnim[element] == nil then
          skinMetadataObjectByAnim['strums'][element] = skinStaticDataObjectByAnim[element]
          return skinMetadataObjectByAnim[element]
     end
     return skinMetadataObjectByAnim[element]
end

--- Gets the skin's metadata object value.
---@param metadataConst table The static data type to use in-place, if no value exists.
---@param metadata table The metadata object type to use.
---@param element string The element to use.
---@return any
local function skinsMetadataObjects(metadataConst, metadata, element)
     assert(element ~= nil,         "Trying to get an unidentified value within the metadata\'s JSON")
     local skinsMetadataObject       = metadata
     local skinsMetadataObjectByElem = metadata[element]
     if skinsMetadataObject == '@void' or skinsMetadataObjectByElem == nil then
          return metadataConst[element]
     end
     return skinsMetadataObjectByElem
end

--- Helper class for utilizing skin metadata object functions.
---@class SkinStrumMetadata
local SkinStrumMetadata = {}
function SkinStrumMetadata:new(metadataConst, metadata)
     local self = setmetatable({}, {__index = self})
     self.metadataConst = metadataConst
     self.metadata = metadata

     return self
end

--- Gets the skin's strum metadata object property values.
---@param element string The element to use.
---@return any
function SkinStrumMetadata:object(element)
     return skinsMetadataObjects(self.metadataConst, self.metadata, element)
end

--- Gets the skin's metadata object value.
---@param element string The element to use.
---@return any
function SkinStrumMetadata:object_strums(element)
     return skinsMetadataObjectStrums(self.metadataConst, self.metadata, element)
end

-- Main Code --

local SkinStrumNotePlayer   = SkinStrumMetadata:new(staticMetaConstSkinNotes, skinMetadataObjectAllNotePlayer)
local SkinStrumNoteOpponent = SkinStrumMetadata:new(staticMetaConstSkinNotes, skinMetadataObjectAllNoteOpponent)
local skinPathNotePlayer    = skinSpritePathNotePlayer:gsub('assets/shared/images/', '')
local skinPathNoteOpponent  = skinSpritePathNoteOpponent:gsub('assets/shared/images/', '')

local SkinStrumSplashes    = SkinStrumMetadata:new(staticMetaConstSkinSplashes, skinMetadataObjectAllSplashPlayer)
local skinPathSplashPlayer = skinSpritePathSplashPlayer:gsub('assets/shared/images/', '')

--- Sets up the skins strumline's texture and shaders.
---@return nil
local function onSetStrumTexture()
     if getPropertyFromClass('states.PlayState', 'stageUI') == 'pixel' then return end

     local playerTexture     = skinPathNotePlayer
     local opponentTexture   = skinPathNoteOpponent
     local playerRGBShader   = SkinStrumNotePlayer:object('rgbshader')
     local opponentRGBShader = SkinStrumNoteOpponent:object('rgbshader')
     for memberStrums = 0,3 do
          if skinSpritePathNotePlayer ~= '@void' then
               setPropertyFromGroup('playerStrums', memberStrums, 'texture', playerTexture)
               setPropertyFromGroup('playerStrums', memberStrums, 'useRGBShader', playerRGBShader)
          end
          if skinSpritePathNoteOpponent ~= '@void' then
               setPropertyFromGroup('opponentStrums', memberStrums, 'texture', opponentTexture)
               setPropertyFromGroup('opponentStrums', memberStrums, 'useRGBShader', opponentRGBShader)
          end
     end

     local playerTexture   = skinPathSplashPlayer
     local playerRGBShader = SkinStrumSplashes:object('rgbshader')
     for memberSplashes = 0, getProperty('unspawnNotes.length')-1 do
          if skinPathSplashPlayer ~= '@void' then
               setPropertyFromGroup('unspawnNotes', memberSplashes, 'noteSplashData.texture', playerTexture)
               setPropertyFromGroup('unspawnNotes', memberSplashes, 'noteSplashData.useRGBShader', playerRGBShader)
          end
     end
end

--- Sets up the spawning note's texture and shaders.
---@param memberStrums number The current note member ID number.
---@param noteType string The current note-type of the note.
---@param isSustainNote boolean Whether the notes are sustain (long notes) or not.
---@return nil
local function onSetSkinTexture(memberStrums, noteType, isSustainNote)
     if getPropertyFromClass('states.PlayState', 'stageUI') == 'pixel' then return end

     local percentage   = 100
     local amplifier    = 1.05
     local songSpeed    = getProperty('songSpeed')
     local songPlayRate = getProperty('playbackRate')
     local noteSustainHeight = (stepCrochet / percentage) * amplifier * (songSpeed / songPlayRate)

     local ultimateSwagWidth = getPropertyFromClass('objects.Note', 'swagWidth')
     local ultimateNoteWidth = getPropertyFromGroup('notes', memberStrums, 'width')
     local ultimateWidth     = (ultimateSwagWidth - ultimateNoteWidth) / 2

     --- Self-explanatory, idiot.
     ---@param skinStrumMetadata table The specified skin strum class to be utilize. 
     ---@return string
     local function noteTypeExists(skinStrumMetadata)
          return table.find(skinStrumMetadata:object('types'), noteType)
     end

     --- Adjust the strum sustain group's offsets and height.
     ---@param skinStrumMetadata table The specified skin strum class to be utilize. 
     ---@return nil
     local function setPropertySustainGroup(skinStrumMetadata)
          if isSustainNote == false then return end

          local strumOffsetX = skinStrumMetadata:object_strums('offsetX')
          local strumHeight  = skinStrumMetadata:object_strums('height')
          setPropertyFromGroup('notes', memberStrums, 'offsetX', ultimateWidth - strumOffsetX)

          local isTailName = getProperty(F"game.notes.members[{memberStrums}].animation.curAnim.name")
          local isTailNote = stringEndsWith(isTailName, 'end')
          if not isTailNote then
               local noteSustainHeightStrum   = noteSustainHeight / strumHeight % noteSustainHeight
               local noteSustainHeightScaleBy = strumHeight == 0 and noteSustainHeight or noteSustainHeightStrum
               setPropertyFromGroup('notes', memberStrums, 'scale.y', noteSustainHeightScaleBy)
          end
     end

     if getPropertyFromGroup('notes', memberStrums, 'mustPress') then
          if skinSpritePathNotePlayer ~= '@void' and noteTypeExists(SkinStrumNotePlayer) ~= nil then
               setPropertyFromGroup('notes', memberStrums, 'texture', skinPathNotePlayer);
               setPropertyFromGroup('notes', memberStrums, 'rgbShader.enabled', SkinStrumNotePlayer:object('rgbshader'))
               setPropertySustainGroup(SkinStrumNotePlayer)
               updateHitboxFromGroup('notes', memberStrums)
          end
     else
          if skinSpritePathNoteOpponent ~= '@void' and noteTypeExists(SkinStrumNoteOpponent) ~= nil then
               setPropertyFromGroup('notes', memberStrums, 'texture', skinPathNoteOpponent);
               setPropertyFromGroup('notes', memberStrums, 'rgbShader.enabled', SkinStrumNoteOpponent:object('rgbshader'))
               setPropertySustainGroup(SkinStrumNoteOpponent)
               updateHitboxFromGroup('notes', memberStrums)
          end
     end
end

--- Self-explanatory, idiot.
local function loadSkinSelectorState()
     if getPropertyFromClass('states.PlayState', 'stageUI') == 'pixel' then return end

     SkinStatesGSave:set('GAME_SONG_NAME', 'GENERAL', songName)
     SkinStatesGSave:set('GAME_DIFFICULTY_ID', 'GENERAL', tostring(difficulty))
     SkinStatesGSave:set('GAME_DIFFICULTY_LISTS', 'GENERAL', getPropertyFromClass('backend.Difficulty', 'list'))
     loadNewSong('Skin Selector', 2, {'Easy', 'Normal', 'Hard'})
end

function onCreatePost()
     onSetStrumTexture()
end

function onCountdownStarted() -- A fail-safe, if initaiting the noteskin's texture setup fails this will be called
     onSetStrumTexture()
end

function onSpawnNote(memberStrums, noteData, noteType, isSustainNote, strumTime)
     onSetSkinTexture(memberStrums, noteType, isSustainNote)
end

function onUpdatePost(elapsed)
     if getModSetting('ENABLE_DOUBLE-TAPPING_SAFE', modFolder) == true then
          if keyboardJustDoublePressed('TAB') then
               loadSkinSelectorState()
          end
     else
          if keyboardJustPressed('TAB') then
               loadSkinSelectorState()
          end
     end

     if keyboardJustPressed('F1') then
          loadNewSong('Skin Editor', 2, {'Easy', 'Normal', 'Hard'})
     end
end