extends RigidBody2D

var is_moving = false
var target_direction = Vector2()
var is_targeted_movement = false
var target_position = Vector2()
var target_planet: Node2D
var rotation_speed = 2.0  # Adjust this value to control the rotation speed
var max_angular_velocity = PI / 4  # Maximum angular velocity
var click_position = Vector2()
var arrival_threshold = 5.0  # Distance threshold to consider as "arrived"
var show_line = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var shooting_point = %ShootingPoint # Reference to ShootingPoint

func _ready():
	animated_sprite.play("idle")

func _physics_process(_delta):
	if is_moving:
		handle_rotation(_delta)
		move_towards_target(_delta)
		queue_redraw()
		
		# Confine the player within the grid boundaries
		position.x = clamp(position.x, 0, Global.GRID_WIDTH * Global.SQUARE_SIZE)
		position.y = clamp(position.y, 0, Global.GRID_HEIGHT * Global.SQUARE_SIZE)

		if is_targeted_movement and position.distance_to(target_position) < arrival_threshold:
			print_planet_info(target_planet)
			stop_ship()
		
		# Check the length of the line and hide it if the target is reached
		if position.distance_to(target_position) < arrival_threshold:
			show_line = false

func shoot():
	const BULLET = preload("res://scenes/projectiles/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	var mouse_position = get_global_mouse_position() # Get mouse position
	var direction = (mouse_position - shooting_point.global_position).normalized() # Calculate direction
	new_bullet.global_position = shooting_point.global_position # Set the position of the bullet
	new_bullet.direction = direction # Set the direction of the bullet
	get_tree().root.add_child(new_bullet) # Add the bullet to the scene

func _draw():
	if show_line:
		var local_start_position = to_local(position)
		var local_target_position = to_local(target_position)
		var _line_length = local_start_position.distance_to(local_target_position)
		var segment_count = 10  # Number of segments to create the gradient effect

		for i in range(segment_count):
			var t1 = float(i) / segment_count
			var t2 = float(i + 1) / segment_count
			var start_pos = local_start_position.lerp(local_target_position, t1)
			var end_pos = local_start_position.lerp(local_target_position, t2)
			
			# Use an easing function for smoother alpha blending
			var alpha = ease_in_out(t2)
			var color = Color(0, 1, 0, alpha)  # Green color with varying alpha
			draw_line(start_pos, end_pos, color, 1.0)

# Easing function for smoother alpha blending
func ease_in_out(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)

func move_to_position(new_position: Vector2):
	is_targeted_movement = false
	is_moving = true
	target_position = new_position
	target_direction = (target_position - position).normalized()
	show_line = true

func move_to_planet(planet_position: Vector2, planet_node: Node2D):
	is_targeted_movement = true
	is_moving = true
	target_position = planet_position
	target_planet = planet_node
	target_direction = (target_position - position).normalized()
	show_line = true

func stop_ship():
	is_moving = false
	linear_velocity = Vector2()
	angular_velocity = 0
	animated_sprite.play("idle")
	show_line = false
	if not is_targeted_movement:
		print("Player has reached the clicked position.")

func handle_rotation(delta: float):
	var target_rotation = target_direction.angle()
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

func move_towards_target(_delta: float):
	if is_targeted_movement:
		var distance_to_target = position.distance_to(target_position)
		if distance_to_target > arrival_threshold:
			var move_direction = (target_position - position).normalized()
			linear_velocity = move_direction * Global.PLAYER_SPEED
		else:
			stop_ship()
	else:
		var move_direction = target_direction
		linear_velocity = move_direction * Global.PLAYER_SPEED

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if Input.is_action_just_pressed('right_click'):
			shoot()
		elif Input.is_action_just_pressed('left_click'):
			click_position = get_global_mouse_position()
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsPointQueryParameters2D.new()
			query.position = click_position
			var result = space_state.intersect_point(query)
			
			var clicked_planet = false
			for collision in result:
				if collision.collider.is_in_group("planets"):
					clicked_planet = true
					move_to_planet(collision.collider.position, collision.collider)
					break
			
			if not clicked_planet:
				move_to_position(click_position)

func _on_body_entered(body: Node):
	if is_targeted_movement and body == target_planet:
		print_planet_info(target_planet)
		stop_ship()

func print_planet_info(planet: Node2D):
	if planet:
		#var planet_id = str(planet.get_meta("id"))
		#var planet_type = planet.get_meta("type")
		var planet_name = planet.get_meta("name")
		#var shield_strength = str(planet.get_meta("shield_strength"))
		var population = str(planet.get_meta("population"))
		var resources = str(planet.get_meta("resources"))
		var alignment = str(planet.get_meta("alignment"))
		
		print('')
		print("Arrived at " + str(planet_name) + ":")
		print("  Population: ", population)
		print("  Resources: ", resources)
		print("  Alignment: ", alignment)
