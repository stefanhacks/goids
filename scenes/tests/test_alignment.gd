extends Node2D

@export var boids: Array[Boid]

var direction_interval: float = .7
var tracking_boid: Boid
var boids_zero: Vector2i


func _ready() -> void:
	get_tree().create_timer(direction_interval).timeout.connect(_change_direction)
	
	for boid in boids:
		boid.boids = boids
		
		if tracking_boid == null:
			tracking_boid = boid
			boids_zero = boid.position
			boid.show_direction_line = true
			boid.tracking = true
			boid._track()
		else:
			boid.direction = Vector2.UP


func _physics_process(delta: float) -> void:
	for boid in boids:
		if boid.tracking == true:
			var alignment_point = boid._alignment(500)
			boid._update_direction_line(alignment_point)
			boid._rotate(boid.position + alignment_point)
			print(boid.name, ": ", alignment_point)
		else:
			boid._move(delta)
			boid._wrap_around()


func _change_direction() -> void:
	get_tree().create_timer(direction_interval).timeout.connect(_change_direction)
	
	var i = 0
	for boid in boids:
		if boid.tracking == false:
			boid.position = boids_zero - Vector2i(20, 20) + Vector2i(40, 40) * i
			boid.direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			i += 1
