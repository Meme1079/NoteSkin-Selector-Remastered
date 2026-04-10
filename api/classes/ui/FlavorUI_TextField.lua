luaDebugMode = true

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

--- Main text field component class for FlavorUI.
---@class FlavorUI_TextField
local FlavorUI_TextField = {}

--- Initializes the main attributes for the text field.
---@param tag string The corresponding tag name given for this text field.
---@param text string The main text content to be display to the text field, usually left empty.
---@param x number The given x-position to initially set to.
---@param y number The given y-position to initially set to.
---@param fieldWidth number The width of the text field to only show.
---@return FlavorUI_TextField
function FlavorUI_TextField:new(tag, text, x, y, fieldWidth)
     local self = setmetatable({}, {__index = self})
     self.tag            = tag
     self.x              = x or 0
     self.y              = y or 0
     self.offset_x       = 0
     self.offset_y       = 0
     self.text           = text or ''
     self.font           = ''
     self.size           = 16
     self.color          = '0xffffffff'
     self.fieldWidth     = fieldWidth or 0
     self.fieldHeight    = 0
     self.border_color   = '0xff000000'
     self.border_quality = 1
     self.border_size    = 0
     self.antialiasing   = true
     self.cameras        = 'game.camHUD'
     self.deactivate     = false

     -- Miscellaneous --

     self.maxLength         = 0
     self.passwordMask      = false
     self.selection_scale_x = -1
     self.selection_scale_y = 25
     self.selection_color   = '0xff007bff'

     -- Fields --

     self.field_selectable = true
     self.field_wordWrap   = true
     self.field_multiline  = false

     -- Caret --

     self.caret_x         = 0
     self.caret_y         = 0
     self.caret_offset_x  = 0
     self.caret_offset_y  = 0
     self.caret_width     = 1
     self.caret_height    = 1
     self.caret_color     = '0xffffffff'

     -- Placeholder --

     self.placeholder_x              = self.x
     self.placeholder_y              = self.y
     self.placeholder_offset_x       = self.offset_x-1
     self.placeholder_offset_y       = self.offset_y-1
     self.placeholder_text           = ''
     self.placeholder_color          = '0xff808080'
     self.placeholder_fieldWidth     = 0
     self.placeholder_fieldHeight    = 0
     self.placeholder_border_color   = '0xff000000'
     self.placeholder_border_quality = 1
     self.placeholder_border_size    = -1

     -- Callbacks --

     self.onCreate     = [[]]
     self.onCreatePost = [[]]
     self.onUpdate     = [[]]
     self.onChange     = [[]]
     self.onPressEnter = [[]]
     self.onField      = [[]]
     self.onFieldMax   = [[]]
     return self
end

--- Adds the text field object into the game, including its elements field, placeholder, and caret.
--- Must be called after initiating the text field's attributes.
---@return nil
function FlavorUI_TextField:add()
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

          var flavorTextField_caret:FlxSprite     = new FlxSprite(${self.caret_x}, ${self.caret_y});
          var flavorTextField_placeholder:FlxText = new FlxText(${self.placeholder_x}, ${self.placeholder_y}, ${self.placeholder_fieldWidth}, "${self.placeholder_text}");
          var flavorTextField:PsychUIInputText    = new PsychUIInputText(${self.x}, ${self.y}, ${self.fieldWidth}, "${self.text}", ${self.size});

          flavorTextField_caret.makeGraphic(${self.caret_width}, ${self.caret_height}, ${self.caret_color});
          flavorTextField_caret.cameras      = [${self.cameras}];
          flavorTextField_caret.antialiasing = ${self.antialiasing};
          flavorTextField_caret.offset.set(${self.caret_offset_x}, ${self.caret_offset_y});
          
          flavorTextField_placeholder.text          = '${self.placeholder_text}';
          flavorTextField_placeholder.font          = Paths.mods('${self.font}');
          flavorTextField_placeholder.size          = ${self.size};
          flavorTextField_placeholder.color         = ${self.placeholder_color};
          flavorTextField_placeholder.borderColor   = ${self.placeholder_border_color};
          flavorTextField_placeholder.borderQuality = ${self.placeholder_border_quality};
          flavorTextField_placeholder.borderSize    = ${self.placeholder_border_size};
          flavorTextField_placeholder.cameras       = [${self.cameras}];
          flavorTextField_placeholder.antialiasing  = ${self.antialiasing};
          flavorTextField_placeholder.offset.set(${self.placeholder_offset_x}, ${self.placeholder_offset_y});

          flavorTextField.textObj.font          = Paths.mods('${self.font}');
          flavorTextField.textObj.color         = ${self.color};
          flavorTextField.textObj.fieldHeight   = ${self.fieldHeight};
          flavorTextField.textObj.borderColor   = ${self.border_color};
          flavorTextField.textObj.borderQuality = ${self.border_quality};
          flavorTextField.textObj.borderSize    = ${self.border_size};
          flavorTextField.textObj.antialiasing  = ${self.antialiasing};
          flavorTextField.textObj.offset.set(${self.offset_x}, ${self.offset_y});
          flavorTextField.bg.visible         = false;
          flavorTextField.behindText.visible = false;
          flavorTextField.caret.alpha        = 0;
          flavorTextField.maxLength          = ${self.maxLength};
          flavorTextField.passwordMask       = ${self.passwordMask};
          flavorTextField.selection.color    = ${self.selection_color};
          flavorTextField.cameras            = [${self.cameras}];
          flavorTextField.deleteSelection();
          flavorTextField.onChange = function(preText:String, curText:String) {
               if (curText.length > 0) {
                    flavorTextField_placeholder.text  = '';
               } else {
                    flavorTextField_placeholder.text  = '${self.placeholder_text}';
                    flavorTextField_placeholder.color = ${self.placeholder_color};
               }
     
               if (curText.length >= ${self.maxLength}) {
                    ${self.onFieldMax:gsub('this', self.tag)}
               } else {
                    ${self.onField:gsub('this', self.tag)}
               }

               setVar('flavorTextField_preText', preText);
               setVar('flavorTextField_curText', curText);
               ${self.onChange:gsub('this', self.tag)}
          };
          flavorTextField.onPressEnter = function(e) {
               setVar('flavorTextField_enterText', flavorTextField.textObj.textField.text);
               ${self.onPressEnter:gsub('this', self.tag)}
          }

          add(flavorTextField_placeholder);
          add(flavorTextField);
          add(flavorTextField_caret);

          /* Miscellaneous */

          setVar('flavorTextField_placeholder', flavorTextField_placeholder);
          setVar('flavorTextField', flavorTextField);
          setVar('flavorTextField_caret', flavorTextField_caret);

          ${self.onCreatePost:gsub('this', self.tag)}
     ]]):gsub('flavorTextField', self.tag))
