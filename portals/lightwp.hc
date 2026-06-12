/*
==============================================================================

 $Header: /H2 Mission Pack/HCode/lightwp.hc 41    3/17/98 4:06p Mgummelt $

==============================================================================
*/

// For building the model
$cd Q:\art\models\weapons\spllbook
$origin 0 0 0
$base BASE skin
$skin skin
$flags 0

//
$frame fidle1       fidle2       fidle3       fidle4       fidle5       
$frame fidle6       fidle7       fidle8       fidle9       fidle10      
$frame fidle11      fidle12      fidle13      fidle14      fidle15      
$frame fidle16      

//
$frame nidle1       nidle2       nidle3       nidle4       nidle5       
$frame nidle6       nidle7       nidle8       nidle9       nidle10      
$frame nidle11      nidle12      nidle13      nidle14      nidle15      
$frame nidle16      

//
$frame normal1      normal2      normal3      normal4      normal5      
$frame normal6      normal7      normal8      normal9      normal10     
$frame normal11     normal12     normal13     normal14     normal15     
$frame normal16     

//
$frame pidle1       pidle2       pidle3       pidle4       pidle5       
$frame pidle6       pidle7       pidle8       pidle9       pidle10      
$frame pidle11      pidle12      pidle13      pidle14      pidle15      
$frame pidle16      

//
$frame power1       power2       power3       power4       power5       
$frame power6       power7       power8       power9       power10      
$frame power11      power12      power13      power14      power15      
$frame power16      

//
$frame select1      select2      select3      select4      select5      
$frame select6      select7      select8      select9      select10     
$frame select11     select12     


/*
======================
Lightning Bolts Test

Unpowered: Ball Lightning

Powered: Chain lightning- arcs between monsters
======================
*/

void lball_remove ()
{
	stopSound(self,0);
	remove(self);
}

void LightningBallTouch ()
{
float zap_cnt,zap_other;
vector org,tospot;
	if(other.classname==self.classname&&other.owner==self.owner)
		return;

	self.level=FALSE;
	if(other.takedamage)
	{
		T_Damage(other,self,self.owner,self.dmg);
		if(other.flags&FL_MONSTER)
			zap_other=TRUE;
	}
	T_RadiusDamage(self,self.owner,self.dmg,other);
	stopSound(self,0);
	sound(self,CHAN_AUTO,"crusader/lghtn2.wav",1,ATTN_NORM);
	starteffect(CE_LBALL_EXPL,self.origin-self.movedir*8,0.05);
	if(zap_other)
	{
		org=self.origin;
		tospot=normalize((other.absmin+other.absmax)*0.5-org);
		tospot=org+tospot*(random(75)+75);
		do_lightning (self.owner,zap_cnt,0,4,org,tospot,100,TE_STREAM_LIGHTNING);
	}

	while(zap_cnt<3)//8)
	{
		self.angles=randomv('0 0 0','360 360 360');
		makevectors(self.angles);
		org=self.origin;
		tospot=org+v_forward*(random(75)+75);
		do_lightning (self.owner,zap_cnt,0,4,org,tospot,50,TE_STREAM_LIGHTNING);
		zap_cnt+=1;
	}
	remove(self);
}

