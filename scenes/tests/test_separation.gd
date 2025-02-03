extends Node2D

@export var boids: Array[Boid]

var tracking_boid: Boid


func _ready() -> void:
	for boid in boids:
		boid.boids = boids
		if tracking_boid == null:
			boid.show_direction_line = true
			tracking_boid = boid
			boid.tracking = true
			boid._track()


func _physics_process(delta: float) -> void:
	for boid in boids:
		boid.direction = boid._separation(500) * 70
		
		if boid.tracking == true:
			print(boid.name, ": ", boid.direction)
			boid._update_direction_line()
		
		boid._move(delta)
		boid._wrap_around()
