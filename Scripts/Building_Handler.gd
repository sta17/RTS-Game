@icon("res://Assets/Mine/HumanoidIconWhite.svg")
extends StaticBody3D
class_name Building

#const module_camera:GDScript = preload("res://Scripts/module_camera.gd")
var object_data:Dictionary = {} # Any data by modules or object.
@export var building_data:Unit_data
var currentHP:float
var currentAETHER:float

@export var player:faction
@export var personalInventory:Inv

var currentTarget: Node3D
var gotTarget:bool = false
var unitActionRange:float = 0
var defaultRange:float

var canAttack:bool = true

var currentColor:Color

#region Nodes
@onready var gravity_raycast:RayCast3D = $RayCast3D
@onready var spr_selected:Sprite3D = $selected
@onready var healthbar:ProgressBar = $Sprite3D/SubViewport/HealthBar3D
@onready var graphicsBody:MeshInstance3D = $MeshInstance3D
@onready var graphicsRoof:MeshInstance3D = $MeshInstance3D/MeshInstance3D
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer
@onready var attackTimer:Timer = $AttackTimer
#endregion

#region General Variables
var selected:bool = false:
	set(new_value):
		selected = new_value
		spr_selected.selected = selected
#endregion

#region General Funcs
func _ready() -> void:
	
	set_physics_process(false)
	set_process(false)
	
	selected = false
	
	await(get_tree().process_frame)
	set_physics_process(true)
	set_process(true)
	
	attackTimer.timeout.connect(attackTimerCOOLDOWN)
	attackTimer.wait_time = building_data.attack_cooldown
	
	if building_data:
		setCurrentHP(building_data.hp)
		setCurrentAETHER(building_data.aether)
		
	if player:
		changeTeamColor(player.teamcolor)

func HandleArrivalAtTarget(delta:float):
	if !currentTarget:
		gotTarget = false
		return
	
	if currentTarget is UnitV4:
		Attack()
	if currentTarget is Building:
		Attack()
	if currentTarget is CollectibleItem2D:
		CollectItem()

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

func Attack() -> void:
	if currentTarget.player == player:
		return
	if currentTarget is CharacterBody3D and !currentTarget==self:
		if currentTarget.has_method("TakeDamage") and canAttack:
			currentTarget.TakeDamage(building_data.attack)
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
	graphicsRoof.material_override = null
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = newColor
	graphicsBody.material_override = newMaterial
	graphicsRoof.material_override = newMaterial

func applyTeamColor():
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = currentColor
	graphicsBody.material_override = newMaterial
	graphicsRoof.material_override = newMaterial

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

#region Get Unit Info
func setCurrentHP(health: float) -> void:
	currentHP = health
	healthbar.value = currentHP
	if building_data and currentHP == building_data.hp:
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
	return building_data.unit_icon
	
func GetName() -> String:
	return building_data.name
	
func GetMaxHPAmount() -> float:
	return building_data.hp

func GetCurrentHPAmount() -> float:
	return currentHP

func GetMaxAETHERAmount() -> float:
	return building_data.aether

func GetCurrentAETHERAmount() -> float:
	return currentAETHER

func GetArmorAmount() -> float:
	return building_data.defense
	
func GetDamageAmount() -> float:
	return building_data.attack

func GetBodyAmount() -> float:
	return building_data.body_start
	
func GetFinesseAmount() -> float:
	return building_data.finesse_start
	
func GetMindAmount() -> float:
	return building_data.mind_start
#endregion
