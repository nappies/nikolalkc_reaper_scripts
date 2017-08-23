--[[
 * ReaScript Name: Type In Hopa Name
 * Description: Renames take name in format @input1:input2 based on input strings from user (replaces spaces with underscore)
 * Author: nikolalkc
 * Repository URL: https://github.com/nikolalkc/AutoHotKey_Macros/tree/master/Reaper%20Scripts
 * REAPER: 5.0 pre 40
 * Version: 1.4
]]
 
--[[
 * Changelog:
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

--MAIN FUNCTION
function Main()
	--get info
	--Msg("-------------")
	
	
	

	--procitaj fajl ako ga ima
	file = io.open("last_scene.dat", "r")
	if file ~= nil then
		-- Msg(file:read())
		last_scene = file:read()
		
		if last_scene == nil then
			last_scene = ""
		end
		file:close()
	end
	
	
	cur_item = reaper.GetSelectedMediaItem(0,0)
	cur_take = reaper.GetMediaItemTake(cur_item, 0)
	if cur_take ~= nil then
		cur_name = reaper.GetTakeName(cur_take)
	else
		item_is_empty = true
		cur_name =  reaper.ULT_GetMediaItemNote( cur_item )
	end
	
	--split current name
	if cur_name ~= nil then
		if cur_name ~= "" then
			scene_name, file_name = cur_name:match("([^,]+):([^,]+)")
			
			if scene_name ~= nil then
				--kul tebra
			else 
				scene_name = cur_name
				file_name = ""
			end
			
			
			--ako je @ na pocetku skini
			first_char = string.sub(scene_name, 0, 1)
			if first_char == "@" then
				scene_name = string.gsub(scene_name, "%@", "")
			end
		else
			scene_name = last_scene
		end
	end

	
	--USER INPUT
	retval, result = reaper.GetUserInputs("NAME THE FILE:", 2, "Scene:,File:", scene_name..","..file_name)
	answer1, answer2 = result:match("([^,]+),([^,]+)")
	--Msg("Answer1:"..answer1)
	--Msg("Answer2:"..answer2)
	--proveri da li su oba polja upisana
	if answer1 ~= nil and answer2 ~= nil then                --ako jesu onda iseckaj i sastavi
		--Msg("Oba polja su popunjena!")
		answer1 = string.gsub(answer1, "% ", "_")
		answer2 = string.gsub(answer2, "% ", "_")
		
		answer1 =string.gsub(answer1, "\n", "")
		answer1 =string.gsub(answer1, "\r", "")
		
		answer2 =string.gsub(answer2, "\n", "")
		answer2 =string.gsub(answer2, "\r", "")
		final_name = "@"..answer1..[[:
]]..answer2

		answer_to_save = answer1
	else
		--Msg("Nisu oba polja popunjena!")
		--Msg(result)
		if result == "," then          --ako nisu uopste popunjena onda nek bude prazno
			--Msg("Oba polja su prazna")
			final_name = ""
		else                                                       --ako je jedno polje popunjeno stavi @
			--Msg("Nisu Oba polja prazna")
			cut_result = string.gsub(result, "%,", "")  --izvadi zarez 
			cut_result = string.gsub(cut_result, "% ", "_")               
			answer_to_save = cut_result
			final_name = "@"..cut_result
		end
	end
	
	
	-- SETNAMES
	if retval == true then
		if item_is_empty ~= true then
			reaper.GetSetMediaItemTakeInfo_String(cur_take, "P_NAME", final_name, true)
		else
			reaper.ULT_SetMediaItemNote( cur_item, final_name)
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_RSb428746958e98560bf16fdec0d9022a5b13465c0"),0) -- fit notes stretch
		end
		
		local file = io.open("last_scene.dat", "w")
		file:write(answer_to_save)
		file:close()
	end
	
end

--RUN
Main()
reaper.UpdateArrange()
