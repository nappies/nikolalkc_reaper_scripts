--[[
 ReaScript Name:MHG - Type In Name
 Author: nikolalkc
 Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 REAPER: 5+
 Version: 2.0
 About:
  Renames take name in format @input1:input2 based on input strings from user (replaces spaces with underscore)
]]

--[[
 * Changelog:
 * v2.0	(2018-03-09)
	+ Proper case with uppercase two-letter prefix and no underscores naming convention for WWISE projects
 * v1.9 (2017-12-04)
	+ Added support for ce chapter prefix naming -iic or -uuc
 * v1.8 (2017-12-04)
	+ Added -uu and -ii prefixes for faster typing
 * v1.7 (2017-09-28)
	+ Added extra width to input window
 * v1.6 (2017-09-11)
	+ Added support for naming multiple selected empty items with indexes
 * v1.5 (2017-09-05)
	+ last_scene.dat is loaded and saved to environmental variable path %HOPA_NAME% which is set from audio manager
 * v1.4 (2017-06-02)
	+ Stretch empty item note to fit on write
 * v1.3 (2017-06-01)
	+ Support for saving last scene name
 * v1.3 (2017-05-30)
	+ Support for empty items
 * v1.2 (2017-05-17)
	+ Support for only one answer, and no answers
 * v1.1 (2017-05-17)
	+ Reads Current Take Name
 * v1.0 (2017-05-16)
	+ Initial Release
]]

--[[ ----- DEBUGGING ===>

]]-- <=== DEBUGGING -----

--UTILITIES
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

--MEAT
scene_name = ""
file_name = ""
cur_name = nil
answer_to_save = ""
last_scene = ""
empty_items = {}
array_naming = false

--MAIN FUNCTION
function Main()
	--read environmental variable
	hopa_name_path = os.getenv("HOPA_NAME")
	active_project_type = os.getenv("ACTIVE_AUDIO_PROJECT")
	--Msg(hopa_name_path)


	--Read data config file in which the last name is saved+++++++++++++++++++++++++
	file_path = [[]]..hopa_name_path..[[\last_scene.dat]]
	file = io.open(file_path, "r")
	if file ~= nil then
		-- Msg(file:read())
		last_scene = file:read()

		if last_scene == nil then
			last_scene = ""
		end
		file:close()
	end


	cur_name = ""

	--MANAGE NAMING, SINGLE OR ARRAY==========================================================================
	--count selected items
	reaper.Main_OnCommand(40296,0) --select all tracks
	selected_count = reaper.CountSelectedMediaItems(0)

	idx = 0
	if selected_count > 1 then
		--nadji sve empty iteme
		for i = 0, selected_count - 1 do
			--get info
			cur_item = reaper.GetSelectedMediaItem(0,i)
			cur_take = reaper.GetMediaItemTake(cur_item, 0)
			if cur_take == nil then
				--this one is empty, add it to array of empty items
				empty_items[idx] = cur_item
				idx = idx + 1
			else
				--not empty, skip
			end

		end

		--SET ARRAY FOR NAMING
		if idx > 1 then
			--ARRAY WITH EMPTY MORE EMPTY ITEMS
			array_naming = true
			item_is_empty = true
		else
			--ARRAY WITH ONE OR ZERO EMTPY ITEMS
			--Msg("What happens if we select more, but there is just one empy item??*????")
			if idx == 1 then
				cur_item = empty_items[0]   --when there is only one empty item
			else
				cur_item = reaper.GetSelectedMediaItem(0,0) -- just first, or all?
			end
		end

	else
		--SELECTED ITEM SHOULD BE NAMED, WHETER IT'S EMPTY MIDI OR EMPTY ITEM, LATER DECIDEDs
		empty_items[0] = reaper.GetSelectedMediaItem(0,0)
		cur_item = empty_items[0]
	end
	--================================================================================================

	--NAMING OF ARRAY OF SELECTED ITEMS
	if array_naming == true then
		first_item = empty_items[0]
		input_name = reaper.ULT_GetMediaItemNote( first_item )
		user_input,final_name = ShowDialogForNaming(input_name)
		for i = 0, idx -1 do
			SetNameForItem(empty_items[i], user_input, final_name, true,i)
		end
	else
		--NAMING JUST ONE SELECTED ITEM

		cur_take = reaper.GetMediaItemTake(cur_item, 0)

		item_is_empty = false
		if cur_take == nil then
			--set emtpy item for naming
			item_is_empty = true
			cur_name =  reaper.ULT_GetMediaItemNote( cur_item )
		else
			--set regular take to be named (audio or midi)
			cur_name = reaper.GetTakeName(cur_take)
		end

		user_input,final_name = ShowDialogForNaming(cur_name)
		SetNameForItem(cur_item, user_input, final_name, item_is_empty)
	end

end

