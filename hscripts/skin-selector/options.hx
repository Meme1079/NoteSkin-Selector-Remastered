import options.OptionsState;
import backend.MusicBeatState;

game.paused = true; // For lua
game.vocals.volume = 0;
MusicBeatState.switchState(new OptionsState());
if (ClientPrefs.data.pauseMusic != 'None') {
    	FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), game.modchartSounds('pauseMusic').volume);
    	FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
     FlxG.sound.music.time = game.modchartSounds('pauseMusic').time;
}
OptionsState.onPlayState = true;