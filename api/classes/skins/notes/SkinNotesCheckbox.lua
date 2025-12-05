luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

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

--- Subclass dedicated for the checkboxes component for the note skin state.
---@class SkinNotesCheckbox
local SkinNotesCheckbox = {}

--- Creates the checkboxes to select the skins you want.
--- The selection highlight are also created here.
---@return nil
function SkinNotesCheckbox:checkbox_create()
     local checkboxSkinData = {
          posX  = {player = 775 + 12, opponent = 775 + 12 + (80*2.9)},
          color = {player = '31b0d1', opponent = 'af66ce'}
     }

     for checkboxIndex = 1, #self.checkboxSkinObjectType do
          local checkboxName  = self.checkboxSkinObjectType[checkboxIndex]
          local checkboxPosX  = checkboxSkinData['posX'][checkboxName]
          local checkboxColor = checkboxSkinData['color'][checkboxName]

          local checkboxSkinTag  = 'selectionSkinButton'..checkboxName:upperAtStart()
          makeAnimatedLuaSprite(checkboxSkinTag, 'checkboxanim', checkboxPosX, 330)
          addAnimationByPrefix(checkboxSkinTag, 'check', 'checkbox finish0', 24, false)
          addAnimationByPrefix(checkboxSkinTag, 'checking', 'checkbox anim0', 24, false)
          addAnimationByPrefix(checkboxSkinTag, 'unchecking', 'checkbox anim reverse0', 24, false)
          addAnimationByPrefix(checkboxSkinTag, 'uncheck', 'checkbox0', 24, false)
          playAnim(checkboxSkinTag, 'uncheck')
          scaleObject(checkboxSkinTag, 0.4, 0.4)
          setObjectCamera(checkboxSkinTag, 'camHUD')
          addOffset(checkboxSkinTag, 'check', 34.5, 36 + (math.pi - 3))
          addOffset(checkboxSkinTag, 'checking', 48.5, 42)
          addOffset(checkboxSkinTag, 'unchecking', 44.5, 44)
          addOffset(checkboxSkinTag, 'uncheck', 33.3, 32.2)
          setProperty(checkboxSkinTag..'.antialiasing', false)
          addLuaSprite(checkboxSkinTag)

          local checkboxTitleTag   = 'selectionSkinTextButton'..checkboxName:upperAtStart()
          makeLuaText(checkboxTitleTag, checkboxName:upperAtStart(), 0, checkboxPosX + 60, 330 + 7)
          setTextFont(checkboxTitleTag, 'sonic.ttf')
          setTextSize(checkboxTitleTag, 30)
          setTextColor(checkboxTitleTag, checkboxColor)
          setObjectCamera(checkboxTitleTag, 'camHUD')
          setProperty(checkboxTitleTag..'.antialiasing', false)
          addLuaText(checkboxTitleTag)

          local selectionSkinTag = 'displaySelection'..checkboxName:upperAtStart()
          makeAnimatedLuaSprite(selectionSkinTag, 'ui/display_selected', 0, 0)
          scaleObject(selectionSkinTag, 0.8, 0.8)
          addAnimationByPrefix(selectionSkinTag, 'player', 'selected-player', 24, false)
          addAnimationByPrefix(selectionSkinTag, 'opponent', 'selected-opponent', 24, false)

          local displaySelectionOffsetX = getProperty(selectionSkinTag..'.offset.x')
          local displaySelectionOffsetY = getProperty(selectionSkinTag..'.offset.y')
          addOffset(selectionSkinTag, 'player', displaySelectionOffsetX + 5, displaySelectionOffsetY + 5)
          addOffset(selectionSkinTag, 'opponent', displaySelectionOffsetX + 5, displaySelectionOffsetY + 5)
          playAnim(selectionSkinTag, checkboxName)
          setObjectCamera(selectionSkinTag, 'camHUD')
          setProperty(selectionSkinTag..'.antialiasing', false)
     end
end

--- Removes the checkboxes and the selection highlight when switching through different states.
---@return nil
function SkinNotesCheckbox:checkbox_remove()
     for checkboxIndex = 1, #self.checkboxSkinObjectType do
          local checkboxName  = self.checkboxSkinObjectType[checkboxIndex]

          local checkboxSkinTag  = 'selectionSkinButton'..checkboxName:upperAtStart()
          local checkboxTitleTag = 'selectionSkinTextButton'..checkboxName:upperAtStart()
          local selectionSkinTag = 'displaySelection'..checkboxName:upperAtStart()
          removeLuaSprite(checkboxSkinTag, true)
          removeLuaSprite(checkboxTitleTag, true)
          removeLuaSprite(selectionSkinTag, false)
     end
