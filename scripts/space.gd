extends Node2D

@onready var home_planet_scene = preload("res://scenes/planet.tscn")
@onready var neutral_planet_scene = preload("res://scenes/neutral_planet.tscn")
@onready var uninhabited_planet_scene = preload("res://scenes/uninhabited_planet.tscn")
@onready var player = $PlayerShip
@onready var square_borders = $SquareBorders
@onready var planet_positions = []
@onready var pause_menu = null  # Set this to null as it will be instantiated in Global

var grid_width = Global.GRID_WIDTH * Global.SQUARE_SIZE
var grid_height = Global.GRID_HEIGHT * Global.SQUARE_SIZE
var planet_radius = Global.PLANET_SIZE * Global.PLANET_SCALE_FACTOR / 2
var min_distance_between_planets = Global.SQUARE_SIZE * Global.PLANET_DISTANCE_FACTOR + Global.PLANET_SIZE * Global.PLANET_SCALE_FACTOR
var margin = Global.SQUARE_SIZE * Global.PLANET_MARGIN
var current_planet_id = 1

func _ready():
	load_planet_data()
	generate_planets()
	square_borders.update_borders()
	square_borders.create_grid_border()
	
	Global.space = self  # Register the space node globally
	
	Global.save_data.save()
	
	# Set the player position to the home planet position if it exists, otherwise use default
	if Global.save_data.player_position:
		player.position = Global.save_data.player_position
	else:
		var home_planet_position = player.position  # Default to player position
		for planet_data in planet_positions:
			if planet_data["type"] == "home":
				home_planet_position = Vector2(planet_data["position"].x, planet_data["position"].y)
				break
		player.position = home_planet_position

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Global.pause_game()

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and Input.is_action_just_pressed('left_click'):
		var click_position = get_global_mouse_position()
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = click_position
		var result = space_state.intersect_point(query)
		
		var clicked_planet = false
		for collision in result:
			if collision.collider.is_in_group("planets"):
				clicked_planet = true
				break
		
		if not clicked_planet and player:
			player.move_to_position(click_position)

func generate_planets():
	if planet_positions.size() == 0:
		create_planet(player.position, "home", "Home Planet")
		for i in range(Global.NEUTRAL_PLANET_COUNT):
			var neutral_planet_position = get_valid_planet_position()
			create_planet(neutral_planet_position, "neutral", "Neutral Planet " + str(i + 1))
		for i in range(Global.UNINHABITED_PLANET_COUNT):
			var uninhabited_planet_position = get_valid_planet_position()
			create_planet(uninhabited_planet_position, "uninhabited", "Uninhabited Planet " + str(i + 1))
	else:
		for planet_data in planet_positions:
			load_planet(Vector2(planet_data["position"].x, planet_data["position"].y), planet_data)

func create_planet(position: Vector2, planet_type: String, planet_name: String):
	var planet_scene: Node2D = null
	match planet_type:
		"home":
			planet_scene = home_planet_scene.instantiate()
		"neutral":
			planet_scene = neutral_planet_scene.instantiate()
		"uninhabited":
			planet_scene = uninhabited_planet_scene.instantiate()
	if planet_scene:
		var planet_data = {
			"id": current_planet_id,
			"type": planet_type,
			"name": planet_name,
			"position": position,
			"shield_strength": randi_range(1, 15),
			"population": randi_range(1000, 50000),
			"resources": randi_range(1, 100)
		}
		planet_scene.position = position
		for key in planet_data.keys():
			planet_scene.set_meta(key, planet_data[key])
		# Debug prints for verification
		print("Created Planet: ", planet_data)
		for key in planet_data.keys():
			print("Meta Key: ", key, " Meta Value: ", planet_scene.get_meta(key))
		current_planet_id += 1
		add_child(planet_scene)
		planet_positions.append(planet_data)

func load_planet(position: Vector2, planet_data: Dictionary):
	var planet_scene: Node2D = null
	match planet_data["type"]:
		"home":
			planet_scene = home_planet_scene.instantiate()
		"neutral":
			planet_scene = neutral_planet_scene.instantiate()
		"uninhabited":
			planet_scene = uninhabited_planet_scene.instantiate()
	if planet_scene:
		planet_scene.position = position
		for key in planet_data.keys():
			planet_scene.set_meta(key, planet_data[key])
		add_child(planet_scene)
		# Debug prints for verification
		print("Loaded Planet: ", planet_data)
		for key in planet_data.keys():
			print("Meta Key: ", key, " Meta Value: ", planet_scene.get_meta(key))

func get_valid_planet_position() -> Vector2:
	var new_position = Vector2()
	var valid_position = false
	var attempts = 0
	var max_attempts = 100
	
	while not valid_position and attempts < max_attempts:
		new_position.x = randf_range(margin + planet_radius, grid_width - margin - planet_radius)
		new_position.y = randf_range(margin + planet_radius, grid_height - margin - planet_radius)
		
		valid_position = true
		for existing_position in planet_positions:
			if new_position.distance_to(Vector2(existing_position["position"].x, existing_position["position"].y)) < min_distance_between_planets:
				valid_position = false
				break
		attempts += 1
				
	if not valid_position:
		print("Warning: Could not find valid position after", max_attempts, "attempts.")
	
	return new_position

func load_planet_data():
	planet_positions = Global.save_data.planet_positions
