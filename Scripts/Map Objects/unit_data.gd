@icon("res://Assets/Mine/HumanoidIconWhite.svg")
extends Resource
class_name Unit_data

@export var unit_icon:Texture2D
@export var name:String

@export var hp:float
@export var hp_regen:float
@export var aether:float
@export var aether_regen:float
@export var attack:float

@export var attack_cooldown:float
@export var attack_range:float
@export var defense:float
@export var speed:float

@export var color:Color

@export var tooltip:String

#Spells and Actions
@export var actions : Array[ActionData]

# Unit Tag (Use Bit Flags)
@export var unitTags : Array[ItemCategory]

func contains_category(tag : ItemCategory) -> bool:
	for c in unitTags:
		if c == tag:
			return true
	return false
