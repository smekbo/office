extends Node

signal heard(location: Vector3)

@onready var hearing_area = $Hearing

func _ready():
	pass
	
func heard_sound(location: Vector3):
	emit_signal("heard", location)

func _on_hearing_area_entered(area):
	area.connect("sound_made", heard_sound)
	pass # Replace with function body.

func _on_hearing_area_exited(area):
	area.disconnect("sound_made", heard_sound)
	pass # Replace with function body.
