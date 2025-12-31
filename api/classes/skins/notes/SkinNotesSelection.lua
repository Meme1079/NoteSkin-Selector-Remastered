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
     local totalSkinObjectsPagePerIds      = self.TOTAL_SKIN_OBJECTS_ID[self.SELECT_SKIN_PAGE_INDEX]
     local totalSkinObjectsPagePerHovered  = self.TOTAL_SKIN_OBJECTS_HOVERED[self.SELECT_SKIN_PAGE_INDEX]
     local totalSkinObjectsPagePerClicked  = self.TOTAL_SKIN_OBJECTS_CLICKED[self.SELECT_SKIN_PAGE_INDEX]
     local totalSkinObjectsPagePerSelected = self.TOTAL_SKIN_OBJECTS_SELECTED[self.SELECT_SKIN_PAGE_INDEX]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     for curIDs = totalSkinObjectsPagePerIds[1], totalSkinObjectsPagePerIds[#totalSkinObjectsPagePerIds] do
          local curSkinIDs = curIDs - (MAX_NUMBER_CHUNK * (self.SELECT_SKIN_PAGE_INDEX - 1))

          local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{curIDs}"
          local displaySkinIconSkinTag   = F"displaySkinIconSkin{self.stateClass:upperAtStart()}-{curIDs}"
          local function displaySkinSelect()
               local byClick   = clickObject(displaySkinIconButtonTag, 'camHUD')
               local byRelease = mouseReleased('left') and self.SELECT_SKIN_PRE_SELECTION_INDEX == curIDs

               if byClick == true and totalSkinObjectsPagePerClicked[curSkinIDs] == false then
                    playAnim(displaySkinIconButtonTag, 'pressed', true)

                    self.SELECT_SKIN_PRE_SELECTION_INDEX = curIDs
                    self.SELECT_SKIN_CLICKED_SELECTION   = true

                    SkinNoteSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
                    totalSkinObjectsPagePerClicked[curSkinIDs] = true
               end

               if byRelease == true and totalSkinObjectsPagePerClicked[curSkinIDs] == true then
                    playAnim(displaySkinIconButtonTag, 'selected', true)
     
                    self.SELECT_SKIN_INIT_SELECTION_INDEX = self.SELECT_SKIN_CUR_SELECTION_INDEX
                    self.SELECT_SKIN_CUR_SELECTION_INDEX  = curIDs
                    self.SELECT_SKIN_PAGE_INDEX           = self.SELECT_SKIN_PAGE_INDEX
                    self.SELECT_SKIN_CLICKED_SELECTION    = false
                    
                    self:preview()

                    SkinNoteSave:set('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_INIT_SELECTION_INDEX)
                    SkinNoteSave:set('SELECT_SKIN_CUR_SELECTION_INDEX',  self.stateClass:upper(), self.SELECT_SKIN_CUR_SELECTION_INDEX)
                    SkinNoteSave:set('SELECT_SKIN_PAGE_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PAGE_INDEX)
                    totalSkinObjectsPagePerSelected[curSkinIDs] = true
                    totalSkinObjectsPagePerClicked[curSkinIDs]  = false
               end
          end
          local function displaySkinDeselect()
               local byClick   = clickObject(displaySkinIconButtonTag, 'camHUD')
               local byRelease = mouseReleased('left') and self.SELECT_SKIN_PRE_SELECTION_INDEX == curIDs
               if byClick == true and totalSkinObjectsPagePerClicked[curSkinIDs] == false then
                    playAnim(displaySkinIconButtonTag, 'pressed', true)

                    self.SELECT_SKIN_PRE_SELECTION_INDEX = curIDs
                    self.SELECT_SKIN_CLICKED_SELECTION   = true

                    SkinNoteSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
                    totalSkinObjectsPagePerClicked[curSkinIDs] = true
               end

               if byRelease == true and totalSkinObjectsPagePerClicked[curSkinIDs] == true then
                    playAnim(displaySkinIconButtonTag, 'static', true)

                    self.SELECT_SKIN_CUR_SELECTION_INDEX = 0
                    self.SELECT_SKIN_PRE_SELECTION_INDEX = 0
                    self.SELECT_SKIN_CLICKED_SELECTION   = false

                    self:preview()
                    SkinNoteSave:set('SELECT_SKIN_CUR_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_CUR_SELECTION_INDEX)
                    SkinNoteSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
                    totalSkinObjectsPagePerSelected[curSkinIDs] = false
                    totalSkinObjectsPagePerClicked[curSkinIDs]  = false
                    totalSkinObjectsPagePerHovered[curSkinIDs]  = false
               end
          end
          local function displaySkinAutoDeselect()
               self.SELECT_SKIN_CUR_SELECTION_INDEX = 0
               self.SELECT_SKIN_PRE_SELECTION_INDEX = 0
               self.SELECT_SKIN_CLICKED_SELECTION   = false

               self:preview()
               SkinNoteSave:set('SELECT_SKIN_CUR_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_CUR_SELECTION_INDEX)
               SkinNoteSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
               totalSkinObjectsPagePerSelected[curSkinIDs] = false
               totalSkinObjectsPagePerClicked[curSkinIDs]  = false
               totalSkinObjectsPagePerHovered[curSkinIDs]  = false
          end

          local previewObjectCurAnim        = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewObjectMissingAnim    = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING[self.SELECT_SKIN_PAGE_INDEX][curSkinIDs]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]
          if totalSkinObjectsPagePerSelected[curSkinIDs] == false and curIDs ~= self.SELECT_SKIN_CUR_SELECTION_INDEX and previewObjectCurMissingAnim == false then
               displaySkinSelect()
          end
          if totalSkinObjectsPagePerSelected[curSkinIDs] == true then
               --displaySkinDeselect()
          end

          if totalSkinObjectsPagePerSelected[curSkinIDs] == true and previewObjectCurMissingAnim == true then
               displaySkinAutoDeselect()
          end

          if curIDs ~= self.SELECT_SKIN_INIT_SELECTION_INDEX then --! DO NOT CHANGE ANYTHING FROM THIS CODE
               local curSkinSelectIDs = self.SELECT_SKIN_CUR_SELECTION_INDEX - (MAX_NUMBER_CHUNK * (self.SELECT_SKIN_PAGE_INDEX - 1))
               if curSkinIDs ~= curSkinSelectIDs then -- fuck you bug
                    totalSkinObjectsPagePerSelected[curSkinIDs] = false
               end

               self.SELECT_SKIN_INIT_SELECTION_INDEX = 0
               SkinNoteSave:set('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_INIT_SELECTION_INDEX)
          end
     end
end

--- Main display skin button hovering functionality and animations.
--- Allowing the cursor's sprite to change its corresponding sprite when hovering for visual aid.
---@return nil
function SkinNotesSelection:selection_byhover()
     local totalSkinObjectsPagePerIds      = self.TOTAL_SKIN_OBJECTS_ID[self.SELECT_SKIN_PAGE_INDEX]
     local totalSkinObjectsPagePerHovered  = self.TOTAL_SKIN_OBJECTS_HOVERED[self.SELECT_SKIN_PAGE_INDEX]
     local totalSkinObjectsPagePerClicked  = self.TOTAL_SKIN_OBJECTS_CLICKED[self.SELECT_SKIN_PAGE_INDEX]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end     

     local skinHighlightName = ''
     for curIDs = totalSkinObjectsPagePerIds[1], totalSkinObjectsPagePerIds[#totalSkinObjectsPagePerIds] do
          local curSkinIDs = curIDs - (MAX_NUMBER_CHUNK * (self.SELECT_SKIN_PAGE_INDEX - 1))

          local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{curIDs}"
          if hoverObject(displaySkinIconButtonTag, 'camHUD') == true then
               totalSkinObjectsPagePerHovered[curSkinIDs] = true
          end
          if hoverObject(displaySkinIconButtonTag, 'camHUD') == false then
               totalSkinObjectsPagePerHovered[curSkinIDs] = false
          end

          local nonCurrentPreSelectedSkin = self.SELECT_SKIN_PRE_SELECTION_INDEX ~= curIDs
          local nonCurrentCurSelectedSkin = self.SELECT_SKIN_CUR_SELECTION_INDEX ~= curIDs
          if totalSkinObjectsPagePerHovered[curSkinIDs] == true and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButtonTag) == false then return end
               playAnim(displaySkinIconButtonTag, 'hover', true)

               skinHighlightName = self.TOTAL_SKIN_OBJECTS_NAMES[self.SELECT_SKIN_PAGE_INDEX][curSkinIDs]
          end
          if totalSkinObjectsPagePerHovered[curSkinIDs] == false and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButtonTag) == false then return end
               playAnim(displaySkinIconButtonTag, 'static', true)
          end
          
          local previewObjectCurAnim        = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewObjectMissingAnim    = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING[self.SELECT_SKIN_PAGE_INDEX][curSkinIDs]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]
          if previewObjectCurMissingAnim == true then
               playAnim(displaySkinIconButtonTag, 'blocked', true)
          end
     end

     if getPropertyFromClass('flixel.FlxG', 'mouse.justMoved') == true then
          setTextString('skinHighlightName', skinHighlightName ~= '' and skinHighlightName or '')
          return
     end
end

--- Main cursor functionality for the displau skin and its animations.
--- Allowing the cursor's sprite to change depending on its interaction (i.e. selecting and hovering).
---@return nil
function SkinNotesSelection:selection_bycursor()
     local totalSkinObjectsPagePerIds      = self.TOTAL_SKIN_OBJECTS_ID[self.SELECT_SKIN_PAGE_INDEX]
     local totalSkinObjectsPagePerHovered  = self.TOTAL_SKIN_OBJECTS_HOVERED[self.SELECT_SKIN_PAGE_INDEX]
     local totalSkinObjectsPagePerClicked  = self.TOTAL_SKIN_OBJECTS_CLICKED[self.SELECT_SKIN_PAGE_INDEX]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     if mouseClicked('left') or mousePressed('left') then 
          playAnim('mouseTexture', 'idleClick', true)
     else
          playAnim('mouseTexture', 'idle', true)
     end

     local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{self.SELECT_SKIN_CUR_SELECTION_INDEX}"
     for curIDs = 1, math.max(#totalSkinObjectsPagePerClicked, #totalSkinObjectsPagePerHovered) do
          if hoverObject(displaySkinIconButtonTag, 'camHUD') == true then
               goto SKIP_SELECTED_SKIN_HOVERED -- disabled deselecting
          end

          if totalSkinObjectsPagePerClicked[curIDs] == true then
               playAnim('mouseTexture', 'handClick', true)
          end
          if totalSkinObjectsPagePerHovered[curIDs] == true and totalSkinObjectsPagePerClicked[curIDs] == false then
               playAnim('mouseTexture', 'hand', true)
          end
          ::SKIP_SELECTED_SKIN_HOVERED::
     end
     
     for curIDs = totalSkinObjectsPagePerIds[1], totalSkinObjectsPagePerIds[#totalSkinObjectsPagePerIds] do
          local curSkinIDs = curIDs - (MAX_NUMBER_CHUNK * (self.SELECT_SKIN_PAGE_INDEX - 1))

          local previewObjectCurAnim        = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewObjectMissingAnim    = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING[self.SELECT_SKIN_PAGE_INDEX][curSkinIDs]
          local previewObjectCurMissingAnim = previewObjectMissingAnim[previewObjectCurAnim]
          if previewObjectCurMissingAnim == true then
               local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{curIDs}"
               if hoverObject(displaySkinIconButton, 'camHUD') == false then
                    goto SKIP_SELECTED_SKIN_MISSING_ANIMS_HOVERED
               end

               if mouseClicked('left') then 
                    playSound('cancel') 
               end

               if mouseClicked('left') or mousePressed('left') then 
                    playAnim('mouseTexture', 'disabledClick', true)
               else
                    playAnim('mouseTexture', 'disabled', true)
               end
          end
          ::SKIP_SELECTED_SKIN_MISSING_ANIMS_HOVERED::
     end
     
     local MINIMUM_SKIN_LIMIT = 1
     if hoverObject('displaySliderIcon', 'camHUD') == true and self.TOTAL_SKIN_LIMIT == MINIMUM_SKIN_LIMIT then
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