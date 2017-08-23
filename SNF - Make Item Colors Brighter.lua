--COLORS==========================
function Main() 
	local selitems = reaper.CountSelectedMediaItems(0)
	if selitems > 0 then
		for i = 0, selitems - 1 do 
			local item =  reaper.GetSelectedMediaItem( 0, i )
			local color = reaper.GetDisplayedMediaItemColor(item)
			local R, G, B = reaper.ColorFromNative(color|0x1000000)
			local new_r, new_g, new_b = Luminance(0.9, R, G, B)
			local con_r, con_g, con_b = Convert_RGB(new_r,new_g,new_b)
			local new_color = reaper.ColorToNative(con_r,con_g,con_b)|0x1000000
			ApplyColor_Items(new_color,item)
		end
	end
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
  --lum = lum + change
  lum = change
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

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh( 1 )
Main() -- odradi funkciju
reaper.PreventUIRefresh( -1 )
reaper.Undo_EndBlock("Make Item Colors Brighter", -1)
reaper.UpdateArrange()