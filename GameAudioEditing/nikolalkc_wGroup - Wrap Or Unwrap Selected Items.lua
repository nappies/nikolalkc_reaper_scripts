--[[
	ReaScript Name:wGroup - Wrap or Unwrap Selected Items
	Author: nikolalkc
	Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
	REAPER: 5+
	Extensions: SWS
	Version: 1.6
	About:
		Creates special kind of group from selected items, filled with empty midi items and one empty item which can be used for naming
		Instructions: Create item selection and run the script
]]

--[[
 * Changelog:
 * v1.6 (2018-04-10)
	+ Fixed error with unwrapping multiple groups
 * v1.5 (2018-04-10)
	+ Cleaned deprecated toggle strech items code
 * v1.4 (2018-03-19)
	+ Wrapping and unwrapping now does not affect label name, group id is used instead
 * v1.3 (2018-03-19)
	+ Support for deleting just automatically created empty midi items when unwrapping
 * v1.2 (2018-03-19)
	+ Label item update their lentgth on rewraping if selection is wider that label item
 * v1.1 (2018-03-19)
	+ Action is now toggle for wrapping and unwrapping
 * v1.0 (0000-00-00)
	+ Initial Release
--]]

--UTILITIES=======================================
function Msg(param)
	reaper.ShowConsoleMsg(tostring(param).."\n")
end


--INIT============================================
item = {}
take = {}
name = {}
start_pos = {}
length = {}
end_pos = {}
items_on_same_track = {}
item_track = {}
midi_items = {}
midi_idx = 0

track_idx = 0
item_idx = 0

first_start_pos_in_track = nil
last_end_pos_in_track = nil

first_selected_track = nil
last_selected_track = nil

--MAIN==========================================
empty_items = {}
empty_index = 0
function Main()
	reaper.ShowConsoleMsg("") --Clear Screen

	reaper.Main_OnCommand(40290,0) --Time selection: Set time selection to items
	track = reaper.GetTrack(0,1)
	starttime = 1
	endtime = 2
	qnInOptional = 0
	
	reaper.Main_OnCommand( 40034, 0 ) --Item grouping: Select all items in groups
	selected_count = reaper.CountSelectedMediaItems(0)
	--Msg(selected_count)

	--Find selection start and end
	selectionStart, selectionEnd =  reaper.GetSet_LoopTimeRange(0,0,0,0,0)
	selectionLength = selectionEnd - selectionStart
	 
	--check if there are empty items in selection
	for i = 0, selected_count - 1 do
		local item = reaper.GetSelectedMediaItem(0,i)
		local take = reaper.GetMediaItemTake(item, 0)
		if take ~= nil then
			local name =  reaper.GetTakeName(take)
		else
			empty_items[empty_index] = item
			empty_index = empty_index + 1
		end
	end
	
	local Error = false
	if empty_index > 0 then
		local first_signature = nil
		for k = 0, empty_index -1 do
			if k == 0 then
				first_signature = reaper.GetMediaItemInfo_Value(empty_items[k],"I_GROUPID")
				if first_signature ~= 0 then first_signature = 1 end
				-- first_signature = string.sub(reaper.ULT_GetMediaItemNote( empty_items[k]),1,2)		--  >>UNWRAPPED<<
				-- if first_signature ~= "[[" then
					-- first_signature = ""
				-- end
			else
				local signature = reaper.GetMediaItemInfo_Value(empty_items[k],"I_GROUPID")
				if signature ~= 0 then signature = 1 end
				-- Msg("Signature:"..signature)
				-- local signature = string.sub(reaper.ULT_GetMediaItemNote( empty_items[k]),1,2)		--  >>UNWRAPPED<<
				-- if signature ~= "[[" then
					-- signature = ""
				-- end
				if signature ~= first_signature then
					Error = true
					break
				end
			end
		end
		
		if Error then
			Msg("ERROR: You must select just wrapped or just unwrrapped items!")
		else
			-- Msg("First signature:"..first_signature)
			if first_signature ~= 0.0 then
				Unwrap()
			else
				if empty_index == 1 then
					Wrap()
				else
					Msg("ERROR: Wrapping multiple wGroups at the same time is not currently supported!")
				end
			end
		end
	else
		Wrap()
	end
	
	reaper.Main_OnCommand(40020,0) --Time selection: Remove time selection and loop points
	

end


