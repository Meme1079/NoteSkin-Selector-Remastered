local string = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string' 
local table  = table

require 'table.new'

--- Returns the table's key by finding its value
---@param tab table The table itself to use
---@param value any The value from the table to find its keys
---@return any
function table.find(tab, value)
     for k,v in pairs(tab) do
          if v == value then return k end
     end
end

--- Moves the selection(s) of table values to another new table
---@param tab table The table to move the selection(s) of values
---@param startPos number The starting position to start
---@param endPos number The starting position to end
---@param dest table The new destination to store the selection(s) of values
---@param ind number An optional parameter, The table index to place the values; Default value: 1
---@return table
function table.move(tab, startPos, endPos, dest, ind)
     local ind = ind or 1
     for i = startPos, endPos do
          table.insert(dest, ind, tab[i])
     end
     return dest
end

--- Gets the keys from the given table.
---@param tab table The table to get its keys from
---@return table
function table.keys(tab)
     local result = table.new(#tab, 0)
     for k,_ in pairs(tab) do
          result[#result + 1] = k
     end
     return result
end

--- Copies the elements from a table
---@param tab table The table to copy its value
---@return table
function table.clone(tab)
     local result = table.new(#tab, 0)
     for k,v in pairs(tab) do
          result[k] = v
     end
     return result
end

--- Repeats the elements inside a table
---@param size number The size to inherit
---@param element number The element to repeat each value
---@return value
function table.rep(size, element)
     local result = table.new(#tab, 0)
     for i = 1, size do
          result[i] = element
     end
     return result
end

--- Subtring, works exactly the same as string:sub() function but for tables
--- Removes any elements that isn't selected
---@param tab table The table's specific values to be extracted.
---@param startPos number The starting position of the value to be extracted.
---@param endPos number The ending position of the value to end the extraction.
---@return table
function table.sub(tab, startPos, endPos)
     local faker = table.new(#tab, 0)
     for i = startPos, endPos or #tab do
          table.insert(faker, tab[i])
     end
     return faker
end

--- Merges two or more array-like table into one
---@param tab table The table to merge the contents with other tables
---@param extras table The extra table(s) to merge with
---@return table
function table.merge(tab, ...)
     local tabMerge      = table.concat(tab, ', ') .. ', '
     local tabArgMerge   = ''
     local tabArgContent = ({...})
     for i = 1, #tabArgContent do
          tabArgMerge = tabArgMerge .. table.concat(tabArgContent[i], ', ') .. ', '
     end

     local tabResult = tabMerge .. tabArgMerge
     return tabResult:sub(1, #tabResult - #(', ')):split(', ')
end

--- Filters any elements from a table, provided by the `func` parameter
---@param tab table The table to filter its elements
---@param func function The function to provide the filter code
---@return table
function table.filter(tab, func)
     local result = table.new(#tab, 0)
     for i = 1, #tab do
          if func(tab[i]) == true then
               table.insert(result, tab[i])
          end
     end
     return result
end

--- Tallies the table's content by a numeric loop; adding the iterated numbers until it reaches its limit
--- Creates a new table with the tallied contents
---@param min number The minimum value to start
---@param max number The maximum value to end
---@param iter number The iteraion number to add while looping
---@return table
function table.tally(min, max, iter)
     local result = table.new(max, 0)
     for index = min, max, iter or 1 do
          result[#result + 1] = index
     end
     return result
end

--- Removes any same element within a table
---@param tab table The table to remove any same elements within
---@param reverse boolean Only gets the same elements within
---@return table
function table.singularity(tab, reverse)
     local diff = table.new(#tab, 0)
     local same = table.new(#tab, 0)
     for index = 1, #tab do
          for subindex = 1, #same do 
               if tab[index] == same[subindex] then
                    diff[#diff + 1] = same[subindex]
                    goto skip_duplicate
               end
          end
          same[index] = tab[index]
          ::skip_duplicate::
     end
     return reverse == true and diff or same
end

return table