/// @description Insert description here
// You can write your code in this editor
var player = instance_nearest(x, y, oPlayer1);

prevYSpd = yspd;

//Apply gravity
yspd += grav;

//Collision checking
if (place_meeting(x + xspd, y, oSolid))
{
	x = round(x);
	var _pixelCheck = sign(xspd);
	while !place_meeting(x + _pixelCheck, y, oSolid)
	{
		x += _pixelCheck;
	}
	xspd = 0;
	walled = true;
}
else
{
	walled = false;
}

if (place_meeting(x + xspd, y + ceil(yspd), oSolid))
{
	y = round(y);
	var _pixelCheck = sign(yspd);
	while !place_meeting(x + xspd, y + _pixelCheck, oSolid)
	{
		y += _pixelCheck;
	}
	if (place_meeting(x, y + 1, oSolid))
	{
		grounded = true;
		if (prevYSpd > 0 && currentState == "jumping")
		{
			audio_play_sound(sfxKmLand, 0, false);
		}
	}
	yspd = 0;
}
else
{
	grounded = false;
}

//Apply movement
x += xspd;
y += yspd;

//Player collision checking
if (player.currentState == "pogoing" && place_meeting(x, y - 1, oPlayer1) && currentState != "swinging" && currentState != "dying" && currentState != "teleportingOut" && currentState != "crouching")
{
	player.yspd = player.jumpSpd;
	if (player.pogoDelay == 0)
	{
		if (currentState == "blockingUp")
		{
			audio_play_sound(sfxSkPogoShield, 0, false);
		}
		else
		{
			audio_play_sound(sfxSkPogoReg, 0, false);
		}
	}
	if (currentState != "replenishing" && currentState != "blockingUp" && player.pogoDelay == 0)
	{
		currentHealth--;
		hitCounter = 1;
		player.pogoDelay++;
		audio_play_sound(sfxKmHurt, 0, false);
	}
}
else if (currentState != "dying" && currentState != "teleportingOut" && currentState != "crouching" && player.currentState != "dead" && player.currentState != "dying" && player.currentState != "stunned" && player.invulnerableCounter == 0 && (place_meeting(x + xspd, y, oPlayer1) || place_meeting(x + xspd, y + yspd, oPlayer1)))
{
	player.yspd = -3;
	if ((currentState == "bashing" || currentState == "running") && player.currentState == "crouching" && global.armourType == 1 && player.image_xscale != image_xscale)
	{
		bashStarted = false;
		currentState = "bashReady";
		player.bashed = true;
		audio_play_sound(sfxSkShieldBreak, 0, false);
	}
	else
	{
		player.currentHealth--;
		if (player.currentHealth == 0)
		{
			player.yspd = -5;
			audio_stop_sound(musFight);
			instance_destroy(oMusicFight);
		}
		audio_play_sound(sfxSkHurt, 0, false);
	}
	player.currentState = "stunned";
}
if (hitCounter > 0 && hitCounter < 30)
{
	hitCounter++;
}
else
{
	hitCounter = 0;
}

