-- Copyright (c) 2018, Souche Inc.

local Constant   = require "mods.NoteSkin Selector Remastered.api.libraries.json.files.constant"
local Serializer = require "mods.NoteSkin Selector Remastered.api.libraries.json.files.serializer"
local Parser     = require "mods.NoteSkin Selector Remastered.api.libraries.json.files.parser"

local json = {
    _VERSION = "0.1",
    null = Constant.NULL
}

function json.stringify(obj, replacer, space, print_address, sort_table_keys, escape_string_values, empty_table_as_array)
    if type(space) ~= "number" then space = 0 end

    return Serializer({
        print_address = print_address,
        sort_table_keys = sort_table_keys,
        escape_string_values = escape_string_values,
        empty_table_as_array = empty_table_as_array,
        stream = {
            fragments = {},
            write = function(self, ...)
                for i = 1, #{...} do
                    self.fragments[#self.fragments + 1] = ({...})[i]
                end
            end,
            toString = function(self)
                return table.concat(self.fragments)
            end
        }
    }):json(obj, replacer, space, space):toString()
end

function json.parse(str, without_null)
    return Parser({ without_null = without_null }):json(str, 1)
end

return json