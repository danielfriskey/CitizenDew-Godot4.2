extends Node2D

@onready var area: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var shield_drawer: Node2D = $AnimatedSprite2D/Shields

@onready var status: String = get_meta("status")
@onready var planet_name: String = get_meta("name")
@onready var shield_strength: int = get_meta("shield_strength")
@onready var shield_color = null
@onready var number_of_shields = int(shield_strength / 20)

func _ready():
	sprite.play()
	sprite.scale = Vector2(Global.PLANET_SCALE_FACTOR, Global.PLANET_SCALE_FACTOR)
	
	queue_redraw()
	randomize()
	
	var shape = collision_shape.shape
	if shape is CircleShape2D:
		shape.radius = Global.PLANET_SPRITE_SIZE * Global.PLANET_SCALE_FACTOR / 2
	elif shape is RectangleShape2D:
		shape.extents = Vector2(Global.PLANET_SPRITE_SIZE * Global.PLANET_SCALE_FACTOR / 2, Global.PLANET_SPRITE_SIZE * Global.PLANET_SCALE_FACTOR / 2)

	area.body_entered.connect(_on_area_2d_body_entered)
	area.input_event.connect(_on_area_2d_input_event)
	
	shield_drawer.z_index = 10  # Ensure shield_drawer is drawn on top

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		# Handle collision with player
		pass

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and Input.is_action_just_pressed('left_click'):
		var player = get_tree().get_root().get_node("Game/Space/PlayerShip")
		if player:
			player.move_to_planet(self.global_position, self)

func _draw():
	if status == "friendly":
		shield_color = Color(0, 1, 0) # GREEN
	elif status == "neutral":
		shield_color = Color(1, 1, 0) # YELLOW
	elif status == "hostile":
		shield_color = Color(1, 0, 0) # RED
	
	if number_of_shields > 0:
		for i in range(number_of_shields):
			var shape = collision_shape.shape
			var rect_position = Vector2()
			var rect_size = Vector2()

			if shape is CircleShape2D:
				var radius = shape.radius
				rect_position = Vector2(-radius, -radius)
				rect_size = Vector2(radius * 2, radius * 2)
			elif shape is RectangleShape2D:
				var extents = shape.extents
				rect_position = -extents
				rect_size = extents * 2
			
			# Generate a random offset
			var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
			rect_position += offset

			var rect = Rect2(rect_position, rect_size)
			# Draw the rectangle with the offset
			draw_rect(rect, shield_color, false)
