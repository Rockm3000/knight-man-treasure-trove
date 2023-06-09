/// @description Update every frame
// You can write your code in this editor
rightKey = keyboard_check(ord("D")) || (gamepad_axis_value(0,gp_axislh) > 0);
leftKey = keyboard_check(ord("A")) || (gamepad_axis_value(0,gp_axislh) < 0);
downKey = keyboard_check(ord("S")) || (gamepad_axis_value(0,gp_axislv) > 0);
jumpKeyPressed =  (keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("K"))) || (gamepad_button_check_pressed(0,gp_face1));
jumpKeyHeld = (keyboard_check(vk_space) || keyboard_check(ord("K"))) || (gamepad_button_check(0,gp_face1));
attackKeyPressed = keyboard_check_pressed(ord("J")) || (gamepad_button_check_pressed(0,gp_face2));
pauseKeyPressed = keyboard_check_pressed(vk_enter) || (gamepad_button_check_pressed(0,gp_start));

prevXSpd = xspd;
prevYSpd = yspd;
//Moving
var moveDir = (rightKey - leftKey);
if (rightKey && leftKey)
{
	moveDir = -1;
}
if (moveDir == 0)
{
	runningInitCounter = 0;
}
if (currentState != "stunned" && currentState != "dying" && currentState != "dead" && !grounded && !paused)
{
	xspd = moveDir * runningSpeed;
}

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
}

if (place_meeting(x + xspd, y + ceil(yspd), oSolid))
{
	y = round(y);
	var _pixelCheck = sign(yspd);
	while !place_meeting(x + xspd, y + _pixelCheck, oSolid)
	{
		y += _pixelCheck;
	}
	grounded = true;
	yspd = 0;
	if (currentState == "stunned" && !bashed)
	{
		invulnerableCounter++;
	}
	bashed = false;
}
else
{
	grounded = false;
}
if (prevYSpd > 0 && grounded)
{
	attackCounter = 0;
	attackBuffered = false;
	landed = true;
	audio_play_sound(sfxSkLand, 0, false);
}
else
{
	landed = false;
}

if (yspd == jumpSpd + grav && currentState != "pogoing")
{
	audio_play_sound(sfxSkJump, 0, false);
}

//Apply movement
x += xspd;
y += yspd;

//Determine state from inputs
if (!instance_exists(oEnemy)) //Force player to run right in intro
{
	if (x < 80)
	{
		x += 1.75;
		moveDir = 0;
		currentState = "running";
	}
	else
	{
		var enemy = instance_create_layer(300, 0, "Instances", oEnemy);
		enemy.currentState = "teleportingIn";
	}
}
else if (currentState == "dead")
{
	turningCounter = 0;
	attackCounter = 0;
	attackBuffered = false;
	currentState = "dead";
}
else if (currentState == "victory")
{
	turningCounter = 0;
	attackCounter = 0;
	attackBuffered = false;
	currentState = "victory";
}
else if (currentState == "armorGet")
{
	xspd = 0;
	currentState = "armorGet";
}
else if (currentHealth == 0 && grounded)
{
	turningCounter = 0;
	attackCounter = 0;
	attackBuffered = false;
	currentState = "dying";
}
else if ((pauseKeyPressed && !instance_exists(oPauseBox)) && !instance_exists(oDialogueBox) && !instance_exists(oChoiceBox) || paused)
{
	if (!instance_exists(oPauseBox))
	{
		instance_create_layer(112, 72, "Instances", oPauseBox);
		paused = true;
	}
	xspd = 0;
	yspd = 0;
	grav = 0;
	moveDir = 0;
	image_speed = 0;
}
else if (currentState == "stunned" && !grounded)
{
	turningCounter = 0;
	attackCounter = 0;
	attackBuffered = false;
	currentState = "stunned";
}
else if ((grounded && jumpKeyPressed) || (!grounded && !attackKeyPressed && attackCounter == 0 && !attackBuffered && currentState != "pogoing" && !downKey))
{
	if (grounded && jumpKeyPressed)
	{
		turningCounter = 0;
		attackCounter = 0;
		attackBuffered = false;
	}
	currentState = "jumping";
}
else if (attackKeyPressed || attackBuffered || attackCounter > 0)
{
	turningCounter = 0;
	currentState = "attacking";
}
else if (!grounded && (currentState == "pogoing" || downKey))
{
	currentState = "pogoing";
}
else if (((currentState == "turning") || grounded && ((xspd < 0 && rightKey && !leftKey) || (xspd > 0 && leftKey))) && !instance_exists(oDialogueBox))
{
	currentState = "turning";
}
else if (grounded && (leftKey || rightKey))
{
	currentState = "running";
}
else if (grounded && downKey)
{
	currentState = "crouching";
}
else
{
	currentState = "idle";
}

