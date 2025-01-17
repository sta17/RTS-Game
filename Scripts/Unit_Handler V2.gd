@icon("res://Assets/Mine/HumanoidIconWhite.svg")
extends CharacterBody3D
class_name UnitV2

#const module_camera:GDScript = preload("res://Scripts/module_camera.gd")
var object_data:Dictionary = {} # Any data by modules or object.
@export var unit_data:Unit_data
var currentHP:float
var currentAETHER:float

@export var player:faction
@export var personalInventory:Inv
@export var equiptmentInventory:Inv

var currentTarget: Node3D
var gotTarget:bool = false
var unitActionRange:float = 0
var defaultRange:float
var gotOrderedRotate:bool = false

var canAttack:bool = true

var currentColor:Color

#region Nodes
@onready var nav_path_timer:Timer = $"Nav Path Timer"
@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D
@onready var gravity_raycast:RayCast3D = $RayCast3D
@onready var spr_selected:Sprite3D = $selected
@onready var healthbar:ProgressBar = $SubViewport/HealthBar3D
@onready var attackTimer:Timer = $AttackTimer
@onready var graphicsBody:MeshInstance3D = $Graphic
@onready var graphicsNose:MeshInstance3D = $Graphic/MeshInstance3D
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer
#endregion

#region General Variables
var rotation_fast:bool = false
var steer_speed:float = 4.0
var nav_path_goal_position:Vector3
var stuck_max:int = 9
var stuck_count:int = 0
var last_position:Vector3

var selected:bool

const range_min_from_loc:float = -1.5
const range_max_from_loc:float = 1.5
const floating_smoothing_ground:float = 0.05
#endregion

#region General Funcs
func _ready() -> void:
	
	set_physics_process(false)
	set_process(false)
	
	set_max_slides(2)
	nav_agent.velocity_computed.connect(char_move)
	nav_path_timer.timeout.connect(nav_path_timer_update)
	setSelected(false)
	
	await(get_tree().process_frame)
	set_physics_process(true)
	set_process(true)
	
	attackTimer.timeout.connect(attackTimerCOOLDOWN)
	attackTimer.wait_time = unit_data.attack_cooldown
	defaultRange = nav_agent.target_desired_distance
	
	if unit_data:
		setCurrentHP(unit_data.hp)
		setCurrentAETHER(unit_data.aether)
		
	if player:
		changeTeamColor(player.teamcolor)
		
	#if unit_data is Hero_data:
	#	player.register_hero(self)

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

func update_selected() -> void:
	if selected: spr_selected.show()
	else: spr_selected.hide()

func HandleArrivalAtTarget(delta:float):
	if !currentTarget:
		gotTarget = false
		gotOrderedRotate = false
		nav_agent.set_path_desired_distance(defaultRange)
		return
	
	#gotTarget = false
	if gotOrderedRotate:
		gotOrderedRotate = false
	rotate_to_fast_direction(currentTarget.position,delta)
	nav_agent.set_path_desired_distance(defaultRange)
	if currentTarget is UnitV2:
		Attack()
	if currentTarget is CollectibleItem2D:
		CollectItem()
	#currentTarget = null
	#gotTarget = false

func CollectItem()	-> void:
	
	var item = currentTarget.item
	var stacksize = currentTarget.stackSize
	
	var result: bool
	if personalInventory:
		result = personalInventory.AddWithAmount(item,stacksize)
	else:
		result = false
	
	if result:
		currentTarget.CleanUpItem()
	
	cancel_navigation()

func Attack() -> void:
	if currentTarget.player == player:
		return
	if currentTarget is CharacterBody3D and !currentTarget==self:
		if currentTarget.has_method("TakeDamage") and canAttack:
			currentTarget.TakeDamage(unit_data.attack)
			attackTimer.start()
			canAttack = false

func TakeDamage(damage: float) -> void:
	animationPlayer.play("Flash")
	
	setCurrentHP(currentHP-damage)
	
	if currentHP<=0:
		handleDeath()

func changeTeamColor(newColor:Color):
	currentColor = newColor
	graphicsBody.material_override = null
	graphicsNose.material_override = null
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = newColor
	graphicsBody.material_override = newMaterial
	graphicsNose.material_override = newMaterial

func applyTeamColor():
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = currentColor
	graphicsBody.material_override = newMaterial
	graphicsNose.material_override = newMaterial

func attackTimerCOOLDOWN():
	canAttack = true
	attackTimer.stop()
	
func handleDeath():
	self.queue_free()

func selectEnemy():
	# ff00004b
	spr_selected.modulate = Color(255,0,0)
	
func selectPlayer():
	# 00ff004b
	spr_selected.modulate = Color(0,255,0)

func selectNeutral():
	# ffff004b
	spr_selected.modulate = Color(255,255,0)

func selectEnemyFlash():
	# ff00004b
	spr_selected.modulate = Color(255,0,0)
	animationPlayer.play("Selection Flash Enemy")
	
func selectPlayerFlash():
	# 00ff004b
	spr_selected.modulate = Color(0,255,0)
	animationPlayer.play("Selection Flash Player")

func selectNeutralFlash():
	# ffff004b
	spr_selected.modulate = Color(255,255,0)
	animationPlayer.play("Selection Flash Neutral")

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
	gotTarget = false
	gotOrderedRotate = false

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
	gotTarget = true
	gotOrderedRotate = true
	
func move_to_unit(newTarget:Node3D) -> void:
	currentTarget = newTarget
	gotTarget = true
	gotOrderedRotate = true
	
	var new_movement_goal:Vector3 = newTarget.position
	stuck_count = 0
	
	new_movement_goal += Vector3(randf_range(range_min_from_loc,range_max_from_loc),0,randf_range(range_min_from_loc,range_max_from_loc))
	
	unitActionRange = unit_data.attack_range
	nav_agent.set_path_desired_distance(defaultRange + unitActionRange)
	
	nav_path_goal_position = new_movement_goal
	nav_path_timer.emit_signal("timeout")
	nav_agent.set_target_position(nav_path_goal_position)
#endregion

#region Get Unit Info
func setSelected(status:bool):
	selected = status
	update_selected()
	
func GetSelected() -> bool:
	return selected

func setCurrentHP(health: float) -> void:
	currentHP = health
	healthbar.value = currentHP
	if unit_data and currentHP == unit_data.hp:
		healthbar.visible = false
	else:
		healthbar.visible = true

func setCurrentAETHER(AETHER: float) -> void:
	currentAETHER = AETHER
	#AETHERbar.value = currentAETHER
	#if unit_data and currentAETHER == unit_data.aether:
	#	AETHERbar.visible = false
	#else:
	#	AETHERbar.visible = true

func GetIcon() -> Texture2D:
	return unit_data.unit_icon
	
func GetName() -> String:
	return unit_data.name
	
func GetMaxHPAmount() -> float:
	return unit_data.hp

func GetCurrentHPAmount() -> float:
	return currentHP

func GetMaxAETHERAmount() -> float:
	return unit_data.aether

func GetCurrentAETHERAmount() -> float:
	return currentAETHER

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
