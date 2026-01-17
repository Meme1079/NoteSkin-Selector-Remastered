require 'table.new'
local global = {}

function global.switch(value) -- calling operation (); first argument value
     return function(cases)   -- calling operation (); "second" argument table
          if cases[value] or cases.default then -- checks if any cases or default case exists
               return (cases[value] or cases.default)()
          end
          return -- if not, return nothing
     end
end

function global.toAllMetatable(tab, default)
     local duplicateMetaData = { 
          __index    = function() return default end,
          __newindex = function() return default end
     }

     local duplicate = table.new(0xff, 0)
     for keys, values in pairs(tab) do
          if type(values) == "table" then
               values = global.toAllMetatable(setmetatable(values, duplicateMetaData), default)
          else
               values = values
          end
          duplicate[keys] = values
     end
     return setmetatable(duplicate, duplicateMetaData)
end

return global