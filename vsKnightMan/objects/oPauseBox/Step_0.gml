/// @description Insert description here
// You can write your code in this editor
downKeyPressed = keyboard_check_pressed(ord("S")) || (gamepad_axis_value(0,gp_axislv) > 0);
upKeyPressed = keyboard_check_pressed(ord("W")) || (gamepad_axis_value(0,gp_axislv) < 0);
confirmKeyPressed = (keyboard_check_pressed(ord("K")) || keyboard_check_pressed(vk_space)) || (gamepad_button_check_pressed(0,gp_face1));

var enemy = instance_nearest(x, y, oEnemy);
var player = instance_nearest(x, y, oPlayer1);
player.xspd = 0;
player.yspd = 0;
enemy.yspd = 0;
enemy.xspd = 0;
enemy.grav = 0;
enemy.idleCounter = 0;
enemy.runningCounter = 0;
enemy.swingingCounter = 0;
enemy.throwingCounter = 0;
enemy.blockingCounter = 0;
enemy.bashReadyCounter = 0;
enemy.replenishCounter = 0;
enemy.image_speed = 0;

cursorAnimCounter++; //Keep animating the cursor until a choice is made

if (titleSelected)
{
	image_alpha = 0;
	downKeyPressed = false;
	upKeyPressed = false;
	confirmKeyPressed = false;
	if (!instance_exists(oCurtainTransitionOutro))
	{
		room_goto(titleScreen);
	}
}
else if (instance_exists(oControlsBox))
{
	downKeyPressed = false;
	upKeyPressed = false;
	confirmKeyPressed = false;
}

if (image_index > 3 && image_index < 4 && !resumed)
{
	image_speed = 0;
	//Change selection based on inputs
	if (downKeyPressed)
	{
		selection++;
		if (selection == array_length(choices))
		{
			selection = 0;
		}
		audio_play_sound(sfxMenuCursorMove, 0, false);
	}
	else if (upKeyPressed)
	{
		selection--;
		if (selection == -1)
		{
			selection = array_length(choices) - 1;
		}
		audio_play_sound(sfxMenuCursorMove, 0, false);
	}
	else if (confirmKeyPressed)
	{
		switch(choices[selection])
		{
			case "resume":
				audio_play_sound(sfxBack, 0, false);
				image_speed = 1;
				resumed = true;
			break;
			case "controls":
				if (!instance_exists(oControlsBox))
				{
					instance_create_layer(112, 72, "Instances", oControlsBox);
					audio_play_sound(sfxMenuConfirm, 0, false);
				}
			break;
			case "back to title screen":
				instance_create_layer(0, 0, "Instances", oCurtainTransitionOutro);
				titleSelected = true;
				audio_play_sound(sfxMenuConfirm, 0, false);
			break;
			case "quit to desktop":
				audio_play_sound(sfxMenuConfirm, 0, false);
				game_end();
			break;
		}
	}
}
