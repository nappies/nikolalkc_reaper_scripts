--[[
 ReaScript Name: Toggle Freeze And Unfreeze Selected Items
 Author: nikolalkc
 Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 REAPER: 5+
 Version: 1.32
 About:
  This is a simulation of Nuendo's DIRECT OFFLINE PROCESSING. This script renders selected items to new takes and puts all item fx offline.
  If that operation has already been done then it restores original items length and fades,
  deletes rendered take from project and puts all items fx back online.
  NOTE: It works only with items that have one or two takes.
]]

--[[
 * Changelog:
 * v1.32 (2018-04-03)
	+ Volume saving and support added
 * v1.31 (2018-04-03)
	+ New description
 * v1.3 (2018-04-03)
 	+ Rendered item have stretch markers as visual indicators
 * v1.2 (2018-04-03)
	+ Redefined rendering logic to include fades and time selection
 * v1.1 (2018-04-02)
	+ Preserve source type when rendering (added)
	+ Delete active take and source file on restore (added)
 * v1.0 (2018-02-26)
	+ Initial Commit
]]

function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end
--take item info
number_of_takes_in_first_item= nil
selected_count = reaper.CountSelectedMediaItems(0)
selection_valid = nil
selected_items = {}
idx = 0

function RenderItemsAndSetFXOffline()
	for i = 0, selected_count -1 do 
		selected_items[idx] = reaper.GetSelectedMediaItem(0,i)
		idx = idx + 1
	end
	
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVETIME5"),0) --save time selection slot 5
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_WNCLS4"),0) --SWS/S&M: Close all FX chain windows
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_WNCLS3"),0) --SWS/S&M: Close all floating FX windows
	
	for i = 0, idx - 1 do
		reaper.Main_OnCommand(40289,0) --unselect all items
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTTIME5"),0) --restore time selection slot 5
		
		local item = selected_items[i]
		local take = reaper.GetMediaItemTake(item, 0)
		local track = reaper.GetMediaItem_Track( item )
		local length = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
		local fadein = reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN" )
		local fadeout = reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN" )
		local item_volume = reaper.GetMediaItemInfo_Value(item, "D_VOL")
		
		--write parameters to notes
		local note = length..[[-]]..fadein..[[-]]..fadeout..[[-]]..item_volume
		reaper.ULT_SetMediaItemNote( item, note)
		--retval, offsOut, lenOut, revOut reaper.PCM_Source_GetSectionInfo( src )
		
		
		reaper.SetMediaItemSelected( item, true )
		reaper.Main_OnCommand(41173,0) --move cursor to start of items
		reaper.Main_OnCommand(40222,0) --set start loop point to selected item start
		reaper.Main_OnCommand(40698,0) --copy items
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_OFFLINE"),0) --SWS/S&M: Set all take FX offline for selected items
		reaper.Main_OnCommand(40297,0) --unselect all tracks
		reaper.SetTrackSelected( track, true )
		reaper.Main_OnCommand(40001,0) --insert new track
		local temp_track =  reaper.GetSelectedTrack( 0, 0 )
		reaper.Main_OnCommand(40058,0) --paste item to new track
		local fx_count = reaper.TakeFX_GetCount( take )
		if fx_count > 0 then 
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYFXCHAIN2"),0) --SWS/S&M: cut fx chain from selected items
		end
		reaper.Main_OnCommand(40606,0) --Item: Glue items, including leading fade-in and trailing fade-out
		if fx_count > 0 then 
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYFXCHAIN8"),0) --SWS/S&M: paste fx chain to selected items
		end
		reaper.Main_OnCommand(41993,0) --Item: Apply track/take FX to items (multichannel output) -- temp track is empty so it will not have track fx
		reaper.Main_OnCommand(40126,0) --Take: Switch items to previous take
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_DELTAKEANDFILE4"),0) --SWS/S&M: Delete active take and source file in selected items (no undo)
		reaper.SetMediaItemSelected( item, true )
		reaper.Main_OnCommand(40438,0) --Take: Implode items across tracks into takes
		reaper.Main_OnCommand(40125,0) --Take: Switch items to next take
		reaper.Main_OnCommand(41193,0) --Item: Remove fade in and fade out
		reaper.DeleteTrack( temp_track )
		
		local start_time, end_time =  reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false)
		local delta_time = end_time - start_time
		local new_item  = reaper.GetSelectedMediaItem(0,0)
		if delta_time > 0 then
			reaper.Main_OnCommand(41320,0) --Item: Move items to time selection, trim/loop to fit
		end
		local new_length = reaper.GetMediaItemInfo_Value( new_item, "D_LENGTH" )
		local new_take =  reaper.GetActiveTake( item )
		reaper.SetTakeStretchMarker(new_take, -1, new_length*0.5)
		reaper.SetTakeStretchMarker(new_take, -1, new_length*0.49)
		reaper.SetTakeStretchMarker(new_take, -1, new_length*0.51)
		reaper.Main_OnCommand(41923,0) -- reset item volume to 0db

		
		
		
		
		
		
		
	end

	--choose
	-- reaper.Main_OnCommand(41999,0) --Item: Render items to new take --old
	-- -- reaper.Main_OnCommand(40601,0) --Item: Render items to new take (PRESERVE SOURCE TYPE)
	
	-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELECTFIRSTTAKEOFITEMS"),0) --Xenakios/SWS: Select first take in selected items
	-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_OFFLINE"),0) --SWS/S&M: Set all take FX offline for selected items
	-- reaper.Main_OnCommand(40125,0) --Take: Switch items to next take
	-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_TAKESRANDCOLS"),0) --one random custom take color
	-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_RESETITEMLENMEDOFFS"),0) --Xenakios/SWS: Reset item length and media offset
