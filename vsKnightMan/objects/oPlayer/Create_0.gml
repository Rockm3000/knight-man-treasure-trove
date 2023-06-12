/// @description Update on instance creation
// You can write your code in this editor
xspd = 0;
yspd = 0;

prevXSpd = 0;
prevYSpd = 0;
initMoveSpd = 1;
maxMoveSpd = 1.75;
jumpSpd = -8.5; //8.5 for roughly 4.5 tile jump height
grav = 0.5;
pogoing = false;
attackCounter = 0;
attackBuffered = false;

initMoveCounter = 0;
turnAroundCounter = 0; //8 frames to switch running direction
image_speed = 0;