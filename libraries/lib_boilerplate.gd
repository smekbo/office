extends Resource
class_name Boilerplate

## Returns the first CollisionShape3D volume that [param ray] collides with
static func get_ray_collider_shape(ray:RayCast3D):
	var object : CollisionObject3D = ray.get_collider()
	var shape_id = ray.get_collider_shape()
	return get_shape_from_id(object, shape_id)

## Returns the CollisionShape3D volume that matches the id [param shape_id] on [param object]
static func get_shape_from_id(object:CollisionObject3D, shape_id:int):
	var owner_id = object.shape_find_owner(shape_id)
	var shape = object.shape_owner_get_owner(owner_id)
	return shape