//Do stuff based on current state
switch (currentState)
{
	case "idle":
		image_xscale = sign(player.x - x)
		if (image_xscale == 0)
		{
			image_xscale = 1;
		}
		idleCounter++;
		xspd = 0;
		if (player.x > x - 32 && player.x < x + 32 && player.y < y)
		{
			idleCounter = 0;
			currentState = "blockingUp"
		}
		else if (player.grounded && grounded && ((player.x > x - 80 && player.x < x) || (player.x < x + 80 && player.x > x)))
		{
			idleCounter = 0;
			currentState = "blockingSide"
		}
		else if (idleCounter == 60)
		{
			idleCounter = 0;
			currentState = "running";
		}
	break;
	case "running":
		runningCounter++;
		if (instance_exists(oPlayerAttackHitbox) && place_meeting(x, y, oPlayerAttackHitbox))
		{
			runningCounter = 0;
			currentState = "bashReady";
		}
		else if ((player.currentState == "pogoing" && place_meeting(x, y - 1, oPlayer1)) || player.x > x - 8 && player.x < x + 8)
		{
			runningCounter = 0;
			currentState = "swinging";
		}
		else if (runningCounter == 120)
		{
			runningCounter = 0;
			currentState = "throwing";
		}
		else if (player.jumpKeyPressed)
		{
			runningCounter = 0;
			currentState = choose("jumping", "bashReady");
		}
		else
		{
			xspd = 2 * sign(player.x - x);
		}
	break;
	case "jumping":
		if (grounded && jumpNum < round(random_range(1, 4)))
		{
			jumpNum++;
			yspd = -8;
			xspd = (player.x - x)/48; //1.5 * sign(player.x - x)
			audio_play_sound(sfxKmJump, 0, false);
		}
		else if (grounded)
		{
			jumpNum = 0;
			currentState = "idle";
		}
	break;
	case "swinging":
		swingingCounter++;
		xspd = 0;
		if (player.currentState != "stunned" && player.invulnerableCounter == 0 && (place_meeting(x + xspd, y, oPlayer1) || place_meeting(x + xspd, y + yspd, oPlayer1)))
		{
			swingingCounter = 0;
			currentState = "idle";
		}
		else if (swingingCounter == 60)
		{
			swingingCounter = 0;
			currentState = "throwing";
		}
	break;
	case "throwing":
		throwingCounter++;
		if (throwingCounter == 4)
		{
			instance_create_layer(x + (image_xscale * 40), y, "Instances", oEnemyAttackHitbox);
			audio_play_sound(sfxKmKnightCrusher, 0, false);
		}
		else if (throwingCounter == 20)
		{
			audio_play_sound(sfxKmPull, 0, false);
		}
		xspd = 0;
	break;
	case "bashReady":
		image_xscale = sign(player.x - x);
		if (image_xscale == 0)
		{
			image_xscale = 1;
		}
		xspd = 0;
		bashReadyCounter++;
		if (bashReadyCounter == 30)
		{
			bashReadyCounter = 0;
			instance_create_layer(x - (16 * image_xscale), y, "Instances", oEnemyDashEffect);
			audio_play_sound(sfxKmDash, 0, false);
			currentState = "bashing";
		}
	break;
	case "bashing":
		if (!bashStarted)
		{
			bashStarted = true;
			xspd = 6 * sign(player.x - x);
		}
		else if (walled && bashStarted)
		{
			bashStarted = false;
			currentState = "idle";
		}
	break;
	case "blockingUp":
		blockingCounter++;
		if (player.currentState == "pogoing" && place_meeting(x, y - 1, oPlayer1))
		{
			blockingCounter = 0;
			currentState = "swinging";
		}
		else if ((instance_exists(oPlayerAttackHitbox) && place_meeting(x, y, oPlayerAttackHitbox)) || blockingCounter == 120)
		{
			blockingCounter = 0;
			currentState = "jumping";
		}
	break;
	case "blockingSide":
		blockingCounter++;
		image_xscale = sign(player.x - x);
		if (image_xscale == 0)
		{
			image_xscale = 1;
		}
		if (player.attackCounter == 5)
		{
			blockingCounter = 0;
			currentState = "bashReady";
		}
		else if (player.currentState == "pogoing" && place_meeting(x, y, oPlayer1))
		{
			blockingCounter = 0;
			currentState = "swinging";
		}
		else if (blockingCounter == 120)
		{
			blockingCounter = 0;
			currentState = "jumping";
		}
	break;
	case "replenishing":
		xspd = 0;
		replenishCounter++;
		image_xscale = sign(player.x - x);
		if (image_xscale == 0)
		{
			image_xscale = 1;
		}
		if (currentHealth < 20 && replenishCounter >= 3 && ((image_index >= 4 && sprite_index = sEnemyReplenish) || (sprite_index == sEnemyIdle)))
		{
			currentHealth++;
			replenishCounter = 0;
			if (currentHealth % 2 == 0)
			{
				audio_play_sound(sfxKmHealthFill, 0, false);
			}
		}
		if (replenishedNum == 0)
		{			
			player.xspd = 0;
			player.yspd = 0;
			player.currentState = (player.currentState == "crouching") ? "crouching" : "idle";
		}
	break;
	case "dying":
		if (!deathLaunched)
		{
			deathLaunched = true;
			xspd = 2 * image_xscale; //image_xscale gets set in previous step, negativity depends on placement of check for death
			yspd = -7;
			audio_play_sound(sfxKmDying, 0, false);
		}
		else if (grounded && deathLaunched)
		{
			xspd = 0;
			currentState = "crouching";
		}
		
	break;
	case "crouching":
		image_xscale = sign(player.x - x)
		if (image_xscale == 0)
		{
			image_xscale = 1;
		}
		if (player.grounded && !instance_exists(oDialogueBox) && player.victoryCounter < 500)
		{
			victoryDelay++;
			if (victoryDelay >= 30)
			{
				player.currentState = "victory";
			}
		}
		else if (!audio_is_playing(sfxVictory) && player.grounded)
		{
			if (!instance_exists(oDialogueBox))
			{
				newDialogue(["\\0knight man: \\wgaaah... \\0i am ashamed. i never thought i'd lose in this way.", "\\0shovel knight: you fought well, but i am not the one you seek!", "\\0shovel knight: i am shovel knight, on my quest to defeat the enchantress.", "\\0knight man: ...forgive me, shovel knight. i am knight man, on my quest to find a \\scerulean coward\\0!", "\\0shovel knight: all is forgiven, as a knight of the code of shovelry! i wish you well in your search, fellow knight.", "\\0knight man: likewise. for chivalry!", "\\0shovel knight: for shovelry!"]);
			}
		}
		
		//Force the player to be still
		if (player.currentState == "jumping" && !player.grounded)
		{
			player.currentState = "jumping"; //Let the player fall if they are still in the air
		}
		else if (player.currentState == "pogoing")
		{
			player.currentState = "pogoing"; //Let the player fall if they are still in the air
		}
		else if (player.currentState == "crouching")
		{
			player.currentState = "crouching"; //Allow crouching
			player.xspd = 0;
			player.yspd = 0;
		}
		else if (player.currentState == "victory" && player.victoryCounter < 500)
		{
			player.currentState = "victory"; //Allow victory
		}
		else
		{
			player.currentState = "idle"; //Be still
			player.xspd = 0;
			player.yspd = 0;
		}
	break;
	case "teleportingIn":
		if (!grounded)
		{
			yspd = 5;
		}
		else
		{
			yspd = 0;
		}
		io_clear();
		//Force the player to be still
		if (player.currentState == "jumping" && !player.grounded)
		{
			player.currentState = "jumping"; //Let the player fall if they are still in the air
		}
		else if (player.currentState == "pogoing")
		{
			player.currentState = "pogoing"; //Let the player fall if they are still in the air
		}
		else if (player.currentState == "crouching")
		{
			player.currentState = "crouching"; //Allow crouching
			player.xspd = 0;
			player.yspd = 0;
		}
		else
		{
			player.currentState = "idle"; //Be still
			player.xspd = 0;
			player.yspd = 0;
		}
	break;
	case "teleportingOut":
		yspd = 0;
		if (y > 0)
		{
			//Force the player to be still
			if (player.currentState == "jumping" && !player.grounded)
			{
				player.currentState = "jumping"; //Let the player fall if they are still in the air
			}
			else if (player.currentState == "pogoing" && !player.grounded)
			{
				player.currentState = "pogoing"; //Let the player fall if they are still in the air
			}
			else if (player.currentState == "crouching")
			{
				player.currentState = "crouching"; //Allow crouching
				player.xspd = 0;
				player.yspd = 0;
			}
			else
			{
				player.currentState = "idle"; //Be still
				player.xspd = 0;
				player.yspd = 0;
			}
		}
		else if (y <= 0 && player.currentState != "idle" && !replenished && player.x > 96)
		{
			playerMoved = true;
			currentState = "teleportingIn";
		}
		else if (y <= 0 && replenished)
		{
			instance_create_layer(0, 0, "Instances", oVictoryTransition);
		}
	break;
}
if (currentHealth == 0 && !deathLaunched && replenished)
{
	currentState = "dying";
	image_index = 0;
	audio_stop_sound(sfxKmPull);
	audio_stop_sound(musFight);
	instance_destroy(oMusicFight);
}
if (currentHealth <= 6 && grounded && !replenished && currentState != "replenishing" && currentState != "bashing" && currentState != "bashReady" && currentState != "jumping" && currentState != "teleportingIn" && currentState != "teleportingOut" && !instance_exists(oDialogueBox))
{
	audio_stop_sound(sfxKmPull);
	idleCounter = 0;
	runningCounter = 0;
	swingingCounter = 0;
	throwingCounter = 0;
	blockingCounter = 0;
	bashReadyCounter = 0;
	jumpNum = 0;
	bashStarted = false;
	currentState = "replenishing";
	image_index = 0;
}