end

--- Checkbox functionality, selecting certain skins for the player or opponent.
---@return nil
function SkinNotesCheckbox:checkbox_checking()
     for checkboxIndex = 1, #self.checkboxSkinObjectType do
          local checkboxObjectTypes   = self.checkboxSkinObjectType[checkboxIndex]
          local checkboxObjectTypeTag = self.checkboxSkinObjectType[checkboxIndex]:upperAtStart()

          local checkboxSkinIndex      = self.checkboxSkinObjectIndex[checkboxObjectTypes:lower()]
          local checkboxSkinCurrent    = checkboxSkinIndex == self.selectSkinCurSelectedIndex
          local checkboxSkinNonCurrent = checkboxSkinIndex ~= self.selectSkinCurSelectedIndex
          if self.selectSkinCurSelectedIndex == 0 and checkboxSkinCurrent == true then
               return
          end

          local selectionSkinButton = 'selectionSkinButton'..checkboxObjectTypeTag
          local selectionSkinButtonAnimFinish = getProperty(selectionSkinButton..'.animation.finished')
          local selectionSkinButtonAnimName   = getProperty(selectionSkinButton..'.animation.curAnim.name')
          local selectionSkinHasInstaSwitch   = self.selectSkinPreSelectedIndex ~= self.selectSkinCurSelectedIndex
          if checkboxSkinCurrent == true and selectionSkinButtonAnimFinish == true or selectionSkinHasInstaSwitch then
               self.checkboxSkinObjectToggle[checkboxObjectTypes:lower()] = true
               playAnim(selectionSkinButton, 'check')
          end
          if checkboxSkinNonCurrent == true and selectionSkinButtonAnimFinish == true or selectionSkinHasInstaSwitch then
               self.checkboxSkinObjectToggle[checkboxObjectTypes:lower()] = false
               playAnim(selectionSkinButton, 'uncheck')
          end
     end
end

--- Syncs the display highlights for visual purposes.
---@return nil
function SkinNotesCheckbox:checkbox_sync()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     local skinObjectsPerIDs = self.totalSkinObjectID[self.selectSkinPagePositionIndex]
     for checkboxIndex = 1, #self.checkboxSkinObjectType do
          local checkboxObjectTypes      = self.checkboxSkinObjectType[checkboxIndex]
          local checkboxObjectTypeTag    = self.checkboxSkinObjectType[checkboxIndex]:upperAtStart()
          local checkboxSkinIndex        = self.checkboxSkinObjectIndex[checkboxObjectTypes:lower()]
          local checkboxSkinIndexPresent = table.find(skinObjectsPerIDs, checkboxSkinIndex)

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = checkboxSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if checkboxSkinIndex == self.selectSkinCurSelectedIndex or checkboxSkinIndex == checkboxSkinIndexPresent or luaSpriteExists(displaySkinIconButton) == true then
               local displaySelectionHighlightX = ('displaySelection${select}.x'):interpol({select = checkboxObjectTypeTag})
               local displaySelectionHighlightY = ('displaySelection${select}.y'):interpol({select = checkboxObjectTypeTag})
               setProperty(displaySelectionHighlightX, getProperty(displaySkinIconButton..'.x'))
               setProperty(displaySelectionHighlightY, getProperty(displaySkinIconButton..'.y'))
          end

          if checkboxSkinIndex == 0 or luaSpriteExists(displaySkinIconButton) == false then
               removeLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
          else
               addLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
          end
     end
end

--- Collection of similair methods of the checkbox selection functions.
---@return nil
function SkinNotesCheckbox:checkbox_selection()
     self:checkbox_selection_byclick()
     self:checkbox_selection_byhover()
     self:checkbox_selection_bycursor()
end

