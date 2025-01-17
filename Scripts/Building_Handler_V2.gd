@icon("res://Assets/Mine/HumanoidIconWhite.svg")
extends StaticBody3D
class_name BuildingV2

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

var currentTarget: Node3D
var gotTarget:bool = false

#region Temp
func _ready():
	ConnectLowerNode()
	setup()

func ConnectLowerNode():
	player_object = $Node
	player_object.target_provider = self
	
func setup():
	player_object.setupScripts()
	player_object.setup()

func GetIcon() -> Texture2D:
	return object_data.unit_icon
	
func setSelected(status:bool):
	player_object.selected(status)
	
func GetSelected() -> bool:
	return player_object.GetSelected()
	
func CollectedItem():
	currentTarget = null
	player_object.setcurrentTarget(currentTarget)
	gotTarget = false
	
func handleDeath():
	self.queue_free()
#endregion
