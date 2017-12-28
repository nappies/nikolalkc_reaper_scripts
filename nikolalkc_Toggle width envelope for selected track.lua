--Toggle width envelope for selected tracks
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

track_count =  reaper.CountSelectedTracks(0)

for i = 0, track_count -1 do
	track = reaper.GetSelectedTrack(0,i)
	br_env = reaper.GetTrackEnvelopeByName( track,"Width" )
	if br_env ~= nil then
		local width_env = reaper.BR_EnvAlloc(br_env, false)
		
		--Msg(width_env)
		local active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(width_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

		if visible == true then visible = false else
		if visible == false then visible = true end end
		reaper.BR_EnvSetProperties( width_env, active, visible, armed, inLane, laneHeight, defaultShape, faderScaling )
		reaper.BR_EnvFree(width_env,1)
		reaper.UpdateArrange() -- Update the arrangement (often needed)
	else 
		 retval, track_name = reaper.GetTrackName( track, "" )
		retva = reaper.ShowMessageBox("You must enable Width envelope on track "..track_name.." in order to show it.","Error",0)
	end
end