--- Main click functionality when interacting any checkbox buttons when selecting one.
--- Allows to select the skin to either the player or opponent along side displaying its animations.
---@return nil
function SkinNotesCheckbox:checkbox_selection_byclick()
     local function checkboxSelectionButtonClick(index, skin)
          if self.selectSkinCurSelectedIndex == 0 then
               return
          end
          
          local selectionSkinButton = 'selectionSkinButton'..skin:upperAtStart()
          local selectionSkinButtonClick    = clickObject(selectionSkinButton, 'camHUD')
          local selectionSkinButtonReleased = mouseReleased('left')
          if selectionSkinButtonClick == true and self.checkboxSkinObjectClicked[index] == false then
               self.checkboxSkinObjectClicked[index] = true
          end

          if selectionSkinButtonReleased == true and self.checkboxSkinObjectClicked[index] == true then
               if self.checkboxSkinObjectToggle[skin:lower()] == false then
                    self.checkboxSkinObjectIndex[skin:lower()] = self.selectSkinCurSelectedIndex
                    playAnim(selectionSkinButton, 'checking')
     
                    local checkboxSkinIndexField = 'checkboxSkinObjectIndex'..skin:upperAtStart()
                    SkinNoteSave:set(checkboxSkinIndexField, self.stateClass, self.checkboxSkinObjectIndex[skin:lower()])
               end
               if self.checkboxSkinObjectToggle[skin:lower()] == true then
                    self.checkboxSkinObjectIndex[skin:lower()] = 0
                    playAnim(selectionSkinButton, 'unchecking')
     
                    local checkboxSkinIndexField = 'checkboxSkinObjectIndex'..skin:upperAtStart()
                    SkinNoteSave:set(checkboxSkinIndexField, self.stateClass, self.checkboxSkinObjectIndex[skin:lower()])
               end
               playSound('remote_click')

               self.checkboxSkinObjectToggle[skin:lower()] = not self.checkboxSkinObjectToggle[skin:lower()]
               self.checkboxSkinObjectClicked[index]       = false
          end

          local selectionSkinButtonAnimFinish = getProperty(selectionSkinButton..'.animation.finished')
          local selectionSkinButtonAnimName   = getProperty(selectionSkinButton..'.animation.curAnim.name')
          if selectionSkinButtonAnimName == 'unchecking' and selectionSkinButtonAnimFinish == true then
               playAnim(selectionSkinButton, 'uncheck')
               return
          end
          if selectionSkinButtonAnimName == 'checking' and selectionSkinButtonAnimFinish == true then
               playAnim(selectionSkinButton, 'check')
               return
          end
     end

     for checkboxIndex = 1, #self.checkboxSkinObjectType do
          checkboxSelectionButtonClick(checkboxIndex, tostring(self.checkboxSkinObjectType[checkboxIndex]))
     end
end

--- Main hovering functionality when interacting any checkbox buttons when selecting any.
--- Allows the support of the cursor's sprite changing when hovering any checkbox buttons.
---@return nil
function SkinNotesCheckbox:checkbox_selection_byhover()
     local function checkboxSelectionButtonHover(index, skin)
          local selectionSkinButton = 'selectionSkinButton'..skin:upperAtStart()
          if self.checkboxSkinObjectClicked[index] == true then
               return
          end

          if hoverObject(selectionSkinButton, 'camHUD') == true then
               self.checkboxSkinObjectHovered[index] = true
          end
          if hoverObject(selectionSkinButton, 'camHUD') == false then
               self.checkboxSkinObjectHovered[index] = false
          end
     end

     for checkboxIndex = 1, #self.checkboxSkinObjectType do
          checkboxSelectionButtonHover(checkboxIndex, tostring(self.checkboxSkinObjectType[checkboxIndex]))
     end
end

--- Main cursor functionality when interacting any checkbox buttons when selecting any.
--- Changes the cursor's texture depending on its interaction (i.e. selecting and hovering).
---@return nil
function SkinNotesCheckbox:checkbox_selection_bycursor()
     for checkboxIndex = 1, #self.checkboxSkinObjectType do
          local selectionSkinButtonTemplate = {type = tostring(self.checkboxSkinObjectType[checkboxIndex]):upperAtStart()}
          local selectionSkinButton = ('selectionSkinButton${type}'):interpol(selectionSkinButtonTemplate)
          if hoverObject(selectionSkinButton, 'camHUD') == true and self.selectSkinCurSelectedIndex == 0 then
               if mouseClicked('left') or mousePressed('left') then 
                    playAnim('mouseTexture', 'disabledClick', true)
               else
                    playAnim('mouseTexture', 'disabled', true)
               end
     
               if mouseClicked('left') then 
                    playSound('cancel') 
               end
               goto skipCheckboxBlocked
          end

          if self.checkboxSkinObjectClicked[checkboxIndex] == true then
               playAnim('mouseTexture', 'handClick', true)
               return
          end
          if self.checkboxSkinObjectHovered[checkboxIndex] == true then
               playAnim('mouseTexture', 'hand', true)
               return
          end
          ::skipCheckboxBlocked::
     end
end

return SkinNotesCheckbox