extends Area3D

#region Variables
@onready var colliderShape:CollisionShape3D = $CollisionShape3D
@onready var units_array:Array = []
# { unit_id : unit_node }
@onready var units_dictionary:Dictionary = {}
#endregion

#region Set Detection Form
func setSphereRadius(radius:float):
	var shape:SphereShape3D
	shape = SphereShape3D.new()
	#shape = colliderShape.shape
	shape.radius = radius
	colliderShape.shape = shape
	EmptyLists()

func setCyllinderRadius(radius:float):
	var shape:CylinderShape3D
	shape = CylinderShape3D.new()
	#shape = colliderShape.shape
	shape.radius = radius
	shape.height = 1000
	colliderShape.shape = shape
	EmptyLists()
	
func setBoxValues(x:float,y:float,z:float):
	var shape:BoxShape3D
	shape = BoxShape3D.new()
	#shape = colliderShape.shape
	shape.size = Vector3(x,y,z)
	colliderShape.shape = shape
	EmptyLists()
#endregion

#region List Handling
func getTargetsArray() -> Array:
	return units_array

func getTargetsDictionary() -> Dictionary:
	return units_dictionary

func EmptyLists() -> void:
	units_array = []
	units_dictionary = {}

func refreshArray() -> void:
	units_array.clear()
	for unit in units_dictionary.values():
		if validTarget(unit):
			units_array.append(unit)
#endregion

#region Target Validation
func validTarget(target:Node3D)->bool:
	if !target: return false
	if target is UnitV4:
		return true
	if target is BuildingV2:
		return true
	if target is CollectibleItem2D:
		return true
	return false
#endregion

#region Add and Remove
func Add(unit):
	var unit_id:int = unit.get_instance_id()
	if units_dictionary.keys().has(unit_id):return
	if validTarget(unit):
		units_dictionary[unit_id] = unit.get_parent()
		units_array.append(unit)

func Remove(unit):
	var unit_id:int = unit.get_instance_id()
	if !units_dictionary.keys().has(unit_id):return
	units_dictionary.erase(unit_id)
	units_array.erase(unit)

func _on_body_entered(body: Node3D):
	Add(body)

func _on_body_exited(body: Node3D):
	Remove(body)
#endregion
