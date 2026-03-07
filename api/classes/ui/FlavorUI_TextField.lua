local FlavorUI_TextField = {}

function FlavorUI_TextField:new()
     local self = setmetatable({}, {__index = self})

     return self
end

function FlavorUI_TextField:create()
     runHaxeCode([[
          import flixel.FlxG;
          import flixel.util.FlxTimer;
          import backend.ClientPrefs;
          import backend.Paths;
          import backend.ui.PsychUIInputText;
          import psychlua.LuaUtils;

          var skinSearchInput_placeholder:FlxText  = new FlxText(35, 55 + 12, 0, '...');
          var skinSearchInput_caret:FlxSprite      = new FlxSprite(0, 0);
          var skinSearchInput:PsychUIInputText     = new PsychUIInputText(34, 54+12, 385, '', 23);

     
          skinSearchInput_placeholder.font  = Paths.font('tomo.otf');
          skinSearchInput_placeholder.size  = 23;
          skinSearchInput_placeholder.color = 0xffb3b3b5;
          skinSearchInput_placeholder.borderSize   = -1;
          skinSearchInput_placeholder.cameras      = [game.camHUD];
          skinSearchInput_placeholder.antialiasing = false;
     
          skinSearchInput.textObj.font  = Paths.mods('NoteSkin Selector Remastered/fonts/tomo.otf');
          skinSearchInput.textObj.color = FlxColor.WHITE;
          skinSearchInput.textObj.antialiasing = false;
          skinSearchInput.bg.visible           = false;
          skinSearchInput.behindText.visible   = false;
          skinSearchInput.caret.alpha     = 0;
          skinSearchInput.selection.color = 0xff1565de;
          skinSearchInput.cameras   = [game.camHUD];
          skinSearchInput.maxLength = 50;

          skinSearchInput_caret.makeGraphic(3, 25, FlxColor.WHITE);
          skinSearchInput_caret.y = skinSearchInput.caret.y + 1;
          skinSearchInput_caret.cameras      = [game.camHUD];
          skinSearchInput_caret.antialiasing = false;
     
          skinSearchInput.onChange     = function(preText:String, curText:String) {
               FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1);
               setVar('SEARCH_INPUT_PRE_TEXT_CONTENT', preText);
               setVar('SEARCH_INPUT_TEXT_CONTENT', curText);
     
               if (curText.length > 0) {
                    skinSearchInput_placeholder.text  = '';
               } else {
                    skinSearchInput_placeholder.text  = '...';
                    skinSearchInput_placeholder.color = 0xFFB3B3B5;
               }
     
               if (curText.length >= 50) {
                    FlxG.sound.play(Paths.sound('cancel'), 0.5);
                    skinSearchInput.textObj.color = FlxColor.RED;
               } else {
                    skinSearchInput.textObj.color = FlxColor.WHITE;
               }          
          };
          skinSearchInput.onPressEnter = function() {
               //skinSearchInput.textObj.color = 0xFFF0B72F;
               //setVar('SEARCH_INPUT_TEXT_CONTENT', skinSearchInput.text);
     
               //new FlxTimer().start(0.1, () -> { PsychUIInputText.focusOn = null; });
               //new FlxTimer().start(0.3, () -> { setVar('SEARCH_INPUT_TEXT_CONTENT', ''); }); // forcefully resets, due to a bug
          };
     
          add(skinSearchInput_placeholder);
          add(skinSearchInput);
          add(skinSearchInput_caret);

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

          setVar('skinSearchInput', skinSearchInput);
          setVar('skinSearchInput_caret', skinSearchInput_caret);
     ]])
end

function FlavorUI_TextField:update()
     runHaxeCode([[
          skinSearchInput_onFocus();

          var skinSearchInput_caret = getVar('skinSearchInput_caret');
          var skinSearchInput       = getVar('skinSearchInput');

          skinSearchInput_caret.visible = PsychUIInputText.focusOn == null ? false : skinSearchInput.caret.visible;
          skinSearchInput_caret.x       = skinSearchInput.caret.x + 1;
     ]])
end

return FlavorUI_TextField