/* 
		Pipe Kingdom Zone's Collectibles

Description:
Scripts needed on collectible side

Contributors: Ace Lite, Krabs(Checkpoints)
@Team Blue Spring 2022

Contains:
	SMS Alfredo - Shelmet; Mushroom Movement Thinker
*/
freeslot("MT_BACKERADUMMY", "MT_FRONTERADUMMY", "MT_EXTRAERADUMMY", "S_DUMMYMONITOR", "S_DUMMYGMONITOR", "SPR_1MOA")

mobjinfo[MT_EXTRAERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOGRAVITY|MF_SCENERY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

mobjinfo[MT_BACKERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOTHINK|MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	dispoffset = -1
}

mobjinfo[MT_FRONTERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOTHINK|MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	dispoffset = 1	
}

states[S_DUMMYMONITOR] = {
	sprite = SPR_1MOA,
	frame = A
}

states[S_DUMMYGMONITOR] = {
	sprite = SPR_1MOA,
	frame = B
}

states[S_BOX_FLICKER].nextstate = S_DUMMYMONITOR
states[S_GOLDBOX_FLICKER].nextstate = S_DUMMYGMONITOR
states[S_GOLDBOX_OFF7].nextstate = S_DUMMYGMONITOR
addHook("MapThingSpawn", function(a, mt)
	if a.info.flags & MF_MONITOR then
		
		if a.info.flags & MF_GRENADEBOUNCE then
			a.state = S_DUMMYGMONITOR
		else
			a.state = S_DUMMYMONITOR
		end
		
		local icon = mobjinfo[a.type].damage
		local icstate = mobjinfo[icon].spawnstate
		local icsprite = states[icstate].sprite
		local icframe = states[icstate].frame	

		a.item = P_SpawnMobjFromMobj(a, 0,0,0, MT_FRONTERADUMMY)
		a.item.state = S_INVISIBLE
		a.item.sprite = icsprite
		a.item.frame = icframe
		a.item.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT	
	end
end, MT_NULL)

addHook("MobjThinker", function(a, mt)
	if a.info.flags & MF_MONITOR then
		if a.info.flags & MF_GRENADEBOUNCE then
			P_TeleportMove(a.item, a.x, a.y, a.z+15*FRACUNIT)
			if a.state ~= S_DUMMYGMONITOR			
				a.item.flags2 = $|MF2_DONTDRAW
			else
				if a.item.flags2 & MF2_DONTDRAW then 
					a.item.flags2 = $ &~ MF2_DONTDRAW
				end
				A_SmokeTrailer(a, MT_BOXSPARKLE)
			end
		else
			P_TeleportMove(a.item, a.x, a.y, a.z+16*FRACUNIT)
			if a.state == S_DUMMYMONITOR and a.health > 0
				if (leveltime % 3) / 2
					a.item.flags2 = $|MF2_DONTDRAW
					a.sprite = SPR_MSTV
					a.frame = A
				else
					a.item.flags2 = $ &~ MF2_DONTDRAW				
					a.sprite = SPR_1MOA
					a.frame = A					
				end
			end
		end		
		
	end
end, MT_NULL)

addHook("MobjDeath", function(a, mt)
	if a.info.flags & MF_MONITOR and not (a.info.flags & MF_GRENADEBOUNCE) then
		a.item.flags2 = $|MF2_DONTDRAW
		a.flags = $ &~ MF_SOLID
		a.sprite = SPR_MSTV
		a.frame = B
		a.momz = 4*FRACUNIT
		
		local smuk = P_SpawnMobjFromMobj(a, 0,0,0, MT_EXTRAERADUMMY)
		smuk.state = S_XPLD1
		smuk.fuse = 32 
		smuk.scale = a.scale	
		
		local boxicon = P_SpawnMobjFromMobj(a.item, 0,0,0, mobjinfo[a.type].damage)
		boxicon.scale = a.item.scale
		boxicon.target = mt
		return true
	end
end, MT_NULL)