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
	--Msg(hopa_name_path)
	

	--PROCITAJ FAJL U KOM JE SACUVANO IME PRETHODNOG IMENOVANJA +++++++++++++++++++++++++
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
				--ovaj je prazan, dodaj ga u niz praznih
				empty_items[idx] = cur_item
				idx = idx + 1
			else
				--nije prazan, preskoči
			end
		
		end
		
		--SETUJ DA TREBA NIZ DA SE IMENUJE
		if idx > 1 then 
			--NIZ U KOME IMA VIŠE EMPTY ITEMA
			array_naming = true
			item_is_empty = true
		else 
			--NIZ U KOJEM IMA SAMO JEDAN ili NULA EMPTY ITEMa
			--Msg("šta se dešava ako selektujemo više, a ima samo jedan empty item??*????")
			if idx == 1 then
				cur_item = empty_items[0]   -- kad ima jedan empty item
			else 
				cur_item = reaper.GetSelectedMediaItem(0,0) -- samo prvi, ili sve ????
			end
		end
	
	else
		--TREBA SAMO SELEKTOVANI ITEM DA SE IMENUJE, BIO ON TAKE ILI EMPTY ITEM, KASNIJE SE BIRA KOJI
		empty_items[0] = reaper.GetSelectedMediaItem(0,0)
		cur_item = empty_items[0]
	end
	--================================================================================================
	
	--IMENOVANJE NIZA SELEKTOVANIH ITEMA
	if array_naming == true then 
		first_item = empty_items[0]
		input_name = reaper.ULT_GetMediaItemNote( first_item )
		user_input,final_name = ShowDialogForNaming(input_name)
		for i = 0, idx -1 do 
			SetNameForItem(empty_items[i], user_input, final_name, true,i)
		end
	else
		--IMENOVANJE SAMO JEDNOG SELEKTOVANOG ITEMa
	
		cur_take = reaper.GetMediaItemTake(cur_item, 0)
		
		item_is_empty = false
		if cur_take == nil then
			--setuj da treba empty item da se imenuje
			item_is_empty = true
			cur_name =  reaper.ULT_GetMediaItemNote( cur_item )
		else
			--setuj da treba običan tejk da imenuje
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
	
	return retval,final_name
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
				final_name = final_name.."_"..zero..index_to_add
			end
			reaper.ULT_SetMediaItemNote( cur_item, final_name)
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_RSb428746958e98560bf16fdec0d9022a5b13465c0"),0) -- fit notes stretch (ovo radi  na sve selektovane iteme)
		end
		
		--Msg(file_path)
		local file = io.open(file_path, "w")
		file:write(answer_to_save)
		file:close()
	end

end

--RUN
Main()
reaper.UpdateArrange()
