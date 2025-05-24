extends Area3D
class_name ComponentUsable

## Adds context-sensitive "usability" to this object. This allows the player to press a "use" button and do a thing.

## How long you have to wait between uses.
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var cooldown : float = 1
var cooldown_timer : float = 0

## This object was used. Should be linked to a function on the parent object that does an action when used.
signal used(user)

func _physics_process(delta: float) -> void:
	cooldown_timer = max(0, cooldown_timer - delta)

## This function is called when the user successfully uses a usable (what a mouthful)
func use(user = null):
	if cooldown_timer <= 0:
		used.emit(user)
		cooldown_timer = cooldown
