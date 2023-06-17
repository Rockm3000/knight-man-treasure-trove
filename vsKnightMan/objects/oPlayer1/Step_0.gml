/// @description Update every frame
// You can write your code in this editor
rightKey = keyboard_check(ord("D"));
leftKey = keyboard_check(ord("A"));
downKey = keyboard_check(ord("S"));
jumpKeyPressed = keyboard_check_pressed(vk_space);
jumpKeyHeld = keyboard_check(vk_space);
attackKeyPressed = keyboard_check_pressed(ord("J"));

prevXSpd = xspd;
prevYSpd = yspd;

//Moving
var moveDir = (rightKey - leftKey);
if (rightKey && leftKey)
{
	moveDir = -1;
}
if (currentState != "stunned" && currentState != "dying" && currentState != "dead" && !grounded)
{
	xspd = moveDir * runningSpeed;
}

//Apply gravity
yspd += grav;

//Collision checking
if (place_meeting(x + sign(xspd) + xspd, y, oSolid))
{
	x = round(x);
	var _pixelCheck = sign(xspd);
	while !place_meeting(x + _pixelCheck, y, oSolid)
	{
		x += _pixelCheck;
	}
	xspd = 0;
}

if (place_meeting(x + xspd, y + sign(yspd) + yspd, oSolid))
{
	y = round(y);
	var _pixelCheck = sign(yspd);
	while !place_meeting(x + xspd, y + _pixelCheck, oSolid)
	{
		y += _pixelCheck;
	}
	grounded = true;
	yspd = 0;
	if (currentState == "stunned")
	{
		invulnerableCounter++;
	}
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
}
else
{
	landed = false;
}

//Apply movement
x += xspd;
y += yspd;

//Determine state from inputs
if (currentState == "dead")
{
	turningCounter = 0;
	attackCounter = 0;
	attackBuffered = false;
	currentState = "dead";
}
else if (currentState = "dying")
{
	turningCounter = 0;
	attackCounter = 0;
	attackBuffered = false;
	currentState = "dying";
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
else if ((currentState == "turning") || grounded && ((xspd < 0 && rightKey && !leftKey) || (xspd > 0 && leftKey)))
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
//currentState = nextState;
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
			runningInitCounter = 0;
			xspd = moveDir * runningSpeed;
		}
		if (sign(prevXSpd) == -sign(xspd) && abs(prevXSpd) == runningSpeed)
		{
			currentState = "turning";
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
	break;
	case "stunned":
		xspd = -image_xscale * 2;
	break;
	case "dying":
	break;
	case "dead":
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