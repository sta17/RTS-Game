extends Resource
class_name ActionSlot

@export var data: ActionData
@export var index: int

func get_item_id() -> int:
	if data == null:
		return ActionData.NONE
	else:
		return data.id
