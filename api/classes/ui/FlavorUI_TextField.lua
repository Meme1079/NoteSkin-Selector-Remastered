local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local hoverObject   = funkinlua.hoverObject
local clickObject   = funkinlua.clickObject
local pressedObject = funkinlua.pressedObject

---@class FlavorUI_TextField
local FlavorUI_TextField = {}

function FlavorUI_TextField:new(tag, sprite, x, y, width, content)
     local self = setmetatable({}, {__index = self})
     self.tag     = tag
     self.sprite  = sprite
     self.x       = x
     self.y       = y
     self.width   = width
     self.content = content

     self.font            = ''
     self.size            = 16
     self.antialiasing    = true
     self.color           = '0xffffffff'
     self.selection_color = '0xff1565de'
     self.max_length      = 50

     self.caret_width   = 3
     self.caret_height  = 25
     self.caret_offsetY = 1
     self.caret_color   = '0xffffffff'

     self.placeholder_content = ''
     self.placeholder_color   = '0xFFB3B3B5'
     return self
end

function FlavorUI_TextField:create()
     runHaxeCode((F[[
          import flixel.FlxG;
          import flixel.util.FlxTimer;
          import backend.ClientPrefs;
          import backend.Paths;
          import backend.ui.PsychUIInputText;
          import psychlua.LuaUtils;

          /* Sprites */

          var skinSearchInput_caret:FlxSprite     = new FlxSprite(0, 0);
          var skinSearchInput_placeholder:FlxText = new FlxText(${self.x}, ${self.y}, 0, "${self.content}");
          var skinSearchInput:PsychUIInputText    = new PsychUIInputText(${self.x}, ${self.y}, ${self.width}, "${self.content}", ${self.size});
     
          skinSearchInput_caret.makeGraphic(${self.caret_width}, ${self.caret_height}, ${self.caret_color});
          skinSearchInput_caret.y            = skinSearchInput.caret.y + ${self.caret_offsetY};
          skinSearchInput_caret.cameras      = [game.camHUD];
          skinSearchInput_caret.antialiasing = false;

          skinSearchInput_placeholder.text  = '${self.placeholder_content}';
          skinSearchInput_placeholder.font  = Paths.mods('${self.font}');
          skinSearchInput_placeholder.size  = ${self.size};
          skinSearchInput_placeholder.color = ${self.placeholder_color};
          skinSearchInput_placeholder.borderSize   = -1;
          skinSearchInput_placeholder.cameras      = [game.camHUD];
          skinSearchInput_placeholder.antialiasing = ${self.antialiasing};

          skinSearchInput.textObj.font  = Paths.mods('${self.font}');
          skinSearchInput.textObj.color = ${self.color};
          skinSearchInput.textObj.antialiasing = ${self.antialiasing};
          skinSearchInput.bg.visible           = false;
          skinSearchInput.behindText.visible   = false;
          skinSearchInput.caret.alpha     = 0;
          skinSearchInput.selection.color = ${self.selection_color};
          skinSearchInput.cameras   = [game.camHUD];
          skinSearchInput.maxLength = ${self.max_length};
          skinSearchInput.deleteSelection();
          skinSearchInput.onChange  = function(preText:String, curText:String) {
               FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1);
     
               if (curText.length > 0) {
                    skinSearchInput_placeholder.text  = '';
               } else {
                    skinSearchInput_placeholder.text  = '${self.placeholder_content}';
                    skinSearchInput_placeholder.color = ${self.placeholder_color};
               }
     
               if (curText.length >= ${self.max_length}) {
                    FlxG.sound.play(Paths.sound('cancel'), 0.5);
                    skinSearchInput.textObj.color = FlxColor.RED;
               } else {
                    skinSearchInput.textObj.color = FlxColor.WHITE;
               }
          };

          add(skinSearchInput);
          add(skinSearchInput_placeholder);
          add(skinSearchInput_caret);

          setVar('skinSearchInput', skinSearchInput);
          setVar('skinSearchInput_placeholder', skinSearchInput_placeholder);
          setVar('skinSearchInput_caret', skinSearchInput_caret);

          /* Miscellaneous */

          var skinSearchInputFocusToggle = false;
          var skinSearchInputFocus       = false;
          function skinSearchInput_onFocus() {
               skinSearchInputFocus = PsychUIInputText.focusOn != null && PsychUIInputText.focusOn == skinSearchInput;
               setVar('skinSearchInputFocus', skinSearchInputFocus);
          
               if (skinSearchInputFocus == true && skinSearchInputFocusToggle == false) {
                    ClientPrefs.toggleVolumeKeys(false);
                    game.allowDebugKeys = false;
          
                    skinSearchInputFocusToggle = true;
               }
               if (skinSearchInputFocus == false && skinSearchInputFocusToggle == true){
                    ClientPrefs.toggleVolumeKeys(true);
                    game.allowDebugKeys = true;
          
                    skinSearchInputFocusToggle = false;
               }
          
               if (FlxG.keys.pressed.ENTER) {
                    PsychUIInputText.focusOn   = skinSearchInput;
                    skinSearchInput.caretIndex = skinSearchInput.text.length;
               }
          }
     ]]):gsub('skinSearchInput', self.tag))
end

function FlavorUI_TextField:update()
     runHaxeCode((F[[
          var skinSearchInput       = getVar('skinSearchInput');
          var skinSearchInput_caret = getVar('skinSearchInput_caret');

          skinSearchInput_onFocus();          
          skinSearchInput_caret.visible = PsychUIInputText.focusOn == null ? false : skinSearchInput.caret.visible;
          skinSearchInput_caret.x       = skinSearchInput.caret.x;
          skinSearchInput_caret.y       = skinSearchInput.caret.y;
     ]]):gsub('skinSearchInput', self.tag))
end

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

return FlavorUI_TextField