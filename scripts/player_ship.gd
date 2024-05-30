extends RigidBody2D

var is_moving = false
var target_direction = Vector2()
var is_targeted_movement = false
var target_position = Vector2()
var target_planet: Node2D
var rotation_speed = 2.0  # Adjust this value to control the rotation speed
var max_angular_velocity = PI / 4  # Maximum angular velocity

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	target_direction = Vector2()
	animated_sprite.play("idle")

func _physics_process(_delta):
	if is_moving:
		handle_rotation(_delta)
		apply_central_impulse(target_direction * Global.PLAYER_SPEED)
		
		# Confine the player within the grid boundaries
		position.x = clamp(position.x, 0, Global.GRID_WIDTH * Global.SQUARE_SIZE)
		position.y = clamp(position.y, 0, Global.GRID_HEIGHT * Global.SQUARE_SIZE)

		if is_targeted_movement and position.distance_to(target_position) < (Global.PLANET_SIZE * 0.75):
			print_planet_info(target_planet)
			stop_ship()

func move_to_position(new_position: Vector2):
	is_targeted_movement = false
	is_moving = true
	target_position = new_position
	target_direction = (target_position - position).normalized()

func move_to_planet(planet_position: Vector2, planet_node: Node2D):
	is_targeted_movement = true
	is_moving = true
	target_position = planet_position
	target_planet = planet_node
	target_direction = (target_position - position).normalized()

func stop_ship():
	is_moving = false
	linear_velocity = Vector2()

func handle_rotation(delta: float):
	var target_rotation = target_direction.angle()
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and Input.is_action_just_pressed('left_click'):
		var click_position = get_local_mouse_position()
		move_to_position(click_position)

func _on_body_entered(body: Node):
	if is_targeted_movement and body == target_planet:
		print_planet_info(target_planet)
		stop_ship()

func print_planet_info(planet: Node2D):
	if planet:
		var planet_id = "Unknown"
		var planet_type = "Unknown"
		var planet_name = "Unknown"
		var shield_strength = "Unknown"
		var population = "Unknown"
		var resources = "Unknown"

		if planet.has_meta("id"):
			planet_id = str(planet.get_meta("id"))
		if planet.has_meta("type"):
			planet_type = planet.get_meta("type")
		if planet.has_meta("name"):
			planet_name = planet.get_meta("name")
		if planet.has_meta("shield_strength"):
			shield_strength = str(planet.get_meta("shield_strength"))
		if planet.has_meta("population"):
			population = str(planet.get_meta("population"))
		if planet.has_meta("resources"):
			resources = str(planet.get_meta("resources"))

		print("Arrived at Planet:")
		print("  ID: ", planet_id)
		print("  Name: ", planet_name)
		print("  Type: ", planet_type)
		print("  Shield Strength: ", shield_strength)
		print("  Population: ", population)
		print("  Resources: ", resources)
		# Debug prints for verification
		print("Planet Properties: ", planet)
