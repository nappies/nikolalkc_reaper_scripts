--CLOSE MIDI
hwnd = reaper.MIDIEditor_GetActive()
reaper.MIDIEditor_OnCommand(hwnd,2) --close midi editor