--[[
 ReaScript Name:wGroup - Unwrap Selected Wrap Group(s)
 Description: Deletes empty midi items for selected Wrap Groups and ungroups items so they can be independently edited.
 Instructions: Select your wGroup and run the script.
 Author: nikolalkc
 Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 REAPER: 5+
 Extensions: SWS
 Version: 1.0
]]

--[[
 * Changelog:
 * v1.0 (2017-12-28)
	+ Initial Release
--]]

function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

array_index = 0
array_of_items_to_unselect = {}

reaper.Undo_BeginBlock()

reaper.Main_OnCommand( 40034, 0 ) --Item grouping: Select all items in groups
reaper.Main_OnCommand( 40033, 0 ) --Ungroup

selected_count = reaper.CountSelectedMediaItems(0)
--Msg("COUNT:"..selected_count)
if	selected_count > 0  then
	for i = 0, selected_count - 1 do
		--Msg("I:"..i)
		--assign values
		item = reaper.GetSelectedMediaItem(0,i)
		take = reaper.GetMediaItemTake(item, 0)
		if take ~= nil then
			name =  reaper.GetTakeName(take)
			--Msg("Name:"..name)
			source =  reaper.GetMediaItemTake_Source(take)
			source_type = reaper.GetMediaSourceType(source,"")
		end

		-- Msg("Item:")
		-- Msg(item)
		--Msg("Take:")
		--Msg(take)

		--Msg("SourceType:")
		--Msg(source_type)
		--Msg("===")

		if item ~= nil then
			if source_type == "MIDI" then
				--delete later
			else
				--do nothing
				array_of_items_to_unselect[array_index] = item
				array_index = array_index +1
			end
		end

	end

	--unselect
	for i=0, array_index -1 do
		reaper.SetMediaItemSelected( array_of_items_to_unselect[i], 0 )
	end


	reaper.Main_OnCommand( 40697, 0 ) --delete
	reaper.UpdateArrange()
	reaper.Undo_EndBlock("nikolalkc: Unwrap selected wGroup(s).", -1)
end
