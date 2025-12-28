local function filter_search(list, input)
     local search_result = {}
     for i = 1, #list, 1 do
          local startPos = list[i]:upper():find(input:upper())
          local wordPos  = startPos == nil and -1 or startPos
          if wordPos > -1 and #search_result < 16 then
               search_result[#search_result + 1] = list[i]
          end
     end
     return search_result
end

local isMovedX = getPropertyFromClass('flixel.FlxG', 'mouse.deltaScreenX')
local isMovedY = getPropertyFromClass('flixel.FlxG', 'mouse.deltaScreenY')
if isMovedX == 0 and isMovedY == 0 then
     return
end