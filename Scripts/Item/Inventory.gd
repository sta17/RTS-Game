@icon("res://Assets/Inventory Addin/node_inventory_system_base.svg")
extends Resource
class_name Inv

signal update

@export var slots: Array[InvSlot]

func _ready():
	var i: int = 0
	for slot in slots:
		slot.index = i
		i = i + 1

func Add(Item: InventoryItem):
	AddWithAmount(Item,1)

func AddWithAmount(Item: InventoryItem,amount:int) -> bool:
	var itemslots = slots.filter(func(slot): return slot.Item == Item)
	if !itemslots.is_empty():
		itemslots[0].amount += amount
		update.emit()
		return true
	else:
		var emptyslots = slots.filter(func(slot): return slot.Item == null)
		if !emptyslots.is_empty():
			emptyslots[0].Item = Item
			emptyslots[0].amount = amount
			update.emit()
			return true
	return false

func Add_Slot_at_Index(slot: InvSlot, slotnumber: int) -> bool:
	if slots[slotnumber].Item == slot.Item:
		slots[slotnumber].amount += slot.amount
		update.emit()
		return true
	else:
		if slots[slotnumber].Item == null:
			slots[slotnumber].Item = slot.Item
			slots[slotnumber].amount = slot.amount
			update.emit()
			return true
	return false
	
func Check_Addable_at_Index(slot: InvSlot, slotnumber: int) -> bool:
	if slots[slotnumber].Item == slot.Item:
		return true
	elif slots[slotnumber].Item == null:
		return true
	return false

func Remove_at_Index(slotnumber: int) -> bool:
	slots[slotnumber].Item = null
	slots[slotnumber].amount = 0
	update.emit()
	return true
