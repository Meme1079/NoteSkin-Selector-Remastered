luaDebugMode = true

local SkinSaves    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed

local SkinStatesGSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')
function onCreatePost()
     for _,scripts in pairs(getRunningScripts()) do
          if scripts:match(F"{modFolder}/scripts/skins") or not scripts:match(modFolder) then
               removeLuaScript(scripts, true)
          end
     end
     playMusic(getModSetting('SONG_SELECT', modFolder):lower(), 0.5, true)
end

--- Updates the mouse positions based on the current cursor position.
---@param mouseTag string The specified mouse tag to update its position.
---@param offsetX number The offset of the x position.
---@param offsetY number The offset of the y position.
---@return nil
local function mouseSetUpdatingPosition(mouseTag, offsetX, offsetY)
     setProperty(F"{mouseTag}.x", getMouseX('camHUD') + offsetX)
     setProperty(F"{mouseTag}.y", getMouseY('camHUD') + offsetY)
end

function onUpdatePost(elapsed)
     if keyboardJustConditionPressed('ONE',    not getVar('skinSearchInputFocus')) then restartSong(true) end
     if keyboardJustConditionPressed('ESCAPE', not getVar('skinSearchInputFocus')) then exitSong()        end
     if mouseClicked('left')  then playSound('clicks/clickDown', 0.5) end
     if mouseReleased('left') then playSound('clicks/clickUp', 0.5)   end

     mouseSetUpdatingPosition('mouseTexture', -4, 0)
     mouseSetUpdatingPosition('mouseSkinToolTip', 35, 12)
     if keyboardJustConditionPressed('ENTER', not getVar('skinSearchInputFocus')) and songName == 'Skin Selector' then
          local GAME_SONG_NAME        = SkinStatesGSave:get('GAME_SONG_NAME', 'GENERAL')
          local GAME_DIFFICULTY_ID    = SkinStatesGSave:get('GAME_DIFFICULTY_ID', 'GENERAL')
          local GAME_DIFFICULTY_LISTS = SkinStatesGSave:get('GAME_DIFFICULTY_LISTS', 'GENERAL')
          loadNewSong(GAME_SONG_NAME, tonumber(GAME_DIFFICULTY_ID), GAME_DIFFICULTY_LISTS)
     end
end

local allowCountdown = false;
function onStartCountdown()
     local camUI = {'iconP1', 'iconP2', 'healthBar', 'scoreTxt', 'botplayTxt'}
     for elements = 1, #camUI do
          callMethod('uiGroup.remove', {instanceArg(camUI[elements])})
     end

     if not allowCountdown then -- Block the first countdown
          allowCountdown = true;
          return Function_Stop;
     end
     setProperty('camHUD.visible', true)
     return Function_Continue;
end