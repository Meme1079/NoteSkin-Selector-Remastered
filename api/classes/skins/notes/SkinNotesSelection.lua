luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local math      = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.newglobal'

local MAX_NUMBER_CHUNK = global.MAX_NUMBER_CHUNK

local hoverObject = funkinlua.hoverObject
local clickObject = funkinlua.clickObject

--- Childclass extension, main selecting component functionality for the note skin state.
---@class SkinNotesSelection
local SkinNotesSelection = {}
local SkinNotesGSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

--- Selection component group.
---@return nil
function SkinNotesSelection:selection()
     self:selection_byclick()
     self:selection_byhover()
     self:selection_bycursor()
end

--- Selection main clicking functionality and animations.
---@private
---@return nil
function SkinNotesSelection:selection_byclick()
     local totalSkinObjectsPagePerIds      = self.TOTAL_SKIN_OBJECTS_ID[self.SCROLLBAR_PAGE_INDEX]
     local totalSkinObjectsPagePerHovered  = self.TOTAL_SKIN_OBJECTS_HOVERED[self.SCROLLBAR_PAGE_INDEX]
     local totalSkinObjectsPagePerClicked  = self.TOTAL_SKIN_OBJECTS_CLICKED[self.SCROLLBAR_PAGE_INDEX]
     local totalSkinObjectsPagePerSelected = self.TOTAL_SKIN_OBJECTS_SELECTED[self.SCROLLBAR_PAGE_INDEX]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     for curIDs = totalSkinObjectsPagePerIds[1], totalSkinObjectsPagePerIds[#totalSkinObjectsPagePerIds] do
          local curSkinIDs = curIDs - (MAX_NUMBER_CHUNK * (self.SCROLLBAR_PAGE_INDEX - 1))

          local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{curIDs}"
          local displaySkinIconSkinTag   = F"displaySkinIconSkin{self.stateClass:upperAtStart()}-{curIDs}"
          local function displaySkinSelect()
               local byClick   = clickObject(displaySkinIconButtonTag, 'camHUD')
               local byRelease = mouseReleased('left') and self.SELECT_SKIN_PRE_SELECTION_INDEX == curIDs

               if byClick == true and totalSkinObjectsPagePerClicked[curSkinIDs] == false then
                    playAnim(displaySkinIconButtonTag, 'pressed', true)

                    self.SELECT_SKIN_PRE_SELECTION_INDEX = curIDs
                    self.SELECT_SKIN_CLICKED_SELECTION   = true

                    SkinNotesGSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
                    totalSkinObjectsPagePerClicked[curSkinIDs] = true
               end

               if byRelease == true and totalSkinObjectsPagePerClicked[curSkinIDs] == true then
                    playAnim(displaySkinIconButtonTag, 'selected', true)
     
                    self.SELECT_SKIN_PAGE_INDEX           = self.SCROLLBAR_PAGE_INDEX
                    self.SELECT_SKIN_INIT_SELECTION_INDEX = self.SELECT_SKIN_CUR_SELECTION_INDEX
                    self.SELECT_SKIN_CUR_SELECTION_INDEX  = curIDs
                    self.SELECT_SKIN_CLICKED_SELECTION    = false
                    self:preview()

                    SkinNotesGSave:set('SELECT_SKIN_PAGE_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PAGE_INDEX)
                    SkinNotesGSave:set('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_INIT_SELECTION_INDEX)
                    SkinNotesGSave:set('SELECT_SKIN_CUR_SELECTION_INDEX',  self.stateClass:upper(), self.SELECT_SKIN_CUR_SELECTION_INDEX)
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

                    SkinNotesGSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
                    totalSkinObjectsPagePerClicked[curSkinIDs] = true
               end

               if byRelease == true and totalSkinObjectsPagePerClicked[curSkinIDs] == true then
                    playAnim(displaySkinIconButtonTag, 'static', true)

                    self.SELECT_SKIN_CUR_SELECTION_INDEX = 0
                    self.SELECT_SKIN_PRE_SELECTION_INDEX = 0
                    self.SELECT_SKIN_CLICKED_SELECTION   = false

                    self:preview()
                    SkinNotesGSave:set('SELECT_SKIN_CUR_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_CUR_SELECTION_INDEX)
                    SkinNotesGSave:set('SELECT_SKIN_PRE_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_PRE_SELECTION_INDEX)
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

               totalSkinObjectsPagePerSelected[curSkinIDs] = false
               totalSkinObjectsPagePerClicked[curSkinIDs]  = false
               totalSkinObjectsPagePerHovered[curSkinIDs]  = false
          end

          local previewSkinObjectAnims        = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewSkinObjectMissingAnims = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING[self.SCROLLBAR_PAGE_INDEX][curSkinIDs]
          local previewSkinObjectDefaultAnims = previewSkinObjectMissingAnims[previewSkinObjectAnims]
          if totalSkinObjectsPagePerSelected[curSkinIDs] == false and curIDs ~= self.SELECT_SKIN_CUR_SELECTION_INDEX and previewSkinObjectDefaultAnims == false then
               displaySkinSelect()
          elseif totalSkinObjectsPagePerSelected[curSkinIDs] == true then
               --displaySkinDeselect()
          elseif totalSkinObjectsPagePerSelected[curSkinIDs] == true and previewSkinObjectDefaultAnims == true then
               displaySkinAutoDeselect()
          end

          if curIDs ~= self.SELECT_SKIN_INIT_SELECTION_INDEX then --! DO NOT CHANGE ANYTHING FROM THIS CODE
               local curSkinSelectIDs = self.SELECT_SKIN_CUR_SELECTION_INDEX - (MAX_NUMBER_CHUNK * (self.SCROLLBAR_PAGE_INDEX - 1))
               if curSkinIDs ~= curSkinSelectIDs then -- fuck you bug
                    totalSkinObjectsPagePerSelected[curSkinIDs] = false
               end

               self.SELECT_SKIN_INIT_SELECTION_INDEX = 0
               SkinNotesGSave:set('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), self.SELECT_SKIN_INIT_SELECTION_INDEX)
          end
     end
end

--- Selection main hovering functionality and animations.
---@private
---@return nil
function SkinNotesSelection:selection_byhover()
     local totalSkinObjectsPagePerIds      = self.TOTAL_SKIN_OBJECTS_ID[self.SCROLLBAR_PAGE_INDEX]
     local totalSkinObjectsPagePerHovered  = self.TOTAL_SKIN_OBJECTS_HOVERED[self.SCROLLBAR_PAGE_INDEX]
     local totalSkinObjectsPagePerClicked  = self.TOTAL_SKIN_OBJECTS_CLICKED[self.SCROLLBAR_PAGE_INDEX]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end     

     local mouseSkinToolTip = ''
     for curIDs = totalSkinObjectsPagePerIds[1], totalSkinObjectsPagePerIds[#totalSkinObjectsPagePerIds] do
          local curSkinIDs = curIDs - (MAX_NUMBER_CHUNK * (self.SCROLLBAR_PAGE_INDEX - 1))

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

               mouseSkinToolTip = self.TOTAL_SKIN_OBJECTS_NAMES[self.SCROLLBAR_PAGE_INDEX][curSkinIDs]
          end
          if totalSkinObjectsPagePerHovered[curSkinIDs] == false and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButtonTag) == false then return end
               playAnim(displaySkinIconButtonTag, 'static', true)
          end
          
          local previewSkinObjectAnims        = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewSkinObjectMissingAnims = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING[self.SCROLLBAR_PAGE_INDEX][curSkinIDs]
          local previewSkinObjectDefaultAnims = previewSkinObjectMissingAnims[previewSkinObjectAnims]
          if luaSpriteExists(displaySkinIconButtonTag) == true then
               if previewSkinObjectDefaultAnims == true then
                    playAnim(displaySkinIconButtonTag, 'blocked', true)
               elseif self.SELECT_SKIN_CUR_SELECTION_INDEX == curIDs and previewSkinObjectDefaultAnims == false then
                    playAnim(displaySkinIconButtonTag, 'selected', true)
               end
          end
     end
     setTextString('mouseSkinToolTip', mouseSkinToolTip ~= '' and mouseSkinToolTip or '') -- no way to optimize this :(
end

--- Selection main cursor interactive functionality and animations.
---@private
---@return nil
function SkinNotesSelection:selection_bycursor()
     local totalSkinObjectsPagePerIds      = self.TOTAL_SKIN_OBJECTS_ID[self.SCROLLBAR_PAGE_INDEX]
     local totalSkinObjectsPagePerHovered  = self.TOTAL_SKIN_OBJECTS_HOVERED[self.SCROLLBAR_PAGE_INDEX]
     local totalSkinObjectsPagePerClicked  = self.TOTAL_SKIN_OBJECTS_CLICKED[self.SCROLLBAR_PAGE_INDEX]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     if mouseClicked('left') or mousePressed('left') then 
          playAnim('mouseTexture', 'idleClick', true)
     else
          setTextColor('mouseSkinToolTip', 'ffffff')
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
          local curSkinIDs = curIDs - (MAX_NUMBER_CHUNK * (self.SCROLLBAR_PAGE_INDEX - 1))

          local previewSkinObjectAnims        = self.PREVIEW_SKIN_OBJECT_ANIMS[self.PREVIEW_SKIN_OBJECT_INDEX]
          local previewSkinObjectMissingAnims = self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING[self.SCROLLBAR_PAGE_INDEX][curSkinIDs]
          local previewSkinObjectDefaultAnims = previewSkinObjectMissingAnims[previewSkinObjectAnims]
          if previewSkinObjectDefaultAnims == true then
               local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{curIDs}"
               if hoverObject(displaySkinIconButtonTag, 'camHUD') == false then
                    goto SKIP_SELECTED_SKIN_MISSING_ANIMS_HOVERED
               end

               if mouseClicked('left') then 
                    playSound('cancel') 
               end
               if mouseClicked('left') or mousePressed('left') then 
                    playAnim('mouseTexture', 'disabledClick', true)
               else
                    setTextColor('mouseSkinToolTip', 'ff293d')
                    playAnim('mouseTexture', 'disabled', true)
               end
               ::SKIP_SELECTED_SKIN_MISSING_ANIMS_HOVERED::
          end
     end
     
     local MINIMUM_SKIN_LIMIT = 1
     if hoverObject('pageScrollbarThumb', 'camHUD') == true and self.TOTAL_SKIN_LIMIT == MINIMUM_SKIN_LIMIT then
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