void FireLightningBall ()
{
entity lball;//,star1,star2;

	makevectors(self.v_angle);
	self.effects(+)EF_MUZZLEFLASH;
	stuffcmd (self, "bf\n");
	lball=spawn();
	lball.classname="lightning ball";
	lball.owner=self;
	lball.drawflags(+)SCALE_ORIGIN_CENTER|DRF_TRANSLUCENT;
	lball.movetype=MOVETYPE_FLYMISSILE;
	lball.solid=SOLID_BBOX;
	lball.level=TRUE;

	lball.touch=LightningBallTouch;
	lball.dmg=random(50,75);

	lball.speed=1000;
	lball.velocity=normalize(v_forward)*lball.speed;
	lball.angles=randomv('-600 -600 -600','600 600 600');
//	lball.avelocity=randomv('-600 -600 -600','600 600 600');

	setmodel(lball,"models/lball.mdl");
	setsize(lball,'0 0 0','0 0 0');

	lball.scale=0.75;
	setorigin(lball,self.origin+self.proj_ofs+v_forward*10);
	sound(self,CHAN_AUTO,"succubus/firelbal.wav",1,ATTN_NORM);

	lball.turn_time=2;
	lball.dmg=random(45,55);
	lball.effects=EF_DIMLIGHT;
	lball.frags=TRUE;
	lball.veer=100;
	lball.homerate=0.1;
	lball.lifetime=time+5;
	lball.th_die=lball_remove;
	lball.think=HomeThink;
	lball.hoverz=TRUE;
	thinktime lball : 0.2;
	// [2026-06-12] jsH2+ flight loop removed (user decision): vanilla stacked TWO copies of
	// the buzz2 loop on every ball - one here on CHAN_WEAPON at spawn, another from HomeThink
	// on CHAN_BODY 0.02-0.5s later (via t_width, also removed). Discovered when the paced
	// charge made the sound stack audible. The ball flies silent; buzz2 is the charge sound now.
/*
	star1=spawn();
	lball.movechain = star1;
	star1.drawflags(+)MLS_ABSLIGHT;
	star1.abslight=0.5;
	star1.avelocity_z=400;
	star1.avelocity_y=300;
	star1.angles_y=90;
	setmodel(star1,"models/star.mdl");
	star1.scale=0.3;
	setorigin(star1,lball.origin);
	star2=spawn();
	star1.movechain = star2;
	star2.drawflags(+)MLS_ABSLIGHT;
	star2.abslight=0.5;
	star2.avelocity_z=-400;
	star2.avelocity_y=-300;
	star2.scale=0.3;
	setmodel(star2,"models/star.mdl");
	setorigin(star2,lball.origin);
	star1.movetype=star2.movetype=MOVETYPE_NOCLIP;
	star1.owner=star2.owner=lball;
	star1.think=star2.think=StarTwinkle;
	thinktime star1 : 0;
	thinktime star2 : 0;
*/
}

void branch_fire (vector org)
{
vector tospot, lightn_dir;
float num_branches;

	tospot=org+v_forward*1000;
	traceline(org,tospot,TRUE,self);
	tospot=trace_endpos;

	self.t_width=time+1;
	sound(self,CHAN_WEAPON,"succubus/firelght.wav",1,ATTN_NORM);
	num_branches = 3;
//	num_branches = rint(random(3,7));
	self.count=0;
	while(num_branches)
	{
		self.count+=1;
		if(self.count>=8)
			self.count=0;

		do_lightning (self,self.count,STREAM_ATTACHED,4,org,tospot,30,TE_STREAM_LIGHTNING_SMALL);

		lightn_dir=normalize(tospot-org);
		org=org + lightn_dir*random(num_branches+20,num_branches+45);//Include trace_fraction?
		tospot=org+v_forward*1000;
		traceline(trace_endpos,tospot,TRUE,self);
		tospot=trace_endpos;
		if(random()<0.5)
			tospot+=v_right*random(150,400);
		else
			tospot-=v_right*random(150,400);
		if(random()<0.5)
			tospot+=v_up*random(150,400);
		else
			tospot-=v_up*random(150,400);
		
		num_branches-=1;
	}		
}

/*
void glowball_fade ()
{
	self.abslight-=0.1;
	self.scale-=0.01;
	if(self.lifetime<time)
		remove(self);
	else
	{
		thinktime self : 0.05;
		self.think=glowball_fade;
	}
}
*/

/*
void make_glowball (vector org)
{
entity glowball;
	glowball=spawn();
	glowball.solid=SOLID_NOT;
	glowball.movetype = MOVETYPE_NOCLIP;
	setmodel(glowball,"models/glowball.mdl");
	setorigin(glowball,org-v_forward*26+'0 0 3'-v_right*1);
	glowball.owner=self;
	glowball.angles=randomv('-300 -300 -300','300 300 300');
	glowball.avelocity=randomv('-600 -600 -600','600 600 600');
	glowball.scale=0.1;
	glowball.drawflags=MLS_POWERMODE;//ABSLIGHT;
//	glowball.abslight=1;
//	glowball.lifetime=time+0.2;
	thinktime glowball : 0.1;
	glowball.think=SUB_Remove;//glowball_fade;
}
*/

