class_name PredatorBoid
extends Boid

@export var predator_color: Color = Color('279cb0')

var target: Boid
var hunger = Constants.PREDATOR_MAX_HUNGER


func _ready() -> void:
	speed = Constants.PREDATOR_SPEED
	if testing == true:
		return
	
	hunger *= randf_range(0.5, 1)
	super()


func _physics_process(delta: float) -> void:
	if testing == true:
		return
	
	_handle_hunger(delta)
	if (hunger == 0):
		speed = Constants.PREDATOR_HUNTING_SPEED
		direction = (direction + _hunt()).normalized()
	
	_track()
	_update_direction_line()
	_move(delta)
	_wrap_around()


func _handle_hunger(delta: float, biting_distance = Constants.BITING_DISTANCE) -> void:
	hunger = max(hunger - delta, 0)
	if (target != null):
		var distance = position.distance_to(target.position)
		if distance < biting_distance:
			target.get_eaten()
			var index = boids.find(target)
			boids.pop_at(index)
			target = null
			hunger = Constants.PREDATOR_MAX_HUNGER
			speed = Constants.PREDATOR_SPEED


# Returns normalized vector pointing towards target if exists.
func _hunt() -> Vector2:
	if target == null:
		var targets = boids.filter(func(boid): return boid is not PredatorBoid)
		if targets.size() == 0:
			return Vector2.ZERO
			
		var target_index = randi_range(0, targets.size())
		var size = targets.size()
		target = boids[target_index]
		target.targeted = true
	
	var wrapped_x = target.position.x + active_area.x * (1 if target.position.x < position.x else -1)
	var wrapped_y = target.position.y + active_area.y * (1 if target.position.y < position.y else -1)
	
	var points: Array[Vector2] = [
		Vector2(wrapped_x, target.position.y),
		Vector2(target.position.x, wrapped_y),
		Vector2(wrapped_x, wrapped_y),
	]
	
	var closest = target.position
	for point in points:
		if (point.distance_to(position) < closest.distance_to(position)):
			closest = point
	
	return position.direction_to(closest).normalized()


func _track() -> void:
	body_root.modulate = predator_color
