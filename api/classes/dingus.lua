--- Loads multiple attribute properties (including its save data) for the class, used after initialization.
--- * All attribute properties are PRIVATE (i.e. not accessible outside this class), hence the CAPITALIZATION format.
---@return nil
function SkinNotes:load()
     self.TOTAL_SKINS       = states.getTotalSkins(self.stateClass, false)
     self.TOTAL_SKINS_PATHS = states.getTotalSkins(self.stateClass, true)
     self.TOTAL_SKINS_NAMES = states.getTotalSkinNames(self.stateClass)

     -- Skin Properties --

     self.TOTAL_SKIN_LIMIT           = states.getTotalSkinLimit(self.stateClass)
     self.TOTAL_SKIN_OBJECTS         = states.getTotalSkinObjects(self.stateClass)
     self.TOTAL_SKIN_OBJECTS_ID      = states.getTotalSkinObjects(self.stateClass, 'ids')
     self.TOTAL_SKIN_OBJECTS_NAMES   = states.getTotalSkinObjects(self.stateClass, 'names')
     self.TOTAL_SKIN_OBJECTS_INDICES = states.getTotalSkinObjectIndexes(self.stateClass)

     -- Display Properties --

     self.TOTAL_SKIN_OBJECTS_HOVERED  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.TOTAL_SKIN_OBJECTS_CLICKED  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.TOTAL_SKIN_OBJECTS_SELECTED = states.getTotalSkinObjects(self.stateClass, 'bools')

     self.TOTAL_SKIN_METAOBJ_DISPLAY = states.getMetadataObjectSkins(self.stateClass, 'display', true)
     self.TOTAL_SKIN_METAOBJ_PREVIEW = states.getMetadataObjectSkins(self.stateClass, 'preview', true)
     self.TOTAL_SKIN_METAOBJ_SKINS   = states.getMetadataObjectSkins(self.stateClass, 'skins', true)

     self.TOTAL_SKIN_METAOBJ_ORDERED_DISPLAY = states.getMetadataSkinsOrdered(self.stateClass, 'display', true)
     self.TOTAL_SKIN_METAOBJ_ORDERED_PREVIEW = states.getMetadataSkinsOrdered(self.stateClass, 'preview', true)
     self.TOTAL_SKIN_METAOBJ_ORDERED_SKINS   = states.getMetadataSkinsOrdered(self.stateClass, 'skins', true)

     -- Scrollbar Properties --

     self.SCROLLBAR_PAGE_INDEX          = 1
     self.SCROLLBAR_TRACK_PAGE_INDEX    = 1
     self.SCROLLBAR_TRACK_THUMB_PRESSED = false
     self.SCROLLBAR_TRACK_TOGGLE        = false
     self.SCROLLBAR_TRACK_MAJOR_SNAP    = states.getPageSkinSliderPositions(self.stateClass).intervals
     self.SCROLLBAR_TRACK_MINOR_SNAP    = states.getPageSkinSliderPositions(self.stateClass).semiIntervals

     -- Display Selection Properties --

     local SELECT_SKIN_PAGE_INDEX           = SkinNoteSave:get('SELECT_SKIN_PAGE_INDEX',           self.stateClass:upper(), 1)
     local SELECT_SKIN_INIT_SELECTION_INDEX = SkinNoteSave:get('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), 1)
     local SELECT_SKIN_PRE_SELECTION_INDEX  = SkinNoteSave:get('SELECT_SKIN_PRE_SELECTION_INDEX',  self.stateClass:upper(), 1)
     local SELECT_SKIN_CUR_SELECTION_INDEX  = SkinNoteSave:get('SELECT_SKIN_CUR_SELECTION_INDEX',  self.stateClass:upper(), 1)

     self.SELECT_SKIN_PAGE_INDEX           = SELECT_SKIN_PAGE_INDEX           -- current page index
     self.SELECT_SKIN_INIT_SELECTION_INDEX = SELECT_SKIN_INIT_SELECTION_INDEX -- current pressed selected skin
     self.SELECT_SKIN_PRE_SELECTION_INDEX  = SELECT_SKIN_PRE_SELECTION_INDEX  -- highlighting the current selected skin
     self.SELECT_SKIN_CUR_SELECTION_INDEX  = SELECT_SKIN_CUR_SELECTION_INDEX  -- current selected skin index
     self.SELECT_SKIN_CLICKED_SELECTION    = false                            -- whether the skin display has been clicked or not

     -- Preview Animation Properties --

     local PREVIEW_SKIN_OBJECT_INDEX = SkinNoteSave:get('PREVIEW_SKIN_OBJECT_INDEX', self.stateClass:upper(), 1)

     self.PREVIEW_CONST_METADATA_DISPLAY       = json.parse(getTextFromFile('json/notes/constant/display.json'))
     self.PREVIEW_CONST_METADATA_PREVIEW       = json.parse(getTextFromFile('json/notes/constant/preview.json'))
     self.PREVIEW_CONST_METADATA_PREVIEW_ANIMS = json.parse(getTextFromFile('json/notes/constant/preview_anims.json'))
     self.PREVIEW_CONST_METADATA_SKINS         = json.parse(getTextFromFile('json/notes/constant/skins.json'))

     self.PREVIEW_SKIN_OBJECT_INDEX         = PREVIEW_SKIN_OBJECT_INDEX
     self.PREVIEW_SKIN_OBJECT_ANIMS         = {'confirm', 'pressed', 'colored'}
     self.PREVIEW_SKIN_OBJECT_ANIMS_HOVERED = {false, false}
     self.PREVIEW_SKIN_OBJECT_ANIMS_CLICKED = {false, false}

     self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING = states.getPreviewObjectMissingAnims(
          {'strums', 'confirm', 'pressed', 'colored'},
          self.TOTAL_SKIN_METAOBJ_PREVIEW,
          self.TOTAL_SKIN_LIMIT
     )

     -- Checkbox Skin Properties --

     local CHECKBOX_SKIN_OBJECT_CHARS_PLAYER   = SkinNoteSave:get('CHECKBOX_SKIN_OBJECT_CHARS_PLAYER',   self.stateClass:upper(), 0)
     local CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT = SkinNoteSave:get('CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT', self.stateClass:upper(), 0)

     self.CHECKBOX_SKIN_OBJECT_HOVERED = {false, false}
     self.CHECKBOX_SKIN_OBJECT_CLICKED = {false, false}

     self.CHECKBOX_SKIN_OBJECT_CHARS  = {CHECKBOX_SKIN_OBJECT_CHARS_PLAYER, CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT}
     self.CHECKBOX_SKIN_OBJECT_TOGGLE = {false, false}

     -- Search Properties --

     self.SEARCH_SKIN_OBJECT_IDS           = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_PAGES         = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_ANIMS_MISSING = table.new(MAX_NUMBER_CHUNK, 0)
end

--- Loads multiple attribute properties (including its save data) for the class, used after initialization.
--- * All attribute properties are PRIVATE (i.e. not accessible outside this class), hence the CAPITALIZATION format.
---@return nil
function SkinSplashes:load()
     self.TOTAL_SKINS       = states.getTotalSkins(self.stateClass, false)
     self.TOTAL_SKINS_PATHS = states.getTotalSkins(self.stateClass, true)
     self.TOTAL_SKINS_NAMES = states.getTotalSkinNames(self.stateClass)

     -- Skin Properties --

     self.TOTAL_SKIN_LIMIT           = states.getTOTAL_SKIN_LIMIT(self.stateClass)
     self.TOTAL_SKIN_OBJECTS         = states.getTOTAL_SKIN_OBJECTS(self.stateClass)
     self.TOTAL_SKIN_OBJECTS_ID      = states.getTOTAL_SKIN_OBJECTS(self.stateClass, 'ids')
     self.TOTAL_SKIN_OBJECTS_NAMES   = states.getTOTAL_SKIN_OBJECTS(self.stateClass, 'names')
     self.TOTAL_SKIN_OBJECTS_INDICES = states.getTotalSkinObjectIndexes(self.stateClass)

     -- Display Properties --
     
     self.TOTAL_SKIN_OBJECTS_HOVERED  = states.getTOTAL_SKIN_OBJECTS(self.stateClass, 'bools')
     self.TOTAL_SKIN_OBJECTS_CLICKED  = states.getTOTAL_SKIN_OBJECTS(self.stateClass, 'bools')
     self.TOTAL_SKIN_OBJECTS_SELECTED = states.getTOTAL_SKIN_OBJECTS(self.stateClass, 'bools')

     self.TOTAL_SKIN_METAOBJ_DISPLAY = states.getMetadataObjectSkins(self.stateClass, 'display', true)
     self.TOTAL_SKIN_METAOBJ_PREVIEW = states.getMetadataObjectSkins(self.stateClass, 'preview', true)
     self.TOTAL_SKIN_METAOBJ_SKINS   = states.getMetadataObjectSkins(self.stateClass, 'skins', true)

     self.TOTAL_SKIN_METAOBJ_ORDERED_DISPLAY = states.getMetadataSkinsOrdered(self.stateClass, 'display', true)
     self.TOTAL_SKIN_METAOBJ_ORDERED_PREVIEW = states.getMetadataSkinsOrdered(self.stateClass, 'preview', true)
     self.TOTAL_SKIN_METAOBJ_ORDERED_SKINS   = states.getMetadataSkinsOrdered(self.stateClass, 'skins', true)

     -- Slider Properties --

     self.SCROLLBAR_PAGE_INDEX          = 1
     self.SCROLLBAR_TRACK_PAGE_INDEX    = 1
     self.SCROLLBAR_TRACK_THUMB_PRESSED = false
     self.SCROLLBAR_TRACK_TOGGLE        = false
     self.SCROLLBAR_TRACK_MAJOR_SNAP    = states.getPageSkinSliderPositions(self.stateClass).intervals
     self.SCROLLBAR_TRACK_MINOR_SNAP    = states.getPageSkinSliderPositions(self.stateClass).semiIntervals

     -- Display Selection Properties --
     
     local SELECT_SKIN_PAGE_INDEX           = SkinNoteSave:get('SELECT_SKIN_PAGE_INDEX',           self.stateClass:upper(), 1)
     local SELECT_SKIN_INIT_SELECTION_INDEX = SkinNoteSave:get('SELECT_SKIN_INIT_SELECTION_INDEX', self.stateClass:upper(), 1)
     local SELECT_SKIN_PRE_SELECTION_INDEX  = SkinNoteSave:get('SELECT_SKIN_PRE_SELECTION_INDEX',  self.stateClass:upper(), 1)
     local SELECT_SKIN_CUR_SELECTION_INDEX  = SkinNoteSave:get('SELECT_SKIN_CUR_SELECTION_INDEX',  self.stateClass:upper(), 1)

     self.SELECT_SKIN_PAGE_INDEX           = SELECT_SKIN_PAGE_INDEX             -- current page index
     self.SELECT_SKIN_INIT_SELECTION_INDEX = SELECT_SKIN_INIT_SELECTION_INDEX   -- current pressed selected skin
     self.SELECT_SKIN_PRE_SELECTION_INDEX  = SELECT_SKIN_PRE_SELECTION_INDEX    -- highlighting the current selected skin
     self.SELECT_SKIN_CUR_SELECTION_INDEX  = SELECT_SKIN_CUR_SELECTION_INDEX    -- current selected skin index
     self.SELECT_SKIN_CLICKED_SELECTION    = false                              -- whether the skin display has been clicked or not

     -- Preview Animation Properties --

     local PREVIEW_SKIN_OBJECT_INDEX = SkinNoteSave:get('PREVIEW_SKIN_OBJECT_INDEX', self.stateClass:upper(), 1)

     local PREVIEW_NOTES_SKIN_METAOBJ_STRUMS        = SkinSplashSave:get('PREVIEW_NOTES_SKIN_METAOBJ_STRUMS',        self.stateClass:upper(), json.parse(getTextFromFile('json/splashes/constant/strums.json')))
     local PREVIEW_NOTES_SKIN_METAOBJ_STRUMS_FRAMES = SkinSplashSave:set('PREVIEW_NOTES_SKIN_METAOBJ_STRUMS_FRAMES', self.stateClass:upper(), {24, 24, 24, 24})
     local PREVIEW_NOTES_SKIN_METAOBJ_STRUMS_SIZE   = SkinSplashSave:get('PREVIEW_NOTES_SKIN_METAOBJ_STRUMS_SIZE',   self.stateClass:upper(), {0.65, 0.65, 0.65, 0.65})
     local PREVIEW_NOTES_SKIN_METAOBJ_STRUMS_PATH   = SkinSplashSave:get('PREVIEW_NOTES_SKIN_METAOBJ_STRUMS_PATH',   self.stateClass:upper(), 'noteSkins/NOTE_assets')

     self.PREVIEW_CONST_METADATA_DISPLAY       = json.parse(getTextFromFile('json/splashes/constant/display.json'))
     self.PREVIEW_CONST_METADATA_PREVIEW       = json.parse(getTextFromFile('json/splashes/constant/preview.json'))
     self.PREVIEW_CONST_METADATA_PREVIEW_ANIMS = json.parse(getTextFromFile('json/splashes/constant/preview_anims.json'))
     self.PREVIEW_CONST_METADATA_PREVIEW_NOTE  = json.parse(getTextFromFile('json/notes/constant/preview.json'))
     self.PREVIEW_CONST_METADATA_SKINS         = json.parse(getTextFromFile('json/splashes/constant/skins.json'))

     self.PREVIEW_SKIN_OBJECT_INDEX         = PREVIEW_SKIN_OBJECT_INDEX
     self.PREVIEW_SKIN_OBJECT_ANIMS         = {'note_splash1', 'note_splash2'}
     self.PREVIEW_SKIN_OBJECT_ANIMS_HOVERED = {false, false}
     self.PREVIEW_SKIN_OBJECT_ANIMS_CLICKED = {false, false}

     self.PREVIEW_NOTES_SKIN_METAOBJ_STRUMS        = PREVIEW_NOTES_SKIN_METAOBJ_STRUMS
     self.PREVIEW_NOTES_SKIN_METAOBJ_STRUMS_FRAMES = PREVIEW_NOTES_SKIN_METAOBJ_STRUMS_FRAMES
     self.PREVIEW_NOTES_SKIN_METAOBJ_STRUMS_SIZE   = PREVIEW_NOTES_SKIN_METAOBJ_STRUMS_SIZE
     self.PREVIEW_NOTES_SKIN_METAOBJ_STRUMS_PATH   = PREVIEW_NOTES_SKIN_METAOBJ_STRUMS_PATH

     self.PREVIEW_SKIN_OBJECT_ANIMS_MISSING = states.getPreviewObjectMissingAnims(
          {'note_splash1', 'note_splash2'},
          self.TOTAL_SKIN_METAOBJ_PREVIEW,
          self.TOTAL_SKIN_LIMIT
     )

     -- Checkbox Skin Properties --

     local CHECKBOX_SKIN_OBJECT_CHARS_PLAYER   = SkinNoteSave:get('CHECKBOX_SKIN_OBJECT_CHARS_PLAYER',   self.stateClass:upper(), 0)
     local CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT = SkinNoteSave:get('CHECKBOX_SKIN_OBJECT_CHARS_OPPONENT', self.stateClass:upper(), 0)

     self.CHECKBOX_SKIN_OBJECT_HOVERED = {false, false}
     self.CHECKBOX_SKIN_OBJECT_CLICKED = {false, false}

     self.CHECKBOX_SKIN_OBJECT_CHARS  = {CHECKBOX_SKIN_OBJECT_CHARS_PLAYER}
     self.CHECKBOX_SKIN_OBJECT_TOGGLE = {false}

     -- Search Properties --

     self.SEARCH_SKIN_OBJECT_IDS           = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_PAGES         = table.new(MAX_NUMBER_CHUNK, 0)
     self.SEARCH_SKIN_OBJECT_ANIMS_MISSING = table.new(MAX_NUMBER_CHUNK, 0)
end