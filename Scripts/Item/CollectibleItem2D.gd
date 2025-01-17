extends StaticBody3D
class_name CollectibleItem2D

@onready var spr_selected:Sprite3D = $Selected

@export var item: InventoryItem:
	set(new_value):
		item = new_value
		$Sprite3D.texture = item.icon
		$Sprite3D.texture_changed
	get:
		return item

@export var stackSize: int = 1

func _ready():
	pass

func setSelected(status:bool):
	spr_selected.setSelected(status)

func GetSelected() -> bool:
	return spr_selected.selected

func GetIcon() -> Texture2D:
	return item.icon

func CleanUpItem()	-> void:
	await get_tree().create_timer(0.1).timeout
	self.queue_free()
