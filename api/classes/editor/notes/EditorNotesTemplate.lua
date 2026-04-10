local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'

local SKIN_DIRECTIONS = {'left', 'down', 'up', 'right'}
local SKIN_COLORS     = {'purple0', 'blue0', 'green0', 'red0'}

local EditorNotesTemplate = {}

function EditorNotesTemplate:new(sprite)
     local self = setmetatable({}, {__index = self})
     self.sprite = sprite or 'noteSkins/NOTE_assets'

     return self
end

function EditorNotesTemplate:create()
     for templateIndex = 1, 4 do
          local templateTag = F"editorNotesTemplate${templateIndex}"
          local templateX = 600 + (130*(templateIndex-1))
          local templateY = 150
     
          local templateDirection = SKIN_DIRECTIONS[templateIndex]
          local templateColors    = SKIN_COLORS[templateIndex]
          makeAnimatedLuaSprite(templateTag, self.sprite, templateX, templateY)
          scaleObject(templateTag, 0.65, 0.65)
          addAnimationByPrefix(templateTag, F"${templateDirection} pressed", F"${templateDirection} pressed", 24, false)
          addAnimationByPrefix(templateTag, F"${templateDirection} confirm", F"${templateDirection} confirm", 24, false)
          addAnimationByPrefix(templateTag, F"${templateDirection} colored", templateColors, 24, false)
          addAnimationByPrefix(templateTag, templateDirection, F"arrow${templateDirection:upper()}", 24, false)
          playAnim(templateTag, templateDirection, false)
          setProperty(F"${templateTag}.alpha", 0.5)
          setObjectCamera(templateTag, 'camHUD')
          --setObjectOrder(templateTag, 100)
          addLuaSprite(templateTag)
     end
end

function EditorNotesTemplate:texture(sprite)
     for templateIndex = 1, 4 do
          local templateTag = F"editorNotesTemplate${templateIndex}"

          local templateDirection = SKIN_DIRECTIONS[templateIndex]
          local templateColors    = SKIN_COLORS[templateIndex]
          loadFrames(templateTag, sprite)
          addAnimationByPrefix(templateTag, F"${templateDirection} pressed", F"${templateDirection} pressed", 24, true)
          addAnimationByPrefix(templateTag, F"${templateDirection} confirm", F"${templateDirection} confirm", 24, true)
          addAnimationByPrefix(templateTag, F"${templateDirection} colored", templateColors, 24, true)
          addAnimationByPrefix(templateTag, templateDirection, F"arrow${templateDirection:upper()}", 24, true)
          playAnim(templateTag, templateDirection)
     end
end

function EditorNotesTemplate:set_order(value)
     for templateIndex = 1, 4 do
          local templateTag = F"editorNotesTemplate${templateIndex}"
          setObjectOrder(templateTag, value)
     end
end

return EditorNotesTemplate