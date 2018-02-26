--[[
 ReaScript Name: Toggle Freeze And Unfreeze Selected Items
 Author: nikolalkc
 Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 REAPER: 5+
 Version: 1.0
 About:
	This script renders selected items to new takes and puts all item fx offline. If that operation has already
	been done then it restores original items length and fades, deletes rendered take from project and put all items fx
	back online. NOTE: Remember to occasionaly do project clean up because this script does not delete files when it deletes takes.
	Also it works only with items that have one or two takes. 
]]

--[[
 * Changelog:
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



function RenderItemsAndSetFXOffline()
	for i = 0, selected_count - 1 do
		local item = reaper.GetSelectedMediaItem(0,i)
		local length = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
		local fadein = reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN" )
		local fadeout = reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN" )
		
		local note = length..[[-]]..fadein..[[-]]..fadeout
		reaper.ULT_SetMediaItemNote( item, note)
		--retval, offsOut, lenOut, revOut reaper.PCM_Source_GetSectionInfo( src )
	end

	reaper.Main_OnCommand(41999,0) --Item: Render items to new take
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELECTFIRSTTAKEOFITEMS"),0) --Xenakios/SWS: Select first take in selected items
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_OFFLINE"),0) --SWS/S&M: Set all take FX offline for selected items
	reaper.Main_OnCommand(40125,0) --Take: Switch items to next take
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_TAKESRANDCOLS"),0) --one random custom take color
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_RESETITEMLENMEDOFFS"),0) --Xenakios/SWS: Reset item length and media offset
end

function RestoreItemsAndSetFXOnline()
	for i = 0, selected_count - 1 do
		local item = reaper.GetSelectedMediaItem(0,i)
		note =  reaper.ULT_GetMediaItemNote( item )
		reaper.ULT_SetMediaItemNote( item, note)
		--retval, offsOut, lenOut, revOut reaper.PCM_Source_GetSectionInfo( src )
		
		length, fadein, fadeout = note:match("([^,]+)-([^,]+)-([^,]+)")
		-- Msg(length)
		-- Msg(fadein)
		-- Msg(fadeout)
		
		reaper.SetMediaItemInfo_Value( item, "D_LENGTH", length)
		reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", fadein)
		reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", fadeout)
		reaper.ULT_SetMediaItemNote( item, "")
	end
	reaper.Main_OnCommand(40129,0) --Take: Delete active take from items
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_ONLINE"),0) --all take fx online
	reaper.Main_OnCommand(40638,0) --show item fx
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





