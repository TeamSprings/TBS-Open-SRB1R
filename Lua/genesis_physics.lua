-- Translation of https://info.sonicretro.org/Sonic_Physics_Guide
-- God, this sucks.
-- WHY DID I EVEN STARTED THIS?!?!?!?!?!?!?!?!

//
//
//	Constants
//
//

-- seemingly, all default variables are still too low compare to genesis
local scale_adjustment = 93716
-- Genesis ran at 60 Tics and SRB2 does in 35, so increase is required
local framerate_translation = FixedMul(scale_adjustment, 60*FRACUNIT/35)
-- Genesis has smaller sprites compare to SRB2, taken in account too.
local genesis_to_srb2 = FixedMul(framerate_translation, 57*FRACUNIT/39)
-- Genesis works with fixedmath of 256 sub pixels per pixel. 
local genesis_sub_pixel = FRACUNIT/256 

-- Physics Adjustments
local acceleration_speed = FixedMul(12*genesis_sub_pixel, genesis_to_srb2)
local deceleration_speed = FixedMul(128*genesis_sub_pixel, genesis_to_srb2)
local normal_speed = deceleration_speed
local friction_speed = acceleration_speed
local top_speed = FixedMul(6*FRACUNIT, genesis_to_srb2)
local gravity_force = FixedMul(56*genesis_sub_pixel, genesis_to_srb2)
local jump_force = FixedMul(6*FRACUNIT+FRACUNIT/2, genesis_to_srb2)
local slipping_speed_range = FixedMul(2*FRACUNIT+FRACUNIT/2, genesis_to_srb2)
local slipping_time_const = TICRATE

-- Air Acceleration
local air_acceleration_speed = FixedMul(4*genesis_sub_pixel, genesis_to_srb2)
local airspeed_hold = FixedMul(16*FRACUNIT, genesis_to_srb2)
local airdragY_hold = FixedMul(4*FRACUNIT, genesis_to_srb2)
local airdragX_hold = FixedMul(FRACUNIT/8, genesis_to_srb2)

-- Roll Acceleration
local spindash_revtime = 3*TICRATE
local roll_top_speed = FixedMul(16*FRACUNIT, genesis_to_srb2)
local roll_friction_speed = FixedMul(6*genesis_sub_pixel, genesis_to_srb2)
local roll_deceleration_speed = FixedMul(32*genesis_sub_pixel, genesis_to_srb2)

-- Underwater physics
local underwater_acceleration_speed = acceleration_speed/2
local underwater_deceleration_speed = deceleration_speed/2
local underwater_friction_speed = friction_speed/2
local underwater_top_speed = top_speed/2
local underwater_air_acceleration_speed = air_acceleration_speed/2
local underwater_roll_friction_speed = roll_friction_speed/2
local underwater_roll_deceleration_speed = roll_deceleration_speed
local underwater_gravity_force = FixedMul(FRACUNIT/16, genesis_to_srb2)
local underwater_jump_force = FixedMul(3*FRACUNIT+FRACUNIT/2, genesis_to_srb2)

-- 100%s of SRB2 translation -- simply, this is for custom character support of different stats. 
-- For example common normal speed is 35*FRACUNITS, therefore it will be 100%

local vanilla_jump_conv = 93716


--local function translation_skin_variables(skin)

--end


-- Slope Factors
local slope_factor_normal = FixedMul(32*genesis_sub_pixel, genesis_to_srb2)
local slope_factor_rollup = FixedMul(20*genesis_sub_pixel, genesis_to_srb2)
local slope_factor_rolldown = FixedMul(80*genesis_sub_pixel, genesis_to_srb2)

addHook("PlayerSpawn", function(p)
	if not (p.mo and p.mo.valid) then return end
	local a = p.mo	
	a.groundspeed = 0
	a.control_lock_timer = 0
	a.gravityspeed = 0
	a.newspringx = 0
	a.newspringy = 0
	a.type_slope = 1
	a.spindash_tics = 0
	a.attaching_mode = 1
	a.grounded = false
	p.unstandardabilityactivated = false
	p.jumptrigger = false
end)

--local function Gen_IsPlayerGrounded(a)
--	if P_IsObjectOnGround(a) or 
--end

local function sign(num)
	if num > 0 then
		return 1
	elseif num < 0 then
		return -1
	else
		return 0
	end
