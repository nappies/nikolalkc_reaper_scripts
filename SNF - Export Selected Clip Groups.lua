--ChangeLog
--v.03 (2017-10-23)
	--run lua script after rendering
	--bounced_sounds_folder variable
--v.02 (2017-08-17)
	--boje se posvetle kad se eksportuju itemi, ne ode u belo
--v.01 (nekad)
	--eksportovanje klip grupa
--Export selected Clip_groups to BouncedSounds folder and runs SNF - Move Rendered Sounds To Project.lua
	--Clip group names must begin with '@' character
	--Render settings must be set with dummy render to item-name @region and bounds to time selection

--utility===================================================================================================================================================================
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end


--colors utility---------------------------------------------------------------------------------------------
bounced_sounds_folder = [[D:\BouncedSounds\]]
luminance_change_amount = 0.3
absolute_luminance = false --true ako treba da bude na određenu vrednost, false ako treba da bude dodatak na postojeću vrednost


function MakeItemColorBrighter(item)
	local color = reaper.GetDisplayedMediaItemColor(item)
	local R, G, B = reaper.ColorFromNative(color|0x1000000)
	local new_r, new_g, new_b = Luminance(luminance_change_amount, R, G, B)
	local con_r, con_g, con_b = Convert_RGB(new_r,new_g,new_b)
	local new_color = reaper.ColorToNative(con_r,con_g,con_b)|0x1000000
	ApplyColor_Items(new_color,item)
end

function Convert_RGB(ConvertRed,ConvertGreen,ConvertBlue)
	red = math.floor(ConvertRed*255 ) 
	green = math.floor(ConvertGreen*255 )
	blue =  math.floor(ConvertBlue*255 )
	ConvertedRGB = reaper.ColorToNative (red, green, blue)    
	return red, green, blue
end 
 
function hex2rgb(hex)
	  hex = hex:gsub("#","")
	  hex2rgbR = tonumber("0x"..hex:sub(1,2))
	  hex2rgbG = tonumber("0x"..hex:sub(3,4))
	  hex2rgbB = tonumber("0x"..hex:sub(5,6))
end

function Luminance(change, red, green, blue)
  local hue, sat, lum = rgbToHsl(red/255, green/255, blue/255)
  if absolute_luminance == true then
	lum = change
  else 
    lum = lum + change
  end
  local r, g, b = hslToRgb(hue, sat, lum)
  if r<=0 then r = 0 end ; if g<=0 then g = 0 end ; if b<=0 then b = 0 end
  if r>=1 then r = 1 end ; if g>=1 then g = 1 end ; if b>=1 then b = 1 end
  return r, g, b
end

function rgbToHsl(r, g, b) -- values in-out 0-1
      local max, min = math.max(r, g, b), math.min(r, g, b)
      local h, s, l
      l = (max + min) / 2
      if max == min then
        h, s = 0, 0 -- achromatic
      else
        local d = max - min
        if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
        if max == r then
          h = (g - b) / d
          if g < b then h = h + 6 end
        elseif max == g then h = (b - r) / d + 2
        elseif max == b then h = (r - g) / d + 4
        end
        h = h / 6
      end
      return h, s, l or 1
end
    
function hslToRgb(h, s, l) -- values in-out 0-1
  local r, g, b
  if s == 0 then
	r, g, b = l, l, l -- achromatic
  else
	function hue2rgb(p, q, t)
	  if t < 0   then t = t + 1 end
	  if t > 1   then t = t - 1 end
	  if t < 1/6 then return p + (q - p) * 6 * t end
	  if t < 1/2 then return q end
	  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
	  return p
	end
	local q
	if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
	local p = 2 * l - q
	r = hue2rgb(p, q, h + 1/3)
	g = hue2rgb(p, q, h)
	b = hue2rgb(p, q, h - 1/3)
  end
  return r,g,b
end

function ApplyColor_Items(new_color,item)    
	reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",new_color)
	reaper.UpdateItemInProject(item)
end
--colors utility end---------------------------------------------------------------------------------------------


--array defs================================================================================================================================================================
item = {}
take = {}
name = {}
item_pos = {}
item_len = {}
item_is_empty = {}
clip_group = {}
overlapping_items = {}
overlapping_items_mute_state = {}
ov_index = 0
cg_index = 0
selected_count = nil


