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

---@enum CHARACTERS
local CHARACTERS = {
     PLAYER   = 1,
     OPPONENT = 2
}

--- Childclass extension, main checkbox component functionality for the note skin state.
---@class SkinNotesCheckbox
local SkinNotesCheckbox = {}

--- Creates the checkboxes graphic sprites and its text.
--- Additionally the selection highlight are also created here.
---@return nil
function SkinNotesCheckbox:checkbox_create()
     local CHECKBOX_SKIN_PLAYER_OFFSET_X   = 12
     local CHECKBOX_SKIN_OPPONENT_OFFSET_X = 12 + 232

     local CHECKBOX_SKIN_PLAYER_POSITION_X   = 775 + CHECKBOX_SKIN_PLAYER_OFFSET_X
     local CHECKBOX_SKIN_OPPONENT_POSITION_X = 775 + CHECKBOX_SKIN_OPPONENT_OFFSET_X

     local checkboxSkinPositionX = {CHECKBOX_SKIN_PLAYER_POSITION_X, CHECKBOX_SKIN_OPPONENT_POSITION_X}
     local checkboxSkinColors    = {'31b0d1', 'af66ce'}
     for CharNames, CharValues in pairs(CHARACTERS) do
          local checkboxSkinButtonTag    = F"selectionSkinButton{CharNames:upperAtStart(true)}"
          local checkboxSkinTitleTag     = F"selectionSkinTextButton{CharNames:upperAtStart(true)}"
          local checkboxSkinSelectionTag = F"displaySelection{CharNames:upperAtStart(true)}"

          makeAnimatedLuaSprite(checkboxSkinButtonTag, 'checkboxanim', checkboxSkinPositionX[CharValues], 330)
          addAnimationByPrefix(checkboxSkinButtonTag, 'check', 'checkbox finish0', 24, false)
          addAnimationByPrefix(checkboxSkinButtonTag, 'checking', 'checkbox anim0', 24, false)
          addAnimationByPrefix(checkboxSkinButtonTag, 'unchecking', 'checkbox anim reverse0', 24, false)
          addAnimationByPrefix(checkboxSkinButtonTag, 'uncheck', 'checkbox0', 24, false)
          playAnim(checkboxSkinButtonTag, 'uncheck')
          scaleObject(checkboxSkinButtonTag, 0.4, 0.4)
          setObjectCamera(checkboxSkinButtonTag, 'camHUD')
          addOffset(checkboxSkinButtonTag, 'check', 34.5, 36.1415926536) -- ignore that guy
          addOffset(checkboxSkinButtonTag, 'checking', 48.5, 42)
          addOffset(checkboxSkinButtonTag, 'unchecking', 44.5, 44)
          addOffset(checkboxSkinButtonTag, 'uncheck', 33.3, 32.2)
          setProperty(F"{checkboxSkinButtonTag}.antialiasing", false)
          addLuaSprite(checkboxSkinButtonTag)

          local CHECKBOX_SKIN_TITLE_OFFSET_X   = 60
          local CHECKBOX_SKIN_TITLE_POSITION_X = checkboxSkinPositionX[CharValues] + CHECKBOX_SKIN_TITLE_OFFSET_X
          makeLuaText(checkboxSkinTitleTag, CharNames:upperAtStart(true), 0, CHECKBOX_SKIN_TITLE_POSITION_X, 337)
          setTextFont(checkboxSkinTitleTag, 'sonic.ttf')
          setTextSize(checkboxSkinTitleTag, 30)
          setTextColor(checkboxSkinTitleTag, checkboxSkinColors[CharValues])
          setObjectCamera(checkboxSkinTitleTag, 'camHUD')
          setProperty(F"{checkboxSkinTitleTag}.antialiasing", false)
          addLuaText(checkboxSkinTitleTag)

          makeAnimatedLuaSprite(checkboxSkinSelectionTag, 'ui/display_selected', 0, 0)
          scaleObject(checkboxSkinSelectionTag, 0.8, 0.8)
          addAnimationByPrefix(checkboxSkinSelectionTag, 'player', 'selected-player', 24, false)
          addAnimationByPrefix(checkboxSkinSelectionTag, 'opponent', 'selected-opponent', 24, false)

          local CHECKBOX_SKIN_SELECTION_MODIFY_OFFSET    = 5
          local CHECKBOX_SKIN_SELECTION_CURRENT_OFFSET_X = getProperty(F"{checkboxSkinSelectionTag}.offset.x") + CHECKBOX_SKIN_SELECTION_MODIFY_OFFSET
          local CHECKBOX_SKIN_SELECTION_CURRENT_OFFSET_Y = getProperty(F"{checkboxSkinSelectionTag}.offset.y") + CHECKBOX_SKIN_SELECTION_MODIFY_OFFSET
          addOffset(checkboxSkinSelectionTag, 'player', CHECKBOX_SKIN_SELECTION_CURRENT_OFFSET_X, CHECKBOX_SKIN_SELECTION_CURRENT_OFFSET_Y)
          addOffset(checkboxSkinSelectionTag, 'opponent', CHECKBOX_SKIN_SELECTION_CURRENT_OFFSET_X, CHECKBOX_SKIN_SELECTION_CURRENT_OFFSET_Y)
          playAnim(checkboxSkinSelectionTag, CharNames:lower())
          setObjectCamera(checkboxSkinSelectionTag, 'camHUD')
          setProperty(F"{checkboxSkinSelectionTag}.antialiasing", false)
     end
     self:checkbox_sync()
