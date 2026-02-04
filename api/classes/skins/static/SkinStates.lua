local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'

local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed

--- Maintains the skin classes' creation, switching, and saving.
---@class SkinStates
local SkinStates = {}
local SkinStatesGSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

--- Initializes the main attributes for the skinstate.
---@param stateSkins table The skinstate classes to maintain.
---@param stateSelect string The current skinstate to create first.
---@return table
function SkinStates:new(stateSkins, stateSelect)
     local self = setmetatable({}, {__index = self})
     self.stateSkins   = stateSkins
     self.stateSelect  = stateSelect
     
     return self
end

--- Loads in the component attributes for the skinstate to maintains its skin classes.
--- All of the component attributes are VERY IMPORTNAT, so uh don't touch it pls.
---@return nil
function SkinStates:load()
     for index, states in pairs(self.stateSkins) do
          self.stateSkins[index] = nil
          self.stateSkins[states.stateClass] = states
     end
     
     self.__stateSkinNames = table.keys(self.stateSkins)
     self.__stateSkinIndex = table.find(self.__stateSkinNames, self.stateSelect)
     self.__stateSkinMain  = self.stateSkins[self.__stateSkinNames[self.__stateSkinIndex]]
end

--- Swaping helper function for switching through different skinstates, no way!
---@protected
---@return nil
function SkinStates:_swap()
     for skins, states in pairs(self.stateSkins) do
          if skins ~= self.__stateSkinNames[self.__stateSkinIndex] then
               states:destroy()
          end
     end
     self:create()
     SkinStatesGSave:set('dataStateName', '', self.__stateSkinNames[self.__stateSkinIndex])
end

--- Switches the current skinstate to another skinstate, self-explanatory.
---@return nil
function SkinStates:switch()
     local conditionPressedSwitchLeft  = keyboardJustConditionPressed('O', not getVar('skinSearchInputFocus'))
     local conditionPressedSwitchRight = keyboardJustConditionPressed('P', not getVar('skinSearchInputFocus'))
     if not (conditionPressedSwitchLeft or conditionPressedSwitchRight) then 
          return 
     end

     local MAX_STATE = self.__stateSkinIndex < #self.__stateSkinNames
     local MIN_STATE = self.__stateSkinIndex > 1
     if conditionPressedSwitchRight and MAX_STATE then
          self.__stateSkinIndex = self.__stateSkinIndex + 1
          self.__stateSkinMain  = self.stateSkins[self.__stateSkinNames[self.__stateSkinIndex]]
          self:_swap()
     end
     if conditionPressedSwitchLeft and MIN_STATE then
          self.__stateSkinIndex = self.__stateSkinIndex - 1
          self.__stateSkinMain  = self.stateSkins[self.__stateSkinNames[self.__stateSkinIndex]]
          self:_swap()
     end
end

--- Main skinstate creation, obviously self-explanatory.
---@return nil
function SkinStates:create()
     self.__stateSkinMain:load()
     self.__stateSkinMain:load_handling()
     self.__stateSkinMain:generate()
end

--- Main skinstate update, obviously self-explanatory.
---@return nil
function SkinStates:update()
     self.__stateSkinMain:page_scrollbar()
     self.__stateSkinMain:page_moved()
     self.__stateSkinMain:search()
     self.__stateSkinMain:selection()
     self.__stateSkinMain:checkbox_selection()
     self.__stateSkinMain:checkbox_checking()
     self.__stateSkinMain:preview_selection()
     self.__stateSkinMain:preview_toggle()
     self.__stateSkinMain:preview_animation()
end

--- Main skinstate saving, obviously self-explanatory.
---@return nil
function SkinStates:save()
     for _,states in pairs(self.stateSkins) do
          states:save()
     end
end

return SkinStates