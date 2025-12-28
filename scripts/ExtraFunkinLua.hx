import psychlua.FunkinLua;
import backend.InputFormatter;
import backend.Difficulty;
import backend.Highscore;
import backend.Song;
import states.LoadingState;
import flixel.util.FlxColorTransformUtil;

function onCreate() {
     /*
          ** Gets the current note keybinds
          ** @param noteType The specified note keybind index to get; Goes from `1` to `4`.
          ** @return The current keybinds, duh
     */
     createGlobalCallback('getKeyBinds', function(noteType:Int = 1) {
          var binds = ClientPrefs.keyBinds;
          var input = InputFormatter.getKeyName;
          switch (noteType) {
               case 1:  return input(binds.get('note_left')[0]);
               case 2:  return input(binds.get('note_down')[0]);
               case 3:  return input(binds.get('note_up')[0]);
               case 4:  return input(binds.get('note_right')[0]);
               default: return 'invalid, stupid';
          }
     });

     /*
          ** Loads a new song from different json difficulties.
          ** By Rodney~ An Imaginative Furball @see https://gamebanana.com/members/1729833
     
          ** @param name The said name of the song to load to.
          ** @param difficultyNum The difficulty number to choose from the json; Default value: `-1`, will use the current difficulty id.
          ** @param difficultyArray The difficulty array associated from the json.
          ** @return nothing
     */
     createGlobalCallback('loadNewSong', function(name:String = null, difficultyNum:Int = -1, difficultyArray:Array<String> = null) {
          if (difficultyArray != null) Difficulty.list = difficultyArray;
          if (name == null || name.length < 1) name = Song.loadedSongName;
		if (difficultyNum == -1) difficultyNum = PlayState.storyDifficulty;

		var poop = Highscore.formatSong(name, difficultyNum);
		Song.loadFromJson(poop, name);
		PlayState.storyDifficulty = difficultyNum;
		FlxG.state.persistentUpdate = false;
		LoadingState.loadAndSwitchState(new PlayState());

		FlxG.sound.music.pause();
		FlxG.sound.music.volume = 0;
		if (game != null && game.vocals != null) {
			game.vocals.pause();
			game.vocals.volume = 0;
		}
		FlxG.camera.followLerp = 0;
     });

     /* 
          ** Checks if the mouse overlaps an object or not.
          ** @param object The said object to overlap with the mouse.
          ** @param camera The camera for the mouse to detect overlapping objects.
          ** @param inLua  Whether the object is a Lua object or an object inside the game.
          ** @return `true`, if it overlapped an object.
     */
     createGlobalCallback('mouseOverlap', function(object:String, camera:String = 'camGame', inLua:Bool) {
          var cameraState = 'camGame';
          switch (camera.toLowerCase()) {
               case 'camgame':  cameraState = game.camGame;
               case 'camhud':   cameraState = game.camHUD;
               case 'camother': cameraState = game.camOther;
               default: cameraState = game.camGame;
          }

          if (inLua == true) {
               return FlxG.mouse.overlaps(game.object, cameraState);
          }
          return FlxG.mouse.overlaps(game.getLuaObject(object), cameraState);
     });

     /* 
          ** Inserts an object that the mouse will overlap it.
          ** @param object The said object to overlap with the mouse.
          ** @param camera The camera for the mouse to detect overlapping objects.
          ** @param inLua  Whether the object is a Lua object or an object inside the game.
          ** @return `true`, if it overlapped an object.
     */
     var mouseOverlappingObjects:Map<String, Array<String>> = ['objects' => [], 'cameras' => [], 'inLua' => []];
     createGlobalCallback('insertAllMouseOverlapObjects', function(object:String, camera:String = 'camGame', inLua:Bool) {
          var getMouseObjectElements = (elements:String) -> { return mouseOverlappingObjects[elements]; }
          var mouseElementObjects = getMouseObjectElements('objects');
          var mouseElementCameras = getMouseObjectElements('cameras');
          var mouseElementinLua   = getMouseObjectElements('inLua');

          mouseElementObjects.insert(mouseElementObjects.length, object);
          mouseElementCameras.insert(mouseElementCameras.length, camera);
          mouseElementinLua.insert(mouseElementinLua.length, inLua);
     });

     /* 
          ** Receives all the object that the mouse will overlap it.
          ** @return A string of Lua code.
     */
     var mouseOverlappingStrCode:String = '';
     createGlobalCallback('receiveAllMouseOverlapObjects', function() {
          var getMouseObjectElements = (elements:String) -> { return mouseOverlappingObjects[elements]; }
          var mouseElementObjects = getMouseObjectElements('objects');
          var mouseElementCameras = getMouseObjectElements('cameras');
          var mouseElementinLua   = getMouseObjectElements('inLua');

          if (Math.max(mouseElementObjects.length, mouseElementCameras.length) != mouseElementinLua.length) {
               debugPrint('ExtraFunkinError: Insufficient amount of elements equal to eachother', 0xff0000);
               return null;
          }

          for (elements in 0...mouseElementObjects.length) {
               var mouseElementObjects = getMouseObjectElements('objects')[elements];
               var mouseElementCameras = getMouseObjectElements('cameras')[elements];
               var mouseElementinLua   = getMouseObjectElements('inLua')[elements]; 
               mouseOverlappingStrCode += 'mouseOverlap(\'' + mouseElementObjects + '\', \'' + mouseElementCameras + '\', ' + mouseElementinLua + ') or ';
          }
          return 'return ' + mouseOverlappingStrCode.substring(0, mouseOverlappingStrCode.length - (' or ').length);
     });
}