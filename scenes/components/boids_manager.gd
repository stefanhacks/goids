extends Node

@export var boid_count = 80
@export var target_area: Vector2 = Vector2(1050.0, 1050.0)

const BOID = preload("res://scenes/components/boid.tscn")
const PREDATOR_BOID = preload("res://scenes/components/predator_boid.tscn")
var boids: Array[Boid] = []

func _ready() -> void:
	for i in range(boid_count):
		var boid = _make_boid((i + 1) % 40 == 0)
		add_child(boid)
		boid.got_eaten.connect(_timer_to_respawn)


func _make_boid(predator: bool) -> Boid:
	var boid = BOID.instantiate() if predator == false else PREDATOR_BOID.instantiate()
	var rand_position = Vector2(
		target_area.x * randf(), 
		target_area.y * randf(),
	)
	
	boids.append(boid)
	boid.boids = boids
	boid.active_area = target_area
	boid.position = rand_position
	
	return boid


func _timer_to_respawn() -> void:
	var respawn_delay = Constants.RESPAWN_AVERAGE_TIME * randf_range(0.5, 1.5)
	get_tree().create_timer(respawn_delay).timeout.connect(_replace_eaten_boid)


func _replace_eaten_boid() -> void:
	var boid = _make_boid(false)
	add_child(boid)
	boid.track()
	boid.splat()
