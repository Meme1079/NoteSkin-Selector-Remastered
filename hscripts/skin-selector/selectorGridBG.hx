import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import psychlua.LuaUtils;
import backend.Paths;

var modFolder = 'NoteSkin Selector Remastered';
if (getModSetting('remove_checker_bg', modFolder) == false) {
     var selectorGridBGBitmap = FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFF68CBFD, 0x0);
     var selectorGridBG:FlxBackdrop = new FlxBackdrop(selectorGridBGBitmap);
     selectorGridBG.velocity.set(20, 20);
     selectorGridBG.alpha   = 0.2;
     selectorGridBG.cameras = [game.camHUD];

     LuaUtils.getTargetInstance().remove(selectorGridBG);
     LuaUtils.getTargetInstance().insert(1, selectorGridBG);
     add(selectorGridBG, false);

     var selectorSideCover:FlxBackdrop = new FlxBackdrop(null, 0x10, 0);
     selectorSideCover.loadGraphic(Paths.image('ui/sidecover'));
     selectorSideCover.x       = 80;
     selectorSideCover.alpha   = 0.5;
     selectorSideCover.color   = 0xFF000000;
     selectorSideCover.cameras = [game.camHUD];
     selectorSideCover.velocity.y = 1000 / 20;

     LuaUtils.getTargetInstance().remove(selectorSideCover);
     LuaUtils.getTargetInstance().insert(2, selectorSideCover);
     add(selectorSideCover, false);
}