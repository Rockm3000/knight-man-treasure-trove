/// @description Insert description here
// You can write your code in this editor
selectionAnimCounter++;

var player = instance_nearest(x, y, oPlayer1);
var enemy = instance_nearest(x, y, oEnemy);
//Force the player to be still
if (player.currentState == "jumping" && !player.jumpKeyPressed)
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
enemy.currentState = (enemy.currentState == "crouching") ? "crouching" : "idle";

//Check for input
rightKeyPressed = keyboard_check_pressed(ord("D")) || (gamepad_axis_value(0,gp_axislh) > 0);
leftKeyPressed = keyboard_check_pressed(ord("A")) || (gamepad_axis_value(0,gp_axislh) < 0);
confirmKeyPressed = (keyboard_check_pressed(ord("K")) || keyboard_check_pressed(vk_space)) || (gamepad_button_check_pressed(0,gp_face1));

if (rightKeyPressed)
{
	selection++;
	if (selection > 1)
	{
		selection = 0;
	}
	audio_play_sound(sfxMenuCursorMove, 0, false);
}
else if (leftKeyPressed)
{
	selection--;
	if (selection < 0)
	{
		selection = 1;
	}
	audio_play_sound(sfxMenuCursorMove, 0, false);
}
else if (confirmKeyPressed)
{
	io_clear();
	if (selection == 0) //Player selected yes
	{
		global.armourType = 1;
		//Display crouching tooltip
		instance_create_layer(112, 72, "Instances", oArmorGetBox);
		audio_play_sound(sfxSkArmourGet, 0, false);
		instance_destroy();
	}
	else //player selected no
	{
		player.armourType = 0;
		newDialogue(["\\0knight man: no, no, terrible! no honor! no \\schivalry\\0! no matter!", "\\0knight man: it is time to decide with this fight which of us is a \\strue warrior\\0!"]);
		audio_play_sound(sfxMenuConfirm, 0, false);
		instance_destroy();
	}
}