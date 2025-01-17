@icon("res://Assets/Mine/Flag 16x16.svg")
extends Node
class_name faction

enum factionTypes
{
	Human,
	AI,
	NPC
}

@export var symbol:Texture2D
@export var factionName:String
@export var factionType:factionTypes

@export var teamcolor:Color

@export var ui:player_interface

var heros: Array = []

func register_hero(unit: UnitV4):
	if unit.player_object.object_data is Hero_data:
		heros.append(unit)
		if ui:
			ui.hero_display_add(unit)
