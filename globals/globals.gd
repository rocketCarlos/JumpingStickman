extends Node

enum actions {
	FRONT_KICK,
	SPIN_KICK,
	UPPERCUT,
	DOWNWARDS_PUNCH,
	JUMP
}

# current combo that defeats the enemy
var enemy_combo = []

var defeated_enemies = 0

# emitted by player when combo succeeds
signal combo_succeeded
# emmited when an enemy dies
signal enemy_died
