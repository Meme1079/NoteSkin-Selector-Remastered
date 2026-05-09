# NoteSkin Selector Remastered
NoteSkin Selector Remastered; new layout, new code, and more customizability.

<img width="1440" alt="Screen Shot 2025-05-20 at 10 03 01 PM" src="https://github.com/user-attachments/assets/2c767ba6-8a79-4fe7-8381-aac242e73564" />

## About
This is a completely remastered one of my old mods "NoteSkin Selector", created in 2022. This mod heavily improves and enhances everything from the old mod. It includes a new friendlier GUI layout for selecting skins more easily, a better optimized and organized code. Basically, a more improved version of the current built-in noteskin system in the engine, because that one sucks ass ngl.

NoteSkin Selector Remastered © 2024 by Meme1079 is licensed under CC BY-NC-ND 4.0

## Installation Requirements
1. Computer
     - Windows, MacOS, and Linux are only supported when playing this mod. 
     - Android, Switch, Consoles and other devices are not supported due to controller issues (i.e page scrolling and UI interaction). 
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
- Somewhat Optimize, idk
- Data Saving

## Controls
### Selection
- <kbd>Tab</kbd> - Entering the skin selection screen _(May required to be double-tap if double-tapping is enabled)_
- <kbd>Q</kbd> or <kbd>E</kbd> - Switching up or down in pages
- <kbd>O</kbd> or <kbd>P</kbd> - Switching left or right in skin selection states
- <kbd>Z</kbd> or <kbd>X</kbd> - Switching left or right in preview animations
- <kbd>Enter</Kbd> - Returning back to the song
- <kbd>Esc</kbd> - Exiting without going back to the song
- <kbd>F1</kbd> - Entering Skin Editor

### Editor
- <kbd>Z</Kbd> - Make the template reference note move closer
- <kbd>X</Kbd> - Make the template reference note move back
- <kbd>C</Kbd> - Make the template reference note disappear
- <kbd>N</kbd> or <kbd>M</kbd> - Switching left or right in skin editor states
- <kbd>W</Kbd>, <kbd>A</Kbd>, <kbd>S</Kbd>, <kbd>D</Kbd> - Moving the skin's offset positions
- <kbd>UP</Kbd>, <kbd>LEFT</Kbd>, <kbd>DOWN</Kbd>, <kbd>RIGHT</Kbd> - Moving the skin's offset positions in smaller steps
- <kbd>Enter</Kbd> - Returning back to the skin Selection

***

## Version 3.0.0
### Additions/Changes
- Refactor the main source code to prevent shitty spaghetti code.
     - Skin Classes have been split into multiple subclasses each corresponding to their functions.
     - Added a custom UI API (FlavorUI), that I've dedicated way too long on this.
- Added the Skin Editor, making way more better and stylish than the last time.
- Added a new noteskin D-Sides and SonicFunk.
- Added a warning for switching pages (i.e. using keys from your keyboard) while searching skins.
- Added an ability to enable preview animation to fix conflicts with the note keybinds and controls.
- Adjust scrollbar thumb offsets between the start and end page positions.
- Selection of the skin will always remain constant, even when the skin has missing animations.
- Optimize checkboxes, syncing and clicking now checks for its interaction instead of every updated frame.
- Optimize certain parts of the code that might slightly actually optimize it.
     - Correctly allocate table to their corresponding array and dictionaries.
     - Remove certain component attributes that have never been utilize within the code.

### Bug Fixes
- Fixed a previous bug where holding the skin button then switching to another page, will cause some selection issue when choosing a skin.
- Fixed a bug where the searching algorithm would not render any skins due to the array having a max limit for some reason.
- Fixed a bug where the skin highlight name wouldn't render properly when searching/switching while hovering the skins.
- Fixed a bug when searching up skins will have their incorrect offsets shown.

***

# Stuff Used Here
> [!CAUTION]
> If you are a developer and you want to remove certain assets (skins, sprites, music, etc) that you own within this mod. I will happily obliged with your decision, I will remove your assets within the mod with no hesitation.

## Noteskins
- Majin - [Vs. Sonic.EXE 2.0](https://gamebanana.com/mods/316022)
- Arrow Funk - [Arrow Funk](https://gamebanana.com/mods/370234)
- Bad - [FNF, but bad (REMAKE)](https://gamebanana.com/wips/79374)
- Creepy - [Vs. Flippy](https://gamebanana.com/mods/300838)
- DSides - [FNF' D-Sides Redux](https://gamebanana.com/mods/652786)
- DokiDoki - [FNF: Doki Doki Takeover Plus!](https://gamebanana.com/mods/47364)
- M1KU - [Hatsune Miku - Project Funkin'](https://gamebanana.com/mods/485992)
- MM, MM Luigi - [FNF: Mario's Madness](https://gamebanana.com/mods/359554)
- Ourple - [Vs Ourple Guy](https://ourpleguy.neocities.org/)
- SonicFunk - [Sonic The Funk](https://gamebanana.com/mods/655019)
- Rush - [RUSHSHOT](https://gamebanana.com/mods/523534)
- TGT - [Tails Gets Trolled](https://gamebanana.com/mods/320596)

## Music
- File Select - Sonic 3 & Knuckles
- Extras Menu - Sonic Mega Collection
- Palmtree Panic (P mix) - Sonic CD
- Monkey - Original: [Mario Paint (Hirokazu Tanaka)](https://www.youtube.com/watch?v=gMRFXrbfKEo); Remix: [Mario's Madness (FriedFrick)](https://www.youtube.com/watch?v=x0AMU2nelAw)
- [Cruising](https://www.youtube.com/watch?v=samD2CCGkRU) - Xploshi

## Lua Libraries
<!-- - [MathParser](https://github.com/bytexenon/MathParser.lua) - bytexenon -->
- [Lua Pretty JSON](https://github.com/xiedacon/lua-pretty-json) - xiedaco
- [Lua Easing Library](https://github.com/EmmanuelOga/easing) - EmmanuelOga
- [Lua F-Strings](https://github.com/hishamhm/f-strings) - Hisham Muhammad

## Other
- Cursor - [Sonic Legacy](https://gamebanana.com/mods/496733)
- FridayNight Font - [Due Debts (BF Mix)](https://gamebanana.com/mods/575991); Creator: [LeGooey](https://gamebanana.com/members/2322712)