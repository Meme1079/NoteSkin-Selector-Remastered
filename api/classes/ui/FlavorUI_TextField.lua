local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local hoverObject   = funkinlua.hoverObject
local clickObject   = funkinlua.clickObject
local pressedObject = funkinlua.pressedObject

---
---@class FlavorUI_TextField

---@field font string
---@field size number
---@field antialiasing boolean
---@field color string
---@field selection_color string
---@field max_length number

---@field field_offset_x number
---@field field_offset_y number

---@field caret_x number
---@field caret_y number
---@field caret_width number
---@field caret_height number
---@field caret_color string

---@field placeholder_content string
---@field placeholder_color string
---@field placeholder_offset_x number
---@field placeholder_offset_y number

---@field onCreate string
---@field onCreatePost string
---@field onUpdate string
---@field onChange string
---@field onField string
---@field onFieldMax string
local FlavorUI_TextField = {}

---
---@param tag string
---@param text string
---@param x number
---@param y number
---@param width number
---@return FlavorUI_TextField
function FlavorUI_TextField:new(tag, text, x, y, width)
     local self = setmetatable({}, {__index = self})
     self.tag   = tag
     self.text  = text
     self.x     = x
     self.y     = y
     self.width = width
     
     self.font            = ''
     self.size            = 16
     self.antialiasing    = true
     self.color           = '0xffffffff'
     self.selection_color = '0xff1565de'
     self.max_length      = 50

     self.field_offset_x = 0
     self.field_offset_y = 0

     self.caret_x       = 0
     self.caret_y       = 0
     self.caret_width   = 3
     self.caret_height  = 25
     self.caret_color   = '0xffffffff'

     self.placeholder_content  = ''
     self.placeholder_color    = '0xFFB3B3B5'     
     self.placeholder_offset_x = 0
     self.placeholder_offset_y = 0

     self.onCreate     = ''
     self.onCreatePost = ''
     self.onUpdate     = ''
     self.onChange     = ''
     self.onField      = ''
     self.onFieldMax   = ''

     return self
end

---
---@return nil
function FlavorUI_TextField:create()
     runHaxeCode((F[[
          import flixel.FlxG;
          import flixel.util.FlxTimer;
          import backend.ClientPrefs;
          import backend.Paths;
          import backend.ui.PsychUIInputText;
          import psychlua.LuaUtils;
          import StringTools;

          /* Sprites */

          ${self.onCreate:gsub('this', self.tag)}

          var skinSearchInput_caret:FlxSprite     = new FlxSprite(0, 0);
          var skinSearchInput_placeholder:FlxText = new FlxText(${self.x}+1, ${self.y}+1, 0, "${self.text}");
          var skinSearchInput:PsychUIInputText    = new PsychUIInputText(${self.x}, ${self.y}, ${self.width}, "${self.text}", ${self.size});
     
          skinSearchInput_caret.makeGraphic(${self.caret_width}, ${self.caret_height}, ${self.caret_color});
          skinSearchInput_caret.y            = skinSearchInput.caret.y;
          skinSearchInput_caret.cameras      = [game.camHUD];
          skinSearchInput_caret.antialiasing = false;

          skinSearchInput_placeholder.text  = '${self.placeholder_content}';
          skinSearchInput_placeholder.font  = Paths.mods('${self.font}');
          skinSearchInput_placeholder.size  = ${self.size};
          skinSearchInput_placeholder.color = ${self.placeholder_color};
          skinSearchInput_placeholder.borderSize   = -1;
          skinSearchInput_placeholder.cameras      = [game.camHUD];
          skinSearchInput_placeholder.antialiasing = ${self.antialiasing};
          skinSearchInput_placeholder.offset.set(${self.placeholder_offset_x}, ${self.placeholder_offset_y});

          skinSearchInput.textObj.font  = Paths.mods('${self.font}');
          skinSearchInput.textObj.color = ${self.color};
          skinSearchInput.textObj.antialiasing = ${self.antialiasing};
          skinSearchInput.textObj.offset.set(${self.field_offset_x}, ${self.field_offset_y});
          skinSearchInput.bg.visible           = false;
          skinSearchInput.behindText.visible   = false;
          skinSearchInput.caret.alpha     = 0;
          skinSearchInput.selection.color = ${self.selection_color};
          skinSearchInput.cameras   = [game.camHUD];
          skinSearchInput.maxLength = ${self.max_length};
          skinSearchInput.deleteSelection();
          skinSearchInput.onChange  = function(preText:String, curText:String) {
               if (curText.length > 0) {
                    skinSearchInput_placeholder.text  = '';
               } else {
                    skinSearchInput_placeholder.text  = '${self.placeholder_content}';
                    skinSearchInput_placeholder.color = ${self.placeholder_color};
               }
     
               if (curText.length >= ${self.max_length}) {
                    skinSearchInput.textObj.color = FlxColor.RED;
                    ${self.onFieldMax:gsub('this', self.tag)}
               } else {
                    skinSearchInput.textObj.color = FlxColor.WHITE;
                    ${self.onField:gsub('this', self.tag)}
               }
               setVar('skinSearchInput_preText', preText);
               setVar('skinSearchInput_curText', curText);
               ${self.onChange:gsub('this', self.tag)}
          };

          add(skinSearchInput_placeholder);
          add(skinSearchInput_caret);
          add(skinSearchInput);
          
          setVar('skinSearchInput', skinSearchInput);
          setVar('skinSearchInput_caret', skinSearchInput_caret);
          setVar('skinSearchInput_placeholder', skinSearchInput_placeholder);
          ${self.onCreatePost:gsub('this', self.tag)}
     ]]):gsub('skinSearchInput', self.tag))
