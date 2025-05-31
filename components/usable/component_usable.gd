extends Area3D
class_name ComponentUsable

## Adds context-sensitive "usability" to this object. This allows the player to press a "use" button and do a thing.

## How long you have to wait between uses.
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var cooldown : float = 1
var cooldown_timer : float = 0
@onready var sfx_player : AudioStreamPlayer3D = $AudioStreamPlayer3D
@export_category("Sounds")
@export var attempt_sound : AudioStream = null
@export var use_sound : AudioStream = null
@export var fail_sound : AudioStream = null


## This object was attempted to be used. Should be linked to a conditional on the parent object that calls use() when successful.
signal attempted(user, component)
## This object was used. Should be linked to a function on the parent object that does an action when used.
signal used(user, component)
## This object use attempt failed. Should be linked to a function on the parent object that
signal failed(user, component)

func _ready() -> void:
	Warnings.placeholder_warning(owner, attempt_sound)
	Warnings.placeholder_warning(owner, use_sound)
	Warnings.placeholder_warning(owner, fail_sound)

func _physics_process(delta: float) -> void:
	cooldown_timer = max(0, cooldown_timer - delta)

## This function is called when the user attempts to use something. 
## It should link to a conditional check that then uses the use() or fail() functions as necessary.
func attempt(user = null, usable = self):
	_play_sfx(attempt_sound)
	if cooldown_timer <= 0:
		attempted.emit(user, usable)

## This function is called when the user successfully uses a usable (what a mouthful)
func use(user = null, usable = self):
	used.emit(user, usable)
	_play_sfx(use_sound)
	cooldown_timer = cooldown

func fail(user = null, usable = self):
	_play_sfx(fail_sound)
	failed.emit(user, usable)

func _play_sfx(sfx : AudioStream = null):
	if sfx:
		sfx_player.set_stream(sfx)
		sfx_player.play()
