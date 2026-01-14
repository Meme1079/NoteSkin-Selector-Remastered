## Version 3.0.0
### Additions/Changes
- Refactor the main source code to prevent shitty spaghetti code.
     - Skin Classes have been split into multiple subclasses each corresponding to their functions.
- Added a warning for switching pages (i.e. using keys from your keyboard) while searching skins.
- Adjust scrollbar thumb offsets between the start and end page positions.
- Selection of the skin will always remain constant, even when the skin has missing animations.
- Optimize checkboxes, syncing and clicking now checks for its interaction instead of every updated frame.

### Bug Fixes
- Fixed a previous bug where holding the skin button then switching to another page, will cause some selection issue when choosing a skin.
- Fixed a bug where the searching algorithm would not render any skins due to the array having a max limit for some reason.
- Fixed a bug where the skin highlight name wwouldn't render properly when searching/switching while hovering the skins.

## Version 2.1.0
### Additions/Changes
- Added support to Psych Engine v0.7.3.
- Added a skin highlight name, which obviously displays the name of the skin when hovering.
- Blocked the skin implementation and ability to go into the skin selection screen, cuz it's not supported yet.
- Adjust the Bad noteskin pressed offsets.

### Bug Fixes
- All scripts that are outside this mod are now forcefully removed, thus preventing any soft-locking and weird bugs from happening.
- Skins (i.e. notes & slashes) can actually load after a cutscene has been finished.
- Checkbox checking animation will now instantly cut-off when selecting a different skin.
- Switching through different preview animations will now deselect the selected skin, if it has a missing animations within its metadata JSON.

## Version 2.0.1
### Bug Fixes
- Fixed a bug when typing special characters that correspond to the special string patterns, will result in an error.
- Fixed a bug where the previously selected skin was prevented while switching to a different page and selecting skins from that page.

## Version 2.0.0
### Additions/Changes
- Overhual the main GUI with a new redesign, cuz it looks cool. _(inspired by OreUI from Minecraft)_
- Overhual the main source code of the mod for organization and an ability to soft-code new skin selection states.
     - Classes to create custom states for different skins by using inheritance and polymorphism stuff.
     - Loads separated chunks of object sprites of the skins when switching pages.
- Additions/Changes on the skin selection states.
     - Added the splashskin selection state.
          - Obviously works the same as the noteskin selection state.
          - You can switch to other skin selection states by pressing <kbd>O</kbd> (left) or <kbd>P</kbd> (right) keys.
     - Added a slider for switching skin pages manually.
          - Automatically snaps to the nearest page.
          - Automatically disable it itself if there's only contain 1 page within that state.
     - Added prevention for invalid data.
          - If detected, it will reset the specific data that is currently invalid.
     - Added a search bar for searching certain skins more easily.
     - Added a "smoother" color tweening to the background.
- Additions/Changes on the Display Grid Selection.
     - Added a new graphic icon to each display grid to easily see the skin's more easily.
          - Features a hovering, pressed, selection, and blocked sprites.
     - Increase the grid selection from a `3x4` to a `4x4`, to easily select more skins.
- Additions/Changes on the Preview Strum Selection.
     - Added a new GUI for selecting preview strum animations.
          - Display it's current preview strum animation name.
          - 2 selection buttons to change the preview strum animations.
- Added an implementation for custom skin packs.
     - Subfolders for the skin's texture within the skin packs (`images` folder).
     - Subfolders for the skin's metdata JSON within the skin packs (`json` folder).
- Organized file locations.
     - Added an `api` folder to group: `classes`, `libraries`, and `modules` for convenient sake.
     
> [!NOTE]
> The Noteskin Debug State is temporarily removed for reasons. Because I wanna rush it out becuase it has been almost a year without an update. And making an editor is the most hardest part, so cut me some slack here. This will be re-added back in v3.0.0.

## Version 1.5.0
### Additions/Changes
- Additions/Changes on the NoteSkin Debug State.
     - Added an ability to erase all data offset files for clearing stuff, just pressed <kbd>SHIFT + B</kbd>.
     - Added a delay when saving and deleting data offset files.
     - Added an easter egg. _(You will never find this)_
- Added support for animated noteskins for note preview animations.
- The "Enable Double-Tapping Safe" setting will now work for when pressing <kbd>SHIFT</kbd> key.
- Remove any external scripts for better performace and to avoid conflicts with other scripts.
- Organized the files inside the modules folder, for coders like me.

### Bug Fixes
- Fixed a bug, when deleting a noteskin file in-game, it will crash the moment the countdown finished.
- Fixed a bug on the note preview animations, when holding the <kbd>LEFT-BRACKET</kbd> key then changing the type of animation, it will display the last note animation that was playing.
- Fixed a bug on the NoteSkin Debug State.
     - When attempting to move the idle note offset animations, it will actually move it.
     - When saving the offset positions, the positions will swap confirm and pressed positions, causing bugs.

## Version 1.0.0
- Initial Release