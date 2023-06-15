/// @description Update on instance creation
// You can write your code in this editor
xspd = 0;
yspd = 0;

currentHealth = 8;
maxHealth = currentHealth;

gold = 0;

prevXSpd = 0;
prevYSpd = 0;
initMoveSpd = 1;
maxMoveSpd = 1.75;
jumpSpd = -6.5;
grav = 0.3;
pogoing = false;
attackCounter = 0;
attackBuffered = false;
stunned = false;
invulnerableCounter = 0;

deathCounter = 0; //Counts to 60, then does the death transition
deathTransitionXPos = 400;
resetCounter = 0; //Counts to 180, then does the "revive" transition

initMoveCounter = 0;
turnAroundCounter = 0; //8 frames to switch running direction
image_speed = 0;

//Font stuff
shovelFont = font_add("shovel-knight-extended.ttf", 6, false, false, 32, 128);
draw_set_font(shovelFont);
//draw_set_color(#FFFFFF);
//draw_set_alpha(1);
//draw_set_halign(fa_center);
//draw_set_valign(fa_middle);