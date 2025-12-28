local FlxSprite = require('mods.NoteSkin Selector Remastered.libraries.flx.flxsprite')
local FlxText = FlxSprite:new(tag, x, y)

function FlxText:new(tag, content, x, y, width)
     local constructor = setmetatable({}, {__index = self})
     constructor.tag = tag
     constructor.content = content
     constructor.x = x
     constructor.y = y
     constructor.width = width

     return constructor
end

function FlxText:load()
     makeLuaText(self.tag, self.content, self.width, self.x, self.y)
end

function FlxText:setText(properties)
     local setters = {
          string    = function(prop) setTextString(self.tag, prop.string) end,
          size      = function(prop) setTextSize(self.tag, prop.size) end,
          autosize  = function(prop) setTextAutoSize(self.tag, prop.autosize) end,
          width     = function(prop) setTextWidth(self.tag, prop.width) end,
          height    = function(prop) setTextHeight(self.tag, prop.height) end,
          border    = function(prop) setTextBorder(self.tag, prop.border[1], prop.border[2], prop.border[3]) end,
          color     = function(prop) setTextColor(self.tag, prop.color) end,
          alignment = function(prop) setTextAlignment(self.tag, prop.alignment) end,
          font      = function(prop) setTextFont(self.tag, prop.font) end,
          italic    = function(prop) setTextItalic(self.tag, prop.italic) end
     }
     for k,v in next, properties do
          setters[k](properties)
     end
end

function FlxText:add()
     addLuaText(self.tag)
end

return FlxText