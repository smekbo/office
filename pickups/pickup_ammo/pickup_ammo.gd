extends Pickup

@export_enum("Pistol","Shell","Rifle","Sniper","Explosive","Energy") var ammo_type : int = 0
@export_custom(PROPERTY_HINT_NONE, "suffix:rounds") var ammo_amount : int = 25

func _on_body_entered(body: Node3D) -> void:
	var _inventory : Array = body.get("weapon_inventory")
	var _weapons : Array = []
	var _used : bool = false
	
	#todo: make splitting properly split ammo when there's a remainder
	#ex: 2 weapons splitting 5 ammo, first should get 3 second should get 2
	for item : Weapon in _inventory:
		if item.ammo_type == ammo_type:
			_weapons.append(item)
	var ammo_split = ammo_amount / _weapons.size()
	for item in _weapons:
		_used = item.add_reserve(ammo_split)
	if _used: self.queue_free()
