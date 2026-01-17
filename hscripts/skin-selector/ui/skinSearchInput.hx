import flixel.FlxG;
import flixel.util.FlxTimer;
import backend.ClientPrefs;
import backend.Paths;
import backend.ui.PsychUIInputText;
import psychlua.LuaUtils;

var skinSearchInput_background:FlxSprite = new FlxSprite(-32, 48);
var skinSearchInput_placeholder:FlxText  = new FlxText(35, 55 + 12, 0, 'Search Skins...');
var skinSearchInput_caret:FlxSprite      = new FlxSprite(0, 0);
var skinSearchInput:PsychUIInputText     = new PsychUIInputText(34, 54+12, 385, '', 31);
function onCreate() {
     skinSearchInput_background.loadGraphic(Paths.image('ui/buttons/search_input'));
     skinSearchInput_background.frames = Paths.getSparrowAtlas('ui/buttons/search_input');
     skinSearchInput_background.animation.addByPrefix('default', 'default', 24, false);
     skinSearchInput_background.animation.addByPrefix('hovered', 'hovered', 24, false);
     skinSearchInput_background.animation.addByPrefix('selectAll', 'selectAll', 24, false);
     skinSearchInput_background.animation.play('default', true);
     skinSearchInput_background.scale.set(0.8, 0.8);
     skinSearchInput_background.cameras = [game.camHUD];
     skinSearchInput_background.antialiasing = false;

     skinSearchInput_placeholder.font  = Paths.font('sonic.ttf');
     skinSearchInput_placeholder.size  = 31;
     skinSearchInput_placeholder.color = 0xffb3b3b5;
     skinSearchInput_placeholder.borderSize   = -1;
     skinSearchInput_placeholder.cameras      = [game.camHUD];
     skinSearchInput_placeholder.antialiasing = false;

     skinSearchInput_caret.makeGraphic(3, 25, FlxColor.WHITE);
     skinSearchInput_caret.cameras      = [game.camHUD];
     skinSearchInput_caret.antialiasing = false;

     skinSearchInput.textObj.font  = Paths.mods('NoteSkin Selector Remastered/fonts/sonic.ttf');
     skinSearchInput.textObj.color = FlxColor.WHITE;
     skinSearchInput.textObj.antialiasing = false;
     skinSearchInput.bg.visible           = false;
     skinSearchInput.behindText.visible   = false;
     skinSearchInput.caret.alpha     = 0;
     skinSearchInput.selection.color = 0xff1565de;
     skinSearchInput.cameras   = [game.camHUD];
     skinSearchInput.maxLength = 50;

     skinSearchInput.onChange     = function(preText:String, curText:String) {
          FlxG.sound.play(Paths.soundRandom('keyclicks/keyClick', 1, 8, true), 1);
		setVar('SEARCH_INPUT_PRE_TEXT_CONTENT', preText);
          setVar('SEARCH_INPUT_TEXT_CONTENT', curText);

          if (curText.length > 0) {
               skinSearchInput_placeholder.text  = '';
          } else {
               skinSearchInput_placeholder.text  = 'Search Skins...';
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

     add(skinSearchInput_background);
     add(skinSearchInput_placeholder);
     add(skinSearchInput);
     add(skinSearchInput_caret);
}

function skinSearchInput_callInvalidSearch() {
     skinSearchInput.caretIndex = 1;
     skinSearchInput.set_text('');

     skinSearchInput_placeholder.text  = 'Invalid Skin!';
     skinSearchInput_placeholder.color = 0xFFB50000;
     FlxG.sound.play(Paths.sound('cancel'), 0.5);
}

function skinSearchInput_callResetSearch() {
     skinSearchInput.caretIndex = 1;
     skinSearchInput.set_text('');

     setVar('SEARCH_INPUT_TEXT_CONTENT', '');
     skinSearchInput_placeholder.text = 'Search Skins...';
}

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

function onUpdate(elapsed:Float) {
     skinSearchInput_onFocus();

     skinSearchInput_caret.visible = PsychUIInputText.focusOn == null ? false : skinSearchInput.caret.visible;
     skinSearchInput_caret.x       = skinSearchInput.caret.x + 1;
     skinSearchInput_caret.y       = skinSearchInput.caret.y;
}