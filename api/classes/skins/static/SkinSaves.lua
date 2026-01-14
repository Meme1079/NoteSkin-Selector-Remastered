local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'

--- Saves the skinstates saved data, self-explanatory.
---@class SkinSaves
local SkinSaves = {}

--- Initializes the main attributes for the skinstate saves.
---@param saveName string The global name to reference for saving data, will also be the save file name.
---@param saveFolder? string The folder for the saved data to be saved to.
---@return nil
function SkinSaves:new(saveName, saveFolder)
     local self = setmetatable({}, {__index = self})
     self.saveName   = saveName
     self.saveFolder = savePath

     return self
end

--- Creates the save data for the skinstate, required.
---@return nil
function SkinSaves:init()
     initSaveData(self.saveName, self.saveFolder)
end

--- Sets the saved data field with a new value.
--- Creates the saved data field, if said data field doesn't exists.
---@param tag string The saved data field to set a new value to.
---@param prefix string The skinstate prefix to its corresponding skin.
---@param value any The given new value to set it to.
---@return nil
function SkinSaves:set(tag, prefix, value)
     local tagFormat = tag == '' and prefix..tag or F"{prefix}_{tag}"
     setDataFromSave(self.saveName, tagFormat, value)
end

--- Gets the saved data field current value.
---@param tag string The saved data field to get the current value from.
---@param prefix string The skinstate prefix to its corresponding skin.
---@param value any The default value, if said data field doesn't have one.
---@return any
function SkinSaves:get(tag, prefix, default)
     local tagFormat = tag == '' and prefix..tag or F"{prefix}_{tag}"
     return getDataFromSave(self.saveName, tagFormat, default)
end

--- Saves the applied changes of the saved data to the save file.
---@return nil
function SkinSaves:flush()
     flushSaveData(self.saveName)
end

--- Erases the saved data, alongside removing the save file.
---@return nil
function SkinSaves:erase()
     eraseSaveData(self.saveName)
end

return SkinSaves