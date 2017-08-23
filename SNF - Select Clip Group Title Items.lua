--Select Clip Group Title Items

function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end


item = {}
take = {}
name = {}
clip_group = {}
cg_index = 0

function Main()
	reaper.Main_OnCommand(40182,0) --Item: Select all items
	selected_count = reaper.CountSelectedMediaItems(0)
	for i = 0, selected_count - 1 do
		item[i] = reaper.GetSelectedMediaItem(0,i)
		take[i] = reaper.GetMediaItemTake(item[i], 0)
		name[i] =  reaper.GetTakeName(take[i])
		
		local first_string = string.sub(name[i], 1, 1)		
		if first_string == "@" then 
			clip_group[cg_index] = item[i]
			cg_index = cg_index + 1
			Msg(name[i])
		end
	end
	
	Msg("Clip Groups:"..cg_index)
	reaper.Main_OnCommand(40289,0) --Item: Unselect all items
	
	
	for i = 0, cg_index - 1 do 
		reaper.SetMediaItemSelected( clip_group[i], 1 )
	end
	
	
	
	reaper.UpdateArrange()
end
Main()