local FlxSprite = {}

function FlxSprite:new(tag, x, y)
     local constructor = setmetatable({}, {__index = self})
     constructor.tag = tag
     constructor.x = x
     constructor.y = y

     return constructor
end

function FlxSprite:load(image, value, special)
     if special == 'load' then
          loadGraphic(self.tag, image, value.gridX, value.gridY)
          return;
     end
     if special == 'anim' then
          makeAnimatedLuaSprite(self.tag, image, self.x, self.y, value.spriteType)
          return;
     end
     if image == nil then
          makeLuaSprite(self.tag, image, self.x, self.y)
          makeGraphic(self.tag, value.width, value.height, value.color)
          return;
     end
     makeLuaSprite(self.tag, image, self.x, self.y)
end

function FlxSprite:addAnimation(name, frames, framerate, loop)
     addAnimation(self.tag, name, frames, framerate, loop)
end

function FlxSprite:addAnimationByPrefix(name, prefix, framerate, loop)
     addAnimationByPrefix(self.tag, name, prefix, framerate, loop)
end

function FlxSprite:addAnimationByIndices(name, prefix, indices, framerate, loop)
     addAnimationByIndices(self.tag, name, prefix, table.concat(indices, ','), framerate, loop)
end

function FlxSprite:addOffsets(name, x, y)
     addOffset(self.tag, name, x, y)
end

function FlxSprite:loadFrames(image, spriteType)
     loadFrames(self.tag, image, spriteType)
end

function FlxSprite:size(byType, x, y, updateHitbox)
     if byType == 'graphic' then
          setGraphicSize(self.tag, x, y, updateHitbox)
          return;
     elseif byType == 'object' then
          scaleObject(self.tag, x, y, updateHitbox)
          return;
     end
     return debugPrint('Error! invalid byType value!', 'ff0000')
end

function FlxSprite:camera(cam)
     setObjectCamera(self.tag, cam)
end

function FlxSprite:blend(mode)
     setBlendMode(self.tag, mode)
end

function FlxSprite:setOrder(order)
     setObjectOrder(self.tag, order)
end

function FlxSprite:getOrder()
     return getObjectOrder(self.tag)
end

function FlxSprite:overlap(altTag)
     return objectsOverlap(self.tag, altTag)
end

function FlxSprite:getMidpoints(byType)
     if byType == true then
          return {getGraphicMidpointX(self.tag), getGraphicMidpointY(self.tag)}
     end
     return {getMidpointX(self.tag), getMidpointY(self.tag)}
end

function FlxSprite:getScreenPositions()
     return {getScreenPositionX(self.tag), getScreenPositionY(self.tag)}
end

function FlxSprite:screenCenter(pos)
     screenCenter(self.tag, pos)
end

function FlxSprite:set(properties)
     for k,v in pairs(properties) do
          setProperty(self.tag..'.'..k, v)
     end
end

function FlxSprite:get(properties)
     local result = {}
     for k,v in pairs(properties) do
          result[#result + 1] = getProperty(self.tag..'.'..k)
     end
     return result
end

function FlxSprite:add(front)
     addLuaSprite(self.tag, front)
end

function FlxSprite:remove(permenant)
     if permenant == true then
          setmetatable(self, nil)
     end
     removeLuaSprite(self.tag, permenant)
end

return FlxSprite