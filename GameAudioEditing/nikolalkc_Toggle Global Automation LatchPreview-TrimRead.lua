--[[
  ReaScript Name: Toggle Global Automation LatchPreview-TrimRead
  Description: TOGGLE GLOBAL AUTOMATION OVERRIDE FROM LATCH-PREVIEW TO TRIM-READ AND VICEVERSA
  Instructions:With a press of your shortcut key switch between this two global automation modes
  Author: nikolalkc
  Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
  REAPER: 5+
  Version: 1.0
]]

--[[
 * Changelog:
 * v1.0 (2017-12-28)
	+ Initial Release
--]]




--0 - Trim Read
--1 - Read
--2 - Touch
--3 - Write
--4 - Latch
--5 - Latch Preview

--reaper.ShowConsoleMsg("")
auto_mode = reaper.GetGlobalAutomationOverride()

--reaper.ShowConsoleMsg("\n"..auto_mode)

if auto_mode == 0 then
  reaper.SetGlobalAutomationOverride(5)
else
  reaper.SetGlobalAutomationOverride(0)
end
