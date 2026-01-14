---@module
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

---@alias ChildClasses
---| 'inherit' # The childclass to inherit and dervieves its properties from a parentclass.
---| 'extends' # The childclass extensions to be fully chained and link to its main parentclass.

--- Inherits and/or chain extensions from multiple childclasses to its main parentclass.
---@param childClasses ChildClasses The multiple classes to inherit.
---@return table Returns all the parent classes into one table.
function global.inheritedClasses(childClasses)
     local childClassesOutput = {}
     if childClasses.extends ~= nil then
          for _, classes in pairs(childClasses.extends) do
               childClassesOutput[#childClassesOutput+1] = classes
          end
     end
     if childClasses.inherit ~= nil then
          for _, classes in pairs(childClasses.inherit) do
               childClassesOutput[#childClassesOutput+1] = classes
          end
     end

     local classes = {}
     function classes:__index(index)
          for classesIndex = 1, #childClassesOutput do
               local result = childClassesOutput[classesIndex][index]
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