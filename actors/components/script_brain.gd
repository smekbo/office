extends Resource
class_name Brain

const STATE_IDLE = 0
const STATE_MOVE = 1
const STATE_ACT = 2
const STATE_STUN = 3

var queue : Array
var state : int

@export var behaviors : Array[Resource]

## Use to make the AI "think"; that is, decide on the next course of action.
## Typically whatever you put in here should alter the [param queue] based on whatever conditions you desire.
func think():
	pass

## Adds a behavior to the queue.
## This is technically a "new" object of the specified template Behavior, as altering the existing behavior would change it for everyone!
func plan(behavior):
	pass

## Interrupts the current behavior and immediately begins acting on a new one. Also clears the queue.
func interrupt():
	_clear()
	pass

## Helper function to clear the queue array.
func _clear():
	queue.clear()
