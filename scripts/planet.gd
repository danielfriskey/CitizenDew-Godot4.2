extends Node2D

@export var planet_type: String = ""
@export var planet_name: String = ""
@export var planet_id: int = 0

@onready var area: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

func _ready():
	sprite.play()
	sprite.scale = Vector2(Global.PLANET_SCALE_FACTOR, Global.PLANET_SCALE_FACTOR)

	var shape = collision_shape.shape
	if shape is CircleShape2D:
		shape.radius = Global.PLANET_SPRITE_SIZE * Global.PLANET_SCALE_FACTOR / 2
	elif shape is RectangleShape2D:
		shape.extents = Vector2(Global.PLANET_SPRITE_SIZE * Global.PLANET_SCALE_FACTOR / 2, Global.PLANET_SPRITE_SIZE * Global.PLANET_SCALE_FACTOR / 2)

	area.body_entered.connect(_on_area_2d_body_entered)
	area.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		# Handle collision with player
		pass

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and Input.is_action_just_pressed('left_click'):
		var player = get_tree().get_root().get_node("Game/Space/PlayerShip")
		if player:
			player.move_to_planet(self.global_position, self)
