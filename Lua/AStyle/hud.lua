local function spfontdw(d, font, x, y, scale, value, flags, color, alligment, padding, leftadd)
	local patch, val
	local str = ''..value
	local fontoffset, allig, actlinelenght = 0, 0, 0
	local trans = V_TRANSLUCENT

	if leftadd ~= nil and leftadd ~= 0 then
		local strlefttofill = leftadd-#str
		if strlefttofill > 0 then
			for i = 1,strlefttofill do
				str = ";"..str
			end
		end
	end

	for i = 1,#str do
		val = string.sub(str, i,i)
		patch = d.cachePatch(font..''..val)
		if not d.patchExists(font..''..val) then
			if d.patchExists(font..''..string.byte(val)) then
				patch = d.cachePatch(font..''..string.byte(val))
			else
				patch = d.cachePatch('SA2NUMNONE')
			end
		end		
		actlinelenght = $+patch.width+(padding or 0)
	end
	
	if alligment == "center" then
		allig = FixedMul(-actlinelenght/2*FRACUNIT, scale)
	elseif alligment == "right" then
		allig = FixedMul(-actlinelenght*FRACUNIT, scale)	
	end
	
	for i = 1,#str do
		val = string.sub(str, i,i)
		if val ~= nil then
			patch = d.cachePatch(font..''..val)
			if not d.patchExists(font..''..val) then
				if d.patchExists(font..''..string.byte(val)) then
					patch = d.cachePatch(font..''..string.byte(val))
				else
					patch = d.cachePatch('SA2NUMNONE')
				end
			end
 		else
			return
		end
		d.drawScaled(FixedMul(x+allig+(fontoffset)*FRACUNIT, scale), FixedMul(y, scale), scale, patch, (val == ";" and flags|trans or flags), color)
		fontoffset = $+patch.width+(padding or 0)
	end

	
end

hud.add(function(v, p, t, e)
	hud.disable("rings")
	hud.disable("time")
	hud.disable("score")
	local mint = G_TicsToMinutes(leveltime, true)
	local sect = G_TicsToSeconds(leveltime)
	local cent = G_TicsToCentiseconds(leveltime)
	local numlives = (p.lives < 10 and '0'..p.lives or p.lives)	
	mint = (mint < 10 and '0'..mint or mint)
	sect = (sect < 10 and '0'..sect or sect)
	cent = (cent < 10 and '0'..cent or cent)
	if hud.transparencytimer == nil then	
		hud.transparencytimer = 0
	end
	hud.transparencytimer = (($+1) % 40)
	hud.trpcounter = (hud.transparencytimer > 20 and 10-(hud.transparencytimer-20)/2 or hud.transparencytimer/2)
	hud.transparency = V_HUDTRANSDOUBLE-(hud.trpcounter) << V_ALPHASHIFT
	
	v.draw(hudinfo[HUD_SCORE].x, hudinfo[HUD_SCORE].y-2, v.cachePatch('SRB1RING'), hudinfo[HUD_RINGS].f)
	v.draw(hudinfo[HUD_TIME].x, hudinfo[HUD_TIME].y+6, v.cachePatch('SRB1TIME'), hudinfo[HUD_TIME].f)	
	if p.rings == 0	then v.draw(hudinfo[HUD_SCORE].x, hudinfo[HUD_SCORE].y-2, v.cachePatch('SRBRRING'), hudinfo[HUD_RINGS].f|hud.transparency) end
	v.drawString(hudinfo[HUD_SECONDS].x-15, hudinfo[HUD_SECONDS].y+6, ""+mint..':'..sect..':'..cent, hudinfo[HUD_RINGS].f)
	spfontdw(v, 'SON1NUM', (hudinfo[HUD_RINGSNUM].x-15)*FRACUNIT, (hudinfo[HUD_SCORENUM].y+2)*FRACUNIT, FRACUNIT, p.rings, hudinfo[HUD_RINGS].f, v.getColormap(TC_DEFAULT, 0), 0, 1, 0)
	-- Life counter
end, "game")

local function Draw_Triangle_LineWave_Yoffset(v, y_center, wave_width, wave_radius, x_offset, y_offset, line_radius, color)
	local width = v.width()
	local height = v.height()
	local rest_of_x = -(width-320)/2
	--local rest_of_y = -(height-200)/2
	local rest_of_y_central = height-(y_center+wave_radius)
	local actual_width = wave_width

	for x = rest_of_x, width, 1 do
		local act = abs(x)+x_offset
		local y = ((act % wave_radius*4) > (wave_radius*2) and (act % wave_radius*2) - wave_radius or -(act % wave_radius*2) + wave_radius)+FixedInt(y_offset*x)
		v.drawFill(x, y_center+y, 1, line_radius, color)
	end
	
	--v.drawFill(rest_of_x, y_center+wave_radius, width-rest_of_x, y_offset_central, color)
end

local function Draw_Triangle_Wave_Yoffset(v, y_center, wave_width, wave_radius, x_offset, y_offset, color)
	local width = v.width()
	local height = v.height()
	local rest_of_x = -(width-320)/2
	--local rest_of_y = -(height-200)/2
	local rest_of_y_central = height-(y_center+wave_radius)
	local actual_width = wave_width

	for x = rest_of_x, width, 1 do
		local act = abs(x)+x_offset
		local y = ((act % wave_radius*4) > (wave_radius*2) and (act % wave_radius*2) - wave_radius or -(act % wave_radius*2) + wave_radius)+FixedInt(y_offset*x)
		local height_new = rest_of_y_central+wave_radius-y
		v.drawFill(x, y_center+y, 1, height_new, color)
	end
	
	--v.drawFill(rest_of_x, y_center+wave_radius, width-rest_of_x, y_offset_central, color)
end


hud.add(function(v, o, t, endtime)
	hud.disable("stagetitle")
	if t < endtime then
		Draw_Triangle_LineWave_Yoffset(v, 100, 20, 24, (leveltime % 512), FRACUNIT/4-(leveltime % 512)*(FRACUNIT/128), 2, 68)	
		Draw_Triangle_LineWave_Yoffset(v, 102, 20, 24, (leveltime % 512), FRACUNIT/4-(leveltime % 512)*(FRACUNIT/128), 8, 64)
		Draw_Triangle_LineWave_Yoffset(v, 110, 20, 24, (leveltime % 512), FRACUNIT/4-(leveltime % 512)*(FRACUNIT/128), 3, 154)
		Draw_Triangle_Wave_Yoffset(v, 113, 20, 24, (leveltime % 512), FRACUNIT/4-(leveltime % 512)*(FRACUNIT/128), 150)
	end
end, "titlecard")