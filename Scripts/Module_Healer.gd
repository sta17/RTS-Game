extends RefCounted

const ATTRIBUTES = preload("res://Scripts/ATTRIBUTES/Module_Attributes.gd")

func heal(unit:Object,amount:float) -> void:
	unit.object_data[ ATTRIBUTES.HP ] += amount