void shebitch_chain_lightning_strike () 
{
vector org, tospot;//,fire_vec;
float damg,damg_thresh, zap_count,fov_check;
entity loser, lastloser,firstloser;

	if(self.attack_finished>time)
		return;
	self.greenmana-=2;
	self.bluemana-=2;
	self.attack_finished=time+0.2;
	self.effects(+)EF_MUZZLEFLASH;
	makevectors(self.v_angle);
	org=self.origin+self.proj_ofs+v_forward*36;

/*	fire_vec=aim(self,org,1000);
	fire_vec=normalize(fire_vec);
	tracearea(org,org+fire_vec*3000,'-3 -3 -3', '3 3 3',FALSE,self);
	if(!trace_ent.takedamage)
	{
		branch_fire(org);
		return;
	}
*/
	loser=findradius(org,1000);
	firstloser=lastloser=loser;//trace_ent;
	while(loser!=world)
	{
		if(loser.health&&loser.flags2&FL_ALIVE&&loser!=self)
		{
			tospot=(loser.absmin+loser.absmax)*0.5;
			traceline(org,tospot,TRUE,self);
			if(infront(loser))
			{
				if(lastloser==firstloser)
				{
					fov_check=vlen(loser.origin-self.origin);
					fov_check=(50/fov_check);
					if(fov_check>1)
						fov_check=1;
					fov_check*=10;//at further distances, cone is smaller
					if(!fov(loser,self,fov_check))
						trace_fraction=0;
				}
			}
			else
				trace_fraction=0;

			if(trace_fraction==1)
			{
				if(loser.flags&FL_MONSTER)
					damg_thresh=40;
				else
					damg_thresh=random(10,20);
				if(loser.health>damg_thresh)
					damg=damg_thresh;
				else
					damg=1000;
				self.count+=1;
				if(self.count>=8)
					self.count=0;
				tospot=(loser.absmin+loser.absmax)*0.5;
				zap_count+=1;
//FIXME:  Make it so these are staggered so only 1 lightning per frame, max
				do_lightning (self,self.count,STREAM_ATTACHED,4,org,tospot,damg,TE_STREAM_LIGHTNING_SMALL);
				org=tospot;
				if(lastloser==self)
					firstloser=loser;
				lastloser=loser;
			}
		}			
		loser=loser.chain;
	}

	if(!zap_count)
		branch_fire(org);
}

/*
void shebitch_lightning_strike (void)
{
vector org;
	if(self.attack_finished>time)
		return;

	self.attack_finished=time+0.2;
	self.effects(+)EF_MUZZLEFLASH;
	makevectors(self.v_angle);
	org=self.origin+self.proj_ofs+v_forward*36;

//	make_glowball(org);
	branch_fire(org);
}
*/