end

--- Destroys the checkboxes graphic sprites and its text, used only for switching states.
--- Additionally the selection highlight are also destroyed here. (very important information)
---@return nil
function SkinNotesCheckbox:checkbox_destroy()
     for CharNames, _ in pairs(CHARACTERS) do
          local checkboxSkinButtonTag    = F"selectionSkinButton{CharNames:upperAtStart(true)}"
          local checkboxSkinTitleTag     = F"selectionSkinTextButton{CharNames:upperAtStart(true)}"
          local checkboxSkinSelectionTag = F"displaySelection{CharNames:upperAtStart(true)}"
          removeLuaSprite(checkboxSkinButtonTag, true)
          removeLuaSprite(checkboxSkinTitleTag, true)
          removeLuaSprite(checkboxSkinSelectionTag, false)
     end
end

--- The checkboxes main checking functionality and animation.
--- Selecting its current skins for its corresponding state to be used in gameplay.
---@return nil
function SkinNotesCheckbox:checkbox_checking()
     for CharNames, CharValues in pairs(CHARACTERS) do
          local checkboxSkinChars      = self.CHECKBOX_SKIN_OBJECT_CHARS[CharValues]
          local checkboxSkinCurrent    = checkboxSkinChars == self.SELECT_SKIN_CUR_SELECTION_INDEX
          local checkboxSkinNonCurrent = checkboxSkinChars ~= self.SELECT_SKIN_CUR_SELECTION_INDEX
          if self.SELECT_SKIN_CUR_SELECTION_INDEX == 0 and checkboxSkinCurrent == true then
               return
          end
          local checkboxSkinButtonTag        = F"selectionSkinButton{CharNames:upperAtStart(true)}"
          local checkboxSkinButtonAnimName   = getProperty(F"{checkboxSkinButtonTag}.animation.curAnim.name")
          local checkboxSkinButtonAnimFinish = getProperty(F"{checkboxSkinButtonTag}.animation.finished")
     
          local checkboxSkinButtonIsInstaSwitch = self.SELECT_SKIN_PRE_SELECTION_INDEX ~= self.SELECT_SKIN_CUR_SELECTION_INDEX
          if checkboxSkinCurrent == true and checkboxSkinButtonAnimFinish == true or checkboxSkinButtonIsInstaSwitch then
               self.CHECKBOX_SKIN_OBJECT_TOGGLE[CharValues] = true
               playAnim(checkboxSkinButtonTag, 'check')
          end
          if checkboxSkinNonCurrent == true and checkboxSkinButtonAnimFinish == true or checkboxSkinButtonIsInstaSwitch then
               self.CHECKBOX_SKIN_OBJECT_TOGGLE[CharValues] = false
               playAnim(checkboxSkinButtonTag, 'uncheck')
          end
     end
