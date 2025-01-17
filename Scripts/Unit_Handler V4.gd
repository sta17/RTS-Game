@icon("res://Assets/Mine/HumanoidIconWhite.svg")
extends CharacterBody3D
class_name UnitV4

@export var player_object:Player_Object

@export var object_data:Unit_data:
	set(value):
		object_data = value
		player_object.object_data = value
@export var player:faction:
	set(value):
		player = value
		player_object.player = value
@export var personalInventory:Inv:
	set(value):
		personalInventory = value
		player_object.personalInventory = value
@export var equiptmentInventory:Inv:
	set(value):
		equiptmentInventory = value
		player_object.equiptmentInventory = value

@onready var graphicsBody:MeshInstance3D = $Graphic
@onready var graphicsNose:MeshInstance3D = $Graphic/MeshInstance3D

@onready var nav_path_timer:Timer = $"Nav Path Timer"
@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D
@onready var gravity_raycast:RayCast3D = $RayCast3D

var rotation_fast:bool = false
var steer_speed:float = 4.0
var nav_path_goal_position:Vector3
var last_position:Vector3
var stuck_count:int = 0
var stuck_max:int = 9

const floating_smoothing_ground:float = 0.05
const range_min_from_loc:float = -1.5
const range_max_from_loc:float = 1.5
var unitActionRange:float = 0
var defaultRange:float

var currentTarget: Node3D = null
var gotTarget:bool = false

#region General Funcs
func _ready():
	graphicsBody = $Graphic
	graphicsNose = $Graphic/MeshInstance3D
	nav_path_timer = $"Nav Path Timer"
	nav_agent = $NavigationAgent3D
	gravity_raycast = $RayCast3D

func _on_ready():
	set_physics_process(false)
	set_process(false)
	
	set_max_slides(2)
	nav_agent.velocity_computed.connect(char_move)
	nav_path_timer.timeout.connect(nav_path_timer_update)
	#player_object.selected(false)
	
	await(get_tree().process_frame)
	set_physics_process(true)
	set_process(true)
	defaultRange = nav_agent.target_desired_distance
	
	if player:
		changeTeamColor(player.teamcolor)
	player_object.object_data = object_data
	player_object._ready()

func _physics_process(delta:float) -> void:
	if nav_agent.is_navigation_finished():
		if gotTarget:
			HandleArrivalAtTarget(delta)
		return

	if Engine.get_physics_frames() % 3 == 0:
		position.y = gravity_raycast.get_collision_point().y + floating_smoothing_ground
	
	var next_position:Vector3 = nav_agent.get_next_path_position()
	var direction:Vector3 = global_position.direction_to(next_position) * nav_agent.max_speed
	
	rotate_to_direction(direction,delta)
	
	var steered_velocity:Vector3 = (direction - velocity) * delta * steer_speed
	var new_agent_velocity:Vector3 = velocity + steered_velocity
	nav_agent.set_velocity(new_agent_velocity)

func HandleArrivalAtTarget(delta:float):
	if !currentTarget:
		gotTarget = false
		nav_agent.set_path_desired_distance(defaultRange)
		return
	
	rotate_to_fast_direction(currentTarget.position,delta)
	nav_agent.set_path_desired_distance(defaultRange)
	player_object.setcurrentTarget(currentTarget)
	player_object.InteractWithTarget()

func changeTeamColor(newColor:Color):
	graphicsBody.material_override = null
	graphicsNose.material_override = null
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = newColor
	graphicsBody.material_override = newMaterial
	graphicsNose.material_override = newMaterial

func CollectedItem():
	cancel_navigation()

func CancelTargetting():
	cancel_navigation()
#endregion

#region Navigation
func rotate_to_direction(dir:Vector3, delta:float) ->void:
	if rotation_fast:
		rotation.y = atan2(dir.x,dir.z)
	else:
		var pos_2D:Vector2 = Vector2(-transform.basis.z.x,-transform.basis.z.z)
		var goal_2D:Vector2 = Vector2(dir.x,dir.z)
		rotation.y -= pos_2D.angle_to(goal_2D) * delta * steer_speed

func rotate_to_fast_direction(dir:Vector3, delta:float) ->void:
	dir = dir.normalized()
	const SMOOTH_SPEED = 2.0
	var pos_2D:Vector2 = Vector2(-transform.basis.x.x,-transform.basis.z.z)
	var pos_2DfromZero:Vector2 = Vector2.ZERO
	var goal_2D:Vector2 = Vector2(dir.x,dir.z)
	var angle = pos_2D.angle_to(goal_2D) * delta * SMOOTH_SPEED
	var angleFromZero = pos_2DfromZero.angle_to(goal_2D) * delta * SMOOTH_SPEED
	#rotation.y -= angleFromZero
	var angleLerp = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), delta * SMOOTH_SPEED)
	rotation.y = angleLerp
	#print("unit rotation y: ",rotation.y, " target y is: ", pos_2D.angle_to(goal_2D))
	#rotate_y(angleFromZero)
	#rotate_object_local(Vector3(0, 1, 0), angleFromZero)
	#print("Rotation: ", rad_to_deg(angle), " from zero: ",rad_to_deg(angleFromZero), " lerp version: ",rad_to_deg(angleLerp))
	#print("Rotation lerp: ",rad_to_deg(angleLerp))
	
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
	currentTarget = null
	player_object.setcurrentTarget(currentTarget)
	gotTarget = false
	#gotOrderedRotate = false

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
	currentTarget = null
	player_object.setcurrentTarget(currentTarget)
	gotTarget = true
	
func move_to_unit(newTarget:Node3D) -> void:
	currentTarget = newTarget
	player_object.setcurrentTarget(currentTarget)
	gotTarget = true
	
	var new_movement_goal:Vector3 = newTarget.position
	stuck_count = 0
	
	new_movement_goal += Vector3(randf_range(range_min_from_loc,range_max_from_loc),0,randf_range(range_min_from_loc,range_max_from_loc))
	
	unitActionRange = player_object.getObject_Data().attack_range
	nav_agent.set_path_desired_distance(defaultRange + unitActionRange)
	
	nav_path_goal_position = new_movement_goal
	nav_path_timer.emit_signal("timeout")
	nav_agent.set_target_position(nav_path_goal_position)
#endregion

#region Temp
func GetIcon() -> Texture2D:
	return object_data.unit_icon
	
func setSelected(status:bool):
	player_object.selected(status)
	
func GetSelected() -> bool:
	return player_object.GetSelected()
	
func selectEnemyFlash():
	player_object.selectEnemyFlash()
	
func selectPlayerFlash():
	player_object.selectPlayerFlash()
	
func handleDeath():
	self.queue_free()
#endregion