//Run state logic
switch (currentState)
{
	case "idle":
		xspd = 0;
	break;
	case "crouching":
		xspd = 0;
	break;
	case "running":
		if (runningInitCounter < 5 && abs(xspd) != runningSpeed)
		{
			runningInitCounter++;
			xspd = moveDir * runningInitSpeed;
		}
		else if (runningInitCounter == 5)
		{
			xspd = moveDir * runningSpeed;
		}
		
	break;
	case "turning":
		if (turningCounter < 8)
		{
			turningCounter++
			if (turningCounter < 4)
			{
				xspd = prevXSpd;
			}
			else
			{
				xspd = 0;
			}
		}
		else
		{
			turningCounter = 0;
			runningInitCounter = 5;
			currentState = "running";
		}
		
	break;
	case "jumping":
		if (grounded)
		{
			yspd = jumpSpd;
		}
		if (yspd < 0 && !jumpKeyHeld)
		{
			yspd = max(yspd, yspd * (3/4));
		}
	break;
	case "attacking":
		if (grounded)
		{
			xspd = 0;
		}
		if (attackCounter = 0 && attackBuffered)
		{
			attackBuffered = false;
		}
		if (attackCounter < 16)
		{
			attackCounter++;
			if (attackCounter == 4)
			{
				instance_create_layer(x + (image_xscale * 25), y - 16, "Instances", oPlayerAttackHitbox);
				if (sprite_index == sPlayerAttack || sprite_index == sPlayerAttackAlt)
				{
					audio_play_sound(sfxSkAttack, 0, false);
				}
			}
			if (attackKeyPressed && attackCounter > 6)
			{
				attackBuffered = true;
			}
		}
		if (attackCounter == 16)
		{
			attackCounter = 0;
		}
		
	break;
	case "pogoing":
		if (pogoDelay > 0 && pogoDelay < 12)
		{
			pogoDelay++;
		}
		else
		{
			pogoDelay = 0;
		}
	break;
	case "stunned":
		xspd = -image_xscale * 2;
	break;
	case "dying":
		if (landed) //So it only plays once
		{
			audio_play_sound(sfxSkDying, 0, false);
		}
		invulnerableCounter = 0; //So player doesn't flash while dying
		xspd = 0;
		yspd = 0;
	break;
	case "dead":
		deathTransCounter++;
		xspd = 0;
		yspd = 0;
		if (deathTransCounter == 60)
		{
			instance_create_layer(400, 0, "Instances", oDeathTransition);
		}
		
	break;
	case "victory":
		if (victoryCounter == 0)
		{
			audio_play_sound(sfxVictory, 0, false);
		}
		victoryCounter++;
		xspd = 0;
		yspd = 0;
		if (!audio_is_playing(sfxVictory))
		{
			currentState = "idle";
		}
	break;
}
if (invulnerableCounter > 0 && invulnerableCounter < 120)
{
	invulnerableCounter++;
}
else
{
	invulnerableCounter = 0;
}