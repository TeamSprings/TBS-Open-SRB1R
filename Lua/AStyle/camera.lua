local camsettings = {
	cdcamera = false;
	speeddis = false;
}

local FRAx = 30 << FRACBITS

-- SRB1R 2D Camera
addHook("PlayerThink", function(p)
	if not (maptol & TOL_2D) then return end
	
	local runspeed = skins[p.mo.skin].runspeed-20 << FRACBITS
	local momxcam = ((abs(p.rmomx) > runspeed) and (p.rmomx - (p.rmomx/abs(p.rmomx))*runspeed) << 1 or 0)
	local momycam = ((abs(p.rmomy) > runspeed) and (p.rmomy - (p.rmomy/abs(p.rmomy))*runspeed) << 1 or 0)
	P_TeleportCameraMove(
	camera,
	p.mo.x+cos(ANGLE_270)*(515 + (pkz_speedist and min(128,abs(p.rmomx >> FRACBITS)) or 0))+(pkz_cdcamera and max(-FRAx, min(momxcam, FRAx))*4 or 0), 
	p.mo.y+sin(ANGLE_270)*(515 + (pkz_speedist and min(128,abs(p.rmomy >> FRACBITS)) or 0))+(pkz_cdcamera and max(-FRAx, min(momycam, FRAx))*4 or 0), 
	p.mo.z+p.mo.height >> 1)
	camera.momx = 0
	camera.momy = 0
	camera.momz = 0
end)