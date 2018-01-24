count = reaper.CountSelectedMediaItems(0)

if count > 0 then
  reaper.Main_OnCommand(40375,0) --move to next transient
else
  reaper.Main_OnCommand(40417,0) --select and move to next item in track
end