void()lightning_ready_power;
void()lightning_ready_normal;
void()lightning_close_normal;
//void()lightning_to_normal;
//void()lightning_to_power;
void lightning_fire_normal (void)
{
// [2026-06-12] jsH2+ time-paced charge (user design). The mechanism, code-proven: th_weapon
// runs on the player's 20Hz anim clock (HX_FRAME_TIME thinks in player_*.hc), BUT W_Attack
// re-enters Suc_Litn_Fire every server frame while button0 is held and attack_finished has
// elapsed, and that called this function DIRECTLY - so the first windup advanced at think
// rate PLUS frame rate (~0.15s total, framerate-bound since retail: the first ball always
// read as instant). Post-shot windups ran at honest 20Hz (the visible replay players saw).
// Now: the Suc_Litn_Fire re-entry guard leaves the think chain as the only driver, and
// advance is gated to one frame per 0.07s minimum - an even, framerate-independent charge;
// release before frame 12 cancels. weaponframe_cnt is repurposed as the pacing timestamp
// (the old fidle hold loop is gone - every ball is charged through the full windup).
// Fully charged + refire pending holds the pose at $normal12.
// [2026-06-12] jsH2+ measured frame semantics (prong-tip vertex separation, sucwp4.mdl):
// normal1-5 = tips CLOSED at rest, normal6-11 = tips snap OPEN and the ball builds between
// them, normal12-16 = the clap that looses the ball, landing back closed (frame 16 matches
// frame 1 - the artist built a seamless cycle). Vanilla's own animation IS the charge
// weapon; it just played at one frame per 72Hz tick and was never visible.
	if(self.weaponframe_cnt < time)
	{
		self.weaponframe_cnt = time + 0.07;
		if (self.weaponframe != $normal12)	// hold the fully-charged pose; the fire branch
			self.wfs = advanceweaponframe($normal1,$normal16);	// below moves us to $normal13
		// [2026-06-12] jsH2+ full vanilla cycle 1..16 (the closed-rest experiment is retired -
		// the model has no truly closed frame; a fully-shut rest would need model surgery,
		// noted in PROGS_TRACKER as an optional future local-asset project).
		if(self.weaponframe==$normal2)
		{//FIXME:  WHY THE FUCK CAN'T I SET DRAWFLAGS?!!!!
			sound(self,CHAN_WEAPON,"succubus/buzz2.wav",1,ATTN_NORM);	// [2026-06-12] jsH2+ charge hum
										// (loop-marked sample: sustains through the charge, stopped at
										// every exit; the ball's own firelbal.wav stays the only shot sound)
			// [2026-06-12] jsH2+ the charge light is EF_BRIGHTLIGHT (white, like the tome
			// flashes) instead of EF_DIMLIGHT (the torch's orange). The staff and the torch
			// no longer share a bit at all - the original light-theft bug class is gone at
			// the root. lefty ownership + AFL_TORCH guard protect a full-blaze torch's BRIGHT.
			if(self.effects&EF_BRIGHTLIGHT)
				self.lefty=TRUE;
			else
				self.effects(+)EF_BRIGHTLIGHT;
//			self.drawflags(+)MLS_ABSLIGHT;
//			self.abslight=(self.weaponframe - $normal1)/15;
		}
		else if(self.weaponframe==$normal16)
		{
			// [2026-06-12] jsH2+ never strip a light the torch owns (AFL_TORCH): at $normal16 the
			// in-loop branch consumes lefty and the exit branches below re-test it in the SAME call.
			if(!self.lefty && !(self.artifact_flags&AFL_TORCH))
				self.effects(-)EF_BRIGHTLIGHT;
			else
				self.lefty=FALSE;
//			self.drawflags(-)MLS_ABSLIGHT;
//			self.abslight=0;
		}
	}
	self.th_weapon=lightning_fire_normal;
	self.last_attack=time;
	if(self.artifact_active&ART_TOMEOFPOWER)
	{
		if(self.effects&EF_BRIGHTLIGHT)
		{
			if(!self.lefty && !(self.artifact_flags&AFL_TORCH))	// [2026-06-12] jsH2+ torch owns the light
				self.effects(-)EF_BRIGHTLIGHT;
			else
				self.lefty=FALSE;
		}
		stopSound(self,CHAN_WEAPON);	// [2026-06-12] jsH2+ end the charge hum (tome flipped mid-charge)
		lightning_ready_power();
	}
	// [2026-06-12] jsH2+ charge-per-ball trigger (user design, matches the Tome mode's
	// release-anywhere rule): press starts the charge, holding to frame 12 looses the ball,
	// releasing any earlier cancels it (no ball, no mana). Held fire recovers (13-16),
	// wraps, and charges the next ball. Follow-through always plays to completion.
	else if(self.greenmana<6||
			self.bluemana<6||
			(!self.button0&&(self.weaponframe<$normal13 || self.weaponframe==$normal16))
			)
	{
		if(self.effects&EF_BRIGHTLIGHT)
		{
			if(!self.lefty && !(self.artifact_flags&AFL_TORCH))	// [2026-06-12] jsH2+ torch owns the light
				self.effects(-)EF_BRIGHTLIGHT;
			else
				self.lefty=FALSE;
		}
		stopSound(self,CHAN_WEAPON);	// [2026-06-12] jsH2+ end the charge hum (buzz2 has a loop marker)
		if (self.weaponframe > $normal1 && self.weaponframe < $normal12)
			lightning_close_normal();	// [2026-06-12] jsH2+ canceled mid-charge: anim reverses back to rest
		else
			lightning_ready_normal();
	}
	else if(self.weaponframe==$normal12)
	{
		if(self.attack_finished<time)
		{
			stopSound(self,CHAN_WEAPON);	// [2026-06-12] jsH2+ end the charge hum (buzz2 has a loop marker)
			FireLightningBall();	// [2026-06-12] jsH2+ plays its own firelbal.wav (vanilla doubled it
						// here on CHAN_WEAPON; that copy now plays at charge start instead)
			self.bluemana-=6;
			self.greenmana-=6;
			self.attack_finished=time+1;
			self.weaponframe=$normal13;
		}
	}
}

