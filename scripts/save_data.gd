extends Node
class_name SaveData

@export var planet_positions = []
@export var player_position = Vector2()

func save():
	var file = FileAccess.open(Global.SAVE_PATH, FileAccess.WRITE)
	var save_data = {
		"planet_positions": [],
		"player_position": {
			"x": player_position.x,
			"y": player_position.y
		}
	}
	for planet in planet_positions:
		save_data["planet_positions"].append(
			{
				"id": planet["id"],
				"home": planet["home"],
				"status": planet["status"],
				"name": planet["name"],
				"x": planet["position"].x,
				"y": planet["position"].y,
				"shield_strength": planet.get("shield_strength", 0),
				"population": planet.get("population", 0),
				"resources": planet.get("resources", 0)
			}
		)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()

static func load_or_create(mode: String):
	var res = SaveData.new()
	if mode == "load" and FileAccess.file_exists(Global.SAVE_PATH):
		var file = FileAccess.open(Global.SAVE_PATH, FileAccess.READ)
		var file_contents = file.get_as_text()
		if file_contents != "":
			var save_data = JSON.parse_string(file_contents)
			if save_data.has("planet_positions"):
				for planet in save_data["planet_positions"]:
					res.planet_positions.append(
						{
							"id": planet["id"],
							"home": planet["home"],
							"status": planet["status"],
							"name": planet["name"],
							"position": Vector2(planet["x"], planet["y"]),
							"shield_strength": planet["shield_strength"],
							"population": planet["population"],
							"resources": planet["resources"]
						}
					)
			if save_data.has("player_position"):
				res.player_position = Vector2(save_data["player_position"].x, save_data["player_position"].y)
		file.close()
	return res

static func delete_save():
	if FileAccess.file_exists(Global.SAVE_PATH):
		var file = FileAccess.open(Global.SAVE_PATH, FileAccess.WRITE)
		file.close()
