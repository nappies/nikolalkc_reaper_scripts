--SNF - Move Rendered Sounds to HOPA project

--ChangeLog
--v.02 (2017-08-17)
	--boje se posvetle kad se eksportuju itemi, ne ode u belo
--v.01 (nekad)



--utility===================================================================================================================================================================
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

bounced_sounds_folder = "D:\\BouncedSounds\\"
current_export_folder = ""
previous_export_path = ""
first_field = ""
second_field = ""
sound_file_name = ""


function ScanSoundsToMove()
	--scan all files in D:\bounced sounds
	--create array
end

function ScanFoldersInGameProjectFolder()
	--scan and create array
end


function SeparateFolderAndFileName (name)
	local folder_name, file_name = name:match("([^,]+)-([^,]+)")
	return folder_name, file_name
end


function MoveSoundToGameProject(name)
	folder_name,file_name = SeparateFolderAndFileName(name)
	if folder_name == "game" then
		--move it to interface folder
	else
		if current_export_folder == folder_name then --ako je isti folder kao prethodni
			--prebaci u isti folder kao prethodni
		else										 --ako treba da traži folder
			--nadji folder
				--provera dal je ho folder
					--provera dal je ho_second ili tako nesto
				
				--moveit u ho folder i stavi taj folder kao poslednji u koji je eksportovano
				
				--moveit normalno i stavi taj folder kao poslednji...
			
			--exception kad ne nadje folder
				--proveri da li samo ne postoji _sounds folder i napravi ga ako je to slucaj
				--izbaci gresku ako uopste ne postoji folder
				
		end
	end
	
end


--upotreba
a,b = SeparateFolderAndFileName("ime-scena")
Msg(a)
Msg(b)