--Main FUN==================================================================================================================================================================
function Main()
	reaper.Undo_BeginBlock()     
	--proveri kolika je selekcija vremenska
	start_time, end_time =  reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false)
	delta_time = end_time - start_time

	if delta_time > 0 then     --ako ima vremenske selekcije
		--export
		reaper.Main_OnCommand(40717,0) --Item: Select all items in current time selection
		selected_count = reaper.CountSelectedMediaItems(0)
		render_selected_items()
		post_export_dialog()
		
	else --ako nema vremenske selekcije
		
		--check item selection
		selected_count = reaper.CountSelectedMediaItems(0)
		if selected_count == 0 then --ako ni jedan item nije selektovan               
			--Msg("No items selected. You must select at least one item, or make time selection")          
			post_export_dialog("No Items Selected!")
		else --ako je selektovan bar jedan item
			--export
			render_selected_items()
			post_export_dialog()
		end
	end
	reaper.Undo_EndBlock("SNF: Add selected items to render queue", -1)
	reaper.UpdateArrange()
end


--other fun=================================================================================================================================================================
function render_selected_items()
	for i = 0, selected_count - 1 do

		--get stuff from item
		item[i] = reaper.GetSelectedMediaItem(0,i)
		take[i] = reaper.GetMediaItemTake(item[i], 0)
		if take[i] ~= nil then
			name[i] =  reaper.GetTakeName(take[i])
		else
			item_is_empty[i] = true
			name[i] = reaper.ULT_GetMediaItemNote(item[i])
			name[i] = string.gsub (name[i], "\n", "")
			name[i] = string.gsub (name[i], "\r", "")
		end
		
		
		--make new array with items that begin with '@'
		local first_string = string.sub(name[i], 1, 1)          
		if first_string == "@" then 
			clip_group[cg_index] = item[i]
			cg_index = cg_index + 1
			
			--oboj name item u belo
			-- local white = reaper.ColorToNative(255,255,255)|0x1000000          
			-- reaper.SetMediaItemInfo_Value( item[i], "I_CUSTOMCOLOR", white)
			--Msg(name[i])
		end
	end
	
	
	--Msg("Clip Groups:"..cg_index)
	reaper.Main_OnCommand(40289,0) --Item: Unselect all items
	
	--run through new array and add items to render queue
	for i = 0, cg_index - 1 do 
		reaper.SetMediaItemSelected( clip_group[i], 1 )
		reaper.Main_OnCommand(40290,0) --Time selection: Set time selection to items
		
		
		--get stuff 
		local item_pos = reaper.GetMediaItemInfo_Value(clip_group[i],"D_POSITION")
		local item_len = reaper.GetMediaItemInfo_Value(clip_group[i],"D_LENGTH")
		local group_id = reaper.GetMediaItemInfo_Value(clip_group[i],"I_GROUPID")
		local take = reaper.GetMediaItemTake(clip_group[i], 0)
		local item_end = item_pos + item_len
		local name = ""
		if take ~= nil then
			name =  reaper.GetTakeName(take)
		else
			name = reaper.ULT_GetMediaItemNote( clip_group[i])
			name = string.gsub (name, "\n", "")
			name = string.gsub (name, "\r", "")
		end
		local changed_name = string.sub(name, 2)
		local new_name = string.gsub(changed_name, "%:", "-") --da zameni dve tacke sa crticom
		local red = reaper.ColorToNative(255,0,0)|0x1000000          
		
		
		--create region with same name as clip group
		local marker_index = reaper.AddProjectMarker2( 0, 1, item_pos, item_end, new_name, 0, red )
		
		
		--Sacuvaj mute state i mutiraj sve iteme koji nisu deo klip grupe koja treba da se renderuje
			reaper.Main_OnCommand(40717,0) --Item: Select all items in current time selection
			sel_count = reaper.CountSelectedMediaItems(0)
			
			-- uzmi time selection start i end time
			_start_time, _end_time =  reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false)
			
			--uzmi podatke za sve iteme u trenutnoj vertikalnoj selekciji oko klip grupe clip_group[i]
			local mono_item = true
			for j = 0, sel_count - 1 do 
				
				--get stuff
				local _item = reaper.GetSelectedMediaItem(0,j)
				local _take = reaper.GetMediaItemTake(_item, 0)
				local _name = ""
				if _take ~= nil then
					_name =  reaper.GetTakeName(_take)     
				else
					_name = reaper.ULT_GetMediaItemNote(_item)
					_name = string.gsub (_name, "\n", "")
					_name = string.gsub (_name, "\r", "")
				end
				
				local _item_pos = reaper.GetMediaItemInfo_Value(_item,"D_POSITION")
				local _item_len = reaper.GetMediaItemInfo_Value(_item,"D_LENGTH")
				local _item_end = _item_pos + _item_len
				local _current_group_id = reaper.GetMediaItemInfo_Value(_item,"I_GROUPID")
				
				--NEKATIVNO----ako je overlap item 
				--NEAKTIVNO--if _item_pos < _start_time or _item_end > _end_time then
					
					
					--ako ne pripada istoj klip grupi (TODO proveriti dal treba posebno da stoji i gornji uslov koji je neaktivan, a ne nestovano)
					if _current_group_id ~= group_id then
						--sacuvaj mute state i mutiraj ga
						overlapping_items[ov_index] = _item
						overlapping_items_mute_state[ov_index] = reaper.GetMediaItemInfo_Value(_item, "B_MUTE")--get mute
						reaper.SetMediaItemInfo_Value(_item, "B_MUTE", 1 )--mute that item
						ov_index = ov_index + 1

					else -- ako pripadaju istoj grupi
						MakeItemColorBrighter(_item)
						
						--ako su svi mono ili sabrani u mono onda exportuj mono ako vec nije namesteno da se eksportuje mono (NIJE DOBRO AKO IMA NEKIH MONO PANOVANIH FAJLOVA)
						-- if _take ~= nil then
							-- local _pcm_source = reaper.GetMediaItemTake_Source(_take)
							-- local channel_mode = reaper.GetMediaItemTakeInfo_Value(_take, "I_CHANMODE")
							-- local num_channels = reaper.GetMediaSourceNumChannels(_pcm_source)
							-- if channel_mode == 0 then 	--ako je namešteno na normal
								-- if num_channels > 1 then -- a broj kanala je veći od 1
									-- mono_item = false	 -- onda nije mono item
								-- else
									-- --onda je prirodni mono, odlično
								-- end
							-- else 						-- ako nije namešteno na normal nego: reverse stereo, Mono(L+R), Mono L, Mono R
								-- if channel_mode > 1 then  -- ako je Mono(L+R) ili Mono L ili Mono R
									-- --Znači da je forsiran mono, odlično
								-- end
							-- end
						-- end
					end
					
					
				--NEAKTIVNO--end
			end   
			
			
			--(NE RADI JER JER SRANJE)
			-- Msg(new_name)
			-- Msg(mono_item)
			-- Msg("==")
			--da li da eksportuje mono ili stereo
			-- local output_script_name = "ChangeRenderSettingsToStereo"
			-- if mono_item == true then
				-- output_script_name = "ChangeRenderSettingsToMono"
			-- end
			-- --get script path
			-- local info = debug.getinfo(1).source:match("@(.*)") 
			-- ofni = string.reverse(info)
			-- idx = string.find(ofni, "\\" )
			-- htap = string.sub(ofni, idx, -1)
			-- path = string.reverse(htap)
			-- --Msg(path);
			
			-- batch_path = [["]]..path..output_script_name..[[.ahk"]]
			-- io.popen(batch_path)
		----------------------------------------------------------------------------------------------------
		
		reaper.Main_OnCommand(41823,0) --File: Add project to render queue, using the most recent render settings
		
		--Vrati stari mute state itemima koji nisu deo klip grupe koja treba da se renderuje
			for j = 0, ov_index - 1 do 
				reaper.SetMediaItemInfo_Value(overlapping_items[j], "B_MUTE", overlapping_items_mute_state[j])--mute that item
			end
		----------------------------------------------------------------
		
		--brisanje regije
		reaper.DeleteProjectMarker( 0, marker_index, true )
		
		reaper.Main_OnCommand(40289,0) --Item: Unselect all items
		reaper.Main_OnCommand(40020,0) --Time selection: Remove time selection and loop points
	end
	
	reaper.Main_OnCommand(41207,0) --render all
	
