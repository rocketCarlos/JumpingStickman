extends Node

enum actions {
	FRONT_KICK,
	SPIN_KICK,
	UPPERCUT,
	DOWNWARDS_PUNCH,
	JUMP
}

# seconds player must wait before entering another action after the previous failed
const FAIL_COOLDOWN = 1

# current combo that defeats the enemy
var enemy_combo = []

var defeated_enemies = 0

var combo = 0

signal game_start
signal game_end

# emitted by player when an action is executed
signal do_action(action: actions)
# emitted by player when an attack animation starts to make the arrow show progress
signal start_arrow
# emitted by mob when combo succeeds
signal combo_succeeded
# emitted by mob when combo fails
signal combo_failed
# emitted when a combo timesout
signal combo_timeout
# emitted when an enemy dies
signal enemy_died
# emitted when an enemy is spawned
signal new_enemy
# emitted to update the combo
signal combo_updated
# emitted to manage player defeated animation
signal player_defeated_animation
# emitted when enemy reaches the end of the world
signal world_limit
