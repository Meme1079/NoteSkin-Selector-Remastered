local json = require 'mods.NoteSkin Selector Remastered.libraries.json.json'
local data = {}

local function getTextFileContent(path)
     local file = io.open(path)
     local content = ''
     for line in file:lines() do  
          content = content .. line .. '\n'
     end
     return content:sub(1, #content - 1)
end

function data.convertToData(name, class, templateTable)
     local function deepCopy(original)
          local copy = ''
          for k,v in pairs(original) do
               if type(v) == "table" then
                    v = deepCopy(v)
               end
               if tostring(k):match('^%d+$') then
                    copy = copy .. ('${values}, '):interpol({key = k, values = tostring(v)})
               else
                    copy = copy .. ('${key} = ${values}, '):interpol({key = k, values = tostring(v)})
               end
          end
          return '@LCBRACK'..copy:gsub('[,%s*]+@RCBRACK', ', '):sub(1, #copy - 2)..'@RCBRACK'
     end
     local result = ''
     for k,v in next, templateTable do
          if type(v) == 'table' then
               result = result .. deepCopy(v)
          elseif type(v) == 'string' then
               result = result .. ('${key} = \'${values}\', '):interpol({key = k, values = v})
          else
               result = result .. ('${key} = ${values}, '):interpol({key = k, values = v})
          end
     end

     local filter = result:gsub('@LCBRACK', '{'):gsub('@RCBRACK', '}'):sub(1, #result - 2)
     local result_bits = name..':'
     for bits in filter:gmatch('.') do
          result_bits = result_bits .. ('${bits}*'):interpol({bits = bits:byte() + 16})
     end

     local p = result_bits:sub(1, #result_bits - 1)..','
     local dataTemplates = {}
     local dataChunks = {}
     local dataPath = 'mods/NoteSkin Selector Remastered/luadata/'..class..'.txt'
     for _,data in pairs(p:split(',')) do
          dataChunks[#dataChunks + 1] = data
     end
     for _,data in pairs(dataChunks) do
          local data = data:split(':')
          dataTemplates[data[1]] = data[2]
     end

     local j = json.stringify(dataTemplates, nil, 5, false, false)
     --[[ local dataPath = 'NoteSkin Selector Remastered/luadata/'..class..'.txt'
     local data = result_bits:sub(1, #result_bits - 1)..','

     saveFile(dataPath, getTextFileContent('mods/'..dataPath)..data) ]]
     return j
end

function data.convertToReadable(name, class)
     local dataTemplates = {}
     local dataChunks = {}
     local dataPath = 'mods/NoteSkin Selector Remastered/luadata/'..class..'.txt'
     for _,data in pairs(getTextFileContent(dataPath):split(',')) do
          dataChunks[#dataChunks + 1] = data
     end
     for _,data in pairs(dataChunks) do
          local data = data:split(':')
          dataTemplates[data[1]] = data[2]
     end
     
     local result = ''
     for k,v in pairs(dataTemplates[name]:split('*')) do
          result = result .. string.char(tonumber(v) - 16)
     end
     return load('return {'..result..'}')()
end

return data