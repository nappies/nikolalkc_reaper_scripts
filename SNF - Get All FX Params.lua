
track = reaper.GetSelectedTrack( 0, 0 )
retval, minvalOut, maxvalOut = reaper.TrackFX_GetParam( track, 0, 0 )


reaper.ShowConsoleMsg(retval.."\n")
reaper.ShowConsoleMsg(minvalOut.."\n")
reaper.ShowConsoleMsg(maxvalOut.."\n")
