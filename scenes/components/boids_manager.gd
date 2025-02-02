extends Node

@export var boid_count = 60
@export var target_area: Vector2 = Vector2(1050.0, 1050.0)

const BOID = preload("res://scenes/components/boid.tscn")
var boids: Array[Boid] = []

func _ready() -> void:
	for i in range(boid_count):
		var boid = BOID.instantiate()
		var rand_position = Vector2(
			target_area.x * randf(), 
			target_area.y * randf(),
		)
		
		boids.append(boid)
		boid.boids = boids
		boid.active_area = target_area
		boid.position = rand_position
		boid.name = "Boid%s" % i
		
		boid.tracking = i == 0
		
		add_child(boid)
