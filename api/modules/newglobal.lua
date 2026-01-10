---@module global
local global = {}

---@enum DIRECTION
global.DIRECTION = {
     LEFT  = 1,
     RIGHT = 2
}
---@enum CHARACTERS
global.CHARACTERS = {
     PLAYER   = 1,
     OPPONENT = 2
}

---@alias ParentClasses
---| 'inherit' # The child class to inherit and derived from its based parent class.
---| 'extends' # The extension properties of this class. 

--- Allows for the classes inherit multiple parent classes either as an inherit or extension.
---@param parentClasses ParentClasses The multiple classes to inherit.
---@return table Returns all the parent classes into one table.
function global.inheritedClasses(parentClasses)
     local parentClassesOutput = {}
     if parentClasses.extends ~= nil then
          for _, classes in pairs(parentClasses.extends) do
               parentClassesOutput[#parentClassesOutput+1] = classes
          end
     end
     if parentClasses.inherit ~= nil then
          for _, classes in pairs(parentClasses.inherit) do
               parentClassesOutput[#parentClassesOutput+1] = classes
          end
     end

     local classes = {}
     function classes:__index(index)
          for classesIndex = 1, #parentClassesOutput do
               local result = parentClassesOutput[classesIndex][index]
               if result then
                    return result
               end
          end
          return nil
     end
     return setmetatable({}, classes)
end

---@type number
global.MAX_NUMBER_CHUNK = 16

return global