@icon("res://Assets/Mine/Cog Node3D.svg")
extends Node3D

@export var teamcolor: Color

func _ready():
	$"Start Circle".visible = false
