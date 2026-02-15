luaDebugMode = true

local SkinSaves    = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed

function onCreatePost()
     for _,scripts in pairs(getRunningScripts()) do
          if scripts:match(F"{modFolder}/scripts/skins") or not scripts:match(modFolder) then
               removeLuaScript(scripts, true)
          end
     end
     playMusic('editor/get on up again', 0.7, true)
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

     if mouseClicked('left') or mousePressed('left') then 
          playAnim('mouseTexture', 'idleClick', true)
     else
          playAnim('mouseTexture', 'idle', true)
     end
     mouseSetUpdatingPosition('mouseTexture', 0, 0)
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