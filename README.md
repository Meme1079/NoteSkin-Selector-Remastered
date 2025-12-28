# NoteSkin Selector Remastered
NoteSkin Selector Remastered; new layout, new code, and more customizability.

<img width="1440" alt="Screen Shot 2025-05-20 at 10 03 01 PM" src="https://github.com/user-attachments/assets/2c767ba6-8a79-4fe7-8381-aac242e73564" />

## About
This is a completely remastered one of my old mods "NoteSkin Selector", created in 2022. This mod heavily improves and enhances everything from the old mod. It includes a new friendlier GUI layout for selecting skins more easily, a better optimized and organized code. Basically, a more improved version of the current built-in noteskin system in the engine, because that one sucks ass ngl.

NoteSkin Selector Remastered © 2024 by Meme1079 is licensed under CC BY-NC-ND 4.0

## Installation Requirements
1. Computer
     - Windows, MacOS, and Linux are only supported when playing this mod. 
     - Android, Switch, Consoles and other devices are not supported due to controller issues (i.e page slider and UI interaction). 
          - Never ask a FUCKING port of this, especially Android I ain't doin' that shit.
2. Psych Engine
     - Versions: 0.7.3, 1.0.3, & 1.0.4 are only supported when playing this mod.
     - Other Psych Engine forks **might support** this mod.
          - The fork may use an unsupported version of Psych Engine or alter certain Lua & HScript features.

## Features
- A new improved and user-friendly GUI.
     - A `4x4` display grid to select multiple skins
     - A scroll bar to scroll through multiple pages of skin
     - A search bar to easily find the certain skin you want to select
- An new improve preview for skins
     - A preview strum in each of the skins and its accompanying animations
- Subfolders for custom skin packs
- Customizable background music
- Extremely Optimize
- Data Saving

## Controls
- <kbd>Tab</kbd> - Entering the skin selection screen _(May required to be double-tap if double-tapping is enabled)_
- <kbd>Q</kbd> or <kbd>E</kbd> - Switching up or down in pages
- <kbd>O</kbd> or <kbd>P</kbd> - Switching left or right in skin selection states
- <kbd>Z</kbd> or <kbd>X</kbd> - Switching left or right in preview animations
- <kbd>Enter</Kbd> - Returning back to the song
- <kbd>Esc</kbd> - Exiting without going back to the song

***

## Version 2.0.1
### Bug Fixes
- Fixed a bug when typing special characters that correspond to the special string patterns, will result in an error.
- Fixed a bug where the previously selected skin was prevented while switching to a different page and selecting skins from that page.

## Version 2.0.0
### Additions/Changes
- Overhual the main GUI with a new redesign, cuz it looks cool. _(inspired by OreUI from Minecraft)_
- Overhual the main source-code of the mod for organization and an ability to soft-code new skin selection states.
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
> The Noteskin Debug State is temporarily removed for reasons. Because I wanna rush it out becuase it has been almost a year without an update. And making an editor is the most hardest part, so cut me some slack here. This will be re-added back in the version 3.0.0.

***

# Stuff Used Here
> [!CAUTION]
> If you are a developer and you want to remove certain assets (skins, sprites, music, etc) that you own within this mod. I will happily obliged with your decision, I will remove your assets within the mod with no hesitation.

## Noteskins
- Majin - [Vs. Sonic.EXE 2.0](https://gamebanana.com/mods/316022)
- Arrow Funk - [Arrow Funk](https://gamebanana.com/mods/370234)
- Bad - [FNF, but bad (REMAKE)](https://gamebanana.com/wips/79374)
- Creepy - [Vs. Flippy](https://gamebanana.com/mods/300838)
- DokiDoki - [FNF: Doki Doki Takeover Plus!](https://gamebanana.com/mods/47364)
- M1KU - [Hatsune Miku - Project Funkin'](https://gamebanana.com/mods/485992)
- MM, MM Luigi - [FNF: Mario's Madness](https://gamebanana.com/mods/359554)
- Ourple - [Vs Ourple Guy](https://ourpleguy.neocities.org/)
- Rush - [RUSHSHOT](https://gamebanana.com/mods/523534)
- TGT - [Tails Gets Trolled](https://gamebanana.com/mods/320596)

## Music
- File Select - Sonic 3 & Knuckles
- Extras Menu - Sonic Mega Collection
- Palmtree Panic (P mix) - Sonic CD
- Monkey - Original: [Mario Paint (Hirokazu Tanaka)](https://www.youtube.com/watch?v=gMRFXrbfKEo); Remix: [Mario's Madness (FriedFrick)](https://www.youtube.com/watch?v=x0AMU2nelAw)

## Lua Libraries
<!-- - [MathParser](https://github.com/bytexenon/MathParser.lua) - bytexenon -->
- [Lua Pretty JSON](https://github.com/xiedacon/lua-pretty-json) - xiedaco
- [Lua Easing Library](https://github.com/EmmanuelOga/easing) - EmmanuelOga
- [Lua F-Strings](https://github.com/hishamhm/f-strings) - Hisham Muhammad

## Other
- Cursor - [Sonic Legacy](https://gamebanana.com/mods/496733)
- FridayNight Font - [Due Debts (BF Mix)](https://gamebanana.com/mods/575991); Creator: [LeGooey](https://gamebanana.com/members/2322712)