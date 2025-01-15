extends Node

enum actions {
	FRONT_KICK,
	SPIN_KICK,
	UPPERCUT,
	DOWNWARDS_PUNCH,
}

# current combo that defeats the enemy
#var enemy_combo: Array[actions]
var enemy_combo: Array[actions] = [actions.FRONT_KICK, actions.FRONT_KICK, actions.SPIN_KICK]