function ShowDialogForNaming(cur_name)
--split current name
	if cur_name ~= nil then
		if cur_name ~= "" then
			scene_name, file_name = cur_name:match("([^,]+):([^,]+)")

			if scene_name ~= nil then
				--it's fine
			else
				scene_name = cur_name
				file_name = ""
			end


			--if there is @ prefix
			first_char = string.sub(scene_name, 0, 1)
			if first_char == "@" then
				scene_name = string.gsub(scene_name, "%@", "")
			end
		else
			scene_name = last_scene
		end
	end


	--USER INPUT
	retval, result = reaper.GetUserInputs("NAME THE FILE:", 2, "Scene:,File:,extrawidth=300", scene_name..","..file_name)
	answer1, answer2 = result:match("([^,]+),([^,]+)")
	--prefix is upper case
	
	--Msg("Answer1:"..answer1)
	--Msg("Answer2:"..answer2)
	--check if both fields are filled
	if answer1 ~= nil and answer2 ~= nil then                --ako jesu onda iseckaj i sastavi
		--Msg("Both fields are filled")
		if active_project_type ~= "WWISE" then
			answer1 = string.gsub(answer1, "% ", "_")
			answer2 = string.gsub(answer2, "% ", "_")
		else
			--make prefix uppercase
			answer1= MakeStringPrefixUppercase(answer1)
			--velika prva slova
			answer1 = string.gsub(" "..answer1, "%W%l", string.upper):sub(2)
			answer2 = string.gsub(" "..answer2, "%W%l", string.upper):sub(2)
		end

		answer1 =string.gsub(answer1, "\n", "")
		answer1 =string.gsub(answer1, "\r", "")

		answer2 =string.gsub(answer2, "\n", "")
		answer2 =string.gsub(answer2, "\r", "")


		--snippet logic for inventory plus item  (ii2)
		prefix  = string.sub(answer1,0,2)
		if prefix == "ii" then
			chapter = string.sub(answer1,3,3)
			answer1 = string.sub (answer1, 5,-1)

			if chapter == "c" then
				chapter = "ce"
			else
				chapter = [[ch]]..chapter
			end

			answer1 = [[item_]]..chapter..[[_]]..answer1..[[_plus]]
		end


		--snippet logic for use item (uu2)
		prefix = string.sub(answer2, 0,2)
		if prefix == "uu" then
			chapter = string.sub(answer2,3,3)
			answer2 = string.sub (answer2, 5,-1)

			if chapter == "c" then
				chapter = "ce"
			else
				chapter = [[ch]]..chapter
			end
			answer2 = [[use_item_]]..chapter..[[_]]..answer2
		end

		if active_project_type == "WWISE" then
			final_name = "@"..answer1..[[ 
]]..answer2
		else
			final_name = "@"..answer1..[[:
]]..answer2
		end
		answer_to_save = answer1
	else
		--Msg("both fields are NOT filled!")
		--Msg(result)
		if result == "," then                                      --if nothing typed, leave it emtpy
			--Msg("both fields are empty")
			final_name = ""
		else                                                       --if one field is filled, put @ prefix
			--Msg("at least one field is not empty")
			cut_result = string.gsub(result, "%,", "")  --remove comma (,) character
			if active_project_type ~= "WWISE" then
				cut_result = string.gsub(cut_result, "% ", "_")
			else
				--make prefix uppercase
				cut_result= MakeStringPrefixUppercase(cut_result)
				--velika prva slova
				cut_result= string.gsub(" "..cut_result, "%W%l", string.upper):sub(2)
			end
			answer_to_save = cut_result
			final_name = "@"..cut_result
		end
	end

	return retval,final_name
end


function MakeStringPrefixUppercase(some_string)
	local prefix = string.find(some_string,"%a%a%s")
	if prefix == 1 then
		local pre = string.upper(string.sub(some_string,1,3))
		local post = string.sub(some_string,4,-1)
		some_string = pre..post
	end
	return some_string
end


-- SETNAMES
function SetNameForItem(cur_item,retval,final_name,item_is_empty,index_to_add)
	reaper.Main_OnCommand(40289,0)--unselect all items
	if retval == true then
		if item_is_empty ~= true then
			reaper.GetSetMediaItemTakeInfo_String(cur_take, "P_NAME", final_name, true)
		else
			if index_to_add ~= nil and final_name ~= nil then
				index_to_add = index_to_add + 1
				zero = ""
				if index_to_add <= 9 then
					zero = "0"
				end
				if active_project_type == "WWISE" then
					final_name = final_name.." "..zero..index_to_add
				else
					final_name = final_name.."_"..zero..index_to_add
				end
			end
			
			reaper.ULT_SetMediaItemNote( cur_item, final_name)
			ToggleNoteStretchToFit(cur_item)
		end

		--Msg(file_path)
		local file = io.open(file_path, "w")
		file:write(answer_to_save)
		file:close()
	end

end

  --TOGGLE NOTE STRETCH TO FIT WITH LUA
function ToggleNoteStretchToFit(item)
  local strNeedBig = ""
  retval, strNeedBig = reaper.GetItemStateChunk( item, strNeedBig, false )
  -- Msg(strNeedBig)
  -- Msg("=====================================================")
  NoteStretchState = string.match(strNeedBig, "IMGRESOURCEFLAGS %d")
  
  -- TURN ON
  new_state = string.gsub(strNeedBig, "IMGRESOURCEFLAGS %d", "IMGRESOURCEFLAGS 2") --turn on stretch
  
  --TOGGLE
  -- if NoteStretchState == "IMGRESOURCEFLAGS 0" then
    -- new_state = string.gsub(strNeedBig, "IMGRESOURCEFLAGS %d", "IMGRESOURCEFLAGS 2") --turn on stretch
  -- else
    -- new_state = string.gsub(strNeedBig, "IMGRESOURCEFLAGS %d", "IMGRESOURCEFLAGS 0") --turn off stretch
  -- end

  reaper.SetItemStateChunk( item, new_state, true )
end

--RUN
Main()
reaper.UpdateArrange()
