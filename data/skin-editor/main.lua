luaDebugMode = true

local SkinSaves    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed

function onCreatePost()
     for _,scripts in pairs(getRunningScripts()) do
          if scripts:match(F"${modFolder}/scripts/skins") or not scripts:match(modFolder) then
               removeLuaScript(scripts, true)
          end
     end
     playMusic('editor/sherbet lobby', 0.5, true)
end

function onUpdatePost(elapsed)
     if keyboardJustConditionPressed('ONE',    getPropertyFromClass('backend.ui.PsychUIInputText', 'focusOn') == nil) then restartSong(true) end
     if keyboardJustConditionPressed('ESCAPE', getPropertyFromClass('backend.ui.PsychUIInputText', 'focusOn') == nil) then exitSong()        end
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