end

local function sign_n(num)
	if num > 0 then
		return 1
	else
		return -1
	end
end


local function Gen_Movement(a)
	local left = false
	local right = false

	if a.control_lock_timer <= 0 then
		if (input.gameControlDown(GC_STRAFELEFT) or input.gameControlDown(GC_TURNLEFT)) then
			if a.groundspeed > 0 then
				a.groundspeed = $-deceleration_speed
				if a.groundspeed <= 0 then
					a.groundspeed = $-normal_speed
				end
			elseif a.groundspeed > -top_speed then
				a.groundspeed = $-acceleration_speed
				if a.groundspeed <= -top_speed then
					a.groundspeed = -top_speed
				end
			end
			left = true
		end	
	
		if (input.gameControlDown(GC_STRAFERIGHT) or input.gameControlDown(GC_TURNRIGHT)) then
			if a.groundspeed < 0 then
				a.groundspeed = $+deceleration_speed
				if a.groundspeed >= 0 then
					a.groundspeed = $+normal_speed
				end
			elseif a.groundspeed < top_speed then
				a.groundspeed = $+acceleration_speed
				if a.groundspeed >= top_speed then
					a.groundspeed = top_speed
				end
			end
			right = true
		end
	end
	
	if a.control_lock_timer or not (left or right) then
		a.groundspeed = $-min(abs(a.groundspeed), friction_speed) * sign(a.groundspeed)
	end
end

local function Gen_Slipping(a, angle, XY_speed)
	if a.control_lock_timer <= 0 then
		local abs_angle = AngleFixed(abs(angle))
		if abs(XY_speed) <= slipping_speed_range and abs_angle < AngleFixed(ANGLE_315) and abs_angle > AngleFixed(ANGLE_45) then
			
			-- detach (just in case of full 360 physics implementation)
			a.attaching_mode = 1
			a.grounded = false
			
			XY_speed = 0
			a.control_lock_timer = slipping_time_const
		end
	end
end

local function Gen_AirStrafing(a)
	if (input.gameControlDown(GC_STRAFELEFT) or input.gameControlDown(GC_TURNLEFT)) then
		a.momx = $-air_acceleration_speed
		if a.momx < -top_speed then
			a.momx = -top_speed
		end
	end

	if (input.gameControlDown(GC_STRAFERIGHT) or input.gameControlDown(GC_TURNRIGHT)) then
		a.momx = $+air_acceleration_speed
		if a.momx > top_speed then
			a.momx = top_speed
		end		
	end
end


local function Gen_Rolling(a, slope)
	if (input.gameControlDown(GC_STRAFELEFT) or input.gameControlDown(GC_TURNLEFT)) then
		a.angle = ANGLE_180
		if a.groundspeed > 0 then
			a.groundspeed = $-roll_deceleration_speed
		end
	end

	if (input.gameControlDown(GC_STRAFERIGHT) or input.gameControlDown(GC_TURNRIGHT)) then
		a.angle = 0
		if a.groundspeed < 0 then
			a.groundspeed = $+roll_deceleration_speed
		end		
	end
	
	a.groundspeed = max(min(roll_top_speed, a.groundspeed), -roll_top_speed)	
	a.groundspeed = $-min(abs(a.groundspeed), roll_friction_speed) * sign(a.groundspeed)
end

local function Gen_Landing(a, angle)
	local abs_angle = AngleFixed(abs(angle))
	if abs_angle == 0 then
		a.groundspeed = a.momx
	elseif abs_angle > 0 and abs_angle < AngleFixed(ANGLE_45)
		a.groundspeed = -sign(sin(angle))*FixedMul(a.momx, FRACUNIT/2)
	else
		a.groundspeed = -sign(sin(angle))*a.momx
	end
	a.player.jumptrigger = false
	a.player.pflags = $ &~ PF_APPLYAUTOBRAKE|PF_AUTOBRAKE
end

local function Gen_SlopeFactor(a, angle, type)
	if type == 1 then
		a.groundspeed = $-FixedMul(slope_factor_normal+gravity_force/2, sin(angle))
	elseif type == 2 then
		a.groundspeed = $-FixedMul(slope_factor_rollup+gravity_force/2, sin(angle))	
	else
		a.groundspeed = $-FixedMul(slope_factor_rolldown+gravity_force/2, sin(angle))	
	end
