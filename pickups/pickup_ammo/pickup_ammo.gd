extends Pickup

@export_enum("Pistol","Shell","Rifle","Sniper","Explosive","Energy") var ammo_type : int = 0
@export_custom(PROPERTY_HINT_NONE, "suffix:rounds") var ammo_amount : int = 25

func _on_body_entered(body: Node3D) -> void:
	var _inventory : Array = body.get("weapon_inventory")
	var _weapons : Array = []
	var _used : bool = false
	
	# get all weapons in inventory that use this ammo type
	for item : Weapon in _inventory:
		if item.ammo_type == ammo_type && item.reserve != item.reserve_max:
			_weapons.append(item)
	
	if not _weapons.is_empty():
		# calc split + remainder
		@warning_ignore("integer_division") var ammo_split = ammo_amount / _weapons.size()
		var ammo_remainder = ammo_amount % _weapons.size()
		
		# add ammo to all relevant weapons, respecting basic remainder rule
		for item : Weapon in _weapons:
			var _split = ammo_split
			if ammo_remainder > 0:
				_split += 1
				ammo_remainder -= 1
			_used = item.add_reserve(_split)
	if _used: self.queue_free()