end

--- Overwrites the text field attributes, allowing it to update.
--- Must be called after overwriting the text field's attributes.
---@return nil
function FlavorUI_TextField:overwrite()
     runHaxeCode((F[[ 
          var flavorTextField             = getVar('flavorTextField');
          var flavorTextField_caret       = getVar('flavorTextField_caret');
          var flavorTextField_placeholder = getVar('flavorTextField_placeholder');

          flavorTextField.x                 = ${self.x};
          flavorTextField.y                 = ${self.y};
          flavorTextField.maxLength         = ${self.maxLength};
          flavorTextField.passwordMask      = ${self.passwordMask};
          flavorTextField.selection.scale.x = ${self.selection_scale_x};
          flavorTextField.selection.scale.y = ${self.selection_scale_y};
          flavorTextField.selection.color   = ${self.selection_color};
          flavorTextField.cameras           = [${self.cameras}];

          flavorTextField.textObj.font          = Paths.mods('${self.font}');
          flavorTextField.textObj.color         = ${self.color};
          flavorTextField.textObj.fieldHeight   = ${self.fieldHeight};
          flavorTextField.textObj.borderColor   = ${self.border_color};
          flavorTextField.textObj.borderQuality = ${self.border_quality};
          flavorTextField.textObj.borderSize    = ${self.border_size};
          flavorTextField.textObj.offset.set(${self.offset_x}, ${self.offset_y});
          flavorTextField.textObj.antialiasing  = ${self.antialiasing};

          flavorTextField_caret.width        = ${self.caret_width};
          flavorTextField_caret.height       = ${self.caret_height};
          flavorTextField_caret.color        = ${self.caret_color};
          flavorTextField_caret.cameras      = [${self.cameras}];
          flavorTextField_caret.antialiasing = ${self.antialiasing};
          flavorTextField_caret.offset.set(${self.caret_offset_x}, ${self.caret_offset_y});

          flavorTextField_placeholder.text          = '${self.placeholder_text}';
          flavorTextField_placeholder.font          = Paths.mods('${self.font}');
          flavorTextField_placeholder.size          = ${self.size};
          flavorTextField_placeholder.color         = ${self.placeholder_color};
          flavorTextField_placeholder.borderColor   = ${self.placeholder_border_color};
          flavorTextField_placeholder.borderQuality = ${self.placeholder_border_quality};
          flavorTextField_placeholder.borderSize    = ${self.placeholder_border_size};
          flavorTextField_placeholder.cameras       = [${self.cameras}];
          flavorTextField_placeholder.antialiasing  = ${self.antialiasing};
          flavorTextField_placeholder.offset.set(${self.placeholder_offset_x}, ${self.placeholder_offset_y});
     ]]):gsub('flavorTextField', self.tag))
end