function Wrap()
	--run thru all selected items
	for k in pairs(empty_items) do
		local label_start =  reaper.GetMediaItemInfo_Value( empty_items[k], "D_POSITION")
		local label_length = reaper.GetMediaItemInfo_Value( empty_items[k], "D_LENGTH")
		local label_end = label_start + label_length
		
		if label_start ~= selectionStart or label_end ~= selectionEnd then
			 reaper.SetMediaItemInfo_Value( empty_items[k], "D_POSITION", selectionStart)
			 reaper.SetMediaItemInfo_Value( empty_items[k], "D_LENGTH", selectionLength)
		end
	end
	
	for i = 0, selected_count - 1 do

		--get the values
		item[i] = reaper.GetSelectedMediaItem(0,i)
		take[i] = reaper.GetMediaItemTake(item[i], 0)
		if take[i] ~= nil then
			name[i] =  reaper.GetTakeName(take[i])
		else
			there_is_empty_item = true
		end
		start_pos[i] = reaper.GetMediaItemInfo_Value( item[i], "D_POSITION")
		length[i] = reaper.GetMediaItemInfo_Value( item[i], "D_LENGTH")
		end_pos[i] = start_pos[i] + length[i]
		item_track[i] = reaper.GetMediaItem_Track(item[i])


		--Msg(name[i])
		--Msg(item_track[i])
		--Msg()
		--Msg(start_pos[i])
		--Msg(end_pos[i])
		--Msg("===")

		--calculate first and last track
		item_track[i] = reaper.GetMediaItem_Track(item[i])
		track_number = reaper.GetMediaTrackInfo_Value(item_track[i], "IP_TRACKNUMBER" )
		--Msg(track_number)
		if first_selected_track == nil then
			first_selected_track = track_number
			last_selected_track = track_number
		elseif track_number < first_selected_track then
			first_selected_track = track_number
		elseif  last_selected_track < track_number then
			last_selected_track = track_number
		end




		--fill the gaps
		if i > 0 then
			if item_track[i] == item_track[i-1] then
				empty_midi = reaper.CreateNewMIDIItemInProj(item_track[i], end_pos[i-1], start_pos[i], qnInOptional ) --between items of same track
				midi_items[midi_idx] = empty_midi
				--name
				local mid_take = reaper.GetMediaItemTake(empty_midi, 0)
				reaper.GetSetMediaItemTakeInfo_String(mid_take, "P_NAME", "((empty))", true)
				
				midi_idx = midi_idx + 1
			else
				a = reaper.CreateNewMIDIItemInProj(item_track[i-1], end_pos[i-1], selectionEnd,qnInOptional) -- at the end of inner tracks
				--name
				local mid_take = reaper.GetMediaItemTake(a, 0)
				reaper.GetSetMediaItemTakeInfo_String(mid_take, "P_NAME", "((empty))", true)
				
				midi_items[midi_idx] = a
				midi_idx = midi_idx + 1

				b = reaper.CreateNewMIDIItemInProj(item_track[i], selectionStart, start_pos[i],qnInOptional) --at the start of inner tracks
				--name
				local mid_take = reaper.GetMediaItemTake(b, 0)
				reaper.GetSetMediaItemTakeInfo_String(mid_take, "P_NAME", "((empty))", true)
				
				midi_items[midi_idx] = b
				midi_idx = midi_idx + 1

				--fill completely empty tracks
				track_a_idx =  reaper.GetMediaTrackInfo_Value( item_track[i-1], "IP_TRACKNUMBER" )
				track_b_idx =  reaper.GetMediaTrackInfo_Value( item_track[i], "IP_TRACKNUMBER" )


				if track_b_idx - track_a_idx > 1 then
					for k = track_a_idx+1, track_b_idx-1 do
						trackk = reaper.GetTrack(0,k-1)
						mid = reaper.CreateNewMIDIItemInProj(trackk, selectionStart,selectionEnd,qnInOptional)
						local mid_take = reaper.GetMediaItemTake(mid, 0)
						reaper.GetSetMediaItemTakeInfo_String(mid_take, "P_NAME", "((empty))", true)
						midi_items[midi_idx] = mid
						midi_idx = midi_idx + 1
					end
				end

			end
		else
			if selectionStart ~= start_pos[i] then
				c = reaper.CreateNewMIDIItemInProj(item_track[i], selectionStart, start_pos[i], qnInOptional) --for start of first track
				--name
				local mid_take = reaper.GetMediaItemTake(c, 0)
				reaper.GetSetMediaItemTakeInfo_String(mid_take, "P_NAME", "((empty))", true)
				
				midi_items[midi_idx] = c
				midi_idx = midi_idx + 1
			end
		end

		if i == selected_count - 1 then
			if end_pos[i] ~= selectionEnd then
				d = reaper.CreateNewMIDIItemInProj(item_track[i], end_pos[i], selectionEnd, qnInOptional) -- for end of last track
				--name
				local mid_take = reaper.GetMediaItemTake(d, 0)
				reaper.GetSetMediaItemTakeInfo_String(mid_take, "P_NAME", "((empty))", true)
				
				midi_items[midi_idx] = d
				midi_idx = midi_idx + 1
			end
		end


	end




	--create empty on  first-1 track
	if empty_index == 0 then
		title_track = reaper.GetTrack(0,first_selected_track-2)
		if title_track ~= nil then
			--empty item
			reaper.Main_OnCommand(40290,0) --set time selection on group
			reaper.Main_OnCommand(40142,0) --insert empty item
			empty = reaper.GetSelectedMediaItem(0,0)
			reaper.MoveMediaItemToTrack(empty, title_track)

			--empty midi items
			--midi = reaper.CreateNewMIDIItemInProj(title_track,selectionStart,selectionEnd,qnInOptional)
			--reaper.SetMediaItemSelected(midi,1)
		end
	else
		-- for k in pairs(empty_items) do
			-- local label = reaper.ULT_GetMediaItemNote( empty_items[k])
			-- label = string.sub(label,3,-3) --remove >>UNWRAPPED<< prefix
			-- reaper.ULT_SetMediaItemNote( empty_items[k],label)
		-- end
	end


	for i = 0, midi_idx-1 do
		reaper.SetMediaItemSelected( midi_items[i], 1)
	end

	for i = 0, selected_count-1 do
		reaper.SetMediaItemSelected(item[i],1)
	end

	reaper.Main_OnCommand(40032,0) --Item grouping: Group items
	reaper.Main_OnCommand(40290,0) --set time selection on group

	--oboj
	--reaper.Main_OnCommand(40706,0) --Item: Set to one random color
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_ITEMRANDCOL"),0) --SWS: Set selected item(s) to one random custom color

	--Msg(first_selected_track)
	--Msg(last_selected_track)
