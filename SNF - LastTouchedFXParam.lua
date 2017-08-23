function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end



function Main()
  retval, tracknumberOut, fxnumberOut, paramnumberOut = reaper.GetLastTouchedFX()
  Msg("Last FX PARAM:")
  Msg(retval)  
  Msg("TrackNumberOut:"..tracknumberOut)  
  Msg("FxNumberOut:"..fxnumberOut)  
  Msg("ParamNumberOut:"..paramnumberOut)  
  
  
  
  
  reaper.TakeFX_GetEnvelope( 0, fxnumberOut, paramnumberOut, 1)
end



Main()


