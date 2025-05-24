extends Resource
class_name Behavior

@export var animation : Animation
@export var cooldown : int = 1
@export var reactions : Array[String]

## Occurs before the action takes place. Use this to modify behavior variables beforehand.
func pre_act():
	pass

## Performs the action defined by the behavior.
func act():
	pass

## Occurs after the actions. Use this for clean-up tasks.
func post_act():
	pass
