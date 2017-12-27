
reaper.ShowConsoleMsg("")
item = reaper.GetSelectedMediaItem(0, 0)
take = reaper.GetActiveTake(item)
src = reaper.GetMediaItemTake_Source(take)
filename = reaper.GetMediaSourceFileName(src, 1)
reaper.ShowConsoleMsg("\n"..filename)
--proba komitovanja iz atoma
--nove izmene