end

local ANGLE_high = AngleFixed(ANGLE_315+ANG1*40)
local ANGLE_low = AngleFixed(ANG20-ANG1*5)

local function Gen_IsAngleAffectingPlayer(angle)
	local abs_angle = AngleFixed(abs(angle))
	if (abs_angle < ANGLE_high and abs_angle > ANGLE_low) then
		return angle
	else
		return 0
	end
end

--local function Gen_IsAngleAffectingSprite(angle)
--	if angle > ANGLE_315 and angle > ANGLE_45 then
--		return angle
--	else
--		return 0
--	end
--end

// shoots a ray, in direction of choosing. 
--TBSlib.shootRay(vector3 origin, angle_t angleh, angle_t anglev)
local function finitive_ray(origin, amount)
	if not (origin and origin.x and origin.y and origin.z) then return end

	local ray = P_SpawnMobj(origin.x, origin.y, origin.z, MT_RAY)
	ray.state = S_BUSH 
	ray.scale = FRACUNIT/8
	ray.flags = $|MF_NOCLIPTHING|MF_STICKY &~ (MF_NOBLOCKMAP|MF_NOSECTOR|MF_NOCLIP|MF_NOTHINK|MF_NOCLIPHEIGHT|MF_SCENERY)
	ray.fuse = 2
	if ray.floorz > ray.z+amount then
		P_SetOrigin(ray, ray.x, ray.y, ray.floorz)
		if not ray.standingslope then
			P_SetOrigin(ray, ray.x, ray.y, origin.z)
		end
	end
	
	
	return {x = ray.x, y = ray.y, z = ray.z}
end

addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid and twodlevel and p.playerstate ~= PST_DEAD) then return end
	local a = p.mo
	if not p.unstandardabilityactivated then
		a.flags = $|MF_NOGRAVITY
	end
	
	
	a.friction = FRACUNIT
	p.runspeed = top_speed-FRACUNIT
	p.jumpfactor = FixedMul(vanilla_jump_conv, skins[a.skin].jumpfactor)
	p.shieldscale = skins[p.mo.skin].shieldscale*6/5
	
	local slope_angle = 0
	
	if not P_IsObjectOnGround(a) and a.attaching_mode > 1 then
		p.jumptrigger = true
	else
		a.grounded = true
		p.unstandardabilityactivated = false
	end
	
	if a.control_lock_timer > 0 then
		a.control_lock_timer = $-1
		print(a.control_lock_timer)
	end
	
	if p.pflags & PF_SPINNING then
		a.type_slope = 3
	else
		a.type_slope = 1
	end
	
	if p.unstandardabilityactivated or a.state >= S_JETFUMEFLASH then return end
	
	if a.state == S_PLAY_PAIN then
		a.grounded = false
		a.groundspeed = 0
		p.mo.flags = $ &~ MF_NOGRAVITY
		p.mo.rollangle = 0
		p.unstandardabilityactivated = true
		return
	end
	
	if P_IsObjectOnGround(a) or (a.grounded == true and a.attaching_mode > 1) then
		if not (p.pflags & PF_STARTDASH) then
			local ray_one, ray_two, ray_mid
			
			if a.attaching_mode == 2 then
				ray_one = finitive_ray({x = a.x+a.radius, y = a.y, z = a.z}, -a.height, a.angle, ANGLE_90)
				ray_two = finitive_ray({x = a.x+a.radius, y = a.y, z = a.z+a.height/2}, -a.height, a.angle, ANGLE_90)
				ray_mid = finitive_ray({x = a.x, y = a.y, z = a.z+a.height/2}, a.radius, ANGLE_90, ANGLE_180)				
			else
				ray_one = finitive_ray({x = (a.x-a.radius), y = (a.y-a.radius), z = a.z}, -a.height)
				ray_two = finitive_ray({x = (a.x+a.radius), y = (a.y+a.radius), z = a.z}, -a.height)
				ray_mid = finitive_ray({x = (a.x+a.radius), y = a.y, z = (a.z+a.height/2)}, a.radius)
			end
		
			local test_angle = R_PointToAngle2(ray_one.x, ray_one.z, ray_two.x, ray_two.z)
			
			if test_angle > ANGLE_45 and (a.x-ray_mid.x) > a.radius then
				a.attaching_mode = 2
			end

			slope_angle = Gen_IsAngleAffectingPlayer(test_angle)
			if a.type_slope == 3 and sign(slope_angle) == 1 then
				a.type_slope = 2
			end

			if a.spindash_tics then
				a.groundspeed = FixedMul((roll_top_speed*min(a.spindash_tics, spindash_revtime)/spindash_revtime), cos(a.angle))
				a.spindash_tics = 0
			end

			if p.jumptrigger then
				Gen_Landing(a, slope_angle)
			end

			if slope_angle ~= 0 then
				Gen_SlopeFactor(a, slope_angle, a.type_slope)
			end

			if not (p.pflags & PF_SPINNING) then
				Gen_Movement(a)
			end
		
			a.rollangle = slope_angle
			if (a.newspringx or a.newspringy) then
				a.groundspeed = a.newspringx
				a.momz = $+a.newspringy
				a.newspringx = 0
				a.newspringy = 0
				p.pflags = $|PF_THOKKED
			end
		
			local XY_speed = FixedMul(a.groundspeed, cos(slope_angle))
			Gen_Slipping(a, slope_angle, XY_speed)
			if a.attaching_mode % 2 then
				a.momx = XY_speed --, cos(a.angle))		
			else
				a.momz = XY_speed
			end
		
			print("\x85".."Slope Angle: \x80"..test_angle/ANG1.."\x85".." Ray1 Z: \x80"..ray_one.z/FRACUNIT.."\x85".." Ray2 Z: \x80"..ray_two.z/FRACUNIT.."\x85".." Speed: \x80"..XY_speed/FRACUNIT.."\x85".." Mode: \x80"..a.attaching_mode)
			--print()
			--a.momy = FixedMul(XY_speed, sin(a.angle))
			--a.momz = FixedMul(a.groundspeed, -sin(slope_angle))-gravity_force*16
		else
			a.spindash_tics = $+1
		end
	else
		
		a.rollangle = 0
		if a.state ~= S_PLAY_CLIMB then 
			Gen_AirStrafing(a)
			-- Top Y Speed
			a.momz = $-gravity_force
			if a.momz < -airspeed_hold then
				a.momz = -airspeed_hold
			end
		end

		if (a.newspringx or a.newspringy) then
			a.momx = a.newspringx
			a.momz = a.newspringy
			a.newspringx = 0
			a.newspringy = 0
			p.pflags = $|PF_THOKKED		
		end
			
		-- Air Dragging
		--if a.momz > 0 and a.momz < airdragY_hold then
		--	a.momx = $-(FixedMul(FixedDiv(a.momx, airdragX_hold), genesis_sub_pixel))
		--end
	end
	
	if p.pflags & PF_SPINNING then
		Gen_Rolling(a, slope_angle)
		a.rollangle = 0
	end
	
	
	if p.followmobj then
		-- Tails, lights whatever
		p.followmobj.rollangle = a.rollangle
	end
end)

addHook("MobjCollide", function(a, t)
	if not (a.flags & MF_SPRING and t.player and t.z >= a.z-t.height and t.z <= a.z+a.height and not t.player.unstandardabilityactivated) then return end
	t.newspringx = FixedMul(4*a.info.damage/5, cos(a.angle))
	t.newspringy = 3*a.info.mass/2*P_MobjFlip(a)
	P_MoveOrigin(t, t.x+FixedMul(3*a.info.damage, cos(a.angle)), t.y+FixedMul(3*a.info.damage, sin(a.angle)), t.z+t.newspringy)
	if t.newspringy then
		t.state = S_PLAY_SPRING
	end
end, MT_NULL)

addHook("AbilitySpecial", function(p)
	p.unstandardabilityactivated = true
	if not (p.mo and p.mo.valid) then return end
	p.mo.rollangle = 0	
	p.mo.flags = $ &~ MF_NOGRAVITY
end)

addHook("JumpSpinSpecial", function(p)
	p.unstandardabilityactivated = true
	if not (p.mo and p.mo.valid) then return end	
	p.mo.rollangle = 0	
	p.mo.flags = $ &~ MF_NOGRAVITY
end)

addHook("ShieldSpecial", function(p)
	p.unstandardabilityactivated = true
	if not (p.mo and p.mo.valid) then return end	
	p.mo.rollangle = 0	
	p.mo.flags = $ &~ MF_NOGRAVITY
end)