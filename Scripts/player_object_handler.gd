@icon("res://Assets/Mine/HumanoidIconWhite.svg")
extends Node
class_name Player_Object

@export var target_provider:Node
@export var object_data:Unit_data

@export var player:faction
@export var personalInventory:Inv
@export var equiptmentInventory:Inv

var currentTarget: Node3D
var gotTarget:bool = false

var currentColor:Color

var currentAETHER:float

#region Nodes
@export var attack_NODE_PATH:NodePath
@export var healthbar_NODE_PATH:NodePath
@export var selected_NODE_PATH:NodePath
@export var animationPlayer_NODE_PATH:NodePath

@onready var spr_selected:Sprite3D = get_node(selected_NODE_PATH)
@onready var healthbar:Sprite3D = get_node(healthbar_NODE_PATH)
@onready var animationPlayer:AnimationPlayer = get_node(animationPlayer_NODE_PATH)
@onready var attackTimer:Timer = get_node(attack_NODE_PATH)

const attack_SCRIPT = preload("res://Scripts/Attack.gd")
const healthbar_SCRIPT = preload("res://Scripts/HealthBar.gd")
const selected_SCRIPT = preload("res://Scripts/Selected.gd")
#endregion

func _ready():
	spr_selected = $"../Selected"
	healthbar = $"../Healthbar"
	animationPlayer = $"../AnimationPlayer"
	attackTimer = $"../AttackTimer"

func _on_ready():
	await target_provider.ready
	setup()

func setup():
	if object_data:
		attackTimer.setAttackCOOLDOWN(object_data.attack_cooldown)
		attackTimer.setAttackDamage(object_data.attack)
		
		healthbar.setup(object_data.hp)
		setCurrentAETHER(object_data.aether)
		
	if object_data is Hero_data:
		player.register_hero(target_provider)
	#if target_provider is BuildingV2:
	#	spr_selected.setThin()

func setupScripts():
	attackTimer.set_script(attack_SCRIPT)
	healthbar.set_script(healthbar_SCRIPT)
	spr_selected.set_script(selected_SCRIPT)
	
#region Map Iteractions
func selectEnemyFlash():
	# ff00004b
	spr_selected.modulate = Color(255,0,0)
	#animationPlayer.play("Selection Flash Enemy")
	
func selectPlayerFlash():
	# 00ff004b
	spr_selected.modulate = Color(0,255,0)
	#animationPlayer.play("Selection Flash Player")

func selected(status:bool):
	spr_selected.setSelected(status)

func GetSelected() -> bool:
	return spr_selected.selected

func setcurrentTarget(newtarget: Node3D):
	currentTarget = newtarget
	attackTimer.setcurrentTarget(currentTarget)

func InteractWithTarget():
	if !currentTarget:
		gotTarget = false
		return
	
	if currentTarget is UnitV4:
		Attack()
	if currentTarget is BuildingV2:
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
		target_provider.CollectedItem()
	
func Attack() -> void:
	if currentTarget.player == player:
		return
	var result = attackTimer.Attack()
	if result:
		target_provider.CancelTargetting()
	
func TakeDamage(damage: float) -> bool:
	animationPlayer.play("Flash")
	
	healthbar.takeDamage(damage)
	
	if healthbar.isDead():
		handleDeath()
		return true
	return false

func handleDeath():
	#self.queue_free()
	target_provider.handleDeath()
#endregion

#region Get/Set Unit Info
func setCurrentHP(health: float) -> void:
	healthbar.setCurrentHP(health)

func getObject_Data() -> Unit_data:
	return object_data
	
func setCurrentAETHER(AETHER: float) -> void:
	currentAETHER = AETHER
	
func GetCurrentHPAmount() -> float:
	return healthbar.GetCurrentHPAmount()

func GetMaxAETHERAmount() -> float:
	return object_data.aether
	
func GetCurrentAETHERAmount() -> float:
	return currentAETHER
	
func GetIcon() -> Texture2D:
	return object_data.unit_icon

func GetName() -> String:
	return object_data.name
	
func GetMaxHPAmount() -> float:
	return object_data.hp

func GetArmorAmount() -> float:
	return object_data.defense
	
func GetDamageAmount() -> float:
	return object_data.attack

func GetBodyAmount() -> float:
	return object_data.body_start
	
func GetFinesseAmount() -> float:
	return object_data.finesse_start
	
func GetMindAmount() -> float:
	return object_data.mind_start
#endregion
