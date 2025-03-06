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

# emmited by player when an action is executed
signal do_action(action: actions)
# emitted by mob when combo succeeds
signal combo_succeeded
# emmited by mob when combo fails
signal combo_failed
# emmited when an enemy dies
signal enemy_died
# emmited when an enemy is spawned
signal new_enemy
