--[[
	ReaScript Name:wGroup - Create Wrap Group From Selected Items
	Description: Creates special kind of group from selected items, filled with empty midi items and one empty item which can be used for naming
	Instructions: Create item selection and run the script
	Author: nikolalkc
	Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
	REAPER: 5+
	Extensions: SWS
	Version: 1.0
]]


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
function Main()
	reaper.ShowConsoleMsg("") --Clear Screen

	reaper.Main_OnCommand(40290,0) --Time selection: Set time selection to items
	track = reaper.GetTrack(0,1)
	starttime = 1
	endtime = 2
	qnInOptional = 0

	selected_count = reaper.CountSelectedMediaItems(0)
	--Msg(selected_count)

	--Find selection start and end
	selectionStart, selectionEnd =  reaper.GetSet_LoopTimeRange(0,0,0,0,0)
	 --Msg("SelectionStart:")
	 --Msg(selectionStart)
	 --Msg("SelectionEnd:")
	 --Msg(selectionEnd)

	--run thru all selected items
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
				midi_idx = midi_idx + 1
			else
				a = reaper.CreateNewMIDIItemInProj(item_track[i-1], end_pos[i-1], selectionEnd,qnInOptional) -- at the end of inner tracks
				midi_items[midi_idx] = a
				midi_idx = midi_idx + 1

				b = reaper.CreateNewMIDIItemInProj(item_track[i], selectionStart, start_pos[i],qnInOptional) --at the start of inner tracks
				midi_items[midi_idx] = b
				midi_idx = midi_idx + 1

				--fill completely empty tracks
				track_a_idx =  reaper.GetMediaTrackInfo_Value( item_track[i-1], "IP_TRACKNUMBER" )
				track_b_idx =  reaper.GetMediaTrackInfo_Value( item_track[i], "IP_TRACKNUMBER" )


				if track_b_idx - track_a_idx > 1 then
					for k = track_a_idx+1, track_b_idx-1 do
						trackk = reaper.GetTrack(0,k-1)
						mid = reaper.CreateNewMIDIItemInProj(trackk, selectionStart,selectionEnd,qnInOptional)
						midi_items[midi_idx] = mid
						midi_idx = midi_idx + 1
					end
				end

			end
		else
			if selectionStart ~= start_pos[i] then
				c = reaper.CreateNewMIDIItemInProj(item_track[i], selectionStart, start_pos[i], qnInOptional) --for start of first track
				midi_items[midi_idx] = c
				midi_idx = midi_idx + 1
			end
		end

		if i == selected_count - 1 then
			if end_pos[i] ~= selectionEnd then
				d = reaper.CreateNewMIDIItemInProj(item_track[i], end_pos[i], selectionEnd, qnInOptional) -- for end of last track
				midi_items[midi_idx] = d
				midi_idx = midi_idx + 1
			end
		end


	end




	--create empty on  first-1 track
	if there_is_empty_item ~= true then
		title_track = reaper.GetTrack(0,first_selected_track-2)
		if title_track ~= nil then
			--empty item
			reaper.Main_OnCommand(40290,0) --set time selection on group
			reaper.Main_OnCommand(40142,0) --insert empty item
			empty = reaper.GetSelectedMediaItem(0,0)
			reaper.ULT_SetMediaItemNote( empty, "temp")
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_RSb428746958e98560bf16fdec0d9022a5b13465c0"),0) --toggle notes stretch to fit
			reaper.ULT_SetMediaItemNote( empty, "")
			reaper.MoveMediaItemToTrack(empty, title_track)

			--empty midi items
			--midi = reaper.CreateNewMIDIItemInProj(title_track,selectionStart,selectionEnd,qnInOptional)
			--reaper.SetMediaItemSelected(midi,1)
		end
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

	reaper.Main_OnCommand(40020,0) --Time selection: Remove time selection and loop points

	--Msg(first_selected_track)
	--Msg(last_selected_track)

end




--EXECUTION======================================
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh( 1 )
Main() -- run script
reaper.PreventUIRefresh( -1 )
reaper.Undo_EndBlock("Make Clip Group From Selection (With Emtpy Midi Items)", -1)
reaper.UpdateArrange()
