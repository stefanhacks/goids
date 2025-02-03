extends Node2D

@export var boids: Array[Boid]

@onready var direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()


func _physics_process(delta: float) -> void:
	for boid in boids:
		boid.testing = true
		boid.direction = direction
		boid._move(delta)
		boid._wrap_around()
		
