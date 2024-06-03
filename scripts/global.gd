extends Node

# Grid configuration
const SQUARE_SIZE = 500
const GRID_WIDTH = 2
const GRID_HEIGHT = 2

# Border configuration
const BORDER_WIDTH = 2
const GRID_BORDER_WIDTH = 4

# BORDER COLORS
const GRID_BORDER_COLOR = Color(8 / 255.0, 55 / 255.0, 92 / 255.0)  # BLUE
const OUTER_BORDER_COLOR = Color(143 / 255.0, 193 / 255.0, 243 / 255.0)  # LIGHT BLUE
const SUB_GRID_COLOR = Color(34 / 255.0, 34 / 255.0, 34 / 255.0)  # Dark grey color

# Player configuration
const PLAYER_SPEED = 100

# PLANET COUNT
const NEUTRAL_PLANET_COUNT = 15
const UNINHABITED_PLANET_COUNT = 35

const PLANET_SIZE = 50  # Planet size (assuming uniform size)
const PLANET_SCALE_FACTOR = 0.35  # Scale factor for planet sprites
const PLANET_SPRITE_SIZE = 500  # Size of each planet sprite in pixels
const SPRITE_FRAME_SIZE = Vector2(PLANET_SPRITE_SIZE, PLANET_SPRITE_SIZE)

# PLANET SPAWNING
const PLANET_MARGIN = 0.1  # Margin to keep planets away from borders
const PLANET_DISTANCE_FACTOR = 0.1  # Factor for minimum distance between planets

# Save path
const SAVE_PATH:String = "user://citizendew_save_data.json"

# Save data
var save_data = SaveData.new()
var space: Node = null  # Add this line to store the reference to the Space node

func load_save_data(mode: String):
	save_data = SaveData.load_or_create(mode)

func save_game():
	if space:
		save_data.planet_positions = space.planet_positions
		save_data.player_position = space.player.position  # Save player position
		save_data.save()

func delete_save_data():
	SaveData.delete_save()

func pause_game():
	var pause_menu_scene = preload("res://menus/pause_menu.tscn")
	if not space.pause_menu:
		space.pause_menu = pause_menu_scene.instantiate()
		space.add_child(space.pause_menu)
	space.pause_menu.show()
	get_tree().paused = true

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		pause_game()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		#get_tree().paused = false
		pass
