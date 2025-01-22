extends Node

enum actions {
	FRONT_KICK,
	SPIN_KICK,
	UPPERCUT,
	DOWNWARDS_PUNCH,
}

# current combo that defeats the enemy
var enemy_combo = []

var defeated_enemies = 0

# emitted by player when combo succeeds, recieved by enemy to die
signal combo_succeeded
