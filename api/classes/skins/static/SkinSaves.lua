local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'

---
---@class SkinSaves
local SkinSaves = {}

--- Creates a save for this mod, that's it.
---@param saveName string The global save name to utilize with.
---@param saveFolder? string The specified folder to save to.
---@return nil
function SkinSaves:new(saveName, saveFolder, saveInit)
     local self = setmetatable({}, {__index = self})
     self.saveName   = saveName
     self.saveFolder = savePath

     if saveInit == true then
          initSaveData(self.saveName, self.saveFolder)
     end
     return self
end

--- Sets the data field with a new value from the save game data or be created with inherited field value. 
--- If the said data field currently doesn't exist yet.
---@param tag string The specified data field to set a new value to.
---@param prefix string The prefix to concatenate with a tag.
---@param value any The new value to set it to.
---@return nil
function SkinSaves:set(tag, prefix, value)
     setDataFromSave(self.saveName, F"{prefix}_{tag}", value)
end

--- Gets the data field current value from the save game data.
---@param tag string The specified data field to get its current value from.
---@param prefix string The prefix to concatenate with a tag.
---@param default any The field data's default value, if the inherited value doesn't exist.
---@return any
function SkinSaves:get(tag, prefix, default)
     return getDataFromSave(self.saveName, F"{prefix}_{tag}", default)
end

--- Saves the applied changes from the save game data, updates its content with new values.
---@return nil
function SkinSaves:flush()
     flushSaveData(self.saveName)
end

--- Erases the specified save game data, removes the sub-folder within the application data folder.
---@return nil
function SkinSaves:erase()
     eraseSaveData(self.saveName)
end

return SkinSaves