end

--- Syncing of the position and offset of the selection highlight, obviously for visual purposes.
---@protected
---@return nil
function SkinNotesCheckbox:checkbox_sync()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     local skinObjectsPerIDs = self.TOTAL_SKIN_OBJECTS_ID[self.SELECT_SKIN_PAGE_INDEX]
     for CharNames, CharValues in pairs(CHARACTERS) do
          local checkboxSkinChars = self.CHECKBOX_SKIN_OBJECT_CHARS[CharValues]
          local CHECK_CHECKBOX_SKIN_INDEX_IS_CURRENT = checkboxSkinChars == self.SELECT_SKIN_CUR_SELECTION_INDEX
          local CHECK_CHECKBOX_SKIN_INDEX_IS_PRESENT = checkboxSkinChars == table.find(skinObjectsPerIDs, checkboxSkinChars) 

          local displaySkinIconButtonTag = F"displaySkinIconButton{self.stateClass:upperAtStart()}-{checkboxSkinChars}"
          local checkboxSkinSelectionTag = F"displaySelection{CharNames:upperAtStart(true)}"
          local checkboxSkinButtonTag    = F"selectionSkinButton{CharNames:upperAtStart(true)}"

          if CHECK_CHECKBOX_SKIN_INDEX_IS_CURRENT or CHECK_CHECKBOX_SKIN_INDEX_IS_PRESENT or luaSpriteExists(displaySkinIconButtonTag) == true then
               setProperty(F"{checkboxSkinSelectionTag}.x", getProperty(F"{displaySkinIconButtonTag}.x"))
               setProperty(F"{checkboxSkinSelectionTag}.y", getProperty(F"{displaySkinIconButtonTag}.y"))
          end

          if checkboxSkinChars == 0 or luaSpriteExists(displaySkinIconButtonTag) == false then
               removeLuaSprite(checkboxSkinSelectionTag, false)
          else
               addLuaSprite(checkboxSkinSelectionTag, false)
          end
     end
end

--- Collection group of checkbox selection methods.
---@return nil
function SkinNotesCheckbox:checkbox_selection()
     self:checkbox_selection_byclick()
     self:checkbox_selection_byhover()
     self:checkbox_selection_bycursor()
end

