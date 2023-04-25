extends Camera3D

var mouseDelta : Vector2 = Vector2()
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 10.0

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta

	rotation_degrees.x = clamp(rotation_degrees.x, minLookAngle, maxLookAngle)

	# rotate the player along their y-axis
	rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
	
	mouseDelta = Vector2()