end

array_of_items_to_unselect = {}
array_index = 0
function Unwrap()
	reaper.Main_OnCommand( 40033, 0 ) --Ungroup
	if	selected_count > 0  then
		for i = 0, selected_count - 1 do
			--Msg("I:"..i)
			--assign values
			item = reaper.GetSelectedMediaItem(0,i)
			-- Msg(item)
			take = reaper.GetMediaItemTake(item, 0)
			local source_type = nil
			if take ~= nil then
				name =  reaper.GetTakeName(take)
				-- Msg("Name:"..name)
				source =  reaper.GetMediaItemTake_Source(take)
				source_type = reaper.GetMediaSourceType(source,"")
			else
				-- Msg(item) --print empty item id
			end
			-- Msg("")
			-- Msg("Item:")
			-- Msg(item)
			--Msg("Take:")
			--Msg(take)

			--Msg("SourceType:")
			--Msg(source_type)
			--Msg("===")

			if item ~= nil then
				if source_type == "MIDI"  then
					--name
					local mid_take = reaper.GetMediaItemTake(item, 0)
					local retval, name = reaper.GetSetMediaItemTakeInfo_String(mid_take, "P_NAME", "", false)
					-- Msg(name)
					if name ~= "((empty))" then
						array_of_items_to_unselect[array_index] = item
						array_index = array_index + 1
					end
					--delete later
				else
					-- if source_type == nil then --empty item
						-- local label = reaper.ULT_GetMediaItemNote( item)
						-- label = "[["..label.."]]" -- add UNWRAPPED prefix
						-- reaper.ULT_SetMediaItemNote( item,label)
					-- end
					--do nothing - unselect
					array_of_items_to_unselect[array_index] = item
					array_index = array_index + 1
				end
			else
				-- Msg("MISS")
			end

		end

		--unselect
		for i=0, array_index -1 do
			reaper.SetMediaItemSelected( array_of_items_to_unselect[i], 0 )
		end


		reaper.Main_OnCommand( 40697, 0 ) --delete
	end
end


--EXECUTION======================================
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh( 1 )
Main() -- run script
reaper.PreventUIRefresh( -1 )
reaper.Undo_EndBlock("nikolakc_wGroup - Wrap or Unwrap Sel. Items", -1)
reaper.UpdateArrange()