--- Main checkbox clicking functionality and animations.
--- Allowing the selecting of the corresponding skin in gameplay.
---@return nil
function SkinNotesCheckbox:checkbox_selection_byclick()
     for CharNames, CharValues in pairs(CHARACTERS) do
          local checkboxSkinButtonTag     = F"selectionSkinButton{CharNames:upperAtStart(true)}"
          local checkboxSkinButtonClicked = clickObject(checkboxSkinButtonTag, 'camHUD')
          local checkboxSkinButtonIsInteract = checkboxSkinButtonClicked == true or mouseReleased('left') == true
          if not checkboxSkinButtonIsInteract or self.SELECT_SKIN_CUR_SELECTION_INDEX == 0 then
               goto SKIP_NO_INTERACTION_BYCLICK
          end
          if checkboxSkinButtonClicked == true and self.CHECKBOX_SKIN_OBJECT_CLICKED[CharValues] == false then
               self.CHECKBOX_SKIN_OBJECT_CLICKED[CharValues] = true
          end

          if mouseReleased('left') == true and self.CHECKBOX_SKIN_OBJECT_CLICKED[CharValues] == true then
               if self.CHECKBOX_SKIN_OBJECT_TOGGLE[CharValues] == false then
                    self.CHECKBOX_SKIN_OBJECT_CHARS[CharValues] = self.SELECT_SKIN_CUR_SELECTION_INDEX
                    self:checkbox_sync()
                    self:search_checkbox_sync()
                    playAnim(checkboxSkinButtonTag, 'checking')
                    
                    local CHECKBOX_SKIN_OBJECT_CHARS = F"CHECKBOX_SKIN_OBJECT_CHARS_{CharNames:upperAtStart()}"
                    SkinNoteSave:set(CHECKBOX_SKIN_OBJECT_CHARS, self.stateClass:upper(), self.CHECKBOX_SKIN_OBJECT_CHARS[CharValues])
               end
               if self.CHECKBOX_SKIN_OBJECT_TOGGLE[CharValues] == true then
                    self.CHECKBOX_SKIN_OBJECT_CHARS[CharValues] = 0
                    self:checkbox_sync()
                    self:search_checkbox_sync()
                    playAnim(checkboxSkinButtonTag, 'unchecking')
     
                    local CHECKBOX_SKIN_OBJECT_CHARS = F"CHECKBOX_SKIN_OBJECT_CHARS_{CharNames:upperAtStart()}"
                    SkinNoteSave:set(CHECKBOX_SKIN_OBJECT_CHARS, self.stateClass:upper(), self.CHECKBOX_SKIN_OBJECT_CHARS[CharValues])
               end
               playSound('remote_click')

               self.CHECKBOX_SKIN_OBJECT_TOGGLE[CharValues]  = not self.CHECKBOX_SKIN_OBJECT_TOGGLE[CharValues]
               self.CHECKBOX_SKIN_OBJECT_CLICKED[CharValues] = false
          end
          
          local checkboxSkinButtonAnimName   = getProperty(F"{checkboxSkinButtonTag}.animation.curAnim.name")
          local checkboxSkinButtonAnimFinish = getProperty(F"{checkboxSkinButtonTag}.animation.finished")
          if checkboxSkinButtonAnimName == 'unchecking' and checkboxSkinButtonAnimFinish == true then
               playAnim(checkboxSkinButtonTag, 'uncheck')
          end
          if checkboxSkinButtonAnimName == 'checking' and checkboxSkinButtonAnimFinish == true then
               playAnim(checkboxSkinButtonTag, 'check')
          end
          ::SKIP_NO_INTERACTION_BYCLICK::
     end
end

--- Main checkbox hovering functionality and animations.
--- Allowing the cursor's sprite to change its corresponding sprite when hovering for visual aid.
---@return nil
function SkinNotesCheckbox:checkbox_selection_byhover()
     for CharNames, CharValues in pairs(CHARACTERS) do
          local checkboxSkinButtonTag = F"selectionSkinButton{CharNames:upperAtStart(true)}"
          if self.CHECKBOX_SKIN_OBJECT_CLICKED[CharValues] == true then
               return
          end

          if hoverObject(checkboxSkinButtonTag, 'camHUD') == true then
               self.CHECKBOX_SKIN_OBJECT_HOVERED[CharValues] = true
          end
          if hoverObject(checkboxSkinButtonTag, 'camHUD') == false then
               self.CHECKBOX_SKIN_OBJECT_HOVERED[CharValues] = false
          end
     end
end

--- Main cursor functionality for the checkboxes and its animations.
--- Allowing the cursor's sprite to change depending on its interaction (i.e. selecting and hovering).
---@return nil
function SkinNotesCheckbox:checkbox_selection_bycursor()
     for CharNames, CharValues in pairs(CHARACTERS) do
          local checkboxSkinButtonTag     = F"selectionSkinButton{CharNames:upperAtStart(true)}"
          local checkboxSkinButtonHovered = hoverObject(checkboxSkinButtonTag, 'camHUD')
          if checkboxSkinButtonHovered == true and self.SELECT_SKIN_CUR_SELECTION_INDEX == 0 then
               if mouseClicked('left') or mousePressed('left') then 
                    playAnim('mouseTexture', 'disabledClick', true)
               else
                    playAnim('mouseTexture', 'disabled', true)
               end
     
               if mouseClicked('left') then 
                    playSound('cancel') 
               end
               goto SKIP_CHECKBOX_BLOCKED
          end

          if self.CHECKBOX_SKIN_OBJECT_CLICKED[CharValues] == true then
               playAnim('mouseTexture', 'handClick', true)
               return
          end
          if self.CHECKBOX_SKIN_OBJECT_HOVERED[CharValues] == true then
               playAnim('mouseTexture', 'hand', true)
               return
          end
          ::SKIP_CHECKBOX_BLOCKED::
     end
end

return SkinNotesCheckbox