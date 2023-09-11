local camsettings = {
	cdcamera = true;
	speeddis = true;
}


addHook("PlayerSpawn", function(p)
	if (maptol & TOL_2D) then
		p.mo.newcam = P_SpawnMobj(camera.x, camera.y, camera.z, MT_ALARM)
		p.mo.newcam.state = S_INVISIBLE
		p.mo.newcam.angle = ANGLE_90
		p.mo.newcam.height = camera.height
		p.mo.newcam.radius = camera.radius
		p.mo.newcam.flags = $|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_NOTHINK
		p.mo.newcam.flags2 = $|MF2_DONTDRAW		
		p.mo.newcam.scale = p.camerascale
		p.awayviewaiming = camera.aiming
		p.awayviewmobj = p.mo.newcam
		p.awayviewtics = 4
		p.mo.scale = $+FRACUNIT/16
	end
end)


addHook("PostThinkFrame", do for p in players.iterate() do
	if (maptol & TOL_2D) and p.mo.newcam and p.mo.newcam.valid and p.playerstate ~= PST_DEAD then
		local runspeed = skins[p.mo.skin].runspeed-20*FRACUNIT
		local momxcam = ((abs(p.rmomx) > runspeed) and (p.rmomx - (p.rmomx/abs(p.rmomx))*runspeed)*2 or 0)
		local momycam = ((abs(p.rmomy) > runspeed) and (p.rmomy - (p.rmomy/abs(p.rmomy))*runspeed)*2 or 0)
		P_TeleportMove(
		p.mo.newcam,
		p.mo.x+cos(ANGLE_270)*(400 + (camsettings.speeddis and min(128,abs(p.rmomx/FRACUNIT)) or 0))+(camsettings.cdcamera and max(-30*FRACUNIT,min(momxcam, 30*FRACUNIT))*4 or 0), 
		p.mo.y+sin(ANGLE_270)*(400 + (camsettings.speeddis and min(128,abs(p.rmomx/FRACUNIT)) or 0))+(camsettings.cdcamera and max(-30*FRACUNIT,min(momycam, 30*FRACUNIT))*4 or 0), 
		p.mo.z+20*FRACUNIT)
		p.awayviewtics = 2
	end
	
	p.shieldscale = skins[p.mo.skin].shieldscale*6/5
	p.normalspeed = skins[p.mo.skin].normalspeed
	p.runspeed = skins[p.mo.skin].runspeed
	p.jumpfactor = skins[p.mo.skin].jumpfactor
	p.accelstart = skins[p.mo.skin].accelstart
	p.acceleration = skins[p.mo.skin].acceleration
	
	end
end)