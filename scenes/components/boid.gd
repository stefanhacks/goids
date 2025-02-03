class_name Boid
extends Node2D

@export var normal_color: Color = Color('febc55')
@export var predator_color: Color = Color('279cb0')
@export var tracking_color: Color = Color('f04257')
@export var testing = false

@onready var shadow_root: Node2D = $ShadowRoot
@onready var body_root: Node2D = $BodyRoot
@onready var direction_line: Line2D = $DirectionLine

var boids: Array[Boid] = []
var direction: Vector2
var active_area: Vector2 = Vector2.ONE * 1000

var tracking = false
var show_direction_line = false

var predator = false
var target: Boid


func _ready() -> void:
	if testing == true:
		return
	
	show_direction_line = direction_line.visible
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()


func _physics_process(delta: float) -> void:
	if testing == true:
		return
	
	# Multiplied by arbitrary weights
	if predator == true:
		direction = direction + _seek()
	else:
		var separation = _separation() * 50
		var alignment = _alignment() * 1
		var cohesion = _cohesion() * 1
	
		direction = (direction + separation + alignment + cohesion).normalized()
	
	_track()
	_update_direction_line()
	_move(delta)
	_wrap_around()


func _track() -> void:
	if tracking:
		body_root.modulate = tracking_color
	elif predator:
		body_root.modulate = predator_color
	else:
		body_root.modulate = normal_color


func _update_direction_line(point_to = direction) -> void:
	if show_direction_line == true:
		direction_line.modulate = body_root.modulate
		direction_line.points[1] = point_to * 100
		
	direction_line.visible = show_direction_line


# Returns weighted vector pointing average distant direction of close by boids.
func _separation(boid_radius = Constants.SEPARATION_RADIUS, predator_radius = Constants.PREDATOR_RADIUS) -> Vector2:
	var separation = Vector2.ZERO
	
	for boid in boids:
		var distance = boid.position.distance_to(position)
		if distance == 0:
			continue
		
		if predator == false and boid.predator == true and predator_radius > distance:
			var diff = (position - boid.position).normalized()
			separation += diff * 500
		elif boid_radius > distance:
			var diff = (position - boid.position).normalized()
			separation += diff / distance
			
	return separation


# Returns normalized vector pointing towards average direction of close by boids.
func _alignment(boid_radius = Constants.ALIGNMENT_RADIUS) -> Vector2:
	var alignment = Vector2.ZERO
	
	var aligned_to = 0.0
	var direction_sum = Vector2.ZERO
	for boid in boids:
		var distance = boid.position.distance_to(position)
		if boid == self:
			continue
		
		if boid_radius > distance and distance > 0:
			aligned_to += 1.0
			direction_sum += boid.direction
	
	if aligned_to > 0.0:
		alignment = (direction_sum / aligned_to)
	
	return alignment


# Returns normalized vector pointing towards center position of close by boids.
func _cohesion(boid_radius = Constants.COHESION_RADIUS) -> Vector2:
	var cohesion = Vector2.ZERO
	
	var grouped_to = 0.0
	var location_sum = Vector2.ZERO
	for boid in boids:
		var distance = boid.position.distance_to(position)
		if boid_radius > distance and distance > 0:
			grouped_to += 1.0
			location_sum += boid.position
	
	if grouped_to > 0.0:
		cohesion = location_sum / grouped_to
		return position.direction_to(cohesion)
	else:
		return Vector2.ZERO


func _seek() -> Vector2:
	return Vector2.ZERO


func _move(delta: float) -> void:
	var new_point = position + direction * 100.0
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
