extends Node

enum actions {
	FRONT_KICK,
	SPIN_KICK,
	UPPERCUT,
	DOWNWARDS_PUNCH,
}

# current combo that defeats the enemy
#var enemy_combo: Array[actions]
var enemy_combo = [actions.FRONT_KICK, actions.FRONT_KICK, actions.SPIN_KICK]

# emitted by player when combo succeeds, recieved by enemy to die
signal combo_succeeded
