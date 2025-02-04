extends Node2D

@export var boids: Array[Boid]

var direction_interval: float = .7
var predator: PredatorBoid


func _ready() -> void:	
	for boid in boids:
		boid.boids = boids
		
		if boid.testing == true:
			predator = boid
			boid.tracking = true
			boid._track()
			predator.direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()


func _physics_process(delta: float) -> void:
	predator._handle_hunger(delta)
	if predator.hunger == 0:
		predator.direction = predator._hunt()
		predator.speed = Constants.PREDATOR_HUNTING_SPEED
	
	predator._move(delta)
	predator._wrap_around()
