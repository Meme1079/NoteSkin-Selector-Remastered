luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
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

--- Childclass extension, main selecting component functionality for the note skin state.
---@class SkinNotesSelection
local SkinNotesSelection = {}

--- Collection group of selection methods.
---@return nil
function SkinNotesSelection:selection()
     self:selection_byclick()
     self:selection_byhover()
     self:selection_bycursor()
end

--- Main display skin button clicking functionality and animations.
--- Allowing the selecting of the corresponding skin in gameplay.
---@return nil
function SkinNotesSelection:selection_byclick()
     local skinObjectsPerIDs      = self.TOTAL_SKIN_OBJECTS_ID[self.SELECT_SKIN_PAGE_INDEX]
     local skinObjectsPerHovered  = self.TOTAL_SKIN_OBJECTS_HOVERED[self.SELECT_SKIN_PAGE_INDEX]
     local skinObjectsPerClicked  = self.TOTAL_SKIN_OBJECTS_CLICKED[self.SELECT_SKIN_PAGE_INDEX]
     local skinObjectsPerSelected = self.TOTAL_SKIN_OBJECTS_SELECTED[self.SELECT_SKIN_PAGE_INDEX]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     for curIndex = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
          local curSkinIndex = curIndex - (MAX_NUMBER_CHUNK * (self.SELECT_SKIN_PAGE_INDEX - 1))

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = curIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          local function displaySkinSelect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.SELECT_SKIN_PRE_SELECTION_INDEX == curIndex

               if byClick == true and skinObjectsPerClicked[curSkinIndex] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.SELECT_SKIN_PRE_SELECTION_INDEX = curIndex
                    self.SELECT_SKIN_CLICKED_SELECTION   = true

                    SkinNoteSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
                    skinObjectsPerClicked[curSkinIndex] = true
               end

               if byRelease == true and skinObjectsPerClicked[curSkinIndex] == true then
                    playAnim(displaySkinIconButton, 'selected', true)
     
                    self.SELECT_SKIN_INIT_SELECTION_INDEX = self.SELECT_SKIN_CUR_SELECTION_INDEX
                    self.SELECT_SKIN_CUR_SELECTION_INDEX  = curIndex
                    self.SELECT_SKIN_PAGE_INDEX           = self.SELECT_SKIN_PAGE_INDEX
                    self.SELECT_SKIN_CLICKED_SELECTION    = false
                    
                    self:preview()

                    SkinNoteSave:set('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_INIT_SELECTION_INDEX)
                    SkinNoteSave:set('SELECT_SKIN_CUR_SELECTION_INDEX',  self.stateClass:upper(), self.SELECT_SKIN_CUR_SELECTION_INDEX)
                    SkinNoteSave:set('SELECT_SKIN_PAGE_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PAGE_INDEX)
                    skinObjectsPerSelected[curSkinIndex] = true
                    skinObjectsPerClicked[curSkinIndex]  = false
               end
          end
          local function displaySkinDeselect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.SELECT_SKIN_PRE_SELECTION_INDEX == curIndex
               if byClick == true and skinObjectsPerClicked[curSkinIndex] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.SELECT_SKIN_PRE_SELECTION_INDEX = curIndex
                    self.SELECT_SKIN_CLICKED_SELECTION   = true

                    SkinNoteSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
                    skinObjectsPerClicked[curSkinIndex] = true
               end

               if byRelease == true and skinObjectsPerClicked[curSkinIndex] == true then
                    playAnim(displaySkinIconButton, 'static', true)

                    self.SELECT_SKIN_CUR_SELECTION_INDEX = 0
                    self.SELECT_SKIN_PRE_SELECTION_INDEX = 0
                    self.SELECT_SKIN_CLICKED_SELECTION   = false

                    self:preview()
                    SkinNoteSave:set('SELECT_SKIN_CUR_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_CUR_SELECTION_INDEX)
                    SkinNoteSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
                    skinObjectsPerSelected[curSkinIndex] = false
                    skinObjectsPerClicked[curSkinIndex]  = false
                    skinObjectsPerHovered[curSkinIndex]  = false
               end
          end
          local function displaySkinAutoDeselect()
               self.SELECT_SKIN_CUR_SELECTION_INDEX = 0
               self.SELECT_SKIN_PRE_SELECTION_INDEX = 0
               self.SELECT_SKIN_CLICKED_SELECTION   = false

               self:preview()
               SkinNoteSave:set('SELECT_SKIN_CUR_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_CUR_SELECTION_INDEX)
               SkinNoteSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
               skinObjectsPerSelected[curSkinIndex] = false
               skinObjectsPerClicked[curSkinIndex]  = false
               skinObjectsPerHovered[curSkinIndex]  = false
          end

          local previewObjectCurAnim        = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewObjectMissingAnim    = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING[self.SELECT_SKIN_PAGE_INDEX][curSkinIndex]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]

          if skinObjectsPerSelected[curSkinIndex] == false and curIndex ~= self.SELECT_SKIN_CUR_SELECTION_INDEX and previewObjectCurMissingAnim == false then
               displaySkinSelect()
          end
          if skinObjectsPerSelected[curSkinIndex] == true then
               --displaySkinDeselect()
          end

          if skinObjectsPerSelected[curSkinIndex] == true and previewObjectCurMissingAnim == true then
               displaySkinAutoDeselect()
          end

          if curIndex ~= self.SELECT_SKIN_INIT_SELECTION_INDEX then --! DO NOT ALTER
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    playAnim(displaySkinIconButton, 'static', true)
               end

               self.SELECT_SKIN_INIT_SELECTION_INDEX = 0
               SkinNoteSave:set('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_INIT_SELECTION_INDEX)

               local curSelectSkinIndex = self.SELECT_SKIN_CUR_SELECTION_INDEX - (MAX_NUMBER_CHUNK * (self.SELECT_SKIN_PAGE_INDEX - 1))
               if curSkinIndex ~= curSelectSkinIndex then -- fuck you bug
                    skinObjectsPerSelected[curSkinIndex] = false
               end
          end
     end
end

--- Main display skin button hovering functionality and animations.
--- Allowing the cursor's sprite to change its corresponding sprite when hovering for visual aid.
---@return nil
function SkinNotesSelection:selection_byhover()
     local skinObjectsPerIDs      = self.TOTAL_SKIN_OBJECTS_ID[self.SELECT_SKIN_PAGE_INDEX]
     local skinObjectsPerHovered  = self.TOTAL_SKIN_OBJECTS_HOVERED[self.SELECT_SKIN_PAGE_INDEX]
     local skinObjectsPerClicked  = self.TOTAL_SKIN_OBJECTS_CLICKED[self.SELECT_SKIN_PAGE_INDEX]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end     

     local skinHighlightName = ''
     for curIndex = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
          local curSkinIndex = curIndex - (MAX_NUMBER_CHUNK * (self.SELECT_SKIN_PAGE_INDEX - 1))

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = curIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if hoverObject(displaySkinIconButton, 'camHUD') == true then
               skinObjectsPerHovered[curSkinIndex] = true
          end
          if hoverObject(displaySkinIconButton, 'camHUD') == false then
               skinObjectsPerHovered[curSkinIndex] = false
          end

          local nonCurrentPreSelectedSkin = self.SELECT_SKIN_PRE_SELECTION_INDEX ~= curIndex
          local nonCurrentCurSelectedSkin = self.SELECT_SKIN_CUR_SELECTION_INDEX ~= curIndex
          if skinObjectsPerHovered[curSkinIndex] == true and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButton) == false then return end
               playAnim(displaySkinIconButton, 'hover', true)

               skinHighlightName = self.TOTAL_SKIN_OBJECTS_NAMES[self.SELECT_SKIN_PAGE_INDEX][curSkinIndex]
          end
          if skinObjectsPerHovered[curSkinIndex] == false and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButton) == false then return end
               playAnim(displaySkinIconButton, 'static', true)
          end
          
          local previewObjectCurAnim        = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewObjectMissingAnim    = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING[self.SELECT_SKIN_PAGE_INDEX][curSkinIndex]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]
          if previewObjectCurMissingAnim == true then
               playAnim(displaySkinIconButton, 'blocked', true)
          end
     end

     if getPropertyFromClass('flixel.FlxG', 'mouse.justMoved') == true then
          if skinHighlightName ~= '' then
               setTextString('skinHighlightName', skinHighlightName)
               return
          else
               setTextString('skinHighlightName', '')
               return
          end
     end
end

--- Main cursor functionality for the displau skin and its animations.
--- Allowing the cursor's sprite to change depending on its interaction (i.e. selecting and hovering).
---@return nil
function SkinNotesSelection:selection_bycursor()
     local skinObjectsPerIDs      = self.TOTAL_SKIN_OBJECTS_ID[self.SELECT_SKIN_PAGE_INDEX]
     local skinObjectsPerHovered  = self.TOTAL_SKIN_OBJECTS_HOVERED[self.SELECT_SKIN_PAGE_INDEX]
     local skinObjectsPerClicked  = self.TOTAL_SKIN_OBJECTS_CLICKED[self.SELECT_SKIN_PAGE_INDEX]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     if mouseClicked('left') or mousePressed('left') then 
          playAnim('mouseTexture', 'idleClick', true)
     else
          playAnim('mouseTexture', 'idle', true)
     end

     local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = self.SELECT_SKIN_CUR_SELECTION_INDEX}
     local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
     for curIndex = 1, math.max(#skinObjectsPerClicked, #skinObjectsPerHovered) do
          if hoverObject(displaySkinIconButton, 'camHUD') == true then
               goto skipSelectedSkin -- disabled deselecting
          end

          if skinObjectsPerClicked[curIndex] == true then
               playAnim('mouseTexture', 'handClick', true)
          end
          if skinObjectsPerHovered[curIndex] == true and skinObjectsPerClicked[curIndex] == false then
               playAnim('mouseTexture', 'hand', true)
          end
          ::skipSelectedSkin::
     end
     
     for curIndex = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
          local curSkinIndex = curIndex - (MAX_NUMBER_CHUNK * (self.SELECT_SKIN_PAGE_INDEX - 1))

          local previewObjectCurAnim        = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewObjectMissingAnim    = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING[self.SELECT_SKIN_PAGE_INDEX][curSkinIndex]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]
          if previewObjectCurMissingAnim == true then
               local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = curIndex}
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
     end
     
     if hoverObject('displaySliderIcon', 'camHUD') == true and self.TOTAL_SKIN_LIMIT == 1 then
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

return SkinNotesSelection