class_name Boid
extends Node2D

@export var normal_color: Color = Color('febc55')
@export var predator_color: Color = Color('279cb0')
@export var tracking_color: Color = Color('f04257')

@onready var shadow_root: Node2D = $ShadowRoot
@onready var body_root: Node2D = $BodyRoot

var boids: Array[Boid] = []
var direction: Vector2
var active_area: Vector2 = Vector2.ONE * 1000

var predator = false
var tracking = false


func _ready() -> void:
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	predator = randf_range(0, 1) < 0.1


func _physics_process(delta: float) -> void:
	_track()
	
	# Arbitrary weights
	if !predator:
		var separation = _separation() * 2
		var alignment = _alignment()
		var cohesion = _cohesion() * 0
	
		direction = (direction + separation + alignment + cohesion).normalized()
	
	#if predator == true:
		#_seek()
	
	_move(delta)
	_wrap_around()


func _track() -> void:
	if tracking:
		body_root.modulate = tracking_color
	elif predator:
		body_root.modulate = predator_color
	else:
		body_root.modulate = normal_color


func _separation() -> Vector2:
	var separation = Vector2.ZERO
	
	for boid in boids:
		if boid == self:
			continue
		
		var distance = boid.position.distance_to(position)
		if boid.predator == true and distance < Constants.PREDATOR_RADIUS:
			var diff = (position - boid.position).normalized()
			separation += diff * 500
		elif distance < Constants.SEPARATION_RADIUS:
			var diff = (position - boid.position).normalized()
			separation += diff / distance
		
	
	return separation


func _alignment() -> Vector2:
	var alignment = Vector2.ZERO
	
	var aligned_to = 0.0
	var direction_sum = Vector2.ZERO
	for boid in boids:
		if boid != self and boid.position.distance_to(position) < Constants.ALIGNMENT_RADIUS:
			aligned_to += 1.0
			direction_sum += boid.direction
	
	if aligned_to > 0.0:
		alignment = (direction_sum / aligned_to).normalized()
	
	return alignment


func _cohesion() -> Vector2:
	var cohesion = Vector2.ZERO
	
	var grouped_to = 0.0
	var location_sum = Vector2.ZERO
	for boid in boids:
		if boid != self and boid.position.distance_to(position) < Constants.COHESION_RADIUS:
			grouped_to += 1.0
			location_sum += boid.position
	
	if grouped_to > 0.0:
		cohesion = location_sum / grouped_to
	
	return cohesion


func _seek() -> void:
	pass


func _move(delta: float) -> void:
	var new_point = position + direction * 100
	_rotate(new_point)
	
	var speed = Constants.PREDATOR_SPEED if predator else Constants.NORMAL_SPEED
	
	position.x += direction.x * delta * speed
	position.y += direction.y * delta * speed


func _rotate(new_point) -> void:
	body_root.look_at(new_point)
	shadow_root.rotation = body_root.rotation


func _wrap_around() -> void:
	if(position.x < 0):
		position.x += active_area.x
	elif(position.x > active_area.x):
		position.x -= active_area.x
	
	if(position.y < 0):
		position.y += active_area.y
	elif(position.y > active_area.y):
		position.y -= active_area.y