// [2026-06-12] jsH2+ cancel transition: reverse the charge anim back to the closed rest pose
// (paced like the charge). A re-press mid-close goes through Suc_Litn_Fire as usual and
// resumes the charge from the current frame - the guard there deliberately excludes this state.
void lightning_close_normal (void)
{
	self.th_weapon=lightning_close_normal;
	if(self.weaponframe_cnt < time)
	{
		self.weaponframe_cnt = time + 0.07;
		self.wfs = advanceweaponframe($normal11,$normal1);
		if (self.weaponframe == $normal1)
			lightning_ready_normal();
	}
}

void lightning_fire_power (void)
{
	self.wfs = advanceweaponframe($power1,$power16);
	self.th_weapon=lightning_fire_power;
	self.last_attack=time;
	if(!self.artifact_active&ART_TOMEOFPOWER)
		lightning_ready_normal();
	else if(self.greenmana<2||self.bluemana<2||!self.button0)
		lightning_ready_power();
	else
	{
		if(!self.weaponframe_cnt)
			shebitch_chain_lightning_strike();
		self.weaponframe_cnt+=1;
		if(self.weaponframe_cnt==4)
			self.weaponframe_cnt=0;
	}
}

void() Suc_Litn_Fire =
{
	// [2026-06-12] jsH2+ re-entry guard: W_WeaponFrame calls W_Attack EVERY frame while
	// button0 is down and attack_finished has elapsed, so this entry used to re-run per
	// frame during the charge - wiping weaponframe_cnt (the pacing timestamp) and
	// double-stepping the anim. Once the fire think chain owns the weapon, leave it alone.
	if(self.th_weapon==lightning_fire_normal||self.th_weapon==lightning_fire_power)
		return;
	self.weaponframe_cnt=FALSE;
	if(self.artifact_active&ART_TOMEOFPOWER)
		lightning_fire_power();
	else
		lightning_fire_normal();

	thinktime self : 0;
};


void lightning_ready_power (void)
{
	if(random()<=0.07)
	{
		self.weaponframe=$pidle1 + rint(random(15));
		sound(self,CHAN_WEAPON,"succubus/buzz.wav",1,ATTN_NORM);
		self.effects(+)EF_MUZZLEFLASH;
	}
	else
		self.weaponframe=$pidle1;
	//	self.wfs = advanceweaponframe($pidle1,$pidle16);
	self.th_weapon=lightning_ready_power;
	if(!self.artifact_active&ART_TOMEOFPOWER)
		lightning_ready_normal();
}

