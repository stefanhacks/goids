class_name Boid
extends Node2D

@export var normal_color: Color = Color('febc55')
@export var targeted_color: Color = Color('f04257')
@export var tracking_color: Color = Color('b276ff')
@export var testing = false
@export var shadow_root: Node2D
@export var body_root: Node2D
@export var splat_emitter: CPUParticles2D

var boids: Array[Boid] = []
var direction: Vector2
var active_area: Vector2 = Vector2.ONE * 1000
var speed = Constants.BOID_SPEED

var tracking = false

var predator = false
var targeted = false:
	set(value):
		targeted = value
		speed = Constants.BOID_FLEEING_SPEED if value == true else Constants.BOID_SPEED

signal got_eaten


func _ready() -> void:
	if testing == true:
		return
	
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()


func _physics_process(delta: float) -> void:
	if testing == true:
		return
	
	# Multiplied by arbitrary weights
	var separation = _separation() * 30
	var alignment = _alignment() * (1 if targeted == false else 0)
	var cohesion = _cohesion() * (1 if targeted == false else 0)

	direction = (direction + separation + alignment + cohesion).normalized()
	
	track()
	_move(delta)
	_wrap_around()


# Returns weighted vector pointing average distant direction of close by boids.
func _separation(min_distance = Constants.SEPARATION_DISTANCE, min_predator_distance = Constants.AVOID_PREDATOR_DISTANCE) -> Vector2:
	var separation = Vector2.ZERO
	
	for boid in boids:
		var distance = boid.position.distance_to(position)
		if distance == 0:
			continue
		
		if boid is PredatorBoid and distance < min_predator_distance:
			var diff = (position - boid.position).normalized()
			separation += diff * 500
		elif distance < min_distance:
			var diff = (position - boid.position).normalized()
			separation += diff / distance
			
	return separation


# Returns normalized vector pointing towards average direction of close by boids.
func _alignment(aligned_distance = Constants.ALIGNMENT_DISTANCE) -> Vector2:
	var alignment = Vector2.ZERO
	
	var aligned_to = 0.0
	var direction_sum = Vector2.ZERO
	for boid in boids:
		var distance = boid.position.distance_to(position)
		if boid == self:
			continue
		
		if 0 < distance and distance < aligned_distance:
			aligned_to += 1.0
			direction_sum += boid.direction
	
	if aligned_to > 0.0:
		alignment = (direction_sum / aligned_to)
	
	return alignment


# Returns normalized vector pointing towards center position of close by boids.
func _cohesion(grouping_distance = Constants.COHESION_DISTANCE) -> Vector2:
	var cohesion = Vector2.ZERO
	
	var grouped_to = 0.0
	var location_sum = Vector2.ZERO
	for boid in boids:
		var distance = boid.position.distance_to(position)
		if 0 < distance and distance < grouping_distance:
			grouped_to += 1.0
			location_sum += boid.position
	
	if grouped_to > 0.0:
		cohesion = location_sum / grouped_to
		return position.direction_to(cohesion)
	else:
		return Vector2.ZERO


func _rotate(new_point) -> void:
	body_root.look_at(new_point)
	shadow_root.rotation = body_root.rotation


func _move(delta: float) -> void:
	_rotate(position + direction * 100.0)
	position.x += direction.x * delta * speed
	position.y += direction.y * delta * speed


func _wrap_around() -> void:
	if(position.x < 0):
		position.x += active_area.x
	elif(position.x > active_area.x):
		position.x -= active_area.x
	
	if(position.y < 0):
		position.y += active_area.y
	elif(position.y > active_area.y):
		position.y -= active_area.y


func track() -> void:
	if tracking:
		body_root.modulate = tracking_color
	elif targeted:
		body_root.modulate = targeted_color
	else:
		body_root.modulate = normal_color


func get_eaten() -> void:
	got_eaten.emit()
	splat()
	splat_emitter.finished.connect(func(): queue_free())
	body_root.visible = false
	shadow_root.visible = false


func splat() -> void:
	splat_emitter.modulate = body_root.modulate
	splat_emitter.emitting = true
