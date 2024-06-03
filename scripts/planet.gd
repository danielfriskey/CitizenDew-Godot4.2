extends Node2D

@onready var PlanetBoundary: Area2D = $PlanetBoundary
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $PlanetBoundary/CollisionShape2D
@onready var shield_drawer: Node2D = $AnimatedSprite2D/Shields

@onready var alignment_label: Label = $AnimatedSprite2D/Control/HBoxContainer/VBoxContainer/AlignmentLabel
@onready var planetname_label: Label = $AnimatedSprite2D/Control/HBoxContainer/VBoxContainer/PlanetNameLabel
@onready var shieldstrength_label: Label = $AnimatedSprite2D/Control/HBoxContainer/VBoxContainer/ShieldStrengthLabel
@onready var resources_label: Label = $AnimatedSprite2D/Control/HBoxContainer/VBoxContainer/ResourcesLabel

@onready var status: String = get_meta("status")
@onready var planet_name: String = get_meta("name")
@onready var shield_strength: int = get_meta("shield_strength")
@onready var shield_color = null
@onready var number_of_shields = int(shield_strength / 20)
@onready var resources: int = get_meta("resources")
@onready var alignment: int = get_meta("alignment")

func _ready():
	sprite.play()
	sprite.scale = Vector2(Global.PLANET_SCALE_FACTOR, Global.PLANET_SCALE_FACTOR)
	queue_redraw()
	update_labels()
	randomize()
	PlanetBoundary.area_entered.connect(_on_planet_boundary_area_entered)
	PlanetBoundary.input_event.connect(_on_planet_boundary_input_event)
	var shape = collision_shape.shape
	if shape is CircleShape2D:
		shape.radius = Global.PLANET_SPRITE_SIZE * Global.PLANET_SCALE_FACTOR / 2
	elif shape is RectangleShape2D:
		shape.extents = Vector2(Global.PLANET_SPRITE_SIZE * Global.PLANET_SCALE_FACTOR / 2, Global.PLANET_SCALE_FACTOR / 2)

func _on_planet_boundary_area_entered(area):
	if area.is_in_group("projectiles"):
		area.queue_free()
		print(planet_name + " took damage!")
		alignment -= 1
		update_labels()

func _on_planet_boundary_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and Input.is_action_just_pressed('left_click'):
		var player = get_tree().get_root().get_node("Game/Space/PlayerShip")
		if player:
			player.move_to_planet(self.global_position, self)

func update_labels():
	alignment_label.text = str(alignment)
	planetname_label.text = planet_name
	shieldstrength_label.text = str(shield_strength) + '%'
	resources_label.text = 'Resources: ' + str(resources) + ' tons'

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
			if i > 0:
				var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
				rect_position += offset

			var rect = Rect2(rect_position, rect_size)
			# Draw the rectangle with the offset
			draw_rect(rect, shield_color, false)
