--[[
 ReaScript Name:wGroup - Destroy Selected Wrap Group(s)
 Author: nikolalkc
 Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 REAPER: 5+
 Extensions: SWS
 Version: 1.3
 About:
  Deletes empty midi items for selected Wrap Groups and ungroups items so they can be independently edited.
  Instructions: Select your wGroup and run the script.
]]

--[[
 * Changelog:
 * v1.3 (2018-03-19)
	+ Fix error with local variables, now all empty items are deleted always
 * v1.2 (2018-03-19)
	+ Support for deleting all midi items
 * v1.1 (2018-03-19)
	+ Action now deletes empty items
 * v1.0 (2017-12-28)
	+ Initial Release
--]]

--USER SETTINGS
DELETE_ALL_MIDI_ITEMS = true -- change to false if you want to delete just automatically created empty midi items

function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

reaper.Undo_BeginBlock()

array_index = 0
array_of_items_to_unselect = {}


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
		local source = nil
		local source_type = nil
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
			if source_type == "MIDI" or source_type == nil then
				--name
				if DELETE_ALL_MIDI_ITEMS ~= true then
					if source_type ~= nil then
						local item_take = reaper.GetMediaItemTake(item, 0)
						local retval, name = reaper.GetSetMediaItemTakeInfo_String(item_take, "P_NAME", "", false)
						-- Msg(name)
						if name ~= "((empty))" then
								array_of_items_to_unselect[array_index] = item
								array_index = array_index + 1
						end
					end
				end
				--delete later all other items
			else
				--do nothing
				array_of_items_to_unselect[array_index] = item
				array_index = array_index + 1
			end
		end

	end

	--unselect
	for i=0, array_index -1 do
		reaper.SetMediaItemSelected( array_of_items_to_unselect[i], 0 )
	end


	reaper.Main_OnCommand( 40697, 0 ) --delete
	reaper.UpdateArrange()
end

reaper.Undo_EndBlock("nikolalkc: DESTROY SELECTED WGROUP(s).", -1)
