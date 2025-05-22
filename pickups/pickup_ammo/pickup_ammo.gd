extends Pickup

@export_enum("Pistol","Shell","Rifle","Sniper","Explosive","Energy") var ammo_type : int = 0
@export_custom(PROPERTY_HINT_NONE, "suffix:rounds") var ammo_amount : int = 25

func _on_body_entered(body: Node3D) -> void:
	var _used : bool = false
	if _used: self.queue_free()
