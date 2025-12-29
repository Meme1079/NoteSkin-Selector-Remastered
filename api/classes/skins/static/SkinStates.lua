local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local ease      = require 'mods.NoteSkin Selector Remastered.api.libraries.ease.ease'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local switch = global.switch
local createTimer       = funkinlua.createTimer
local addCallbackEvents = funkinlua.addCallbackEvents
local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionPress    = funkinlua.keyboardJustConditionPress
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

local SkinStateSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

---@class SkinStates
local SkinStates = {}

--- Initializes the creation of multiple states to control over (i.e. switching and stuff).
---@param stateSkins table The given states to control over.
---@param stateSelect string The current state to first display when loading.
---@return table
function SkinStates:new(stateSkins, stateSelect)
     local self = setmetatable({}, {__index = self})
     self.stateSkins   = stateSkins
     self.stateSelect  = stateSelect
     
     return self
end

--- Loads multiple-unique data to the class itself, to be used later.
---@return nil
function SkinStates:load()
     for index, states in pairs(self.stateSkins) do
          self.stateSkins[index] = nil
          self.stateSkins[states.stateClass] = states
     end

     local function getStateSkinIndex()
          for skins, states in pairs(self.stateSkins) do
               if skins == self.stateSelect then
                    return table.find(self.stateSkinNames, skins)
               end
          end
     end

     self.stateSkinNames = table.keys(self.stateSkins)
     self.stateSkinIndex = getStateSkinIndex()
     self.stateSkinMain  = self.stateSkins[self.stateSkinNames[self.stateSkinIndex]]
end

--- Switches state to another different state.
---@return nil
function SkinStates:switch()
     local conditionPressedSwitchStateLeft  = keyboardJustConditionPressed('O', not getVar('skinSearchInputFocus'))
     local conditionPressedSwitchStateRight = keyboardJustConditionPressed('P', not getVar('skinSearchInputFocus'))
     if not (conditionPressedSwitchStateLeft or conditionPressedSwitchStateRight) then 
          return 
     end

     local function swapStateSkin()
          for skins, states in pairs(self.stateSkins) do
               if skins ~= self.stateSkinNames[self.stateSkinIndex] then
                    states:destroy()
                    states:checkbox_destroy()
               end
          end
          self:create()
          SkinStateSave:set('dataStateName', '', self.stateSkinNames[self.stateSkinIndex])
     end

     if conditionPressedSwitchStateRight and self.stateSkinIndex < #self.stateSkinNames then
          self.stateSkinIndex = self.stateSkinIndex + 1
          self.stateSkinMain  = self.stateSkins[self.stateSkinNames[self.stateSkinIndex]]
          swapStateSkin()
     end
     if conditionPressedSwitchStateLeft  and self.stateSkinIndex > 1 then
          self.stateSkinIndex = self.stateSkinIndex - 1
          self.stateSkinMain  = self.stateSkins[self.stateSkinNames[self.stateSkinIndex]]
          swapStateSkin()
     end     
end

--- Creates the current state.
---@return nil
function SkinStates:create()
     switch(self.stateSkinNames[self.stateSkinIndex]) {
          notes = function()
               self.stateSkinMain:load()
               self.stateSkinMain:load_preventError()
               self.stateSkinMain:save_load()
               self.stateSkinMain:precache()
               self.stateSkinMain:preload()
               self.stateSkinMain:checkbox_create()
               self.stateSkinMain:preview()
               self.stateSkinMain:page_slider_marks()
          end,
          splashes = function()
               self.stateSkinMain:load()
               self.stateSkinMain:load_preventError()
               self.stateSkinMain:save_load()
               self.stateSkinMain:precache()
               self.stateSkinMain:preload()
               self.stateSkinMain:checkbox_create()
               self.stateSkinMain:preview()
               self.stateSkinMain:preview_notes()
               self.stateSkinMain:page_slider_marks()
          end
     }
end

--- Updates the current state's data.
---@return nil
function SkinStates:update()
     switch(self.stateSkinNames[self.stateSkinIndex]) {
          notes = function()
               self.stateSkinMain:page_slider()
               self.stateSkinMain:page_moved()
               self.stateSkinMain:selection()
               self.stateSkinMain:search()
               self.stateSkinMain:checkbox_checking()
               self.stateSkinMain:checkbox_selection()
               self.stateSkinMain:preview_selection()
               self.stateSkinMain:preview_animation()
          end,
          splashes = function()
               self.stateSkinMain:page_slider()
               self.stateSkinMain:page_moved()
               self.stateSkinMain:selection()
               self.stateSkinMain:search()
               self.stateSkinMain:checkbox_checking()
               self.stateSkinMain:checkbox_selection()
               self.stateSkinMain:preview_selection()
               self.stateSkinMain:preview_animation()
          end
     }
end

--- Saves the state's data.
---@return nil
function SkinStates:save()
     for _,states in pairs(self.stateSkins) do
          states:save()
     end
end

return SkinStates