end

---
---@return nil
function FlavorUI_TextField:update()
     runHaxeCode((F[[
          var skinSearchInput       = getVar('skinSearchInput');
          var skinSearchInput_caret = getVar('skinSearchInput_caret');

          skinSearchInput.selection.scale.y = 25;

          skinSearchInput_caret.visible = PsychUIInputText.focusOn == null ? false : skinSearchInput.caret.visible;
          skinSearchInput_caret.x       = skinSearchInput.caret.x;
          skinSearchInput_caret.y       = skinSearchInput.caret.y + ${self.caret_y};

          ClientPrefs.toggleVolumeKeys(PsychUIInputText.focusOn == null);
          game.allowDebugKeys = PsychUIInputText.focusOn == null;
          ${self.onUpdate:gsub('this', self.tag)}
     ]]):gsub('skinSearchInput', self.tag))
end

---
---@param value number
---@return nil
function FlavorUI_TextField:set_field(value)
     runHaxeCode((F[[
          var skinSearchInput             = getVar('skinSearchInput');
          var skinSearchInput_placeholder = getVar('skinSearchInput_placeholder');

          skinSearchInput.set_text('${value}');
          skinSearchInput_placeholder.text  = '';
     ]]):gsub('skinSearchInput', self.tag))
end

---
---@return string
function FlavorUI_TextField:get_field()
     runHaxeCode((F[[
          var skinSearchInput = getVar('skinSearchInput');
          setVar('skinSearchInput_textContent', skinSearchInput.textObj.textField.text);
     ]]):gsub('skinSearchInput', self.tag))
     return getVar(('skinSearchInput_textContent'):gsub('skinSearchInput', self.tag))
end

---
---@param invalidColor string
---@param invalidContent string
---@return nil
function FlavorUI_TextField:invalid_field(invalidColor, invalidContent)
     runHaxeCode((F[[
          var skinSearchInput             = getVar('skinSearchInput');
          var skinSearchInput_placeholder = getVar('skinSearchInput_placeholder');

          skinSearchInput.caretIndex = 1;
          skinSearchInput.set_text('');
     
          skinSearchInput_placeholder.text  = '${invalidContent}'; // Invalid Skin!
          skinSearchInput_placeholder.color = ${invalidColor};     // 0xFFB50000
          FlxG.sound.play(Paths.sound('cancel'), 0.5);
          return;
     ]]):gsub('skinSearchInput', self.tag))
end

---
---@return nil
function FlavorUI_TextField:reset_field()
     runHaxeCode((F[[
          var skinSearchInput             = getVar('skinSearchInput');
          var skinSearchInput_placeholder = getVar('skinSearchInput_placeholder');

          skinSearchInput.caretIndex = 1;
          skinSearchInput.set_text('');

          skinSearchInput_placeholder.text = '${self.placeholder_content}';
          return;
     ]]):gsub('skinSearchInput', self.tag))
end

---
---@param filterType string
---@return nil
function FlavorUI_TextField:set_filterMode(filterType)
     runHaxeCode((F[[
          var skinSearchInput = getVar('skinSearchInput');
          skinSearchInput.set_filterMode(${filterType});
     ]]):gsub('skinSearchInput', self.tag))
end

---
---@param pattern string
---@param flag string
---@return nil
function FlavorUI_TextField:set_customFilterPattern(pattern, flag)
     runHaxeCode((F[[
          var skinSearchInput = getVar('skinSearchInput');
          skinSearchInput.customFilterPattern = new EReg("${pattern}", "${flag}");
     ]]):gsub('skinSearchInput', self.tag))
end

return FlavorUI_TextField