void lightning_ready_flip (void)
{
// [2026-06-12] jsH2+ paced: the idle spin flourish played one frame per 72Hz tick - a 0.2s
// blur nobody could see. Now ~1.1s, the way the spin was animated to read.
	self.th_weapon=lightning_ready_flip;
	if(self.weaponframe_cnt < time)
	{
		self.weaponframe_cnt = time + 0.07;
		self.wfs = advanceweaponframe($nidle1,$nidle16);
		if(self.wfs==WF_CYCLE_WRAPPED)
			lightning_ready_normal();
	}
}

void lightning_ready_normal (void)
{
// [2026-06-12] jsH2+ rest = vanilla $normal1 (the closed-rest experiment is retired - no
// truly closed frame exists in the model; see PROGS_TRACKER for the model-surgery option).
// The $nidle frames are the idle spin flourish, paced in lightning_ready_flip below.
	self.weaponframe=$normal1;
	self.th_weapon=lightning_ready_normal;
	if(self.artifact_active&ART_TOMEOFPOWER)
		lightning_ready_power();
	else if(random(1000)<1)
	{
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);
		lightning_ready_flip();
	}
}

void lightning_ready (void)
{
	if(self.artifact_active&ART_TOMEOFPOWER)
		lightning_ready_power();
	else
		lightning_ready_normal();
}

void lightning_select (void)
{
	self.wfs = advanceweaponframe($select1,$select12);
	self.weaponmodel = "models/sucwp4.mdl";
	self.th_weapon=lightning_select;
	if(self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		lightning_ready_flip();
//		lightning_ready();
	}
}

void lightning_deselect (void)
{
	stopSound(self,CHAN_WEAPON);	// [2026-06-12] jsH2+ weapon switched away mid-charge: end the hum
	if(!self.lefty && !(self.artifact_flags&AFL_TORCH))
		self.effects(-)EF_BRIGHTLIGHT;	// [2026-06-12] jsH2+ drop the charge light too (vanilla left its
						// light stale on a mid-fire weapon switch until the next staff use)
	self.wfs = advanceweaponframe($select12,$select1);
	self.th_weapon=lightning_deselect;
	if(self.wfs==WF_CYCLE_WRAPPED)
		W_SetCurrentAmmo();
}


/*
void lightning_deselect (void)
{
	if(self.artifact_active&ART_TOMEOFPOWER)
		lightning_power_deselect();
	else
		lightning_normal_deselect();
}
void lightning_to_power (void)
{
	self.wfs = advanceweaponframe(83,102);
	self.th_weapon=lightning_to_power;
	if(self.wfs==WF_CYCLE_WRAPPED)
		lightning_ready_power();
}

void lightning_to_normal (void)
{
	self.wfs = advanceweaponframe(191,210);
	self.th_weapon=lightning_to_normal;
	if(self.wfs==WF_CYCLE_WRAPPED)
		lightning_ready_normal();
}


void lightning_power_deselect (void)
{
	self.wfs = advanceweaponframe($select12,$select1);
	self.th_weapon=lightning_power_deselect;
	if(self.wfs==WF_CYCLE_WRAPPED)
		W_SetCurrentAmmo();
}

void lightning_select (void)
{
	if(self.artifact_active&ART_TOMEOFPOWER)
		lightning_power_select();
	else
		lightning_normal_select();
}

void lightning_power_select (void)
{
	self.wfs = advanceweaponframe(103,122);
	self.weaponmodel = "models/sucwp4.mdl";
	self.th_weapon=lightning_power_select;
	if(self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		lightning_ready_power();
	}
}
void lightning_jellyfingers_normal ()
{
	self.wfs = advanceweaponframe(21,50);
	self.th_weapon=lightning_jellyfingers_normal;
	if(self.wfs==WF_CYCLE_WRAPPED)
		if(self.artifact_active&ART_TOMEOFPOWER)
			lightning_ready_power();
		else
			lightning_ready_normal();
}

void lightning_jellyfingers_power ()
{
	self.wfs = advanceweaponframe(123,152);
	self.th_weapon=lightning_jellyfingers_power;
	if(self.wfs==WF_CYCLE_WRAPPED)
		if(self.artifact_active&ART_TOMEOFPOWER)
			lightning_ready_power();
		else
			lightning_ready_normal();
}
*/