--- Updates the text field.
---@return nil
function FlavorUI_TextField:update()
     runHaxeCode((F[[
          var flavorTextField       = getVar('flavorTextField');
          var flavorTextField_caret = getVar('flavorTextField_caret');

          flavorTextField.selection.scale.x = ${self.selection_scale_x} != -1 ? ${self.selection_scale_x} : flavorTextField.selection.scale.x;
          flavorTextField.selection.scale.y = ${self.selection_scale_y} != -1 ? ${self.selection_scale_y} : flavorTextField.selection.scale.y;
          
          flavorTextField_caret.visible = PsychUIInputText.focusOn == null ? false : flavorTextField.caret.visible;
          flavorTextField_caret.x       = flavorTextField.caret.x;
          flavorTextField_caret.y       = flavorTextField.caret.y;

          ClientPrefs.toggleVolumeKeys(PsychUIInputText.focusOn == null);
          game.allowDebugKeys = PsychUIInputText.focusOn == null;
          ${self.onUpdate:gsub('this', self.tag)}
     ]]):gsub('flavorTextField', self.tag))
end

function FlavorUI_TextField:set_caret_index(value)
     runHaxeCode((F[[
          var flavorTextField       = getVar('flavorTextField');
          var flavorTextField_caret = getVar('flavorTextField_caret');

          flavorTextField.caretIndex = ${value};
          flavorTextField_caret.x = flavorTextField.caret.x;
          flavorTextField_caret.y = flavorTextField.caret.y;
     ]]):gsub('flavorTextField', self.tag))
end

--- Sets the current text field content with a new on
---@param value string The text field content to assign.
---@return nil
function FlavorUI_TextField:set_field(value)
     runHaxeCode((F[[
          var flavorTextField             = getVar('flavorTextField');
          var flavorTextField_placeholder = getVar('flavorTextField_placeholder');

          flavorTextField.set_text('${value}');
          flavorTextField_placeholder.text = '';
     ]]):gsub('flavorTextField', self.tag))
end

--- Gets the current text field content.
---@return string
function FlavorUI_TextField:get_field()
     runHaxeCode((F[[
          var flavorTextField = getVar('flavorTextField');
          setVar('flavorTextField_textContent', flavorTextField.textObj.textField.text);
     ]]):gsub('flavorTextField', self.tag))
     return getVar(('flavorTextField_textContent'):gsub('flavorTextField', self.tag))
end

--- Invalidates the text field.
---@param color string The text color of the invalid field.
---@param content string The text content of the invalid field.
---@return nil
function FlavorUI_TextField:invalid_field(color, content)
     runHaxeCode((F[[
          var flavorTextField             = getVar('flavorTextField');
          var flavorTextField_placeholder = getVar('flavorTextField_placeholder');

          flavorTextField.caretIndex = 1;
          flavorTextField.set_text('');
     
          flavorTextField_placeholder.text  = '${content}'; // Invalid Skin!
          flavorTextField_placeholder.color = ${color};     // 0xFFB50000
          FlxG.sound.play(Paths.sound('cancel'), 0.5);
          return;
     ]]):gsub('flavorTextField', self.tag))
end

--- Resets the current field content of the text field, no shit sherlock.
---@return nil
function FlavorUI_TextField:clear_field()
     runHaxeCode((F[[
          var flavorTextField             = getVar('flavorTextField');
          var flavorTextField_placeholder = getVar('flavorTextField_placeholder');

          flavorTextField.caretIndex = 1;
          flavorTextField.set_text('');

          flavorTextField_placeholder.text = '${self.placeholder_content}';
          return;
     ]]):gsub('flavorTextField', self.tag))
end

--- Sets the filter type of the text field, enabling allowed specific text characters.
---@param filterType string The specified filter type to inherit.
---@return nil
function FlavorUI_TextField:set_filterMode(filterType)
     runHaxeCode((F[[
          var flavorTextField = getVar('flavorTextField');
          flavorTextField.set_filterMode(${filterType});
     ]]):gsub('flavorTextField', self.tag))
end

--- Sets a custom filter to the text field.
---@param pattern string The specific RegEx pattern to filter out.
---@param flag string The specific RegEx modifier flag to use when filtering.
---@return nil
function FlavorUI_TextField:set_customFilterPattern(pattern, flag)
     runHaxeCode((F[[
          var flavorTextField = getVar('flavorTextField');
          flavorTextField.customFilterPattern = new EReg("${pattern}", "${flag}");
     ]]):gsub('flavorTextField', self.tag))
end

function FlavorUI_TextField:focused()
     return runHaxeCode((F[[
          var flavorTextField = getVar('flavorTextField');
          return PsychUIInputText.focusOn == flavorTextField
     ]]):gsub('flavorTextField', self.tag))
end

function FlavorUI_TextField:entered()
     return runHaxeCode((F[[
          var flavorTextField = getVar('flavorTextField');
          return flavorTextField.textObj.textField.text;
     ]]):gsub('flavorTextField', self.tag))
end

return FlavorUI_TextField