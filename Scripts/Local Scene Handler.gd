extends Node3D

@export var spawn_points:Dictionary
@export var Area_Display_Name:Dictionary
@export var players:Array

@export var UnitsPath:NodePath
@export var ItemsPath:NodePath
@export var FactionsPath:NodePath

@onready var Units:Node = get_node(UnitsPath)
@onready var Items:Node = get_node(ItemsPath)
@onready var Factions:Node = get_node(FactionsPath)

func _ready():
	#Factions = $Factions
	players = Factions.get_children()

func getPlayer(factionName:String) -> Node:
	_ready()
	for player in players:
		if player.factionName == factionName:
			return player
	return null

func get_spawn_point(spawn_point_key:String="")-> Vector3:
	if spawn_points.size() == 1:
		return spawn_points[spawn_points.keys()[0]]
	else:
		return spawn_points[spawn_point_key]

func getItemsLocation() -> Node:
	return Items

func getUnitsLocation() -> Node:
	return Units
