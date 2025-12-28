function funkinlua.parseJson(content)
     local addElementIndex = {}
     function addElementIndex:__index(index)
          for ind = 1, #content do
               local globalKey = ind..'_'..index
               if rawget(self, globalKey) ~= nil then
                    return rawget(self, globalKey)
               end
          end
     end     
     function addElementIndex:__newindex(index, value)
          for ind = 1, #content do
               local globalKey = ind..'_'..index
               if rawget(self, globalKey) ~= nil then
                    rawset(self, globalKey, value)
                    break
               end
               if ind == #content then
                    rawset(self, 'UNDEFINED_'..index, value)
               end
          end
     end

     local content = content:split('\n')
     local function orderedNumeric()
          local result = {}
          local j = 0
          for k,v in pairs(content) do
               if v:match('"%w-":%s?') then
                    j = j + 1
               end
               result[#result + 1] = v:gsub('"(%w-":%s?)', '"'..tostring(j)..'_%1')
          end
          local final = table.concat(result, '\n')
          return json.parse(final:sub(1, #final - 1))
     end
     local function setMetaDeepCopy(original)
          local copy = {}
          for k,v in pairs(original) do
               if type(v) == "table" then
                    v = setMetaDeepCopy(v)
               end
               copy[k] = v
          end
          return setmetatable(copy, addElementIndex)
     end
     return setMetaDeepCopy(orderedNumeric())
end

function funkinlua.stringifyJson(parseJson, path)
     local save = save ~= nil and false or true

     local stupidJson = setmetatable(parseJson, nil)
     local resultJson = json.stringify(stupidJson, nil, 5, false, true):gsub('"%d+_(%w-":%s?)', '"%1')

     saveFile(path, resultJson)
     return resultJson
end

local function calculatePosition(skinType)
     local xpos = {20, 220 - 30, (220 + 170) - 30, (220 + (170 * 2)) - 30}
     local ypos = -155 -- increments, in each 4th value

     local xindex = 0
     local result = {}
     for skinIndex = 1, #skinType do
          xindex = xindex + 1
          if xindex > 4 then
               xindex = 1
          end

          local skinIndexNeg = skinIndex - 1
          if skinIndexNeg % 4  == 0 then ypos = ypos + 180 end;
          if skinIndexNeg % 12 == 0 then ypos = ypos + 140 end;
          table.insert(result, {xpos[xindex], ypos});
     end
     return result
end

local function calculatePageLimit(skinType)
     local yindex_limit = 0
     for skinIndex = 1, #skinType do
          local skinIndexNeg = skinIndex - 1
          if skinIndexNeg % 12 == 0 then
               yindex_limit = yindex_limit + 1
          end
     end
     return yindex_limit
end

local function getLocalSkins(state)
     local results_note   = {'future', 'chip'}
     local results_splash = {'vanilla', 'sparkles', 'electric', 'diamond'}

     local results_states = state == 'note' and 'NOTE_assets' or 'noteSplashes'
     local results_statesName = state == 'note' and results_note or results_splash
     local results = {}
     for i = 0, #results_statesName do
          if i == 0 then 
               table.insert(results, results_states)
          else
               table.insert(results, results_states..'-'..results_statesName[i])
          end
     end
     return results
end

local function getSkins(state)
     local results = getLocalSkins(state)
     local pattern = state == 'note' and 'NOTE_assets' or 'noteSplashes'
     local folder  = state == 'note' and 'noteSkins' or 'noteSplashes'
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/'..folder) do
          if v:match('^('..pattern..'%-.+)%.png$') then
               table.insert(results, v:match('^('..pattern..'%-.+)%.png$'))
          end
     end
     return results
end

local function getSkinNames(state)
     local results_note   = {'Normal', 'Future', 'Chip'}
     local results_splash = {'Normal', 'Vanilla', 'Sparkles', 'Electric', 'Diamond'}
     local results = state == 'note' and results_note or results_splash

     local pattern = state == 'note' and 'NOTE_assets' or 'noteSplashes'
     local folder  = state == 'note' and 'noteSkins' or 'noteSplashes'
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/'..folder) do
          if v:match('^('..pattern..'%-.+)%.png$') then
               table.insert(results, v:match('^('..pattern..'%-.+)%.png$'))
          end
     end
     return results
end