end

function RestoreItemsAndSetFXOnline()
	for i = 0, selected_count - 1 do
		local item = reaper.GetSelectedMediaItem(0,i)
		note =  reaper.ULT_GetMediaItemNote( item )
		reaper.ULT_SetMediaItemNote( item, note)
		--retval, offsOut, lenOut, revOut reaper.PCM_Source_GetSectionInfo( src )
		
		local length, fadein, fadeout, volume = note:match("([^,]+)-([^,]+)-([^,]+)-([^,]+)")
		-- Msg(length)
		-- Msg(fadein)
		-- Msg(fadeout)
		-- Msg(volume)
		
		reaper.SetMediaItemInfo_Value( item, "D_LENGTH", length)
		reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", fadein)
		reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", fadeout)
		reaper.SetMediaItemInfo_Value( item, "D_VOL", volume)
		reaper.ULT_SetMediaItemNote( item, "")
	end
	--choose
	-- reaper.Main_OnCommand(40129,0) --Take: Delete active take from items
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_DELTAKEANDFILE4"),0) --SWS/S&M: Delete active take and source file in selected items (no undo)
	
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_ONLINE"),0) --all take fx online
	--reaper.Main_OnCommand(40638,0) --show item fx
end


if selected_count > 1 then
	selection_valid = true
	for i = 0, selected_count - 1 do
		local item = reaper.GetSelectedMediaItem(0,i)
		if number_of_takes_in_first_item == nil then
			number_of_takes_in_first_item = reaper.CountTakes( item )
		else
			local cur_take_number = reaper.CountTakes(item)
			if number_of_takes_in_first_item ~= cur_take_number then
				Msg("ERROR: THIS IS NOT GOING TO WORK, ITEMS DIFFER IN TAKE NUMBERS")
				selection_valid = false
				break
			else 
				if number_of_takes_in_first_item > 2 then 
					Msg("ERROR: THIS SCRIPT WORKS JUST WITH ITEMS THAT HAVE ONE(1) OR TWO(2) TAKES!")
					selection_valid = false
					break
				end
			end
		end
	end
else
	if selected_count == 1 then 
		local item = reaper.GetSelectedMediaItem(0,0)
		number_of_takes_in_first_item = reaper.CountTakes(item)
		if number_of_takes_in_first_item ~= nil then
			if number_of_takes_in_first_item < 3 then
				selection_valid = true
			else 
				Msg("ERROR: THIS SCRIPT WORKS JUST WITH ITEMS THAT HAVE ONE(1) OR TWO(2) TAKES!")
				selection_valid = false
			end
		end
		-- Msg("only one item selected, check what to do")
	else
		Msg("ERROR: SELECT AT LEAST ONE ITEM")
	end
	
end




--MAIN
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh( 1 )
-- Msg(number_of_takes_in_first_item)
if selection_valid then
	if number_of_takes_in_first_item == 1 then
		-- Msg("render items and put sfx offline")
		RenderItemsAndSetFXOffline()
	else
		if number_of_takes_in_first_item == 2 then
			-- Msg("restore previous state and put sfx online")
			RestoreItemsAndSetFXOnline()
		end
	end
else 
	Msg("SELECTION NOT VALID")
end
reaper.PreventUIRefresh( -1 )
reaper.Undo_EndBlock("nikolalkc_Toggle Freeze And Unfreeze Selected Items", -1)



