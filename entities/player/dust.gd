extends Node3D

@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite3D = $Sprite3D

func emit():
	animation.play("emit")

func set_texture(texture : CompressedTexture2D):
	sprite.texture = texture
