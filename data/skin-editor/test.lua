local FlavorUI_Toggle = require 'mods.NoteSkin Selector Remastered.api.classes.ui.FlavorUI_Toggle'
local SkinSaves       = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'

local NoteSkinSelector = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

makeAnimatedLuaSprite('test', 'ui/buttons/preview anim/previewAnimIcon_toggle', 100, 100)
addAnimationByPrefix('test', 'active-static', 'active-static', 24, false)
addAnimationByPrefix('test', 'active-hovered', 'active-hovered', 24, false)
addAnimationByPrefix('test', 'active-focused', 'active-focused', 24, false)
addAnimationByPrefix('test', 'inactive-static', 'inactive-static', 24, false)
addAnimationByPrefix('test', 'inactive-hovered', 'inactive-hovered', 24, false)
addAnimationByPrefix('test', 'inactive-focused', 'inactive-focused', 24, false)
playAnim('test', 'inactive-static', true)
scaleObject('test', 0.51, 0.562)
setObjectCamera('test', 'camHUD')
setProperty(F"test.antialiasing", false)
addLuaSprite('test')

local doodoo = FlavorUI_Toggle:new('test', NoteSkinSelector:get('DOODOO', 'SAVE', false))
doodoo.onClick = function(this)
     NoteSkinSelector:set('DOODOO', 'SAVE', this.status)
end

function onUpdate(elapsed)
     doodoo:update()
end