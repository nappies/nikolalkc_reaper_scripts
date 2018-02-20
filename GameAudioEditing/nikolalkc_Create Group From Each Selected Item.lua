array = {}
index = 0
count = reaper.CountMediaItems(0)
for i = 0, count -1 do
  item =  reaper.GetSelectedMediaItem(0, i )
  array[i] = item
  index = index + 1
end


reaper.Main_OnCommand(40289,0) --unselect all items

for i = 0, index - 1 do 
  local _item = array[i]
  if _item ~= nil then
    reaper.SetMediaItemSelected( _item, true)
    reaper.Main_OnCommand(40032,0) -- group items
    reaper.Main_OnCommand(40289,0) --unselect all items
  end
end

