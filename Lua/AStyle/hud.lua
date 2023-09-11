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