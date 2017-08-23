--Delete item or fade
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end


array_of_selected_items = {}
selected_count = reaper.CountSelectedMediaItems(0)


function Main()
	--TODO - Uraditi za ceo niz selektovanih item isto
		
	if	selected_count > 0  then
		for i = 0, selected_count - 1 do
			array_of_selected_items[i] = reaper.GetSelectedMediaItem(0,i)
			if array_of_selected_items[i] == nil then
				--Msg("PRAZNO")
			else
				--Msg("NEW ITEM=====")
				--get stuff
				item_pos = reaper.GetMediaItemInfo_Value(array_of_selected_items[i],"D_POSITION")
				fadein_len = reaper.GetMediaItemInfo_Value(array_of_selected_items[i],"D_FADEINLEN")
				fadeout_len = reaper.GetMediaItemInfo_Value(array_of_selected_items[i],"D_FADEOUTLEN")
				item_len = reaper.GetMediaItemInfo_Value(array_of_selected_items[i],"D_LENGTH")
				cursor_pos =  reaper.GetCursorPosition()
				
				--Msg(item_pos..fadein_len..fadeout_len..item_len..cursor_pos)
				--calculate stuff
				item_end = item_pos + item_len
				cursor_delta = cursor_pos - item_pos
				cursor_end_delta = item_end - cursor_pos
				
				--do stuff
				--ako si na fadein delu
				if fadein_len > cursor_delta then
					reaper.SetMediaItemInfo_Value(array_of_selected_items[i],"D_FADEINLEN",0)

				else
					--ako si na fadeout delu
					if fadeout_len > cursor_end_delta then 
						reaper.SetMediaItemInfo_Value(array_of_selected_items[i],"D_FADEOUTLEN",0)
					 --ako si na sredini klipa
					else
						--send delete
						--reaper.Main_OnCommand(40697, 0) --DELETE
						track =  reaper.GetMediaItem_Track(array_of_selected_items[i])
						reaper.DeleteTrackMediaItem(track, array_of_selected_items[i] )
					end
				end
				
				
				--ako nisi na nigde na klipu
				if cursor_pos < item_pos or item_end < cursor_pos then
					--send delete
					--reaper.Main_OnCommand(40697, 0) --DELETE
					 track =  reaper.GetMediaItem_Track(array_of_selected_items[i])
					 reaper.DeleteTrackMediaItem(track, array_of_selected_items[i] )
				end
				
					
			end
		end
	end
	
	
	
	
	reaper.UpdateArrange()
end
Main()