end


function post_export_dialog(message_title)
	if message_title == nil then message_title = [[Rendering Completed]] end
	-- --When rendering completed======================================================================
	ok = reaper.ShowMessageBox( [[Do you want to move rendered sounds to P:\data ?
	
Pressing No will open ]]..bounced_sounds_folder, message_title, 3 )
	--Msg(ok)
	
	--Yes clicked --run move script=============================
	if ok == 6 then 
		--autohotkey script
		--get script path
		-- local info = debug.getinfo(1).source:match("@(.*)") 
		-- ofni = string.reverse(info)
		-- idx = string.find(ofni, "\\" )
		-- htap = string.sub(ofni, idx, -1)
		-- path = string.reverse(htap)
		-- --Msg(path);
		
		-- batch_path = [["]]..path..[[Reaper_Move_Sounds.ahk"]]
		-- os.execute (batch_path)
		
		
		--lua script
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS9cc6317b004b851b7bccd1ac1b78b066b6701111"),0)
	end
	
	--No clicked --open folder==================================
	if ok == 7 then
		prog = [[%SystemRoot%\explorer.exe "]]..bounced_sounds_folder..[["]]
		io.popen(prog)     
	end
	--=================================================================================================
end


--EXECUTION=================================================================================================================================================================

Main()--run
