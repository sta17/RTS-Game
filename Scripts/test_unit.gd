extends CharacterBody3D

#const module_camera:GDScript = preload("res://Scripts/module_camera.gd")
var object_data:Dictionary = {} # Any data by modules or object.

var steer_speed:float = 4.0
var nav_path_goal_position:Vector3

@onready var nav_path_timer:Timer = $Timer
@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D
@onready var gravity_raycast:RayCast3D = $RayCast3D
@onready var spr_selected:Sprite3D = $selected

@export var unit_data:Unit_data

var rotation_fast:bool = false

var stuck_max:int = 9
var stuck_count:int = 0
var last_position:Vector3

var selected:bool = false:
	set(new_value):
		selected = new_value
		update_selected()

const range_min_from_loc:float = -1.5
const range_max_from_loc:float = 1.5
const floating_smoothing_ground:float = 0.05

#region General Funcs
func _ready() -> void:
	
	set_physics_process(false)
	set_process(false)
	
	set_max_slides(2)
	nav_agent.velocity_computed.connect(char_move)
	nav_path_timer.timeout.connect(nav_path_timer_update)
	selected = false
	
	await(get_tree().process_frame)
	set_physics_process(true)
	set_process(true)

func _physics_process(delta:float) -> void:
	if nav_agent.is_navigation_finished():return
	
	if Engine.get_physics_frames() % 3 == 0:
		position.y = gravity_raycast.get_collision_point().y + floating_smoothing_ground
	
	var next_position:Vector3 = nav_agent.get_next_path_position()
	var direction:Vector3 = global_position.direction_to(next_position) * nav_agent.max_speed
	
	rotate_to_direction(direction,delta)
	
	var steered_velocity:Vector3 = (direction - velocity) * delta * steer_speed
	var new_agent_velocity:Vector3 = velocity + steered_velocity
	nav_agent.set_velocity(new_agent_velocity)

func update_selected() -> void:
	if selected: spr_selected.show()
	else: spr_selected.hide()

func rotate_to_direction(dir:Vector3, delta:float) ->void:
	if rotation_fast:
		rotation.y = atan2(dir.x,dir.z)
	else:
		var pos_2D:Vector2 = Vector2(-transform.basis.z.x,-transform.basis.z.z)
		var goal_2D:Vector2 = Vector2(dir.x,dir.z)
		rotation.y -= pos_2D.angle_to(goal_2D) * delta * steer_speed

func nav_path_timer_update() -> void:
		if nav_agent.is_navigation_finished():return
		nav_agent.set_target_position(nav_path_goal_position)
		stuck_check()
		last_position = global_position

func stuck_check() -> void:
	#Unit is stuck?
	if last_position.distance_squared_to(global_position) < 0.8:
		if stuck_count < stuck_max: stuck_count += 1
		
		#cancel navigation if stuckked from a while inside cancel min range.
		if stuck_count >= 3:
			if (global_position.distance_squared_to(nav_path_goal_position)) < 10.0 or stuck_count >= stuck_max:
				cancel_navigation()
				stuck_count = 0

func cancel_navigation() -> void:
	#cancel navigation
	nav_agent.emit_signal("navigation_finished")
	nav_agent.set_target_position(global_position)

func char_move(new_velocity:Vector3) -> void:
	if nav_agent.is_navigation_finished(): new_velocity.y = 0
	velocity = new_velocity
	
	var collision:KinematicCollision3D = move_and_collide(new_velocity * get_physics_process_delta_time())
	if collision:
		var collider:Object = collision.get_collider()
		if collider is CharacterBody3D:
			velocity = new_velocity.slide(collision.get_normal())
		elif collider is StaticBody3D:
			move_and_slide()

func move_unit(new_movement_goal:Vector3 = Vector3.ZERO) -> void:
	stuck_count = 0
	
	new_movement_goal += Vector3(randf_range(range_min_from_loc,range_max_from_loc),0,randf_range(range_min_from_loc,range_max_from_loc))
	
	nav_path_goal_position = new_movement_goal
	nav_path_timer.emit_signal("timeout")
	nav_agent.set_target_position(nav_path_goal_position)
#endregion

#region Get Unit Info
func setHealth(health: int) -> void:
	#healthbar.value = health
	pass

func GetIcon() -> Texture2D:
	return unit_data.unit_icon
	
func GetName() -> String:
	return unit_data.name
	
func GetMaxHPAmount() -> float:
	return unit_data.hp

func GetCurrentHPAmount() -> float:
	return unit_data.hp

func GetMaxAETHERAmount() -> float:
	return unit_data.aether

func GetCurrentAETHERAmount() -> float:
	return unit_data.aether

func GetArmorAmount() -> float:
	return unit_data.defense
	
func GetDamageAmount() -> float:
	return unit_data.attack

func GetBodyAmount() -> float:
	return unit_data.body_start
	
func GetFinesseAmount() -> float:
	return unit_data.finesse_start
	
func GetMindAmount() -> float:
	return unit_data.mind_start
#endregion
