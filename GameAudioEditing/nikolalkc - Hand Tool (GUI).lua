--[[ ReaScript Name:nikolalkc - Hand Tool With GUI
 Author: nikolalkc
 Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 REAPER: 5+
 Extensions: SWS
 Version: 1.0
 About:
	Locks item edges, fades, stretch markers, envelopes and time selection and shows visible large red GUI while locking is activated. 
	This enables you to move items like you have real hand tool.

  RENDER SETTINGS: 

    SOURCE: Region render matrix

    FILENEME: $region
]]

--[[
 * Changelog:
 * v1.0	(2018-03-22)
	+ Initial Commit
]]

--utility

-- Improved roundrect() function with fill, adapted from mwe's EEL example.
local function roundrect(x, y, w, h, r, antialias, fill)
	
	local aa = antialias or 1
	fill = fill or 0
	
	if fill == 0 or false then
		gfx.roundrect(x, y, w, h, r, aa)
	elseif h >= 2 * r then
		
		-- Corners
		gfx.circle(x + r, y + r, r, 1, aa)		-- top-left
		gfx.circle(x + w - r, y + r, r, 1, aa)		-- top-right
		gfx.circle(x + w - r, y + h - r, r , 1, aa)	-- bottom-right
		gfx.circle(x + r, y + h - r, r, 1, aa)		-- bottom-left
		
		-- Ends
		gfx.rect(x, y + r, r, h - r * 2)
		gfx.rect(x + w - r, y + r, r + 1, h - r * 2)
			
		-- Body + sides
		gfx.rect(x + r, y, w - r * 2, h + 1)
		
	else
	
		r = h / 2 - 1
	
		-- Ends
		gfx.circle(x + r, y + r, r, 1, aa)
		gfx.circle(x + w - r, y + r, r, 1, aa)
		
		-- Body
		gfx.rect(x + r, y, w - r * 2, h)
		
	end	
	
end


local function rgb2num(red, green, blue)
	
	green = green * 256
	blue = blue * 256 * 256
	
	return red + green + blue

end



--meat starts here

local locked = reaper.GetToggleCommandState(1135) -- check lock

if locked == 1 then
	--close GUI and disable locking
	GUI_ACTIVE = false
	reaper.Main_OnCommand(40570,0) -- disable locking
else
	reaper.Main_OnCommand(40595,0) -- set item edges lock
	reaper.Main_OnCommand(40598,0) --set item fades lock
	reaper.Main_OnCommand(41852,0) --set item stretch markers lock
	reaper.Main_OnCommand(41849,0) --set item envelope
	reaper.Main_OnCommand(40571,0) --set time selection lock
	reaper.Main_OnCommand(40569,0) --enable locking
end


local function Main_GUI()
	--gui
	-- reaper.ClearConsole()
	-- state = gfx.dock(-1)
	-- Msg(state)
	local char = gfx.getchar()
	local LOCK_ACTIVE = reaper.GetToggleCommandState(1135) -- check lock
	if char ~= 27 and char ~= -1 and LOCK_ACTIVE == 1 then
		reaper.defer(Main_GUI)
	else
		-- Msg("Script Over!")
	end
	
	local my_str = "HAND TOOL"

	local x, y = 860, 10
	local w, h = 200, 80
	local r = 10

	roundrect(x, y, w, h, r, 1, 0)

	gfx.setfont(1, "Arial", 24,98)
	local str_w, str_h = gfx.measurestr(my_str)

	gfx.x = x + ((w - str_w) / 2)
	gfx.y = y + ((h - str_h) / 2)

	gfx.drawstr(my_str)
	
	
	gfx.update()
end




local r, g, b = 150, 64, 64
gfx.clear = rgb2num(r, g, b)
gfx.init("Hand Tool", 220, 100, 1537, 900, 900) --1537 is docker below arrange
Main_GUI()