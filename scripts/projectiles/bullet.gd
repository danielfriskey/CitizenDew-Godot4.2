extends Area2D

var travelled_distance = 0
var direction = Vector2()

func _ready():
	# Set the rotation of the bullet to face the direction it's traveling
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	const SPEED = 100
	const RANGE = 150
	position += direction * SPEED * delta
	travelled_distance += SPEED * delta
	
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	print("Bullet hit something")
	print(body.name)
	queue_free()
