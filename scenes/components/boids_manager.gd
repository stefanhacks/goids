extends Node

@export var boid_count = 80
@export var target_area: Vector2 = Vector2(1050.0, 1050.0)

const BOID = preload("res://scenes/components/boid.tscn")
const PREDATOR_BOID = preload("res://scenes/components/predator_boid.tscn")
var boids: Array[Boid] = []

func _ready() -> void:
	for i in range(boid_count):
		var predator = (i + 1) % 40 == 0
		
		var boid = BOID.instantiate() if predator == false else PREDATOR_BOID.instantiate()
		var rand_position = Vector2(
			target_area.x * randf(), 
			target_area.y * randf(),
		)
		
		boids.append(boid)
		boid.boids = boids
		boid.active_area = target_area
		boid.position = rand_position
		boid.name = "Boid%s" % i
		
		add_child(boid)
