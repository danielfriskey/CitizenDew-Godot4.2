extends Node2D

func _ready():
	update_borders()
	create_grid_border()

func update_borders():
	# Remove all existing Line2D nodes
	for child in get_children():
		if child is Line2D:
			remove_child(child)
			child.queue_free()

	# Create new borders based on the grid configuration
	for y in range(Global.GRID_HEIGHT):
		for x in range(Global.GRID_WIDTH):
			create_square_border(Vector2(x * Global.SQUARE_SIZE, y * Global.SQUARE_SIZE))

func create_square_border(new_position):
	# Create outer border
	var line = Line2D.new()
	line.width = Global.BORDER_WIDTH
	line.default_color = Global.OUTER_BORDER_COLOR
	var points = [
		new_position,
		new_position + Vector2(Global.SQUARE_SIZE, 0),
		new_position + Vector2(Global.SQUARE_SIZE, Global.SQUARE_SIZE),
		new_position + Vector2(0, Global.SQUARE_SIZE),
		new_position
	]
	for point in points:
		line.add_point(point)
	add_child(line)

	# Create 3x3 sub-grid borders
	var step_size = Global.SQUARE_SIZE / 3
	for i in range(1, 3):
		# Vertical lines
		var vertical_line = Line2D.new()
		vertical_line.width = 1
		vertical_line.default_color = Global.SUB_GRID_COLOR
		vertical_line.add_point(new_position + Vector2(i * step_size, 0))
		vertical_line.add_point(new_position + Vector2(i * step_size, Global.SQUARE_SIZE))
		add_child(vertical_line)

		# Horizontal lines
		var horizontal_line = Line2D.new()
		horizontal_line.width = 1
		horizontal_line.default_color = Global.SUB_GRID_COLOR
		horizontal_line.add_point(new_position + Vector2(0, i * step_size))
		horizontal_line.add_point(new_position + Vector2(Global.SQUARE_SIZE, i * step_size))
		add_child(horizontal_line)

func create_grid_border():
	var line = Line2D.new()
	line.width = Global.GRID_BORDER_WIDTH
	line.default_color = Global.GRID_BORDER_COLOR
	line.z_index = 1  # Ensure it's on top
	var points = [
		Vector2(0, 0),
		Vector2(Global.GRID_WIDTH * Global.SQUARE_SIZE, 0),
		Vector2(Global.GRID_WIDTH * Global.SQUARE_SIZE, Global.GRID_HEIGHT * Global.SQUARE_SIZE),
		Vector2(0, Global.GRID_HEIGHT * Global.SQUARE_SIZE),
		Vector2(0, 0)
	]
	for point in points:
		line.add_point(point)
	add_child(line)
